#!/usr/bin/env python3
"""
Hytale Server Launcher
MIT License - NodeByte Hosting

Execution flow (4 phases):
1. Prepare filesystem and runtime defaults
2. Resolve update plan (local → backups → API)
3. Acquire auth tokens if enabled (OAuth2)
4. Parse and execute startup command with signal forwarding
"""

import os
import sys
import json
import signal
import subprocess
import time
import zipfile
import hashlib
import shutil
import re
from pathlib import Path
from contextlib import suppress
from dataclasses import dataclass, asdict
from datetime import datetime
from enum import Enum
from urllib.parse import urljoin

try:
    import requests
    from requests.adapters import HTTPAdapter
    from urllib3.util.retry import Retry
except ImportError:
    requests = None

# Color codes for logging
COLORS = {
    'R': '\033[91m',  # Red
    'G': '\033[92m',  # Green
    'Y': '\033[93m',  # Yellow
    'B': '\033[94m',  # Blue
    'C': '\033[96m',  # Cyan
    'N': '\033[0m',   # None
}

def log(color, msg):
    """Log with color."""
    print(f"{COLORS[color]}{msg}{COLORS['N']}", flush=True)

def die(msg):
    """Log error and exit."""
    log('R', msg)
    sys.exit(1)

# Environment and path configuration
ROOT_DIR = Path(os.getenv("ROOT_DIR", "/home/container"))
SERVER_DIR = ROOT_DIR / "Server"
SERVER_JAR = SERVER_DIR / "HytaleServer.jar"
TMP_BASE = ROOT_DIR / ".tmp"
BACKUP_BASE = ROOT_DIR / ".server-backups"

# Server configuration
SERVER_VERSION = os.getenv("SERVER_VERSION", "latest")
AUTO_UPDATE = os.getenv("AUTO_UPDATE", "1") == "1"
PATCHLINE = os.getenv("PATCHLINE", "release")
TRANSPORT = os.getenv("TRANSPORT", "QUIC").upper()

# Feature flags
FLAGS = {
    'auth': os.getenv("HYTALE_API_AUTH", "0") == "1",
    'aot': os.getenv("USE_AOT_CACHE", "1") == "1",
    'world_backup': os.getenv("WORLD_BACKUP", "0") == "1",
    'early_plugins': os.getenv("EARLY_PLUGINS", "0") == "1",
    'compact_headers': os.getenv("COMPACT_HEADERS", "1") == "1",
    'allow_op': os.getenv("ALLOW_OP", "0") == "1",
    'disable_sentry': os.getenv("DISABLE_SENTRY", "0") == "1",
    'ignore_broken_mods': os.getenv("IGNORE_BROKEN_MODS", "0") == "1",
}

# File names and retention
VERSION_FILE = "version"
PATCHLINE_FILE = "patchline"
BACKUP_SERVER_FILES = ["HytaleServer.jar", "config.json", "bans.json", "whitelist.json", "permissions.json"]
BACKUP_ROOT_FILES = ["Assets.zip"]
USER_CONFIG_FILES = ["config.json", "bans.json", "whitelist.json", "permissions.json"]
SERVER_BACKUP_RETENTION = int(os.getenv("SERVER_BACKUP_RETENTION", "2"))

# API endpoints
HYTALE_ASSETS_API = "https://account-data.hytale.com/game-assets"
MAVEN_BASE_URL = "https://maven.hytale.com"

# Global state
auth_state = None
server_process = None
shutting_down = False

class UpdatePlan(Enum):
    """Update strategy options."""
    NONE = "none"
    PATCHLINE = "patchline"
    BACKUP = "backup"
    API = "api"

@dataclass
class AuthState:
    """OAuth2 authentication state."""
    access_token: str = ""
    refresh_token: str = ""
    access_expires: int = 0
    refresh_expires: int = 0
    session_token: str = ""
    identity_token: str = ""
    session_expires: int = 0
    profile_uuid: str = ""
    profile_name: str = ""
    
    def save(self, path):
        """Save state to file with restricted permissions."""
        temp = path.with_suffix('.tmp')
        temp.write_text(json.dumps(asdict(self), indent=2))
        temp.chmod(0o600)
        temp.rename(path)
    
    @classmethod
    def load(cls, path):
        """Load state from file."""
        if not path.exists():
            return None
        try:
            path.chmod(0o600)
            data = json.loads(path.read_text())
            expected = set(cls.__dataclass_fields__)
            return cls(**{k: v for k, v in data.items() if k in expected})
        except Exception:
            return None

def parse_jar_version(jar_path):
    """Extract version from JAR manifest."""
    if not jar_path.exists():
        return None, None
    try:
        with zipfile.ZipFile(jar_path) as zf:
            manifest = zf.read("META-INF/MANIFEST.MF").decode('utf-8')
            version = patchline = None
            for line in manifest.split('\n'):
                lower = line.lower()
                if lower.startswith('implementation-version:'):
                    version = line.split(':', 1)[1].strip()
                elif lower.startswith('implementation-patchline:'):
                    patchline = line.split(':', 1)[1].strip()
            return version, patchline
    except Exception:
        return None, None

def backup_current_version(server_dir, backup_base, patchline, retention):
    """Backup current server version."""
    version_file = server_dir / VERSION_FILE
    if not (version_file.exists() and (server_dir / "HytaleServer.jar").exists()):
        log('C', "[backup] Skipped (no existing server files)")
        return
    
    version = version_file.read_text().strip()
    if not re.match(r'^\d{4}\.\d{2}\.\d{2}-[a-f0-9]+$', version):
        log('C', "[backup] Skipped (invalid version)")
        return
    
    backup_dir = backup_base / patchline / version
    backup_dir.mkdir(parents=True, exist_ok=True)
    server_backup_dir = backup_dir / "Server"
    server_backup_dir.mkdir(exist_ok=True)
    
    # Backup server files
    for f in BACKUP_SERVER_FILES:
        if (src := server_dir / f).exists():
            shutil.copy2(src, server_backup_dir / f)
    
    # Backup root files
    for f in BACKUP_ROOT_FILES:
        if (src := ROOT_DIR / f).exists():
            shutil.copy2(src, backup_dir / f)
    
    # Cleanup old backups
    patchline_dir = backup_base / patchline
    if patchline_dir.exists():
        backups = sorted([d for d in patchline_dir.iterdir() if d.is_dir() and d != backup_dir])
        old_backups = backups[:-retention] if retention > 0 else backups
        for old in old_backups:
            shutil.rmtree(old, ignore_errors=True)
    
    log('G', f"[backup] ✓ .server-backups/{patchline}/{version}/ (retention: {retention})")

def restore_from_backup(backup_dir, server_dir):
    """Restore server from backup."""
    backup_server_dir = backup_dir / "Server"
    if not (backup_server_dir / "HytaleServer.jar").exists():
        log('Y', f"[backup] Restore failed: HytaleServer.jar not found")
        return False
    
    log('C', f"[backup] Restoring from {backup_dir.name}")
    (server_dir / "HytaleServer.aot").unlink(missing_ok=True)
    
    for f in BACKUP_SERVER_FILES:
        if (src := backup_server_dir / f).exists():
            shutil.copy2(src, server_dir / f)
    
    for f in BACKUP_ROOT_FILES:
        if (src := backup_dir / f).exists():
            shutil.copy2(src, ROOT_DIR / f)
        else:
            log('Y', f"[backup] Warning: {f} missing from backup")
    
    return True

def install_from_extract(extract_dir, server_dir):
    """Install server files from extracted download."""
    src_server = extract_dir / "Server"
    if not src_server.exists() or not (src_server / "HytaleServer.jar").exists():
        return False
    
    (server_dir / "HytaleServer.aot").unlink(missing_ok=True)
    
    for item in src_server.iterdir():
        if item.name in USER_CONFIG_FILES and (server_dir / item.name).exists():
            continue
        if item.name.endswith('.aot'):
            continue
        
        dest = server_dir / item.name
        if item.is_dir():
            shutil.rmtree(dest, ignore_errors=True)
            shutil.copytree(item, dest)
        else:
            shutil.copy2(item, dest)
    
    if (assets := extract_dir / "Assets.zip").exists():
        shutil.copy2(assets, ROOT_DIR / "Assets.zip")
    
    return True

def get_maven_latest(patchline):
    """Get latest version from Maven."""
    if not requests:
        return None
    
    try:
        resp = requests.get(f"{MAVEN_BASE_URL}/{patchline}/com/hypixel/hytale/Server/maven-metadata.xml", timeout=30)
        if resp.status_code == 200:
            if versions := re.findall(r'<version>\s*([^<]+)', resp.text):
                return versions[-1].strip()
    except Exception as e:
        log('Y', f"[maven] Failed to fetch metadata: {e}")
    
    return None

def is_valid_backup(backup_path):
    """Check if backup is valid."""
    return backup_path.exists() and (backup_path / "Server" / "HytaleServer.jar").exists()

def plan_update(server_version, patchline, local_version, local_patchline):
    """Determine update strategy."""
    backup_dir = BACKUP_BASE / patchline
    has_jar = SERVER_JAR.exists()
    
    if server_version == "latest":
        if not AUTO_UPDATE and has_jar:
            return UpdatePlan.NONE, "", None
        
        if maven_latest := get_maven_latest(patchline):
            if local_version == maven_latest and (local_patchline == patchline or not local_patchline):
                return UpdatePlan.NONE, "", None
            
            if local_version == maven_latest and local_patchline != patchline:
                return UpdatePlan.PATCHLINE, maven_latest, None
            
            backup_path = backup_dir / maven_latest
            if is_valid_backup(backup_path):
                return UpdatePlan.BACKUP, maven_latest, backup_path
            
            return UpdatePlan.API, maven_latest, None
        
        if not has_jar:
            return UpdatePlan.API, "", None
        
        log('Y', "[update] Maven check failed, running existing server")
        return UpdatePlan.NONE, "", None
    
    else:
        if local_version == server_version and has_jar:
            return UpdatePlan.NONE, "", None
        
        backup_path = backup_dir / server_version
        if is_valid_backup(backup_path):
            return UpdatePlan.BACKUP, server_version, backup_path
        
        if has_jar:
            log('Y', f"[update] Version {server_version} not found, running existing server")
            return UpdatePlan.NONE, "", None
        
        die(f"Version {server_version} not available")

def migrate_legacy_layout():
    """Migrate from legacy directory layout."""
    if not (root_jar := ROOT_DIR / "HytaleServer.jar").exists():
        return
    
    if SERVER_JAR.exists():
        root_jar.unlink()
    else:
        shutil.move(str(root_jar), str(SERVER_JAR))
    
    (ROOT_DIR / "HytaleServer.aot").unlink(missing_ok=True)
    
    for file in [VERSION_FILE, PATCHLINE_FILE]:
        if (src := ROOT_DIR / file).exists():
            shutil.move(str(src), str(SERVER_DIR / file))
    
    for dir_name in ["Licenses", "logs", "universe", "earlyplugins", "builtin", "worlds", "mods"]:
        src_dir = ROOT_DIR / dir_name
        if not src_dir.is_dir():
            continue
        
        dest_dir = SERVER_DIR / dir_name
        if dest_dir.exists():
            try:
                shutil.copytree(src_dir, dest_dir, dirs_exist_ok=True, copy_function=shutil.move)
                shutil.rmtree(src_dir, ignore_errors=True)
            except Exception as e:
                log('Y', f"[migrate] Failed to merge {dir_name}: {e}")
        else:
            shutil.move(str(src_dir), str(dest_dir))

def handle_signal(signum, frame):
    """Handle shutdown signals."""
    global shutting_down, server_process
    if not shutting_down and server_process:
        shutting_down = True
        try:
            os.killpg(os.getpgid(server_process.pid), signum)
        except Exception as e:
            log('Y', f"[signal] Failed to kill process group: {e}")
            server_process.send_signal(signum)

def main():
    """Main execution."""
    global auth_state, server_process
    
    os.umask(0o077)
    os.environ.setdefault('TZ', 'UTC')
    start_time = time.time()
    
    os.chdir(ROOT_DIR)
    TMP_BASE.mkdir(exist_ok=True)
    SERVER_DIR.mkdir(exist_ok=True)
    
    # Migrate legacy layout
    migrate_legacy_layout()
    
    # Load version info
    version_file = SERVER_DIR / VERSION_FILE
    patchline_file = SERVER_DIR / PATCHLINE_FILE
    local_version = version_file.read_text().strip() if version_file.exists() else ""
    local_patchline = patchline_file.read_text().strip() if patchline_file.exists() else ""
    
    if SERVER_JAR.exists() and (not local_version or not local_patchline):
        v, p = parse_jar_version(SERVER_JAR)
        if v:
            local_version = v
            version_file.write_text(v)
        if p:
            local_patchline = p
            patchline_file.write_text(p)
    
    log('C', f"Current version : {local_version or 'none'} ({local_patchline or 'unknown'})")
    log('C', f"Active patchline: {PATCHLINE}")
    log('C', f"Requested build : {SERVER_VERSION}")
    
    # Plan update
    plan, target, backup_path = plan_update(SERVER_VERSION, PATCHLINE, local_version, local_patchline)
    
    if plan != UpdatePlan.NONE:
        log('C', f"[update] Plan: {plan.value}" + (f" (target {target})" if target else ""))
    
    # Execute plan
    if plan == UpdatePlan.PATCHLINE:
        backup_current_version(SERVER_DIR, BACKUP_BASE, local_patchline, SERVER_BACKUP_RETENTION)
        patchline_file.write_text(PATCHLINE)
        log('G', "[update] ✓ Patchline updated")
    
    elif plan == UpdatePlan.BACKUP:
        log('B', f"[backup] Restoring {target or 'version'} from backup")
        backup_current_version(SERVER_DIR, BACKUP_BASE, local_patchline, SERVER_BACKUP_RETENTION)
        if restore_from_backup(backup_path, SERVER_DIR):
            v, p = parse_jar_version(SERVER_JAR)
            if v:
                version_file.write_text(v)
            if p:
                patchline_file.write_text(p)
            log('G', "[backup] ✓ Restored")
        elif not SERVER_JAR.exists():
            die("[backup] Restore failed and no server files exist")
        else:
            log('Y', "[backup] Restore failed, running existing server")
    
    elif plan == UpdatePlan.API:
        if requests:
            log('C', "[api] Update plan requires manual server files or API support")
        else:
            log('Y', "[api] python3-requests not available, skipping update")
        if not SERVER_JAR.exists():
            die("[update] No server files available")
    
    if not SERVER_JAR.exists():
        die("[startup] HytaleServer.jar not found. Ensure server binaries are mounted or provided.")
    
    # Build JVM flags
    jvm_flags = [
        "-Djava.io.tmpdir=/home/container/.tmp",
        "-Dterminal.jline=false",
        "-Dterminal.ansi=true",
    ]
    
    aot_file = SERVER_DIR / "HytaleServer.aot"
    
    if FLAGS['aot']:
        jvm_flags.append("-Xlog:aot")
        if FLAGS['compact_headers']:
            jvm_flags.append("-XX:+UseCompactObjectHeaders")
        
        if not aot_file.exists():
            jvm_flags.append(f"-XX:AOTCacheOutput={aot_file}")
            compact_status = "with" if FLAGS['compact_headers'] else "without"
            log('C', f"[aot] Creating AOT cache {compact_status} CompactObjectHeaders (first run will be slower)")
        else:
            jvm_flags.append(f"-XX:AOTCache={aot_file}")
            log('C', "[aot] Using AOT cache")
    
    elif FLAGS['compact_headers']:
        jvm_flags.append("-XX:+UseCompactObjectHeaders")
    
    # Build server flags
    server_flags = ["--transport", TRANSPORT]
    if FLAGS['allow_op']:
        server_flags.append("--allow-op")
    if FLAGS['early_plugins']:
        server_flags.append("--accept-early-plugins")
    if FLAGS['disable_sentry']:
        server_flags.append("--disable-sentry")
    if FLAGS['ignore_broken_mods']:
        server_flags.append("--ignore-broken-mods")
    
    # Parse startup command
    startup = os.getenv("STARTUP", "")
    if not startup.strip():
        die("[startup] STARTUP variable required")
    
    # Variable substitution
    startup = re.sub(r'\{\{([A-Za-z_][A-Za-z0-9_]*)\}\}', lambda m: os.getenv(m.group(1), ""), startup)
    startup = re.sub(r'\$\{([A-Za-z_][A-Za-z0-9_]*)\}', lambda m: os.getenv(m.group(1), ""), startup)
    
    # Parse command
    import shlex
    cmd = shlex.split(startup)
    
    # Inject JVM flags if this is a Java command
    if cmd and any("java" in str(arg).lower() for arg in cmd[:3]) and "-jar" in cmd:
        jar_idx = cmd.index("-jar") + 1
        pre_jar = cmd[:jar_idx-1]
        post_jar = cmd[jar_idx+1:]
        cmd = pre_jar + jvm_flags + ["-jar", cmd[jar_idx]] + server_flags + post_jar
    
    os.chdir(SERVER_DIR)
    
    # Final startup info
    final_version = version_file.read_text().strip() if version_file.exists() else "unknown"
    final_patchline = patchline_file.read_text().strip() if patchline_file.exists() else "unknown"
    
    log('G', f"[startup] Launching: {final_version} ({final_patchline})")
    log('G', f"[startup] ✓ Ready in {int(time.time() - start_time)}s")
    log('C', f"[startup] Command: {' '.join(cmd)}")
    
    # Setup signal handlers
    for sig in (signal.SIGTERM, signal.SIGINT, signal.SIGHUP, signal.SIGQUIT):
        signal.signal(sig, handle_signal)
    
    # Start server
    try:
        server_process = subprocess.Popen(cmd, preexec_fn=os.setsid)
        sys.exit(server_process.wait())
    finally:
        pass

if __name__ == "__main__":
    main()

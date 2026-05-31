#!/usr/bin/env node
//
// Rust Server Wrapper - Maintained by NodeByte LTD
// Passes command-line arguments to the Rust server
// Filters duplicate prefab loading messages
//

const { spawn } = require('child_process');

const args = process.argv.slice(2);

if (args.length < 1) {
  console.error('ERROR: No startup command specified');
  process.exit(1);
}

const startupCmd = args[0];
const cmdArgs = args.slice(1);
const seenPrefabs = new Set();

function filterOutput(data) {
  const lines = data.toString().split('\n');
  lines.forEach(line => {
    // Filter duplicate prefab loading messages
    if (line.startsWith('Loading Prefab Bundle ')) {
      if (seenPrefabs.has(line)) return;
      seenPrefabs.add(line);
    }
    if (line.length > 0) {
      console.log(line);
    }
  });
}

console.log('Starting Rust server...');

const proc = spawn(startupCmd, cmdArgs, {
  cwd: '/home/container',
  stdio: ['pipe', 'pipe', 'pipe']
});

proc.stdout.on('data', filterOutput);
proc.stderr.on('data', filterOutput);

proc.on('exit', (code) => {
  if (code !== 0) {
    console.error(`Server process exited with code ${code}`);
  } else {
    console.log('Server stopped');
  }
  process.exit(code || 0);
});

process.on('SIGTERM', () => {
  proc.kill('SIGTERM');
});

process.on('SIGINT', () => {
  proc.kill('SIGINT');
});
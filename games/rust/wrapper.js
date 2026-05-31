#!/usr/bin/env node
//
// Rust Server Wrapper - Based on Pterodactyl Yolks
// Improved by NodeByte LTD
// Handles Rust server startup, output filtering, and console input
//

const fs = require('fs');
const exec = require('child_process').exec;

const startupCmd = process.argv.splice(process.execArgv.length + 2);

let command = '';
for (let i = 0; i < startupCmd.length; i++) {
  if (i === startupCmd.length - 1) {
    command += startupCmd[i];
  } else {
    command += startupCmd[i] + ' ';
  }
}

if (command.length < 1) {
  console.error('ERROR: No startup command provided');
  process.exit(1);
}

// Initialize latest.log
fs.writeFile('latest.log', '', (err) => {
  if (err) console.log('ERROR initializing latest.log: ' + err);
});

const seenPercentage = {};

// Filter duplicate messages (Rust spam)
function filter(data) {
  const str = data.toString();
  
  // Filter duplicate "Loading Prefab Bundle" percentages
  if (str.startsWith('Loading Prefab Bundle ')) {
    const percentage = str.substr('Loading Prefab Bundle '.length).trim();
    if (seenPercentage[percentage]) {
      return; // Skip duplicate
    }
    seenPercentage[percentage] = true;
  }
  
  console.log(str);
}

console.log('Starting Rust server with command: ' + command);

let exited = false;
const gameProcess = exec(command);

gameProcess.stdout.on('data', filter);
gameProcess.stderr.on('data', filter);

gameProcess.on('exit', (code, signal) => {
  exited = true;
  if (code !== 0 && code !== null) {
    console.log('Server process exited with code ' + code);
  }
});

// Handle console input
function initialListener(data) {
  const input = data.toString().trim();
  if (input === 'quit') {
    gameProcess.kill('SIGTERM');
  } else {
    console.log('Console input received: ' + input);
  }
}

process.stdin.resume();
process.stdin.setEncoding('utf8');
process.stdin.on('data', initialListener);

process.on('exit', (code) => {
  if (exited) return;
  console.log('Received shutdown signal, stopping server...');
  gameProcess.kill('SIGTERM');
});

process.on('SIGINT', () => {
  console.log('Received SIGINT, stopping server...');
  gameProcess.kill('SIGINT');
});

process.on('SIGTERM', () => {
  console.log('Received SIGTERM, stopping server...');
  gameProcess.kill('SIGTERM');
});

#!/usr/bin/env bun

console.log("Hello from [script-name]!");
process.argv.slice(2).forEach(arg => console.log(`Arg: ${arg}`));
console.log("Hello via Bun!");

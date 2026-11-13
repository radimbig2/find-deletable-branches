#!/usr/bin/env node

const { spawn } = require("child_process");
const { spawnSync } = require("child_process");
const fs = require("fs");
const path = require("path");

function findGitBash() {
  const commonPaths = [
    "C:\\Program Files\\Git\\bin\\bash.exe",
    "C:\\Program Files (x86)\\Git\\bin\\bash.exe",
    path.join(process.env.ProgramFiles || "", "Git\\bin\\bash.exe"),
  ];

  for (const candidate of commonPaths) {
    if (candidate && fs.existsSync(candidate)) {
      return candidate;
    }
  }

  const where = spawnSync("where.exe", ["git.exe"], { encoding: "utf8" });
  if (where.status === 0) {
    const gitPath = where.stdout.split(/\r?\n/).find(Boolean);
    if (gitPath) {
      const gitDir = path.dirname(gitPath);
      const candidates = [
        path.join(gitDir, "bash.exe"),
        path.resolve(gitDir, "..", "bin", "bash.exe"),
      ];

      for (const candidate of candidates) {
        if (fs.existsSync(candidate)) {
          return candidate;
        }
      }
    }
  }

  return null;
}

const script = path.join(__dirname, "git-merged");
const command = process.platform === "win32" ? findGitBash() : script;
const args = process.platform === "win32"
  ? [script, ...process.argv.slice(2)]
  : process.argv.slice(2);

if (!command) {
  console.error("Error: Git Bash not found. Please install Git for Windows from https://git-scm.com/download/win");
  process.exit(1);
}

const child = spawn(command, args, {
  stdio: "inherit",
});

child.on("exit", (code, signal) => {
  if (signal) {
    process.kill(process.pid, signal);
    return;
  }

  process.exit(code ?? 1);
});

child.on("error", (error) => {
  console.error(`Failed to run git-merged: ${error.message}`);
  process.exit(1);
});

#!/bin/bash

echo "📁 Initializing QShellBridge project structure..."

# Create directories
mkdir -p qshellbridge
mkdir -p sessions
mkdir -p logs

# __init__.py
echo "# QShellBridge package initializer" > qshellbridge/__init__.py
echo '__version__ = "0.1.0"' >> qshellbridge/__init__.py

# bridge.py - only created if missing
if [ ! -f "qshellbridge/bridge.py" ]; then
cat <<EOL > qshellbridge/bridge.py
# bridge.py — tmux session control and logging

import subprocess
from datetime import datetime
from pathlib import Path
from time import sleep
from rich.live import Live
from rich.panel import Panel
import json

SESSION_DIR = Path.home() / ".qshellbridge_sessions"
SESSION_DIR.mkdir(parents=True, exist_ok=True)

class QShellBridge:
    def __init__(self, session_name, log_directory, confirm_mode=False):
        self.session = session_name
        self.log_path = Path(log_directory) / f"qshell_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log"
        self.log_path.parent.mkdir(parents=True, exist_ok=True)
        self.log_path.touch()
        self.confirm_mode = confirm_mode

    def send_command(self, cmd):
        subprocess.run(["tmux", "send-keys", "-t", self.session, cmd, "C-m"])

    def send_command_with_confirmation(self, cmd):
        if self.confirm_mode:
            confirm = input(f"Send command '\${cmd}'? [y/N]: ").strip().lower()
            if confirm != "y":
                print("Command cancelled.")
                return
        self.send_command(cmd)

    def send_and_log(self, cmd):
        timestamp = datetime.now().strftime("[%Y-%m-%d %H:%M:%S]")
        with open(self.log_path, "a", encoding="utf-8") as log_file:
            log_file.write(f"\${timestamp} > \${cmd}\\n")
        self.send_command(cmd)

    def is_session_alive(self):
        return subprocess.run(["tmux", "has-session", "-t", self.session],
                              stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode == 0

    def enable_output_mirroring(self, mirror_path):
        mirror_path = Path(mirror_path)
        mirror_path.parent.mkdir(parents=True, exist_ok=True)
        subprocess.run(["tmux", "pipe-pane", "-t", self.session, "-o", f"cat >> \${mirror_path}"])
        print(f"[+] Output mirroring enabled to: \${mirror_path}")

    def tail_log_live(self, interval=1.0, lines=10):
        if not self.log_path.exists():
            print("[-] Log file does not exist.")
            return
        with Live(refresh_per_second=4) as live:
            while True:
                try:
                    with open(self.log_path, "r", encoding="utf-8") as f:
                        content = f.readlines()[-lines:]
                    live.update(Panel("".join(content), title="Live Output", border_style="bold green"))
                    sleep(interval)
                except KeyboardInterrupt:
                    break

    def view_history(self, lines=10):
        if not self.log_path.exists():
            print("[-] No history available.")
            return
        with open(self.log_path, "r", encoding="utf-8") as f:
            content = f.readlines()[-lines:]
            print("Recent Commands:")
            print("".join(content))

    def save_session(self, name, commands):
        session_file = SESSION_DIR / f"\${name}.json"
        with open(session_file, "w", encoding="utf-8") as f:
            json.dump(commands, f, indent=2)
        print(f"[+] Session '\${name}' saved to \${session_file}")

    def load_session(self, name):
        session_file = SESSION_DIR / f"\${name}.json"
        if not session_file.exists():
            print(f"[-] Session '\${name}' not found.")
            return []
        with open(session_file, "r", encoding="utf-8") as f:
            return json.load(f)

    def start_interactive_session(self):
        print("[*] Starting interactive session. Type 'exit' to quit.")
        while True:
            cmd = input(">> ").strip()
            if cmd.lower() == "exit":
                break
            self.send_command_with_confirmation(cmd)
EOL
fi

# config.py
echo '# config.py — placeholder for future settings or file parsing' > qshellbridge/config.py

# utils.py
echo '# utils.py — shared helper functions or I/O utils' > qshellbridge/utils.py

# main.py
cat <<EOL > qshellbridge/main.py
# main.py — optional CLI interface to bridge.py

from bridge import QShellBridge

if __name__ == "__main__":
    session = input("Session name: ")
    log_dir = input("Log directory: ")
    shell = QShellBridge(session, log_dir, confirm_mode=True)
    shell.start_interactive_session()
EOL

# setup.py
cat <<EOL > qshellbridge/setup.py
# setup.py — interactive SSH config and session naming

import json
from pathlib import Path
from rich.console import Console
from rich.prompt import Prompt
from rich.panel import Panel

console = Console()
CONFIG_PATH = Path.home() / ".qshellbridge_config.json"

def prompt_ssh_info():
    ssh_string = Prompt.ask("[bold green]Paste your SSH command[/]")
    return ssh_string

def prompt_log_dir():
    default = str(Path.home() / "qshellbridge/logs")
    return Prompt.ask("[bold green]Log directory[/]", default=default)

def parse_ssh_name(ssh_string):
    return "q_" + ssh_string.split()[-1].split('@')[0][:8]

def save_config(data):
    CONFIG_PATH.write_text(json.dumps(data, indent=2))
    console.print(f"[bold cyan]Saved to:[/] \${CONFIG_PATH}")

def main():
    console.print(Panel("[bold cyan]QShellBridge Setup[/]", border_style="magenta"))
    ssh = prompt_ssh_info()
    log_dir = prompt_log_dir()
    session = parse_ssh_name(ssh)
    save_config({
        "ssh_command": ssh,
        "log_directory": log_dir,
        "tmux_session": session
    })
    console.print(f"[bold green]Next:[/] tmux new -s \${session} '\${ssh}'")

if __name__ == "__main__":
    main()
EOL

# Confirm
echo -e "\n✅ QShellBridge structure is ready:"
tree -I '__pycache__|.git|.mypy_cache|.pytest_cache|*.egg-info'

echo -e "\nTo get started:"
echo "1. poetry install"
echo "2. poetry run qshell --help"
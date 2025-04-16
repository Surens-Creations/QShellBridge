# qshellbridge/setup.py
from rich.console import Console
from rich.prompt import Prompt
from rich.panel import Panel
from pathlib import Path
import os
import json

CONFIG_PATH = Path.home() / ".qshellbridge_config.json"
console = Console()

def prompt_ssh_info():
    console.print("\n🔌 [bold cyan]Enter your SSH connection string[/]:", style="bold magenta")
    ssh_string = Prompt.ask("[bold green]Paste full SSH command[/]", default="ssh user@host")
    return ssh_string

def prompt_log_dir():
    console.print("\n🗂️  [bold cyan]Choose a directory to save session logs[/]:", style="bold magenta")
    default = str(Path.home() / "qshellbridge" / "logs")
    path = Prompt.ask("[bold green]Log directory[/]", default=default)
    os.makedirs(path, exist_ok=True)
    return path

def parse_ssh_name(ssh_string):
    return ssh_string.split()[-1].split('@')[0][:8]  # Use first 8 chars of user/host hash

def save_config(config):
    CONFIG_PATH.write_text(json.dumps(config, indent=2))
    console.print(f"\n✅ Config saved to [bold yellow]{CONFIG_PATH}[/]")

def main():
    console.print(Panel.fit("[bold cyan]QShellBridge Setup[/]", border_style="bright_magenta"))
    ssh = prompt_ssh_info()
    log_dir = prompt_log_dir()
    session_name = "q_" + parse_ssh_name(ssh)

    config = {
        "ssh_command": ssh,
        "log_directory": log_dir,
        "tmux_session": session_name
    }

    save_config(config)

    console.print(f"\n🚀 To launch your session, run: [bold green]tmux new -s {session_name} '{ssh}'[/]")

if __name__ == "__main__":
    main()
# qshellbridge/main.py
from rich.console import Console
from rich.prompt import Prompt
from rich.panel import Panel
from rich.text import Text
from datetime import datetime
from bridge import QShellBridge
import json
from pathlib import Path

CONFIG_PATH = Path.home() / ".qshellbridge_config.json"
console = Console()

def load_config():
    if CONFIG_PATH.exists():
        return json.loads(CONFIG_PATH.read_text())
    else:
        console.print("[bold red]❌ No config found. Please run setup.py first.[/]")
        exit(1)

def banner():
    title = Text("🧠 QShellBridge", style="bold cyan")
    subtitle = Text("Created by Suren's Creations © 2025", style="magenta")
    console.print(Panel(title + "\n" + subtitle, border_style="bright_magenta"))

def main():
    banner()
    config = load_config()
    shell = QShellBridge(config["tmux_session"], config["log_directory"])

    if not shell.is_session_alive():
        console.print(f"[bold red]❌ tmux session '{shell.session}' not found.[/]")
        console.print(f"💡 Start it with: [bold green]tmux new -s {shell.session} '{config['ssh_command']}'[/]")
        return

    console.print("\n[bold cyan]Type commands below to send them into your SSH session. Type 'exit' to quit.[/]\n")
    while True:
        cmd = Prompt.ask("[bold magenta]Q >[/]", default="")
        if cmd.strip().lower() == "exit":
            break
        shell.send_and_log(cmd)

if __name__ == "__main__":
    main()
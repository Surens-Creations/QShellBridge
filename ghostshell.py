"""
👻 GhostShell — Operate a remote SSH tmux session invisibly via local Python.
Designed for seamless use with Amazon Q.
Author: Suren's Creations © 2025
"""

import subprocess
from pathlib import Path
from time import sleep
from rich.console import Console
from rich.panel import Panel
from rich.text import Text
from rich.align import Align
from rich import box

# === CONFIGURATION === #
SESSION_NAME = "q_0878ae1c"
MIRROR_LOG = Path("/tmp/ghostshell_output.log")
MIRROR_LOG.parent.mkdir(parents=True, exist_ok=True)

console = Console()

# === CORE === #
def ghost_send(cmd: str):
    """
    Sends a command to the remote SSH session via tmux.
    """
    subprocess.run(["tmux", "send-keys", "-t", SESSION_NAME, cmd, "C-m"])
    timestamp = Text(f"[$] {cmd}", style="bold cyan")
    console.print(timestamp)

def ghost_read(lines: int = 20):
    """
    Reads the latest N lines from the mirrored tmux log.
    """
    if not MIRROR_LOG.exists():
        console.print("[bold red]Mirror log not found. Is mirroring enabled?")
        return
    with open(MIRROR_LOG, "r") as f:
        output = f.readlines()[-lines:]
    panel = Panel("".join(output), title="[bold green]GhostShell Output", border_style="magenta")
    console.print(panel)

def enable_mirroring():
    """
    Enables tmux output mirroring into a log file.
    """
    subprocess.run([
        "tmux", "pipe-pane", "-t", SESSION_NAME,
        "-o", f"cat >> {MIRROR_LOG}"
    ])
    console.print("[bold green]🪞 Output mirroring enabled.")

def ghost_banner():
    art = Text("""
   ▄████████    ▄████████    ▄████████  ▄█     ▄████████ 
  ███    ███   ███    ███   ███    ███ ███    ███    ███ 
  ███    █▀    ███    █▀    ███    █▀  ███▌   ███    █▀  
 ▄███▄▄▄       ███         ▄███▄▄▄     ███▌   ███        
▀▀███▀▀▀     ▀███████████ ▀▀███▀▀▀     ███▌ ▀███████████ 
  ███    █▄           ███   ███    █▄  ███           ███ 
  ███    ███    ▄█    ███   ███    ███ ███     ▄█    ███ 
  ██████████  ▄████████▀    ██████████ █▀    ▄████████▀  
      """, style="bold bright_cyan")

    subtitle = Text("Suren's Creations © 2025", style="bright_yellow")
    panel = Panel(Align.center(art), subtitle=subtitle, border_style="bright_magenta", box=box.ROUNDED)
    console.print(panel)

def ghost_loop():
    ghost_banner()
    console.print(Panel("[bold magenta]Welcome to GhostShell", subtitle="Type 'exit' to leave.", style="bold magenta", box=box.HEAVY))
    while True:
        try:
            cmd = console.input("[bold bright_magenta]GHOST >> [/] ").strip()
            if cmd.lower() == "exit":
                break
            ghost_send(cmd)
            sleep(1.2)
            ghost_read()
        except KeyboardInterrupt:
            break

if __name__ == "__main__":
    enable_mirroring()
    ghost_loop()
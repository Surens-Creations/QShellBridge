import typer
from bridge import QShellBridge
import os

app = typer.Typer()
DEFAULT_LOG_DIR = os.path.expanduser("~/qshellbridge/logs")

@app.command()
def start(
    session: str = typer.Option(..., help="tmux session name"),
    log_dir: str = typer.Option(DEFAULT_LOG_DIR, help="Directory to store log files"),
    confirm: bool = typer.Option(False, help="Enable command confirmation mode"),
):
    """Launch interactive session."""
    shell = QShellBridge(session, log_dir, confirm_mode=confirm)
    if not shell.is_session_alive():
        typer.echo(f"❌ tmux session '{session}' is not active.")
        raise typer.Exit()
    shell.start_interactive_session()

@app.command()
def log(session: str, log_dir: str = typer.Option(DEFAULT_LOG_DIR), lines: int = 20):
    """Tail recent log lines."""
    shell = QShellBridge(session, log_dir)
    shell.tail_log_live(lines=lines)

@app.command()
def mirror(session: str, output: str):
    """Enable output mirroring to file."""
    shell = QShellBridge(session, DEFAULT_LOG_DIR)
    shell.enable_output_mirroring(output)

@app.command()
def history(session: str, log_dir: str = typer.Option(DEFAULT_LOG_DIR), lines: int = 10):
    """View recent command history."""
    shell = QShellBridge(session, log_dir)
    shell.view_history(lines=lines)

@app.command()
def run(session: str, cmd: str, log_dir: str = typer.Option(DEFAULT_LOG_DIR)):
    """Send a single command to the session."""
    shell = QShellBridge(session, log_dir)
    shell.send_and_log(cmd)

if __name__ == "__main__":
    app()

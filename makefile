.PHONY: install run setup cli tail mirror history clean

install:
	poetry install

run:
	poetry run python main.py

setup:
	poetry run python setup.py

cli:
	poetry run qshell --help

tail:
	poetry run qshell log --session replit-ssh --lines 25

mirror:
	poetry run qshell mirror --session replit-ssh --output /tmp/replit-output.log

history:
	poetry run qshell history --session replit-ssh --lines 10

clean:
	find . -type d -name '__pycache__' -exec rm -r {} +
	rm -rf *.egg-info .pytest_cache .mypy_cache dist build

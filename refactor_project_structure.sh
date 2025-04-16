#!/bin/bash

OLD_DIR="qshellbridge"
NEW_ROOT="QShellBridgeApp"
PKG_NAME="qshellbridge"

echo "🔧 Starting project structure refactor..."

# Ensure we're inside the old folder
if [ ! -d "$OLD_DIR" ]; then
  echo "❌ Folder '$OLD_DIR' not found. Run this script from its parent directory."
  exit 1
fi

# Rename the root folder
mv "$OLD_DIR" "$NEW_ROOT"
cd "$NEW_ROOT" || exit

# Create the inner Python package directory
mkdir -p "$PKG_NAME"

# Move core files into the Python package directory
for file in bridge.py cli.py config.py main.py setup.py utils.py __init__.py; do
  if [ -f "$file" ]; then
    mv "$file" "$PKG_NAME/$file"
    echo "✅ Moved $file → $PKG_NAME/"
  fi
done

# Create __init__.py if missing
if [ ! -f "$PKG_NAME/__init__.py" ]; then
  echo "# Package initializer" > "$PKG_NAME/__init__.py"
fi

# Update pyproject.toml
if [ -f "pyproject.toml" ]; then
  sed -i '' "s|packages = \[{ include = \".*\" }\]|packages = [{ include = \"$PKG_NAME\" }]|" pyproject.toml
  sed -i '' "s|qshell = \".*\"|qshell = \"$PKG_NAME.cli:app\"|" pyproject.toml
  echo "🔁 Updated pyproject.toml to point to $PKG_NAME"
fi

# List final structure
echo -e "\n📁 Final structure:"
tree -I '__pycache__|.git|.mypy_cache|.pytest_cache|*.egg-info'

echo -e "\n✅ Refactor complete. You can now run:\n  cd $NEW_ROOT\n  poetry install\n  poetry run qshell --help"
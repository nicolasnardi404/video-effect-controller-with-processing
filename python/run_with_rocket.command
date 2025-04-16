#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Activate virtual environment if it exists
if [ -f "../.venv/bin/activate" ]; then
    source "../.venv/bin/activate"
elif [ -f ".venv/bin/activate" ]; then
    source ".venv/bin/activate"
fi

# Use Python Launcher (rocket icon) to run the application
/Applications/Python\ 3.12/IDLE.app/Contents/MacOS/Python launcher.py 
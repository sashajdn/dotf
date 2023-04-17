#!/bin/bash
function check_or_install_python() {
	if ! command -v python &> /dev/null
    then
        echo "🐍 Installing python..."
        brew install python
        echo "🐍 Installed python ✅"
    fi
}

check_or_install_python && \
    ## Poetry.
    curl -sSL https://install.python-poetry.org | python3 - &&

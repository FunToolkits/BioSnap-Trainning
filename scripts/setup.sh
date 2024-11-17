#!/bin/bash

# Exit on error
set -e

# Script variables
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ENV_PREFIX=$(source "pipenv shell" && pipenv run )

install(){
    $(ENV_PREFIX)pip install -r requirements.txt
    $(ENV_PREFIX)pip sync -d requirements.txt
}

fmt(){
    $(ENV_PREFIX)isort biosnap_Training/
	$(ENV_PREFIX)black -l 79 biosnap_Training/
	$(ENV_PREFIX)black -l 79 tests/
}

lint(){
    $(ENV_PREFIX)flake8 biosnap_Training/
	$(ENV_PREFIX)black -l 79 --check biosnap_Training/
	$(ENV_PREFIX)black -l 79 --check tests/
	$(ENV_PREFIX)mypy --ignore-missing-imports biosnap_Training/
}

test(){
    $(ENV_PREFIX)pytest -v --cov-config .coveragerc --cov=biosnap_Training -l --tb=short --maxfail=1 tests/
	$(ENV_PREFIX)coverage xml
	$(ENV_PREFIX)coverage html
}

clean(){
    find ./ -name '*.pyc' -exec rm -f {} \;
	find ./ -name '__pycache__' -exec rm -rf {} \;
	find ./ -name 'Thumbs.db' -exec rm -f {} \;
	find ./ -name '*~' -exec rm -f {} \;
	rm -rf .cache
	rm -rf .pytest_cache
	rm -rf .mypy_cache
	rm -rf build
	rm -rf dist
	rm -rf *.egg-info
	rm -rf htmlcov
	rm -rf .tox/
	rm -rf docs/_build
}

docs(){
    echo "building documentation ..."
	$(ENV_PREFIX)mkdocs build
}

init(){
    echo "setting up project..."
    install
    lint
}

show_menu() {
    echo "BioSnap-Training Setup Script"
    echo "=============================="
    echo "1. Initialize project"
    echo "2. Format code"
    echo "3. Lint code"
    echo "4. Run tests"
    echo "5. Clean project"
    echo "6. Build documentation"
    echo "7. Exit"
    echo "=============================="
    echo "Enter your choice [1-8]: "
}

# Main function
main() {
    while true; do
        show_menu
        read -r choice
        
        case $choice in
            1) init ;;
            2) fmt ;;
            3) lint ;;
            4) test ;;
            5) clean ;;
            6) docs ;;
            7) echo "Exiting..."; exit 0 ;;
            *) echo "Invalid option. Please choose between 1-7" ;;
        esac
        
        echo
        echo "Press Enter to continue..."
        read -r
        clear
    done
}

# Execute main function
main "$@"

# Script variables
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ENV_PREFIX = "python -m pipenv run"

function Install-Dependencies {
    & $ENV_PREFIX pip install -r requirements.txt
    & $ENV_PREFIX pip sync -d requirements.txt
}

function Format-Code {
    & $ENV_PREFIX isort biosnap_Training/
    & $ENV_PREFIX black -l 79 biosnap_Training/
    & $ENV_PREFIX black -l 79 tests/
}

function Invoke-Lint {
    & $ENV_PREFIX flake8 biosnap_Training/
    & $ENV_PREFIX black -l 79 --check biosnap_Training/
    & $ENV_PREFIX black -l 79 --check tests/
    & $ENV_PREFIX mypy --ignore-missing-imports biosnap_Training/
}

function Invoke-Tests {
    & $ENV_PREFIX pytest -v --cov-config .coveragerc --cov=biosnap_Training -l --tb=short --maxfail=1 tests/
    & $ENV_PREFIX coverage xml
    & $ENV_PREFIX coverage html
}

function Clear-Project {
    Get-ChildItem -Path ./ -Include *.pyc -Recurse | Remove-Item -Force
    Get-ChildItem -Path ./ -Include __pycache__ -Recurse | Remove-Item -Force -Recurse
    Get-ChildItem -Path ./ -Include Thumbs.db -Recurse | Remove-Item -Force
    Get-ChildItem -Path ./ -Include *~ -Recurse | Remove-Item -Force
    Remove-Item -Path .cache -Force -Recurse -ErrorAction SilentlyContinue
    Remove-Item -Path .pytest_cache -Force -Recurse -ErrorAction SilentlyContinue
    Remove-Item -Path .mypy_cache -Force -Recurse -ErrorAction SilentlyContinue
    Remove-Item -Path build -Force -Recurse -ErrorAction SilentlyContinue
    Remove-Item -Path dist -Force -Recurse -ErrorAction SilentlyContinue
    Remove-Item -Path *.egg-info -Force -Recurse -ErrorAction SilentlyContinue
    Remove-Item -Path htmlcov -Force -Recurse -ErrorAction SilentlyContinue
    Remove-Item -Path .tox -Force -Recurse -ErrorAction SilentlyContinue
    Remove-Item -Path docs/_build -Force -Recurse -ErrorAction SilentlyContinue
}

function Build-Documentation {
    Write-Host "building documentation ..."
    & $ENV_PREFIX mkdocs build
}

function Initialize-Project {
    Write-Host "setting up project..."
    Install-Dependencies
    Invoke-Lint
}

function Show-Menu {
    Write-Host "BioSnap-Training Setup Script"
    Write-Host "=============================="
    Write-Host "1. Initialize project"
    Write-Host "2. Format code"
    Write-Host "3. Lint code"
    Write-Host "4. Run tests"
    Write-Host "5. Clean project"
    Write-Host "6. Build documentation"
    Write-Host "7. Exit"
    Write-Host "=============================="
    Write-Host "Enter your choice [1-7]: " -NoNewline
}

# Main function
function Main {
    while ($true) {
        Show-Menu
        $choice = Read-Host
        
        switch ($choice) {
            1 { Initialize-Project }
            2 { Format-Code }
            3 { Invoke-Lint }
            4 { Invoke-Tests }
            5 { Clear-Project }
            6 { Build-Documentation }
            7 { Write-Host "Exiting..."; exit }
            default { Write-Host "Invalid option. Please choose between 1-7" }
        }
        
        Write-Host
        Write-Host "Press Enter to continue..."
        Read-Host
        Clear-Host
    }
}

# Execute main function
Main

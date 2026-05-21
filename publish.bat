@echo off

for /f "delims=" %%i in ('git status --porcelain') do set changes=1

if defined changes (
    echo Changes detected. Committing...
    git add .
    git commit -m "Content update"
) else (
    echo No changes to commit.
)

echo Running publish script...
powershell -ExecutionPolicy Bypass -File ".\publish_to_github.ps1"
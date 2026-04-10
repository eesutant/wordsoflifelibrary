# 1. Clean the docs folder completely
if (Test-Path "./docs") {
    Remove-Item -Recurse -Force "./docs/*"
}

# 2. Build the site into docs/
hugo --cleanDestinationDir

# 3. Stage all changes
git add .

# 4. Commit with timestamp
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
git commit -m "Publish site - $timestamp"

# 5. Push to GitHub
git push
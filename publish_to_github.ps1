# Build the Hugo site
hugo

# Ensure docs folder exists
if (Test-Path "./docs") {
    Remove-Item "./docs" -Recurse -Force
}

New-Item -ItemType Directory -Path "./docs" | Out-Null

# Copy Hugo output (public) into docs
Copy-Item -Recurse -Force "./public/*" "./docs/"

# Restore the CNAME file
Copy-Item -Force "./CNAME" "./docs/CNAME"

# Commit and push changes
git add .
git commit -m "Publish updated site"
git push origin main
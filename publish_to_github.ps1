# Build the Hugo site (outputs directly into /docs)
hugo

# Ensure the CNAME file stays in /docs
Copy-Item -Force "./CNAME" "./docs/CNAME"

# Commit and push changes
git add .
git commit -m "Publish updated site"
git push origin main
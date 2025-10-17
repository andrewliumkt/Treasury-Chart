#!/usr/bin/env bash
set -euo pipefail

# Always run from the repo root (the folder this script lives in)
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Where your fresh files live:
EXPORT_DIR="/Users/andrewliu/Documents/MKT_Chart/treasury_slides"

# Where they go in the repo:
SITE_SLIDES_DIR="slides"
SITE_HTML_FILE="index.html"

# Make sure git user is set (harmless if already set)
git config user.name >/dev/null 2>&1 || git config user.name "Andrew Liu"
git config user.email >/dev/null 2>&1 || git config user.email "andrew@mktadvisorsllc.com"

git pull

# Copy PNGs into slides/ (overwrite + remove old extras)
mkdir -p "$SITE_SLIDES_DIR"
rsync -av --delete \
  --include='*.png' --include='*/' --exclude='*' \
  "$EXPORT_DIR"/ "$SITE_SLIDES_DIR"/

# Copy the HTML into repo root
cp "$EXPORT_DIR/index.html" "$SITE_HTML_FILE"

# 1) Fix paths so HTML looks for images in slides/ (not ./)
perl -pi -e 's#"\./#\"slides/#g' "$SITE_HTML_FILE"

# 2) Add cache-buster so GitHub Pages + browser always use latest images
perl -pi -e "s#(slides/[^\"']+\\.png)#\\1?v=$(date +%s)#g" "$SITE_HTML_FILE"

# Commit & push
git add -A
git commit -m "Update slides $(date +%F)" || echo "No changes to commit"
git push
echo "Done."

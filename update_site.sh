#!/usr/bin/env bash
set -euo pipefail

# Where your fresh files live:
EXPORT_DIR="/Users/andrewliu/Documents/MKT_Chart/treasury_slides"

# Where they go in the repo:
SITE_SLIDES_DIR="slides"
SITE_HTML_FILE="index.html"

git pull

# Copy PNGs into slides/ (overwrite + remove old extras)
mkdir -p "$SITE_SLIDES_DIR"
rsync -av --delete \
  --include='*.png' --include='*/' --exclude='*' \
  "$EXPORT_DIR"/ "$SITE_SLIDES_DIR"/

# Copy the HTML into repo root
cp "$EXPORT_DIR/index.html" "$SITE_HTML_FILE"

# Commit & push
git add -A
git commit -m "Update slides $(date +%F)" || echo "No changes to commit"
git push
echo "Done."

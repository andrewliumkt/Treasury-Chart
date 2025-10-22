#!/usr/bin/env bash
set -euo pipefail

# Run from the repo root (where this script lives)
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Paths
EXPORT_DIR="/Users/andrewliu/Documents/MKT_Chart/treasury_slides"
DOCS_DIR="docs"
SITE_SLIDES_DIR="$DOCS_DIR/slides"
SITE_HTML_FILE="$DOCS_DIR/index.html"

# Git identity (harmless if already set)
git config user.name >/dev/null 2>&1 || git config user.name "Andrew Liu"
git config user.email >/dev/null 2>&1 || git config user.email "andrew@mktadvisorsllc.com"

git pull

# Guards
[ -d "$EXPORT_DIR" ] || { echo "❌ Export dir missing: $EXPORT_DIR"; exit 1; }
[ -f "$EXPORT_DIR/index.html" ] || { echo "❌ $EXPORT_DIR/index.html missing (run your R script)"; exit 1; }

# Sync into /docs
mkdir -p "$SITE_SLIDES_DIR"
rsync -av --delete --include='*.png' --include='*/' --exclude='*' "$EXPORT_DIR"/ "$SITE_SLIDES_DIR"/
cp "$EXPORT_DIR/index.html" "$SITE_HTML_FILE"

# Fix paths + cache-bust
perl -pi -e 's#"\./#\"slides/#g' "$SITE_HTML_FILE"
perl -pi -e "s#(slides/[^\"']+\\.png)#\\1?v=$(date +%s)#g" "$SITE_HTML_FILE"

# Force HTML change each deploy + disable Jekyll just in case
echo "<!-- deploy $(date +%s) -->" >> "$SITE_HTML_FILE"
touch "$DOCS_DIR/.nojekyll"

# Show tail so you can confirm the deploy marker
echo "---- tail(docs/index.html) ----"
tail -n 5 "$SITE_HTML_FILE" || true
echo "-------------------------------"

# Commit & push
git add -A
git commit -m "Publish to /docs $(date +%F_%H:%M:%S)" || echo "No changes to commit"
git push
echo "Done."

#!/usr/bin/env bash
set -e

echo "🔄 Resetting Art Inventory App data..."

# Define paths relative to project root
DATA_DIR="./data"
IMAGES_DIR="./public/images"
QRCODES_DIR="./public/qr_codes"

# Remove data files
if [ -f "$DATA_DIR/inventory.csv" ]; then
  rm "$DATA_DIR/inventory.csv"
  echo "🗑️  Deleted $DATA_DIR/inventory.csv"
fi

if [ -d "$DATA_DIR/notes" ]; then
  rm -rf "$DATA_DIR/notes"
  echo "🗑️  Deleted $DATA_DIR/notes directory"
fi

# Remove uploaded media
if [ -d "$IMAGES_DIR" ]; then
  find "$IMAGES_DIR" -type f ! -name '.gitkeep' -delete
  echo "🖼️  Cleared all uploaded art images"
fi

if [ -d "$QRCODES_DIR" ]; then
  find "$QRCODES_DIR" -type f ! -name '.gitkeep' -delete
  echo "📇  Cleared all generated QR codes"
fi

echo "✅ Reset complete! App is ready for a clean start."

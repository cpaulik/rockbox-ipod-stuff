#!/bin/bash

# ---- CONFIGURATION ----
MUSIC_DIR="/Volumes/Data/Music/Collection"  # Your local music folder
BW_DIR="$HOME/bw_covers"                           # Temporary output folder
IPOD_MOUNT="/Volumes/IPOD/Music"               # Mount point for your iPod
# ------------------------

mkdir -p "$BW_DIR"

# Step 1: Extract and resize grayscale folder.jpg into BW_DIR
find "$MUSIC_DIR" -type f \( -iname "*.mp3" -o -iname "*.m4a" -o -iname "*.flac" \) | \
while read -r file; do
    REL_PATH="${file#$MUSIC_DIR/}"
    ALBUM_DIR="$(dirname "$REL_PATH")"
    DEST_DIR="$BW_DIR/$ALBUM_DIR"
    COVER="$DEST_DIR/folder.jpg"

    # Skip if already exists
    if [ -f "$COVER" ]; then
        echo "✓ Skipping: $COVER already exists"
        continue
    fi

    mkdir -p "$DEST_DIR"
    echo "🎵 Processing: $file"

    # Extract and convert
    ffmpeg -y -i "$file" -an -vcodec copy "$DEST_DIR/tmp.jpg" 2>/dev/null
    if [ -f "$DEST_DIR/tmp.jpg" ]; then
        # convert "$DEST_DIR/tmp.jpg" -resize 200x200 -colorspace Gray "$COVER"
        convert "$DEST_DIR/tmp.jpg" -resize 196x196 "$COVER"
        echo "📁 Saved: $COVER"
        rm "$DEST_DIR/tmp.jpg"
    else
        echo "⚠️  No embedded cover in: $file"
    fi
done

# Step 2: Copy folder.jpg files to iPod
echo "🚚 Copying to iPod..."

find "$BW_DIR" -type f -name "folder.jpg" | while read -r bw_file; do
    REL_DIR="${bw_file#$BW_DIR/}"
    REL_FOLDER="$(dirname "$REL_DIR")"
    DEST_FOLDER="$IPOD_MOUNT/$REL_FOLDER"
    mkdir -p "$DEST_FOLDER"
    cp "$bw_file" "$DEST_FOLDER/folder.jpg"
    echo "✔ Copied to $DEST_FOLDER"
done

echo "✅ All covers processed and copied to iPod!"


#!/bin/bash

# Set plugin name
PLUGIN_NAME="wp-acf-markdown-field"

# Extract version from plugin file
VERSION=$(grep "Version:" index.php | awk -F': ' '{print $2}' | tr -d '\r')

# Create temporary and build directories
TMP_DIR="/tmp/$PLUGIN_NAME"
BUILD_DIR="build"
mkdir -p "$TMP_DIR" "$BUILD_DIR"

# Build assets first
npm run build

# Copy required files and directories
cp -R index.php \
      src \
      composer.json \
      README.md \
      "$TMP_DIR/"

# Copy dist folder to plugin root
cp -R assets/dist "$TMP_DIR/"

# Install composer dependencies
cd "$TMP_DIR"
composer install --no-dev --optimize-autoloader
cd - > /dev/null

# Remove development files and directories
find "$TMP_DIR" -name ".git*" -exec rm -rf {} +
find "$TMP_DIR" -name "*.map" -delete
find "$TMP_DIR" -name "node_modules" -exec rm -rf {} +
find "$TMP_DIR" -name ".DS_Store" -delete

# Create zip archive
cd /tmp
zip -r "${PLUGIN_NAME}-${VERSION}.zip" "$PLUGIN_NAME"
mv "${PLUGIN_NAME}-${VERSION}.zip" "$OLDPWD/$BUILD_DIR/"

# Cleanup
rm -rf "$TMP_DIR"

echo "Release zip created: $BUILD_DIR/${PLUGIN_NAME}-${VERSION}.zip"
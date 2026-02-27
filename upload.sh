#!/usr/bin/env bash

set -euo pipefail

# ----------------------------
# Configuration
# ----------------------------
PYTHON_BIN="python3"
DIST_DIR="$PWD/dist"
BUILD_DIR_REL=".build_upload_tmp"
BUILD_DIR_ABS="$PWD/$BUILD_DIR_REL"
VENV_DIR_REL=".venv_upload_tmp"
VENV_DIR_ABS="$PWD/$VENV_DIR_REL"

# ----------------------------
# Cleanup function
# ----------------------------
cleanup() {
    echo "🧹 Cleaning up..."
    rm -rf "$BUILD_DIR_ABS" "$VENV_DIR_ABS"
}
trap cleanup EXIT

# ----------------------------
# 1️⃣ Create temporary venv
# ----------------------------
echo "📦 Creating temporary virtual environment..."
$PYTHON_BIN -m venv "$VENV_DIR_ABS"
source "$VENV_DIR_ABS/bin/activate"

pip install --upgrade pip
pip install build twine

# ----------------------------
# 2️⃣ Copy project with symlinks resolved
# ----------------------------
echo "📁 Copying project with resolved symlinks..."
rsync -aL \
  --exclude "$VENV_DIR_REL" \
  --exclude "$BUILD_DIR_REL" \
  --exclude ".git" \
  --exclude "__pycache__" \
  --exclude "$DIST_DIR" \
  ./ "$BUILD_DIR_ABS"

cd "$BUILD_DIR_ABS"

# ----------------------------
# 3️⃣ Build package
# ----------------------------
echo "🏗 Building package..."
python -m build

# ----------------------------
# 4️⃣ Upload package
# ----------------------------
echo "🚀 Uploading package with twine..."
twine upload dist/*

echo "✅ Upload complete!"

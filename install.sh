#!/bin/bash
# Cola Lark Skills Installer

set -e

SKILLS_DIR="$HOME/.cola/mods/default/skills"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/skills"

echo "Cola Lark Skills Installer"
echo "=========================="
echo ""

# Check source
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: skills/ directory not found."
    exit 1
fi

# Create target directory
mkdir -p "$SKILLS_DIR"

# Copy skills
SKILLS=(lark-setup lark-messages lark-tasks lark-calendar lark-docs lark-base)
for skill in "${SKILLS[@]}"; do
    if [ -d "$SOURCE_DIR/$skill" ]; then
        cp -r "$SOURCE_DIR/$skill" "$SKILLS_DIR/"
        echo "  Installed: $skill"
    fi
done

echo ""
echo "Done! $SKILLS_DIR"
echo ""
echo "Now tell Cola: \"帮我连接飞书\""

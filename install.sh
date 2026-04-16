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

# Check Cola
if [ ! -d "$HOME/.cola" ]; then
    echo "Warning: Cola is not installed (~/.cola not found)."
    echo "Please install Cola first: https://cola.dev"
    echo ""
    read -p "Continue anyway? [y/N] " answer
    if [ "$answer" != "y" ] && [ "$answer" != "Y" ]; then
        exit 1
    fi
fi

# Create target directory
mkdir -p "$SKILLS_DIR"

# Copy skills
SKILLS=(lark-setup lark-messages lark-tasks lark-calendar lark-docs lark-base)
for skill in "${SKILLS[@]}"; do
    if [ -d "$SOURCE_DIR/$skill" ]; then
        if [ -d "$SKILLS_DIR/$skill" ]; then
            cp -r "$SOURCE_DIR/$skill" "$SKILLS_DIR/"
            echo "  Updated:   $skill"
        else
            cp -r "$SOURCE_DIR/$skill" "$SKILLS_DIR/"
            echo "  Installed: $skill"
        fi
    fi
done

echo ""
echo "Done! Skills installed to: $SKILLS_DIR"
echo ""
echo "Now tell Cola: \"帮我连接飞书\""

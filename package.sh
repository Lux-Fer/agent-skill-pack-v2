#!/usr/bin/env bash
# Package Agent Skill Pack V2 for distribution
set -euo pipefail

VERSION="2.0.0"
OUTPUT="agent-skill-pack-v2-${VERSION}.tar.gz"

cd "$(dirname "$0")"

echo "📦 Packaging Agent Skill Pack V2 v${VERSION}..."

# Create distribution archive (exclude sell/ folder and .git)
tar czf "../${OUTPUT}" \
    --exclude=".git" \
    --exclude="sell" \
    --exclude="screenshots" \
    --exclude="*.tar.gz" \
    .

echo "✅ Created: ../${OUTPUT}"
echo "   Size: $(du -h ../${OUTPUT} | cut -f1)"


#!/bin/bash

# DSP Wiki Documentation Scraper
# Downloads key pages from DSP wikis for RAG ingestion

DOCS_DIR="/Users/laura/Documents/github-projects/dyson-sphere-facts/docs"
mkdir -p "$DOCS_DIR/dsp-wiki"
mkdir -p "$DOCS_DIR/reddit"

echo "======================================"
echo "DSP Documentation Scraper"
echo "======================================"
echo ""

# Function to download and clean wiki page
download_wiki_page() {
    local page_name=$1
    local file_name=$2
    local wiki_base="https://dsp-wiki.com"
    
    echo "Downloading: $page_name"
    
    # Try to get raw content if available
    curl -s "${wiki_base}/${page_name}?action=raw" > "$DOCS_DIR/dsp-wiki/${file_name}.txt" 2>/dev/null
    
    if [ $? -eq 0 ] && [ -s "$DOCS_DIR/dsp-wiki/${file_name}.txt" ]; then
        echo "  ✓ Saved as ${file_name}.txt"
    else
        # Fallback to HTML and extract text
        curl -s "${wiki_base}/${page_name}" | \
            sed 's/<[^>]*>//g' | \
            sed '/^[[:space:]]*$/d' > "$DOCS_DIR/dsp-wiki/${file_name}.txt"
        echo "  ✓ Saved as ${file_name}.txt (HTML extracted)"
    fi
}

# Core game mechanics pages
echo "1. Downloading Core Mechanics"
echo "-----------------------------"
download_wiki_page "Dyson_Sphere" "dyson-sphere"
download_wiki_page "Critical_Photon" "critical-photons"
download_wiki_page "Antimatter" "antimatter"
download_wiki_page "Ray_Receiver" "ray-receiver"
download_wiki_page "Small_Carrier_Rocket" "small-carrier-rocket"
download_wiki_page "Solar_Sail" "solar-sail"
download_wiki_page "Matrix_Lab" "matrix-lab"
download_wiki_page "Energy_Exchanger" "energy-exchanger"

echo ""
echo "2. Downloading Production Info"
echo "------------------------------"
download_wiki_page "Production_Chain" "production-chain"
download_wiki_page "Logistics" "logistics"
download_wiki_page "Power" "power"
download_wiki_page "Research" "research"

echo ""
echo "3. Downloading Building Info"
echo "----------------------------"
download_wiki_page "Buildings" "buildings"
download_wiki_page "Vertical_Launching_Silo" "vertical-launching-silo"
download_wiki_page "EM-Rail_Ejector" "em-rail-ejector"
download_wiki_page "Miniature_Particle_Collider" "particle-collider"

echo ""
echo "4. Creating Combined Documentation"
echo "----------------------------------"

# Create a master document with all content
cat > "$DOCS_DIR/dsp-wiki/00-index.md" << EOF
# Dyson Sphere Program Documentation Index

This documentation contains comprehensive information about Dyson Sphere Program game mechanics.

## Contents

### Core Concepts
- Dyson Sphere Construction
- Critical Photons and Antimatter
- Ray Receivers and Energy Collection
- Solar Sails and Carrier Rockets

### Production Systems
- Production Chains
- Logistics Networks
- Power Generation
- Research Trees

### Buildings and Structures
- Launch Systems
- Particle Colliders
- Energy Systems

---

EOF

# Append all text files to the master document
for file in "$DOCS_DIR/dsp-wiki"/*.txt; do
    if [ -f "$file" ]; then
        filename=$(basename "$file" .txt)
        echo "## ${filename//-/ }" >> "$DOCS_DIR/dsp-wiki/00-index.md"
        echo "" >> "$DOCS_DIR/dsp-wiki/00-index.md"
        cat "$file" >> "$DOCS_DIR/dsp-wiki/00-index.md"
        echo -e "\n---\n" >> "$DOCS_DIR/dsp-wiki/00-index.md"
    fi
done

echo "✓ Created master index at 00-index.md"

echo ""
echo "5. Sample Reddit Guides"
echo "-----------------------"

# Create sample structure for Reddit guides
cat > "$DOCS_DIR/reddit/beginner-guide.md" << EOF
# DSP Beginner's Guide (Reddit Community)

## Getting Started with Dyson Sphere Program

### Early Game Tips
1. Focus on automation early
2. Don't hand-craft everything
3. Set up iron and copper smelting arrays
4. Research Logistics as soon as possible

### Power Progression
1. Wind Turbines → Solar Panels → Thermal Power
2. Rush to Deuteron Fuel Rods for mid-game
3. Dyson Swarm for late game power

### Critical Photon Production
- Requires Ray Receivers in Photon Generation mode
- Needs line of sight to Dyson Sphere/Swarm
- Used for Antimatter production
- Essential for late-game progression
EOF

echo "✓ Created sample Reddit guide"

echo ""
echo "======================================"
echo "Documentation Scraping Complete!"
echo "======================================"
echo ""
echo "Downloaded files to: $DOCS_DIR"
echo ""
echo "To ingest into RAG system:"
echo "1. Start MCP servers: ./docker/manage-mcp.sh start"
echo "2. Add documents via MCP:"
echo "   ./docker/mcp-query.sh add 'file:///docs/dsp-wiki/00-index.md' 'DSP Complete Guide'"
echo ""
echo "Or manually copy to Docker container:"
echo "   docker cp $DOCS_DIR dsp-mcp-ragdocs:/app/docs"

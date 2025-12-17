#!/bin/bash
# Setup script for creating new project documentation
# Usage: ./scripts/setup-project-docs.sh PROJECT_NAME

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get project name from argument
PROJECT_NAME="$1"

if [ -z "$PROJECT_NAME" ]; then
    echo -e "${YELLOW}Usage: $0 PROJECT_NAME${NC}"
    echo "Example: $0 MyNewProject"
    exit 1
fi

# Get script directory and repository root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

PROJECT_DIR="$REPO_ROOT/projects/$PROJECT_NAME"

echo -e "${BLUE}Setting up documentation for project: $PROJECT_NAME${NC}"

# Check if project directory already exists
if [ -d "$PROJECT_DIR" ]; then
    echo -e "${YELLOW}Warning: Project directory already exists: $PROJECT_DIR${NC}"
    read -p "Continue and potentially overwrite files? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi
else
    echo -e "${GREEN}✓${NC} Creating project directory: $PROJECT_DIR"
    mkdir -p "$PROJECT_DIR"
fi

# Create directory structure
echo -e "${GREEN}✓${NC} Creating directory structure..."
mkdir -p "$PROJECT_DIR/reproducibility"
mkdir -p "$PROJECT_DIR/assets/screenshots"
mkdir -p "$PROJECT_DIR/assets/diagrams"
mkdir -p "$PROJECT_DIR/assets/videos"
mkdir -p "$PROJECT_DIR/assets/graphs"
mkdir -p "$PROJECT_DIR/code"
mkdir -p "$PROJECT_DIR/paper"

# Copy templates
echo -e "${GREEN}✓${NC} Copying documentation templates..."

if [ ! -f "$PROJECT_DIR/README.md" ] || [[ "$REPLY" =~ ^[Yy]$ ]]; then
    cp "$REPO_ROOT/templates/README-template.md" "$PROJECT_DIR/README.md"
    echo -e "${GREEN}  ✓${NC} README.md"
fi

if [ ! -f "$PROJECT_DIR/ABSTRACT.md" ] || [[ "$REPLY" =~ ^[Yy]$ ]]; then
    cp "$REPO_ROOT/templates/ABSTRACT-template.md" "$PROJECT_DIR/ABSTRACT.md"
    echo -e "${GREEN}  ✓${NC} ABSTRACT.md"
fi

if [ ! -f "$PROJECT_DIR/STATUS.md" ] || [[ "$REPLY" =~ ^[Yy]$ ]]; then
    cp "$REPO_ROOT/templates/STATUS-template.md" "$PROJECT_DIR/STATUS.md"
    echo -e "${GREEN}  ✓${NC} STATUS.md"
fi

if [ ! -f "$PROJECT_DIR/reproducibility/reproduce.md" ] || [[ "$REPLY" =~ ^[Yy]$ ]]; then
    cp "$REPO_ROOT/templates/REPRODUCIBILITY-template.md" "$PROJECT_DIR/reproducibility/reproduce.md"
    echo -e "${GREEN}  ✓${NC} reproducibility/reproduce.md"
fi

# Create placeholder files
echo -e "${GREEN}✓${NC} Creating placeholder files..."

# requirements.txt if it doesn't exist
if [ ! -f "$PROJECT_DIR/code/requirements.txt" ]; then
    cat > "$PROJECT_DIR/code/requirements.txt" << 'EOF'
# Python dependencies
# Add your dependencies here with versions
# Example:
# numpy==1.24.0
# pandas==2.0.0
# torch==2.0.0
EOF
    echo -e "${GREEN}  ✓${NC} code/requirements.txt"
fi

# Dockerfile if it doesn't exist
if [ ! -f "$PROJECT_DIR/code/Dockerfile" ]; then
    cat > "$PROJECT_DIR/code/Dockerfile" << 'EOF'
# Dockerfile for PROJECT_NAME
FROM python:3.11-slim

WORKDIR /app

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Expose port (adjust as needed)
EXPOSE 8000

# Run application (adjust command as needed)
CMD ["python", "app.py"]
EOF
    echo -e "${GREEN}  ✓${NC} code/Dockerfile"
fi

# .env.example if it doesn't exist
if [ ! -f "$PROJECT_DIR/code/.env.example" ]; then
    cat > "$PROJECT_DIR/code/.env.example" << 'EOF'
# Environment variables template
# Copy this file to .env and fill in your values

# Example variables (customize for your project)
# API_KEY=your_api_key_here
# DATABASE_URL=your_database_url_here
# DEBUG=false
EOF
    echo -e "${GREEN}  ✓${NC} code/.env.example"
fi

# .gitignore for code directory
if [ ! -f "$PROJECT_DIR/code/.gitignore" ]; then
    cat > "$PROJECT_DIR/code/.gitignore" << 'EOF'
# Environment variables
.env

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
venv/
env/
*.egg-info/

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db
EOF
    echo -e "${GREEN}  ✓${NC} code/.gitignore"
fi

# Create a README for assets
cat > "$PROJECT_DIR/assets/README.md" << 'EOF'
# Project Assets

## Directory Structure

- **screenshots/** - UI screenshots and feature demonstrations
  - Resolution: 1920x1080+ for main, 1280x720+ for features
  - Format: PNG (lossless)

- **diagrams/** - System architecture and technical diagrams
  - Format: SVG preferred, PNG acceptable
  - Tools: Mermaid, draw.io, Figma

- **videos/** - Demo videos and walkthroughs
  - Duration: 60-90 seconds
  - Resolution: 1080p
  - Format: MP4

- **graphs/** - Performance metrics and comparisons
  - Export: PNG at 300 DPI
  - Include: Source data (CSV/JSON)

## Guidelines

For detailed visual asset standards, see:
[DOCUMENTATION_GUIDELINES.md](../../DOCUMENTATION_GUIDELINES.md#visual-assets-standards)
EOF
echo -e "${GREEN}  ✓${NC} assets/README.md"

# Replace PROJECT_NAME placeholder in files
echo -e "${GREEN}✓${NC} Customizing templates with project name..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/PROJECT_NAME/$PROJECT_NAME/g" "$PROJECT_DIR/README.md"
    sed -i '' "s/PROJECT_NAME/$PROJECT_NAME/g" "$PROJECT_DIR/ABSTRACT.md"
    sed -i '' "s/PROJECT_NAME/$PROJECT_NAME/g" "$PROJECT_DIR/STATUS.md"
    sed -i '' "s/PROJECT_NAME/$PROJECT_NAME/g" "$PROJECT_DIR/reproducibility/reproduce.md"
    sed -i '' "s/PROJECT_NAME/$PROJECT_NAME/g" "$PROJECT_DIR/code/Dockerfile"
else
    # Linux
    sed -i "s/PROJECT_NAME/$PROJECT_NAME/g" "$PROJECT_DIR/README.md"
    sed -i "s/PROJECT_NAME/$PROJECT_NAME/g" "$PROJECT_DIR/ABSTRACT.md"
    sed -i "s/PROJECT_NAME/$PROJECT_NAME/g" "$PROJECT_DIR/STATUS.md"
    sed -i "s/PROJECT_NAME/$PROJECT_NAME/g" "$PROJECT_DIR/reproducibility/reproduce.md"
    sed -i "s/PROJECT_NAME/$PROJECT_NAME/g" "$PROJECT_DIR/code/Dockerfile"
fi

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Project documentation setup complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}Project location:${NC} $PROJECT_DIR"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Fill in templates marked with <!-- ✏️ FILL: ... -->"
echo "2. Add visual assets to assets/ directory"
echo "3. Complete code/requirements.txt with dependencies"
echo "4. Test reproducibility/reproduce.md in fresh environment"
echo ""
echo -e "${BLUE}Quick reference:${NC}"
echo "  • Full guidelines: DOCUMENTATION_GUIDELINES.md"
echo "  • Quick reference: templates/QUICK_REFERENCE.md"
echo "  • Examples: projects/EDIFY/ and projects/GUIRA/"
echo ""
echo -e "${GREEN}Happy documenting! 🚀${NC}"
echo ""

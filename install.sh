#!/bin/bash

# Terminal formatting
BOLD=$(tput bold)
NORMAL=$(tput sgr0)
PINK='\033[1;35m'

# Function to display formatted messages
show() {
    case $2 in
        "error")
            echo -e "${PINK}${BOLD}❌ $1${NORMAL}"
            ;;
        "progress")
            echo -e "${PINK}${BOLD}⏳ $1${NORMAL}"
            ;;
        *)
            echo -e "${PINK}${BOLD}✅ $1${NORMAL}"
            ;;
    esac
}

# Check if curl is installed
if ! command -v curl &> /dev/null; then
    show "curl is not installed. Installing curl..." "progress"
    sudo apt-get update
    sudo apt-get install -y curl
    if [ $? -ne 0 ]; then
        show "Failed to install curl. Please install it manually and rerun the script." "error"
        exit 1
    fi
fi

# Check for existing Node.js installations
EXISTING_NODE=$(which node 2>/dev/null)
if [ -n "$EXISTING_NODE" ]; then
    show "Existing Node.js found at $EXISTING_NODE. The script will install the latest version system-wide."
fi

# Fetch the latest LTS Node.js version using a more reliable method
show "Fetching latest Node.js LTS version..." "progress"
LATEST_VERSION=$(curl -s https://nodejs.org/dist/index.tab | grep -E "^v[0-9]+\.[0-9]+\.[0-9]+.*latest.*LTS" | head -1 | cut -f1 | sed 's/^v//')

if [ -z "$LATEST_VERSION" ]; then
    # Fallback method if the first attempt fails
    show "First method failed. Trying alternative method to fetch Node.js version..." "progress"
    LATEST_VERSION=$(curl -s https://nodejs.org/en/download/ | grep -oP 'Latest LTS Version.*?(\d+\.\d+\.\d+)' | grep -oP '\d+\.\d+\.\d+' | head -1)
fi

if [ -z "$LATEST_VERSION" ]; then
    # Second fallback - use a known LTS version
    show "Failed to fetch latest Node.js version. Using default LTS version 20.x" "progress"
    MAJOR_VERSION=20
else
    show "Latest Node.js LTS version is $LATEST_VERSION"
    # Extract the major version
    MAJOR_VERSION=$(echo $LATEST_VERSION | cut -d. -f1)
fi

# Set up the NodeSource repository with better error handling
show "Setting up NodeSource repository for Node.js $MAJOR_VERSION.x..." "progress"

# Create a temporary file for the setup script
TEMP_SCRIPT=$(mktemp)

# Download the setup script with proper error checking
if ! curl -sL "https://deb.nodesource.com/setup_${MAJOR_VERSION}.x" -o "$TEMP_SCRIPT"; then
    show "Failed to download NodeSource setup script. Please check your internet connection." "error"
    rm -f "$TEMP_SCRIPT"
    exit 1
fi

# Verify the downloaded script is not HTML or an error page
if grep -q "<html>" "$TEMP_SCRIPT" || grep -q "404" "$TEMP_SCRIPT" || [ $(wc -l < "$TEMP_SCRIPT") -lt 10 ]; then
    show "The NodeSource script appears to be invalid. Trying alternative installation method..." "progress"
    rm -f "$TEMP_SCRIPT"
    
    # Alternative installation method using nvm
    show "Installing Node.js using direct apt method..." "progress"
    
    # First ensure we have the necessary packages
    sudo apt-get update
    sudo apt-get install -y ca-certificates gnupg
    
    # Create directory for keyrings if it doesn't exist
    sudo mkdir -p /etc/apt/keyrings
    
    # Download and install the NodeSource signing key
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
    
    # Add the NodeSource repository
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$MAJOR_VERSION.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list > /dev/null
    
    # Update apt and install Node.js
    sudo apt-get update
    if ! sudo apt-get install -y nodejs; then
        show "Failed to install Node.js using alternative method." "error"
        exit 1
    fi
else
    # Execute the NodeSource setup script
    sudo bash "$TEMP_SCRIPT"
    if [ $? -ne 0 ]; then
        show "Failed to execute NodeSource setup script." "error"
        rm -f "$TEMP_SCRIPT"
        exit 1
    fi
    
    # Clean up the temporary script
    rm -f "$TEMP_SCRIPT"
    
    # Install Node.js and npm
    show "Installing Node.js and npm..." "progress"
    sudo apt-get install -y nodejs
    if [ $? -ne 0 ]; then
        show "Failed to install Node.js and npm." "error"
        exit 1
    fi
fi

# Verify installation and PATH availability
show "Verifying installation..." "progress"
if command -v node &> /dev/null && command -v npm &> /dev/null; then
    NODE_VERSION=$(node -v)
    NPM_VERSION=$(npm -v)
    INSTALLED_NODE=$(which node)
    
    show "Node.js $NODE_VERSION and npm $NPM_VERSION installed successfully at $INSTALLED_NODE."
    
    # Check if installed in /usr/bin or elsewhere
    if [ "$INSTALLED_NODE" != "/usr/bin/node" ]; then
        show "Note: Node.js is installed at $INSTALLED_NODE instead of /usr/bin/node."
        show "To prioritize the system-wide installation, ensure /usr/bin is before other paths in your PATH variable."
    fi
else
    show "Installation completed, but node or npm not found in PATH." "error"
    show "Please ensure /usr/bin is in your PATH variable (e.g., export PATH=/usr/bin:\$PATH) and restart your shell."
    exit 1
fi

show "Node.js installation completed successfully!"

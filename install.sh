#!/bin/bash

echo "🚀 Installing Gensyn Terminal Node by @CryptoProfezor..."

# ----------- Terminal Formatting & Utility ----------
BOLD=$(tput bold)
NORMAL=$(tput sgr0)
PINK='\033[1;35m'

show() {
    case $2 in
        "error") echo -e "${PINK}${BOLD}❌ $1${NORMAL}" ;;
        "progress") echo -e "${PINK}${BOLD}⏳ $1${NORMAL}" ;;
        *) echo -e "${PINK}${BOLD}✅ $1${NORMAL}" ;;
    esac
}

# ----------- Step 1: Install base dependencies ----------
show "Installing base packages..." "progress"
apt update && apt install -y sudo
sudo apt update && sudo apt install -y python3 python3-venv python3-pip curl wget screen git lsof nano unzip iproute2 gnupg

# ----------- Step 2: Smart Node.js Installer (Zun Style) ----------
if ! command -v curl &> /dev/null; then
    show "curl is not installed. Installing curl..." "progress"
    sudo apt-get update && sudo apt-get install -y curl
    [ $? -ne 0 ] && show "Failed to install curl." "error" && exit 1
fi

EXISTING_NODE=$(which node 2>/dev/null)
[ -n "$EXISTING_NODE" ] && show "Existing Node.js found at $EXISTING_NODE"

show "Fetching latest Node.js LTS version..." "progress"
LATEST_VERSION=$(curl -s https://nodejs.org/dist/index.tab | grep -E "^v[0-9]+\.[0-9]+\.[0-9]+.*latest.*LTS" | head -1 | cut -f1 | sed 's/^v//')

[ -z "$LATEST_VERSION" ] && {
    show "First method failed. Trying backup..." "progress"
    LATEST_VERSION=$(curl -s https://nodejs.org/en/download/ | grep -oP 'Latest LTS Version.*?(\d+\.\d+\.\d+)' | grep -oP '\d+\.\d+\.\d+' | head -1)
}

[ -z "$LATEST_VERSION" ] && {
    show "Failed to fetch latest Node.js version. Using default LTS version 20.x" "progress"
    MAJOR_VERSION=20
} || {
    show "Latest Node.js LTS version is $LATEST_VERSION"
    MAJOR_VERSION=$(echo $LATEST_VERSION | cut -d. -f1)
}

show "Setting up NodeSource repository for Node.js $MAJOR_VERSION.x..." "progress"
TEMP_SCRIPT=$(mktemp)
if ! curl -sL "https://deb.nodesource.com/setup_${MAJOR_VERSION}.x" -o "$TEMP_SCRIPT"; then
    show "Failed to download NodeSource setup script." "error"
    rm -f "$TEMP_SCRIPT"
    exit 1
fi

if grep -q "<html>" "$TEMP_SCRIPT" || grep -q "404" "$TEMP_SCRIPT"; then
    show "NodeSource script invalid. Trying alternative method..." "progress"
    rm -f "$TEMP_SCRIPT"
    sudo apt-get update && sudo apt-get install -y ca-certificates gnupg
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$MAJOR_VERSION.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y nodejs || { show "Failed to install Node.js using fallback." "error"; exit 1; }
else
    sudo bash "$TEMP_SCRIPT"
    [ $? -ne 0 ] && show "Failed to execute NodeSource script." "error" && rm -f "$TEMP_SCRIPT" && exit 1
    rm -f "$TEMP_SCRIPT"
    sudo apt-get install -y nodejs || { show "Failed to install Node.js." "error"; exit 1; }
fi

show "Verifying Node.js installation..." "progress"
if command -v node &> /dev/null && command -v npm &> /dev/null; then
    NODE_VERSION=$(node -v)
    NPM_VERSION=$(npm -v)
    INSTALLED_NODE=$(which node)
    show "Node.js $NODE_VERSION and npm $NPM_VERSION installed successfully at $INSTALLED_NODE."
else
    show "Installation completed, but node or npm not found." "error"
    exit 1
fi

# ----------- Step 3: Clone Node Runner Repo -----------
show "Cloning node runner from your repo..." "progress"
cd $HOME && rm -rf Gensyn-Node-Update
git clone https://github.com/cryptoprofezor/Gensyn-Node-Update.git
chmod +x Gensyn-Node-Update/gensyn.sh

# ----------- Step 4: Install Ngrok -----------
show "Installing Ngrok..." "progress"
curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list
sudo apt update && sudo apt install -y ngrok

echo ""
show "Setup complete! Here's how to proceed:" "progress"
echo "🔐 1. Run this ONCE to authenticate Ngrok:"
echo "   ngrok config add-authtoken <your_token_here>"
echo ""
echo "🌍 2. Start tunnel to expose modal:"
echo "   ngrok http 3000"
echo ""
echo "⚠️ 3. Open the ngrok link in browser & login to Gensyn modal."

# ----------- Step 5: Start Gensyn Node ----------
sleep 2
screen -S gensyn bash Gensyn-Node-Update/gensyn.sh

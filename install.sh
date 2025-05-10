#!/bin/bash

echo "🚀 Installing Gensyn Terminal Node by @CryptoProfezor..."

# Step 1: Install base dependencies
echo "📦 Installing base packages..."
apt update && apt install -y sudo
sudo apt update && sudo apt install -y python3 python3-venv python3-pip curl wget screen git lsof nano unzip iproute2

# Step 2: Install Node.js
echo "📦 Installing Node.js (v18)..."
curl -sSL https://deb.nodesource.com/setup_18.x | sudo bash -
sudo apt install -y nodejs

# Step 3: Clone your actual runner repo (corrected)
echo "📥 Cloning node runner from your repo..."
cd $HOME && rm -rf Gensyn-Node-Update
git clone https://github.com/cryptoprofezor/Gensyn-Node-Update.git
chmod +x Gensyn-Node-Update/gensyn.sh

# Step 4: Install LocalXpose (optional tunnel)
echo "🌐 Installing LocalXpose (for modal login tunnel)..."
curl -s https://raw.githubusercontent.com/localxpose/localxpose/master/install.sh | bash

# Step 5: Start everything in screen
echo ""
echo "✅ Setup complete!"
echo "🧠 Launching in screen session: 'gensyn'"
echo "🔓 After login modal loads, run this to expose it:"
echo "   ./loclx tunnel http --to :3000"
echo ""

sleep 2
screen -S gensyn bash Gensyn-Node-Update/gensyn.sh

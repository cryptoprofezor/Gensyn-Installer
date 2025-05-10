#!/bin/bash

echo "🚀 Installing Gensyn Terminal Node by @CryptoProfezor..."

# Step 1: Install base dependencies
echo "📦 Installing base packages..."
apt update && apt install -y sudo
sudo apt update && sudo apt install -y python3 python3-venv python3-pip curl wget screen git lsof nano unzip iproute2 gnupg

# Step 2: Install Node.js
echo "📦 Installing Node.js (v18)..."
curl -sSL https://deb.nodesource.com/setup_18.x | sudo bash -
sudo apt install -y nodejs

# Step 3: Clone your actual runner repo (Gensyn-Node-Update)
echo "📥 Cloning node runner from your repo..."
cd $HOME && rm -rf Gensyn-Node-Update
git clone https://github.com/cryptoprofezor/Gensyn-Node-Update.git
chmod +x Gensyn-Node-Update/gensyn.sh

# Step 4: Install Ngrok
echo "🌐 Installing Ngrok..."
curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list
sudo apt update && sudo apt install -y ngrok

echo ""
echo "🔐 After install, authenticate Ngrok (only once):"
echo "   ngrok config add-authtoken <your_token_here>"
echo ""
echo "🌍 Then start the tunnel with:"
echo "   ngrok http 3000"
echo ""
echo "⚠️ Open the generated link in your browser to login"

# Step 5: Start Gensyn node inside screen
echo ""
echo "✅ Setup complete!"
echo "🧠 Launching node in screen session: 'gensyn'"
sleep 2
screen -S gensyn bash Gensyn-Node-Update/gensyn.sh

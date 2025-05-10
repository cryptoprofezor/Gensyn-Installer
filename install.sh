#!/bin/bash

echo "🚀 Installing Gensyn Terminal Node by @CryptoProfezor..."

# Step 1: Install base dependencies
apt update && apt install -y sudo
sudo apt update && sudo apt install -y python3 python3-venv python3-pip curl wget screen git lsof nano unzip iproute2

# Step 2: Install Node.js
curl -sSL https://deb.nodesource.com/setup_18.x | sudo bash -
sudo apt install -y nodejs

# Step 3: Clone your branded node repo
cd $HOME && rm -rf gensyn-node-terminal
git clone https://github.com/cryptoprofezor/gensyn-node-terminal.git
chmod +x gensyn-node-terminal/gensyn.sh

# Step 4: Start in a screen session
echo "📦 Setup complete! Starting in screen session 'gensyn'..."
sleep 2
screen -S gensyn bash gensyn-node-terminal/gensyn.sh


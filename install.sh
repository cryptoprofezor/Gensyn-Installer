#!/bin/bash

echo "🚀 Installing Gensyn Node by @CryptoProfezor..."

# Step 1: Install base packages
echo "📦 Installing base packages..."
sudo apt update && sudo apt install -y python3 python3-venv python3-pip curl wget screen git lsof nano unzip iproute2 openssh-client

# Step 2: Clone latest rl-swarm fork
echo "📥 Cloning latest node runner from your fork..."
cd $HOME && rm -rf rl-swarm
git clone https://github.com/cryptoprofezor/rl-swarm.git
cd rl-swarm
chmod +x run_rl_swarm.sh

# Step 3: Run the node setup
echo ""
echo "🧠 Launching node setup..."
sleep 2
./run_rl_swarm.sh

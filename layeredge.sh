#!/bin/bash

# Step 1: Install Dependencies
echo "Installing dependencies..."
sudo apt-get update
sudo apt-get install -y curl git docker docker-compose

# Step 2: Clone the Node Repository
echo "Cloning the node repository..."
git clone https://github.com/layeredge/light-node.git
cd light-node

# Step 3: Build or Download the Node Software
echo "Building the node software..."
docker-compose build

# Step 4: Configure the Node
echo "Configuring the node..."
# Replace with actual configuration steps (e.g., editing config.toml or .env files)
cp config.example.toml config.toml
sed -i 's/PEER_NODES=""/PEER_NODES="node1.example.com,node2.example.com"/' config.toml
sed -i 's/NETWORK_ID=""/NETWORK_ID="layeredge-mainnet"/' config.toml

# Step 5: Start the Node
echo "Starting the light node..."
docker-compose up -d

# Step 6: Check Node Status
echo "Checking node status..."
docker-compose logs -f

# Step 7: Verify Sync Status
echo "Verifying sync status..."
# Replace with actual CLI command to check sync status
docker exec -it light-node-cli layerged status

# Step 8: Monitor the Node
echo "Node is running. Use the following command to monitor logs:"
echo "docker-compose logs -f"

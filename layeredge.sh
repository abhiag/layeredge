#!/bin/bash

# Step 1: Clone the Light Node Repository
echo "Step 1: Cloning the Light Node repository..."
git clone https://github.com/Layer-Edge/light-node.git
cd light-node

# Step 2: Install Required Dependencies
echo "Step 2: Installing dependencies..."

# Install Go (if not already installed)
if ! command -v go &> /dev/null; then
    echo "Go is not installed. Installing Go..."
    sudo apt-get update
    sudo apt-get install -y golang
fi

# Install Rust (if not already installed)
if ! command -v rustc &> /dev/null; then
    echo "Rust is not installed. Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    source $HOME/.cargo/env
fi

# Install Risc0 Toolchain
echo "Installing Risc0 Toolchain..."
curl -L https://risczero.com/install | bash
source $HOME/.cargo/env
rzup install

# Verify Risc0 Toolchain Installation
echo "Verifying Risc0 Toolchain..."
rustup toolchain list
rustup default risc0

# Step 3: Configure Environment Variables
echo "Step 3: Setting up environment variables..."
export GRPC_URL=34.31.74.109:9090
export CONTRACT_ADDR=cosmos1ufs3tlq4umljk0qfe8k5ya0x6hpavn897u2cnf9k0en9jr7qarqqt56709
export ZK_PROVER_URL=http://127.0.0.1:3001
export API_REQUEST_TIMEOUT=100
export POINTS_API=http://127.0.0.1:8080
export PRIVATE_KEY='cli-node-private-key'

# Step 4: Start the Merkle Service
echo "Step 4: Starting the Merkle service..."
cd risc0-merkle-service
cargo clean
cargo build
cargo run &
MERCLE_PID=$!
echo "Merkle service started with PID: $MERCLE_PID"

# Wait for Merkle service to initialize
echo "Waiting for Merkle service to initialize..."
sleep 10

# Step 5: Build and Run the LayerEdge Light Node
echo "Step 5: Building and running the Light Node..."
cd ..
go build
./light-node &
LIGHT_NODE_PID=$!
echo "Light Node started with PID: $LIGHT_NODE_PID"

# Step 6: Connecting CLI Node with LayerEdge Dashboard
echo "Step 6: Instructions for connecting CLI Node with LayerEdge Dashboard:"
echo "1. Fetch Points via CLI:"
echo "   https://light-node.layeredge.io/api/cli-node/points/{walletAddress}"
echo "   Replace {walletAddress} with your actual CLI wallet address."
echo "2. Connect to Dashboard:"
echo "   - Navigate to dashboard.layeredge.io"
echo "   - Connect your wallet"
echo "   - Link your CLI node’s Public Key"

# Step 7: Logging and Monitoring
echo "Step 7: Logging and Monitoring"
echo "Use the following commands to monitor logs:"
echo "Merkle Service Logs: tail -f risc0-merkle-service/logs.txt"
echo "Light Node Logs: tail -f light-node.log"

# Step 8: Cleanup (Optional)
echo "Step 8: To stop the services, run:"
echo "kill $MERCLE_PID"
echo "kill $LIGHT_NODE_PID"

echo "Setup complete! Your LayerEdge CLI Light Node is now running."

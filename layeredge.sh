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
rustup toolchain uninstall risc0 2>/dev/null || true
curl -L https://risczero.com/install | bash
source $HOME/.bashrc  # Reload shell configuration to make rzup available
export PATH="$HOME/.risc0/bin:$PATH"  # Ensure rzup is in PATH

# Verify rzup installation
if ! command -v rzup &> /dev/null; then
    echo "Error: rzup command not found. Please check the installation."
    exit 1
fi

# Install the risc0 toolchain
rzup install

# Verify Risc0 Toolchain Installation
echo "Verifying Risc0 Toolchain..."
rustup toolchain list
rustup default risc0

# Step 3: Create .env File and Save Environment Variables
echo "Step 3: Creating .env file and saving environment variables..."
if [ ! -f .env ]; then
    cat <<EOL > .env
GRPC_URL=34.31.74.109:9090
CONTRACT_ADDR=cosmos1ufs3tlq4umljk0qfe8k5ya0x6hpavn897u2cnf9k0en9jr7qarqqt56709
ZK_PROVER_URL=http://127.0.0.1:3001
API_REQUEST_TIMEOUT=100
POINTS_API=http://127.0.0.1:8080
PRIVATE_KEY='cli-node-private-key'
EOL
    echo ".env file created successfully."
else
    echo ".env file already exists. Skipping creation."
fi

# Set file permissions to restrict access
chmod 600 .env

# Step 4: Load Environment Variables
echo "Step 4: Loading environment variables from .env file..."
export $(cat .env | xargs)

# Step 5: Start the Merkle Service
echo "Step 5: Starting the Merkle service..."
cd risc0-merkle-service
cargo clean
cargo build
cargo run &
MERCLE_PID=$!
echo "Merkle service started with PID: $MERCLE_PID"

# Wait for Merkle service to initialize
echo "Waiting for Merkle service to initialize..."
sleep 10

# Step 6: Build and Run the LayerEdge Light Node
echo "Step 6: Building and running the Light Node..."
cd ..
go build
./light-node &
LIGHT_NODE_PID=$!
echo "Light Node started with PID: $LIGHT_NODE_PID"

# Step 7: Connecting CLI Node with LayerEdge Dashboard
echo "Step 7: Instructions for connecting CLI Node with LayerEdge Dashboard:"
echo "1. Fetch Points via CLI:"
echo "   https://light-node.layeredge.io/api/cli-node/points/{walletAddress}"
echo "   Replace {walletAddress} with your actual CLI wallet address."
echo "2. Connect to Dashboard:"
echo "   - Navigate to dashboard.layeredge.io"
echo "   - Connect your wallet"
echo "   - Link your CLI node’s Public Key"

# Step 8: Logging and Monitoring
echo "Step 8: Logging and Monitoring"
echo "Use the following commands to monitor logs:"
echo "Merkle Service Logs: tail -f risc0-merkle-service/logs.txt"
echo "Light Node Logs: tail -f light-node.log"

# Step 9: Cleanup (Optional)
echo "Step 9: To stop the services, run:"
echo "kill $MERCLE_PID"
echo "kill $LIGHT_NODE_PID"

echo "Setup complete! Your LayerEdge CLI Light Node is now running."

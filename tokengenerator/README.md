# Solana Token Generator

A lightweight solution for generating Solana tokens and their metadata. This repository simplifies the process by leveraging Solana CLI, SPL-Token, and IPFS.

## Prerequisites

To use this repository, ensure the following requirements are met:

### Required Tools
- **Solana CLI**: Ensure Solana CLI is installed and properly configured.
- **SPL-Token**: Ensure SPL-Token CLI is installed for managing Solana tokens.
- **IPFS Node**: A running IPFS node is required for uploading files to the IPFS network.

### IPFS Configuration
1. **Ports**:
   - Allow **Port 4001** (default for IPFS peer communication).
   - Allow **Port 8080** (default for IPFS HTTP Gateway).
2. **Reverse Proxy (Optional)**:
   - Configure a reverse proxy with Nginx to serve IPFS Gateway requests under `/ipfs` on port 8080.

### Solana Wallet
- A working **keypair** configured on the Solana CLI.
- Ensure the wallet has sufficient funds to pay for transaction fees (gas).

## Usage

1. **Prepare Your Image**:
   - Choose an image file to use as the token logo and save it as a friendly filename, in this case image.jpg.
   ```bash
   wget -O image.jpg "https://path-to-image-file-online.com"
   ```

2. **Run script**:
   ```bash
   ./token_generator.sh
   ```

3. **Input Metadata**:
   - Input the Image file path, Name, Ticker, Description for metadata to be uploaded.

## Getting Started

1. First run: 
   ```bash
   wget https://raw.githubusercontent.com/wfreq/utils/refs/heads/main/tokengenerator/token_generator.sh
   sudo chmod +x token_generator.sh
   ./token_generator.sh

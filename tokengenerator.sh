
#!/bin/bash

#requires solana cli, spl-token, and ipfs node running
#ipfs ports 4001, 8080 allowed
#ideally configure a reverse proxy with nginx for /ipfs on port 8080
#obviously you need a working keypair enabled on solana cli with funds to pay for the gas
#other than that all you need is an image file to use for the logo


# Prompt for the image file
read -p "Enter the path to the image file: " IMAGE_FILE

# Check if the image file exists
if [[ ! -f "$IMAGE_FILE" ]]; then
  echo "Error: Image file not found at $IMAGE_FILE."
  exit 1
fi

# Upload the image to IPFS
echo "Uploading image to IPFS..."
IMAGE_CID=$(ipfs add -Q "$IMAGE_FILE")

# Check if the upload was successful
if [[ -z "$IMAGE_CID" ]]; then
  echo "Error: Failed to upload the image to IPFS."
  exit 1
fi

echo "Image uploaded to IPFS with CID: $IMAGE_CID"

# Construct the image URL
IMAGE_URL="https://ipfs.io/ipfs/$IMAGE_CID"

# Prompt for token metadata
read -p "Enter the name of the token: " TOKEN_NAME
read -p "Enter the symbol of the token: " TOKEN_SYMBOL
read -p "Enter the description of the token: " TOKEN_DESCRIPTION

# Build the URI JSON structure
URI_JSON=$(cat <<EOF
{
  "name": "$TOKEN_NAME",
  "symbol": "$TOKEN_SYMBOL",
  "description": "$TOKEN_DESCRIPTION",
  "image": "$IMAGE_URL",
  "showName": true
}
EOF
)

# Save the URI JSON to a file
URI_JSON_FILE="metadata.json"
echo "$URI_JSON" > "$URI_JSON_FILE"
echo "Metadata JSON file created: $URI_JSON_FILE"

# Upload the URI JSON file to IPFS
echo "Uploading metadata JSON file to IPFS..."
URI_CID=$(ipfs add -Q "$URI_JSON_FILE")

# Check if the upload was successful
if [[ -z "$URI_CID" ]]; then
  echo "Error: Failed to upload the metadata JSON file to IPFS."
  exit 1
fi

echo "Metadata JSON uploaded to IPFS with CID: $URI_CID"

# Display the result
echo "Image CID: $IMAGE_CID"
echo "Metadata URI CID: $URI_CID"
echo "Metadata URI: https://ipfs.io/ipfs/$URI_CID"


#!/bin/bash



TOKEN_URI="https://ipfs.io/ipfs/$URI_CID"


# Check if the URI is provided
if [[ -z "$TOKEN_URI" ]]; then
  echo "Error: No URI provided. Please enter a valid token URI."
  exit 1
fi


#  name and symbol 
NAME="$TOKEN_NAME"
SYMBOL="$TOKEN_SYMBOL"

# Output the extracted fields
echo "Name: $NAME"
echo "Symbol: $SYMBOL"


# Step 1: Create a new SPL token and capture the token mint address
echo "Creating a new SPL token..."
TOKEN_MINT=$(spl-token create-token --program-id TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb --enable-metadata --decimals 9 | grep -oP '(?<=Address:  )\w+')

# Step 2: Check if the token mint address was successfully captured
if [[ -z "$TOKEN_MINT" ]]; then
  echo "Failed to create a token or retrieve the token address."
  exit 1
fi

echo "Token Mint Address: $TOKEN_MINT"

# Step 3: Create an associated token account
echo "Creating an associated token account for the new SPL token..."
TOKEN_ACCOUNT=$(spl-token create-account "$TOKEN_MINT" | grep -oP '(?<=Creating account )\w+')

# Step 4: Check if the token account address was successfully captured
if [[ -z "$TOKEN_ACCOUNT" ]]; then
  echo "Failed to create an associated token account."
  exit 1
fi

echo "Token Account Address: $TOKEN_ACCOUNT"

# Step 5: Mint tokens to the associated account
MINT_AMOUNT=1000000000  # Change the amount as needed
echo "Minting $MINT_AMOUNT tokens to the associated account..."
spl-token mint "$TOKEN_MINT" "$MINT_AMOUNT" "$TOKEN_ACCOUNT"


# Step 6: Disable mint and freeze authority
#echo "Disabling mint and freeze authority..."
#spl-token authorize "$TOKEN_MINT" mint --disable
#spl-token authorize "$TOKEN_MINT" freeze --disable
#echo "Mint and freeze authorities disabled."

# Step 7: Initialize and upload metadata

echo "Initializing and updating metadata..."
spl-token -u mainnet-beta initialize-metadata "$TOKEN_MINT" "$NAME" "$SYMBOL" "$TOKEN_URI"

# Disable mint authority
spl-token authorize "$TOKEN_MINT" mint --disable


# Step 8: Print final output
echo "Token creation and minting process completed!"
echo "Token Mint Address: $TOKEN_MINT"
echo "Associated Token Account Address: $TOKEN_ACCOUNT"
echo "Solscan: https://solscan.io/token/$TOKEN_MINT"

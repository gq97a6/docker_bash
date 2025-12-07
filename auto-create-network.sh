#!/bin/bash

# --- Configuration ---
# Name of the file containing network names
FILE="/own/docker/networks.yml"
# Define the network prefix to check against
NETWORK_PREFIX="172.16"

# --- 1. Determine the Starting Subnet Index ---

# Get the highest used third octet (index) among all existing Docker networks 
# in the 172.16.X.0 range.
# Default to 0 if no networks in the range are found.
MAX_USED_INDEX=$(docker network ls -q | \
  xargs docker network inspect --format '{{range .IPAM.Config}}{{.Subnet}}{{end}}' 2>/dev/null | \
  grep "^${NETWORK_PREFIX}" | \
  awk -F. '{print $3}' | \
  sort -n | \
  tail -n 1)

# If no networks were found, start the counter at 1. Otherwise, start it one higher 
# than the maximum found index.
if [ -z "$MAX_USED_INDEX" ]; then
    counter=1
else
    # Start the counter at one more than the highest used index
    counter=$((MAX_USED_INDEX + 1))
fi

echo "✅ Starting subnet index for new networks: ${counter}"

# --- 2. Process File and Create Networks ---

# Read file and extract network names into an array
# Uses grep to find lines ending in -nw: and trims off surrounding characters/whitespace
network_names=($(grep -oP '.*-nw:' $FILE | tr -d ' ' | tr -d ':'))

# Check if any network names were found
if [ ${#network_names[@]} -eq 0 ]; then
    echo "❌ Error: Could not find any network names ending with '-nw:' in ${FILE}."
    exit 1
fi

# Loop through the network names and create Docker networks
for network_name in "${network_names[@]}"
do
  echo ""

  # Check if the counter is still valid
  if [ "$counter" -gt 255 ]; then
    echo "🚨 Warning: Reached the maximum subnet index (255). Stopping network creation."
    break
  fi

  # Define the new subnet
  subnet="${NETWORK_PREFIX}.${counter}.0/24"

  echo "📦 Creating network ${network_name} with subnet ${subnet}..."

  # Create a Docker network with a default driver
  docker network create --subnet="$subnet" "${network_name}"


  # Increment the counter for the next network
  counter=$((counter + 1))
done

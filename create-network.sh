#!/bin/bash

# Define the network prefix for the search range
NETWORK_PREFIX="172.16"

# 1. Ask user for name
read -p "Please enter the network name suffix (XXXXXX-nw): " name

# 2. Get all currently used third octets (indexes) for the 172.16.X.0 range
# - Filters for networks starting with 172.16.
# - Uses awk to extract the third octet (the index) from the Subnet column.
# - Sorts the list numerically and removes duplicates.
used_indexes=$(docker network ls -q | \
  xargs docker network inspect --format '{{range .IPAM.Config}}{{.Subnet}}{{end}}' 2>/dev/null | \
  grep "^${NETWORK_PREFIX}" | \
  awk -F. '{print $3}' | \
  sort -n -u)

# 3. Find the lowest unused index (starting from 1)
index=1
for used in $used_indexes; do
  if [ "$index" -lt "$used" ]; then
    # Found a gap, this is the first available index
    break
  fi
  # If the used index is the current index, check the next number
  index=$((index + 1))
done

# Check if the found index is within the valid range (1-255)
if [ "$index" -gt 255 ]; then
  echo "❌ Error: Could not find an available network index in the ${NETWORK_PREFIX}.X.0/24 range (1-255)."
  exit 1
fi

# 4. Define the new subnet
subnet="${NETWORK_PREFIX}.${index}.0/24"
network_name="${name}-nw"

echo "✅ Found first available index: ${index}"
echo "🌐 Proposed subnet: ${subnet}"
echo "📦 Creating Docker network: ${network_name}"

# 5. Create a docker network with the determined subnet
docker network create --subnet="$subnet" "$network_name"

if [ $? -eq 0 ]; then
  echo "🎉 Successfully created Docker network ${network_name} with subnet ${subnet}."
else
  echo "🚨 Failed to create Docker network."
fi

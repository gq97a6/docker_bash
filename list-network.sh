#!/bin/bash

echo "Docker Networks and Subnets:"
echo "============================"
printf "%-20s %s\n" "NETWORK NAME" "SUBNET"
printf "%-20s %s\n" "------------" "------"

# Get all network names and loop through them
for network in $(docker network ls --format "{{.Name}}"); do
    # Get the subnet for each network
    subnet=$(docker network inspect "$network" --format '{{range .IPAM.Config}}{{.Subnet}}{{end}}' 2>/dev/null)
    
    # Only show networks that have a subnet
    if [ ! -z "$subnet" ]; then
        printf "%-20s %s\n" "$network" "$subnet"
    fi
done

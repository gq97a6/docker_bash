#!/bin/bash

# Definition: This script prints the Container Name, IP, and the Host Network Interface (Bridge) 
# for all running containers.

printf "%-30s %-20s %-20s\n" "CONTAINER NAME" "IP ADDRESS" "BRIDGE INTERFACE"

# Iterate through running containers
docker ps --format '{{.ID}} {{.Names}}' | while read -r c_id c_name; do
    
    # Extract Network Name, IP, and Network ID string for the container
    # Delimiter is pipe '|'
    net_data=$(docker inspect "$c_id" --format '{{range $k, $v := .NetworkSettings.Networks}}{{$k}}|{{.IPAddress}}|{{.NetworkID}} {{end}}')

    for net in $net_data; do
        name=$(echo "$net" | cut -d'|' -f1)
        ip=$(echo "$net" | cut -d'|' -f2)
        net_id=$(echo "$net" | cut -d'|' -f3)

        # Retrieve the specific bridge name
        # 1. Check if explicitly defined in options
        bridge=$(docker network inspect "$net_id" --format '{{index .Options "com.docker.network.bridge.name"}}')

        # 2. Fallback conventions if name is not explicitly set
        if [ -z "$bridge" ]; then
            if [ "$name" == "bridge" ]; then
                bridge="docker0"
            elif [ "$name" == "host" ]; then
                bridge="host"
            elif [ "$name" == "none" ]; then
                bridge="null"
            else
                # Default behavior for custom networks: br-<first 12 chars of ID>
                bridge="br-${net_id:0:12}"
            fi
        fi

        printf "%-30s %-20s %-20s\n" "$c_name" "$ip" "$bridge"
    done
done

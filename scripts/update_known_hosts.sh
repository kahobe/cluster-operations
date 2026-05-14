#!/bin/bash

# List your hosts here (space-separated or newline-separated)
VM_HOSTS=(vm1 vm2 vm3)
RPI_HOSTS=(rpi1 rpi2 rpi3)

HOSTS=("${VM_HOSTS[@]}")


# Path to your known_hosts file
KNOWN_HOSTS="$HOME/.ssh/known_hosts"

# Ensure .ssh directory exists
mkdir -p "$(dirname "$KNOWN_HOSTS")"
chmod 700 "$(dirname "$KNOWN_HOSTS")"

echo "Adding SSH host keys to $KNOWN_HOSTS"
echo "Hosts: ${HOSTS[@]}"

for host in "${HOSTS[@]}"; do
  echo ""
  echo "$host ---------------------------------------------"
  # Resolve IP address
  IP=$(getent ahosts "$host" | awk '/STREAM/ {print $1; exit}')

  # Check if IP was resolvable
  if [[ -z "$IP" ]]; then
    echo "Could not resolve IP for $host — skipping IP entry."
  else
    echo "Resolved $host -> $IP"
  fi

  # Add Hostname to known_hosts
  if ssh-keygen -F "$host" > /dev/null; then
    echo "$host already present in known_hosts — removing it."
    ssh-keygen -R "$host" > /dev/null
  fi
  
  if ssh-keyscan -H "$host" >> "$KNOWN_HOSTS" 2>/dev/null; then
    echo "Added $host to known_hosts."
  else
    echo "Failed to retrieve key for $host."
  fi
  

  # Add IP to known_hosts, if available
  if [[ -n "$IP" ]]; then
    if ssh-keygen -F "$IP" > /dev/null; then
      echo "IP $IP already present in known_hosts — removing it."
      ssh-keygen -R "$IP" > /dev/null
    fi
    
    if ssh-keyscan -H "$IP" >> "$KNOWN_HOSTS" 2>/dev/null; then
        echo "Added IP $IP to known_hosts."
    else
        echo "Failed to retrieve key for IP $IP."
    fi
    
  fi
done

printf "\nDone.\n"

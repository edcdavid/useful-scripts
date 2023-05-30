#!/bin/bash
ip_file="$1"
cidr_block=$2 # CIDR block

# Read the IP addresses from the file
ips=$(cat "$ip_file")

# Extract unique IP addresses using regex
taken_ips_string=$(echo "$ips" | grep -E -o "([0-9]{1,3}\.){3}[0-9]{1,3}" | sort -u)

# Output the unique IP addresses
echo "already taken IPs: "
echo "$taken_ips_string"

# Declare an empty array
taken_ips_array=()

# Read the string into the array
readarray -t taken_ips_array <<<"$taken_ips_string"

# Function to calculate the list of available IP addresses
get_available_ips() {
  taken_ips_array=("$@") # Accept the already taken IP addresses as arguments

  # Extract the network and prefix length from the CIDR block
  network=$(echo "$cidr_block" | cut -d'/' -f1)
  prefix_length=$(echo "$cidr_block" | cut -d'/' -f2)

  cidr_ips_string=$(nmap -sL -n 192.168.28.0/25 | awk '/Nmap scan report/{print $NF}')
  # Declare an empty array
  cidr_ips_array=()

  # Read the string into the array
  readarray -t cidr_ips_array <<<"$cidr_ips_string"

  for ip in "${cidr_ips_array[@]}"; do
    # Check if the IP address is not in the list of taken IPs
    if [[ ! " ${taken_ips_array[@]} " =~ " ${ip} " ]]; then
      echo "$ip" # Print the available IP address
    fi
  done
}

# Call the function to get the available IP addresses
available_ips=$(get_available_ips "${taken_ips_array[@]}")

# Print the list of available IP addresses
echo "Available IP addresses:"
for ip in ${available_ips[@]}; do
  echo "$ip"
done

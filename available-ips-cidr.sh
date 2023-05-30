#!/bin/bash
ip_file="$1"
cidr_block=$2 # CIDR block

if [ $# -eq 0 ]; then
  printf "avialable-ips: missing parameter. Calculates the remaining ip addresses in a CIDR from a file containing ip addresses that are already taken.\nUsage: available-ips.sh <file with list of ip addresses> <cidr>\n"
  exit 1
fi

# Read the IP addresses from the file
ips=$(cat "$ip_file")

# Extract unique IP addresses using regex
taken_ips_string=$(printf "$ips" | grep -E -o "([0-9]{1,3}\.){3}[0-9]{1,3}" | sort -u)

# Output the unique IP addresses
printf "Already taken IPs:\n"
printf "$taken_ips_string"

# Declare an empty array
taken_ips_array=()
readarray -t taken_ips_array <<<"$taken_ips_string"

# Function to calculate the list of available IP addresses
get_available_ips() {
  taken_ips_array=("$@") # Accept the already taken IP addresses as arguments

  # Extract the network and prefix length from the CIDR block
  network=$(printf "$cidr_block" | cut -d'/' -f1)
  prefix_length=$(printf "$cidr_block" | cut -d'/' -f2)

  cidr_ips_string=$(nmap -sL -n $cidr_block | awk '/Nmap scan report/{print $NF}')
  # Declare an empty array
  cidr_ips_array=()

  # Read the string into the array
  readarray -t cidr_ips_array <<<"$cidr_ips_string"

  for ip in "${cidr_ips_array[@]}"; do
    # Check if the IP address is not in the list of taken IPs
    if [[ ! " ${taken_ips_array[@]} " =~ " ${ip} " ]]; then
      printf "%s\n" $ip # Print the available IP address
    fi
  done
}

printf "\nAvailable IPs:\n"
# Call the function to get the available IP addresses
get_available_ips "${taken_ips_array[@]}"

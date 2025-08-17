#!/bin/bash

# iDRAC8 Fan Control Script
# WARNING: Manual fan control can cause overheating and hardware damage!
# Always monitor temperatures when using this script.

# Configuration - Update these with your iDRAC details
IDRAC_IP=""
USERNAME=""
PASSWORD=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_color() {
    echo -e "${1}${2}${NC}"
}

# Function to validate ipmitool is installed
check_ipmitool() {
    if ! command -v ipmitool &> /dev/null; then
        print_color $RED "Error: ipmitool is not installed or not in PATH"
        exit 1
    fi
}

# Function to get iDRAC credentials if not set
get_credentials() {
    if [ -z "$IDRAC_IP" ]; then
        read -p "Enter iDRAC IP address: " IDRAC_IP
    fi
    
    if [ -z "$USERNAME" ]; then
        read -p "Enter iDRAC username: " USERNAME
    fi
    
    if [ -z "$PASSWORD" ]; then
        read -s -p "Enter iDRAC password: " PASSWORD
        echo
    fi
}

# Function to convert percentage to hex
percent_to_hex() {
    local percent=$1
    printf "%02x" $percent
}

# Function to test iDRAC connection
test_connection() {
    print_color $BLUE "Testing iDRAC connection..."
    
    if ! ipmitool -I lanplus -H "$IDRAC_IP" -U "$USERNAME" -P "$PASSWORD" chassis status &>/dev/null; then
        print_color $RED "Error: Cannot connect to iDRAC. Please check IP, username, and password."
        exit 1
    fi
    
    print_color $GREEN "iDRAC connection successful!"
}

# Function to show current fan status
show_fan_status() {
    print_color $BLUE "Current fan status:"
    ipmitool -I lanplus -H "$IDRAC_IP" -U "$USERNAME" -P "$PASSWORD" sdr type fan
    echo
}

# Function to enable manual fan control
enable_manual_control() {
    print_color $YELLOW "Enabling manual fan control..."
    
    if ipmitool -I lanplus -H "$IDRAC_IP" -U "$USERNAME" -P "$PASSWORD" raw 0x30 0x30 0x01 0x00 &>/dev/null; then
        print_color $GREEN "Manual fan control enabled successfully!"
    else
        print_color $RED "Error: Failed to enable manual fan control"
        exit 1
    fi
}

# Function to set fan speed
set_fan_speed() {
    local percentage=$1
    local hex_value=$(percent_to_hex $percentage)
    
    print_color $YELLOW "Setting all fans to ${percentage} percent (0x${hex_value})..."
    
    if ipmitool -I lanplus -H "$IDRAC_IP" -U "$USERNAME" -P "$PASSWORD" raw 0x30 0x30 0x02 0xff 0x$hex_value &>/dev/null; then
        print_color $GREEN "Fan speed set to ${percentage} percent successfully!"
    else
        print_color $RED "Error: Failed to set fan speed"
        exit 1
    fi
}

# Function to return to automatic control
enable_auto_control() {
    print_color $YELLOW "Returning to automatic fan control..."
    
    if ipmitool -I lanplus -H "$IDRAC_IP" -U "$USERNAME" -P "$PASSWORD" raw 0x30 0x30 0x01 0x01 &>/dev/null; then
        print_color $GREEN "Automatic fan control restored!"
    else
        print_color $RED "Warning: Failed to restore automatic fan control"
    fi
}

# Main script
main() {
    print_color $BLUE "=== iDRAC8 Fan Control Script ==="
    print_color $RED "WARNING: This script can cause overheating and hardware damage!"
    print_color $RED "Always monitor temperatures and use with caution."
    print_color $YELLOW "NOTE: Manual fan settings will persist after script exit."
    print_color $YELLOW "Use option 2 to return to automatic control before exiting if needed."
    echo
    
    # Check prerequisites
    check_ipmitool
    get_credentials
    test_connection
    
    # Show current status
    show_fan_status
    
    while true; do
        echo
        print_color $BLUE "Fan Control Options:"
        echo "1) Set manual fan speed"
        echo "2) Return to automatic control"
        echo "3) Show current fan status"
        echo "4) Exit"
        echo
        
        read -p "Select option (1-4): " choice
        
        case $choice in
            1)
                echo
                read -p "Enter fan speed percentage (0-100): " fan_speed
                
                # Validate input
                if ! [[ "$fan_speed" =~ ^[0-9]+$ ]] || [ "$fan_speed" -lt 0 ] || [ "$fan_speed" -gt 100 ]; then
                    print_color $RED "Error: Please enter a valid percentage (0-100)"
                    continue
                fi
                
                # Safety warning for low speeds
                if [ "$fan_speed" -lt 30 ]; then
                    print_color $RED "WARNING: Setting fans below 30 percent can cause overheating!"
                    read -p "Are you sure you want to continue? (y/N): " confirm
                    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
                        print_color $YELLOW "Operation cancelled."
                        continue
                    fi
                fi
                
                enable_manual_control
                set_fan_speed $fan_speed
                ;;
            2)
                enable_auto_control
                sleep 2
                show_fan_status
                ;;
            3)
                show_fan_status
                ;;
            4)
                print_color $GREEN "Exiting..."
                exit 0
                ;;
            *)
                print_color $RED "Invalid option. Please select 1-4."
                ;;
        esac
    done
}

# Run the script
main

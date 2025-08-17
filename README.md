# iDRAC8 Fan Control Script

A bash script for manually controlling fan speeds on Dell PowerEdge servers with iDRAC using IPMI commands.

## Important Safety Warning

**This script can cause overheating and permanent hardware damage if used improperly!**

- Always monitor system temperatures when using manual fan control
- Never set fan speeds below 30% without careful temperature monitoring
- Dell servers may override manual settings if temperatures become dangerous
- Use at your own risk - the authors are not responsible for any hardware damage

## Features

- **Interactive menu** for easy fan control
- **Safety warnings** for potentially dangerous low fan speeds
- **Real-time fan status** display showing RPM for all fans
- **Easy toggle** between manual and automatic fan control
-  **Input validation** to prevent invalid speed settings
- **Color-coded output** for better readability
- **Connection testing** before attempting fan control
- **Persistent settings** - fan speeds remain after script exit

## Prerequisites

### Software Requirements
- `ipmitool` - IPMI management utility
- `bash` - Bash shell (version 4.0 or higher recommended)
- Network access to your iDRAC interface

### Install ipmitool

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install ipmitool
```

**CentOS/RHEL/Rocky Linux:**
```bash
sudo yum install ipmitool
# or for newer versions:
sudo dnf install ipmitool
```

**macOS:**
```bash
brew install ipmitool
```

### Hardware Requirements
- Dell PowerEdge server with iDRAC (tested with iDRAC8)
- Network connectivity between your computer and the iDRAC interface
- Valid iDRAC credentials with administrative privileges

## Installation

1. **Download the script:**
   ```bash
   curl -O https://raw.githubusercontent.com/Darkhand81/idrac_fan_control/refs/heads/main/fan_control.sh
   ```
   Or save the script manually as fan_control.sh

2. **Make it executable:**
   ```bash
   chmod +x fan_control.sh
   ```

3. **Optional: Configure default credentials** (edit the script):
   ```bash
   nano fan_control.sh
   ```
   Update these variables at the top:
   ```bash
   IDRAC_IP="192.168.1.100"    # Your iDRAC IP
   USERNAME="root"             # Your iDRAC username
   PASSWORD="your_password"    # Your iDRAC password
   ```

## Usage

### Basic Usage
```bash
./fan_control.sh
```

### Menu Options

The script provides an interactive menu with the following options:

1. **Set manual fan speed** - Set all fans to a specific percentage (0-100%)
2. **Return to automatic control** - Restore Dell's automatic fan management
3. **Show current fan status** - Display current RPM and status for all fans
4. **Exit** - Exit the script (manual settings persist)

### Example Session
```
=== iDRAC8 Fan Control Script ===
WARNING: This script can cause overheating and hardware damage!
Always monitor temperatures and use with caution.
NOTE: Manual fan settings will persist after script exit.
Use option 2 to return to automatic control before exiting if needed.

Enter iDRAC IP address: 192.168.1.87
Enter iDRAC username: root
Enter iDRAC password: [hidden]
Testing iDRAC connection...
iDRAC connection successful!

Current fan status:
Fan1             | 30h | ok  |  7.1 | 10800 RPM
Fan2             | 31h | ok  |  7.1 | 10800 RPM
Fan3             | 32h | ok  |  7.1 | 10800 RPM
Fan4             | 33h | ok  |  7.1 | 10680 RPM
Fan5             | 34h | ok  |  7.1 | 10800 RPM
Fan6             | 35h | ok  |  7.1 | 10800 RPM

Fan Control Options:
1) Set manual fan speed
2) Return to automatic control
3) Show current fan status
4) Exit

Select option (1-4): 1
Enter fan speed percentage (0-100): 35
```

## Configuration

### Credential Configuration

You can configure credentials in three ways:

1. **Edit the script** (most convenient for repeated use):
   ```bash
   IDRAC_IP="192.168.1.100"
   USERNAME="root"
   PASSWORD="calvin"  # Default Dell password
   ```

2. **Environment variables:**
   ```bash
   export IDRAC_IP="192.168.1.100"
   export IDRAC_USER="root"
   export IDRAC_PASS="calvin"
   ./fan_control.sh
   ```

3. **Interactive prompts** (leave variables empty in script)

### Fan Speed Guidelines

| Percentage | Use Case | Noise Level | Cooling |
|------------|----------|-------------|---------|
| 100% | Maximum cooling, stress testing | Very loud | Excellent |
| 60-80% | High-performance workloads | Loud | Very good |
| 40-50% | Normal server operations | Moderate | Good |
| 30-35% | Quiet home lab, light workloads | Quiet | Adequate |
| 20-25% | Very quiet, minimal load only | Very quiet | Minimal |
| <20% | **Not recommended** | Silent | **Dangerous** |

## Technical Details

### IPMI Commands Used

The script uses these raw IPMI commands:

- **Enable manual control:** `0x30 0x30 0x01 0x00`
- **Set fan speed:** `0x30 0x30 0x02 0xff 0x[hex_percentage]`
- **Return to auto:** `0x30 0x30 0x01 0x01`

### Percentage to Hex Conversion

| Percentage | Hex Value |
|------------|-----------|
| 0% | 0x00 |
| 25% | 0x19 |
| 50% | 0x32 |
| 75% | 0x4B |
| 100% | 0x64 |

### Supported Hardware

This script is designed for Dell PowerEdge servers with iDRAC, including:
- PowerEdge R320, R420, R520, R620, R720, R720xd, R730
- PowerEdge R820, R920
- PowerEdge T320, T420, T620
- Other Dell servers with iDRAC (may require testing)

## Troubleshooting

### Common Issues

**Connection Failed:**
```
Error: Cannot connect to iDRAC. Please check IP, username, and password.
```
- Verify iDRAC IP address is correct and reachable
- Check username and password
- Ensure iDRAC is powered on and network is configured
- Try accessing iDRAC web interface to confirm connectivity

**Permission Denied:**
```
Error: Failed to enable manual fan control
```
- Ensure your user account has administrative privileges on iDRAC
- Try using the root account
- Check if another management session is active

**ipmitool Not Found:**
```
Error: ipmitool is not installed or not in PATH
```
- Install ipmitool using your system's package manager
- Verify installation: `which ipmitool`

**Fans Not Responding:**
- Wait 10-15 seconds for fans to adjust to new speed
- Check fan status manually using option 3
- Some iDRAC versions may override manual control after time
- Verify manual control is still enabled

### Manual IPMI Commands

For troubleshooting, you can run IPMI commands directly:

```bash
# Check current fan status
ipmitool -I lanplus -H <ip> -U <user> -P <pass> sdr type fan

# Enable manual control
ipmitool -I lanplus -H <ip> -U <user> -P <pass> raw 0x30 0x30 0x01 0x00

# Set 50% speed (0x32)
ipmitool -I lanplus -H <ip> -U <user> -P <pass> raw 0x30 0x30 0x02 0xff 0x32

# Return to automatic
ipmitool -I lanplus -H <ip> -U <user> -P <pass> raw 0x30 0x30 0x01 0x01
```

## Best Practices

### Temperature Monitoring
- Monitor CPU and system temperatures regularly
- Use Dell's thermal monitoring tools
- Set up temperature alerts if available
- Have a plan to quickly restore automatic control

### Recommended Usage
- Start with higher percentages (50%+) and work down
- Test during low system load first
- Monitor for several hours before leaving unattended
- Document your optimal settings for different workloads

### Automation
For automated fan control, consider:
- Cron jobs to adjust fans based on temperature
- Integration with monitoring systems
- Scripts that respond to thermal events

## Contributing

Contributions welcome! Please:
- Test on your hardware before submitting
- Update documentation for new features
- Follow existing code style
- Include safety warnings for new functionality

## Disclaimer

**Use at your own risk!** This script directly controls server hardware and can cause:
- Overheating and permanent damage
- Data loss from system shutdowns
- Voided warranties
- Fire hazards in extreme cases

Not responsible for any damage caused by this script. Always monitor temperatures and use appropriate safety measures.

#!/bin/bash
set -euo pipefail

#List all available Drives
echo "[init] List all drives by ID (without partitions)"
echo "-----------------------------------"
ls -l /dev/disk/by-id/ | grep -v 'eui\.' | grep -v -- '-part[0-9]'
echo "-----------------------------------"

# Define a variable to hold the list of modules
COMMANDS=$(sensors-detect --auto | sed -n '/# Chip drivers/,/#----cut here----/{//!p;}')

# Check if the COMMANDS variable is not empty before trying to execute it.
if [ -z "$COMMANDS" ]; then
    echo "No commands were extracted from 'sensors-detect --auto'."
    exit 1
else
    echo "The following commands will be run:"
    echo "-----------------------------------"
    echo "$COMMANDS"
    echo "-----------------------------------"
    # Read each line from the COMMANDS variable and execute it
    echo "$COMMANDS" | while read -r cmd; do
        if [ -n "$cmd" ]; then
            stdbuf -oL sh -c "$cmd" 2>&1 | sed 's/^/[init] /' &
        fi
    done

    wait
    echo "[init] All sensors-detect commands were run successfully."
fi

# list all pwm enabled fans
echo "[init] List all fans that have pwm*_enable."
echo "-----------------------------------"
find /sys/class/hwmon/ -name 'pwm*_enable'
echo "-----------------------------------"


if [ -z "$PWM" ]; then
    echo "[init] PWM Fan config is missing. Startup is stopped. "
    echo "[init] You can now attach the the containers shell and run pwmconfig or hddfancontrol pwm-test"
    tail -f /dev/null
else
    echo "[init] Fans already defined, starting hddfancontrol"
fi


# Create argument array for hddfancontrol
declare -a hddfancontrol_args=()
[[ -n ${DRIVES:-} ]] && hddfancontrol_args+=(--drives "$DRIVES")
[[ -n ${PWM:-} ]] && hddfancontrol_args+=(--pwm "$PWM")
[[ -n ${DRIVE_TEMP_RANGE:-} ]] && hddfancontrol_args+=(--drive-temp-range ${DRIVE_TEMP_RANGE})
[[ -n ${MIN_FAN_SPEED_PRCT:-} ]] && hddfancontrol_args+=(--min-fan-speed-prct "$MIN_FAN_SPEED_PRCT")
[[ -n ${INTERVAL:-} ]] && hddfancontrol_args+=(--interval "$INTERVAL")
[[ -n ${HWMONS:-} ]] && hddfancontrol_args+=(--hwmons "$HWMONS")
[[ -n ${RESTORE_FAN_SETTINGS:-} ]] && hddfancontrol_args+=(--restore-fan-settings)

stdbuf -oL hddfancontrol -v "${VERBOSITY:-INFO}" daemon "${hddfancontrol_args[@]}" 2>&1 | sed 's/^/[hddfancontrol] /' &

# Create argument array for hd-idle
declare -a hdidle_args=()
if [[ -n "${VERBOSITY:-}" ]]; then
    hdidle_args+=(-d)
fi
[[ -n ${SPIN_DOWN_TIME_S:-} ]] && hdidle_args+=(-i "$SPIN_DOWN_TIME_S")
if [[ -n "${DRIVES:-}" ]]; then
    for drive in $DRIVES; do
        hdidle_args+=(-a "$drive")
        hdidle_args+=(-c ata)
    done
fi


stdbuf -oL hd-idle "${hdidle_args[@]}" 2>&1 | sed 's/^/[hd-idle] /' &

# Wait for either process to exit
wait -n

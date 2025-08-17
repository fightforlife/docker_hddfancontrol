#!/bin/bash
#set -euo pipefail

# Define a variable to hold the list of modules
MODULES=$(sensors-detect --auto | sed -n '/# Chip drivers/,/#----cut here----/{//!p;}')

# Check if any modules were detected
if [ -z "$MODULES" ]; then
    echo "No sensor modules detected. Exiting."
    exit 1
fi

echo "Detected modules: $MODULES"

# Loop through each module and load it, providing feedback
for module in $MODULES; do
    echo "Attempting to load module: $module"
    if modprobe "$module"; then
        echo "Successfully loaded $module"
    else
        echo "Error: Failed to load $module"
    fi
done


# Create argument array
declare -a hddfancontrol_args=()
[[ -n ${DRIVES:-} ]] && hddfancontrol_args+=(--drives "$DRIVES")
[[ -n ${PWM:-} ]] && hddfancontrol_args+=(--pwm "$PWM")
[[ -n ${DRIVE_TEMP_RANGE:-} ]] && hddfancontrol_args+=(--drive_temp_range "$DRIVE_TEMP_RANGE")
[[ -n ${MIN_FAN_SPEED_PRCT:-} ]] && hddfancontrol_args+=(--min_fan_speed_prct "$MIN_FAN_SPEED_PRCT")
[[ -n ${INTERVAL:-} ]] && hddfancontrol_args+=(--interval "$INTERVAL")
[[ -n ${HWMONS:-} ]] && hddfancontrol_args+=(--hwmons "$HWMONS")
[[ -n ${RESTORE_FAN_SETTINGS:-} ]] && hddfancontrol_args+=(--restore_fan_settings "$RESTORE_FAN_SETTINGS")


stdbuf -oL hddfancontrol -v "${VERBOSITY:-INFO}" daemon "${hddfancontrol_args[@]}" 2>&1 | sed 's/^/[hddfancontrol] /' &


# Create argument array
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

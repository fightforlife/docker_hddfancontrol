#!/bin/bash
set -euo pipefail

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


    # Wait for all background jobs to complete
    wait

    # Print a success message after all commands have run
    echo "[init] All sensors-detect commands were run successfully."
fi

# Create argument array
declare -a hddfancontrol_args=()
[[ -n ${DRIVES:-} ]] && hddfancontrol_args+=(--drives "$DRIVES")
[[ -n ${PWM:-} ]] && hddfancontrol_args+=(--pwm "$PWM")
[[ -n ${DRIVE_TEMP_RANGE:-} ]] && hddfancontrol_args+=(--drive-temp-range ${DRIVE_TEMP_RANGE})
[[ -n ${MIN_FAN_SPEED_PRCT:-} ]] && hddfancontrol_args+=(--min-fan-speed-prct "$MIN_FAN_SPEED_PRCT")
[[ -n ${INTERVAL:-} ]] && hddfancontrol_args+=(--interval "$INTERVAL")
[[ -n ${HWMONS:-} ]] && hddfancontrol_args+=(--hwmons "$HWMONS")
[[ -n ${RESTORE_FAN_SETTINGS:-} ]] && hddfancontrol_args+=(--restore-fan-settings)

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

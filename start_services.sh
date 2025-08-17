#!/bin/bash
set -euo pipefail

# Create argument array
declare -a hddfancontrol_args=()
[[ -n ${DRIVE_FILEPATHS:-} ]] && hddfancontrol_args+=(--drives "$DRIVE_FILEPATHS")
[[ -n ${FAN_PWM_FILEPATH:-} ]] && hddfancontrol_args+=(--pwm "$FAN_PWM_FILEPATH")
[[ -n ${MIN_TEMP:-} && -n ${MAX_TEMP:-} ]] && hddfancontrol_args+=(--drive_temp_range "$MIN_TEMP" "$MAX_TEMP")
[[ -n ${MIN_FAN_SPEED_PRCT:-} ]] && hddfancontrol_args+=(--min_fan_speed_prct "$MIN_FAN_SPEED_PRCT")
[[ -n ${INTERVAL:-} ]] && hddfancontrol_args+=(--interval "$INTERVAL")
[[ -n ${HWMONS:-} ]] && hddfancontrol_args+=(--hwmons "$HWMONS")
[[ -n ${RESTORE_FANS:-} ]] && hddfancontrol_args+=(--restore_fan_settings "$RESTORE_FANS")


stdbuf -oL hddfancontrol -v "${VERBOSITY:-INFO}" daemon "${hddfancontrol_args[@]}" 2>&1 | sed 's/^/[hddfancontrol] /' &


# Create argument array
declare -a hdidle_args=()
[[ -n ${SPIN_DOWN_TIME_S:-} ]] && hdidle_args+=(-i "$SPIN_DOWN_TIME_S")
if [[ -n "${DRIVE_FILEPATHS:-}" ]]; then
    for drive in $DRIVE_FILEPATHS; do
        hdidle_args+=(-a "$drive")
        hdidle_args+=(-c ata)
    done
fi


stdbuf -oL hd-idle "${hdidle_args[@]}" 2>&1 | sed 's/^/[hd-idle] /' &

# Wait for either process to exit
wait -n

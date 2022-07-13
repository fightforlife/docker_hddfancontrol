#!/bin/bash

#detect sensors and load modules
sensors-detect --auto | sed -n '/# Chip drivers/,/#----cut here----/{//!p;}' | xargs -n1 modprobe

#create argument array
declare -a args=()

[[ ! -z $DEVICES ]] && args+=(--drives $DEVICES)
[[ ! -z $PWM_DEVICES ]] && args+=(--pwm $PWM_DEVICES)
[[ ! -z $PWM_START ]] && args+=(--pwm-start-value $PWM_START)
[[ ! -z $PWM_STOP ]] && args+=(--pwm-stop-value $PWM_STOP)
[[ ! -z $MIN_TEMP ]] && args+=(--min-temp $MIN_TEMP)
[[ ! -z $MAX_TEMP ]] && args+=(--max-temp $MAX_TEMP)
[[ ! -z $MIN_FAN ]] && args+=(--min-fan-speed-prct $MIN_FAN)
[[ ! -z $INTERVALL ]] && args+=(-i $INTERVALL)
[[ ! -z $TEMP_QUERY_MODE ]] && args+=(--$TEMP_QUERY_MODE)
[[ ! -z $SPINDOWN_TIME ]] && args+=(--spin-down-time $SPINDOWN_TIME)
[[ ! -z $LOG_PATH ]] && args+=(-l $LOG_PATH)
[[ ! -z $CPU_TEMP_PROBE ]] && args+=(--cpu-sensor $CPU_TEMP_PROBE)
[[ ! -z $CPU_TEMP_RANGE ]] && args+=(--cpu-temp-range $CPU_TEMP_RANGE)

echo ${args[@]}

hddfancontrol ${args[@]} &

# Wait for any process to exit
wait -n
  
# Exit with status of process that exited first
exit $?

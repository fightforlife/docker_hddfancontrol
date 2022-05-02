#!/bin/bash

#detect sensors and load modules
sensors-detect --auto | sed -n '/# Chip drivers/,/#----cut here----/{//!p;}' | xargs -n1 modprobe

#create argument array
args=()

args+=(-d $DEVICES)
args+=(-p $PWM_DEVICES)
args+=(--pwm-start-value $PWM_START)
args+=(--pwm-stop-value $PWM_STOP)
args+=(--min-temp $MIN_TEMP)
args+=(--max-temp $MAX_TEMP)
args+=(--min-fan-speed-prct $MIN_FAN)
args+=(-i $INTERVALL)
args+=(--$TEMP_QUERY_MODE)
args+=(--spin-down-time $SPINDOWN_TIME)
args+=(-l $LOG_PATH)


hddfancontrol "${params[@]}" &

# Wait for any process to exit
wait -n
  
# Exit with status of process that exited first
exit $?

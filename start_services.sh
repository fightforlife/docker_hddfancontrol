#!/bin/bash

#detect sensors and load modules
sensors-detect --auto | sed -n '/# Chip drivers/,/#----cut here----/{//!p;}' | xargs -n1 modprobe

#create argument array
declare -a args=()

[[ ! -z $DRIVE_FILEPATHS ]] && args+=(--drives $DRIVE_FILEPATHS)
[[ ! -z $FAN_PWM_FILEPATH ]] && args+=(--pwm $FAN_PWM_FILEPATH)
[[ ! -z $FAN_START_VALUE ]] && args+=(--pwm-start-value $FAN_START_VALUE)
[[ ! -z $FAN_STOP_VALUE ]] && args+=(--pwm-stop-value $FAN_STOP_VALUE)
[[ ! -z $MIN_TEMP ]] && args+=(--min-temp $MIN_TEMP)
[[ ! -z $MAX_TEMP ]] && args+=(--max-temp $MAX_TEMP)
[[ ! -z $MIN_FAN_SPEED_PRCT ]] && args+=(--min-fan-speed-prct $MIN_FAN_SPEED_PRCT)
[[ ! -z $INTERVAL_S ]] && args+=(-i $INTERVAL_S)
[[ ! -z $CPU_PROBE_FILEPATH ]] && args+=(--cpu-sensor $CPU_PROBE_FILEPATH)
[[ ! -z $CPU_TEMP_RANGE ]] && args+=(--cpu-temp-range $CPU_TEMP_RANGE)
[[ ! -z $SPIN_DOWN_TIME_S ]] && args+=(--spin-down-time $SPIN_DOWN_TIME_S)
[[ ! -z $VERBOSITY ]] && args+=(--verbosity $VERBOSITY) #warning,normal,debug
[[ ! -z $LOG_FILEPATH ]] && args+=(--log-file $LOG_FILEPATH) 
[[ ! -z $TEMP_QUERY_MODE ]] && args+=(--$TEMP_QUERY_MODE) #hddtemp,hddtemp-daemon,hdparm,drivetemp,smartctl 


echo ${args[@]}

hddfancontrol ${args[@]} &

# Wait for any process to exit
wait -n
  
# Exit with status of process that exited first
exit $?

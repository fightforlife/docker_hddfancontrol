#!/bin/bash

#detect sensors and load modules
sensors-detect --auto | sed -n '/# Chip drivers/,/#----cut here----/{//!p;}' | xargs -n1 modprobe

hddfancontrol -d $DEVICES  \
              -p $PWM_DEVICES \
              --pwm-start-value $PWM_START \
              --pwm-stop-value $PWM_STOP \
              --min-temp $MIN_TEMP \
              --max-temp $MAX_TEMP \
              --min-fan-speed-prct $MIN_FAN \
              -i $INTERVALL \
if [ -z $SPINDOWN_TIME ]
then
              --spin-down-time $SPINDOWN_TIME \
fi
              --$TEMP_QUERY_MODE \
if [ -z $LOG_PATH ]
then
              -l $LOG_PATH \
fi
              &
  
# Wait for any process to exit
wait -n
  
# Exit with status of process that exited first
exit $?

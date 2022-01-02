#!/bin/bash

#detect sensors and load modules
sensors-detect --auto | sed -n '/# Chip drivers/,/#----cut here----/{//!p;}' | xargs -n1 modprobe

hddfancontrol $1 &
  
# Wait for any process to exit
wait -n
  
# Exit with status of process that exited first
exit $?

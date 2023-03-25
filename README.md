# docker_hddfancontrol
simple Docker image for hddfancontrol by desbma
https://github.com/desbma/hddfancontrol

This is a docker image which includes the following programs to run **hddfancontrol** by desbma.
- smartmontools - needed for the --smartctl option, which uses smartmontolls instead of hdparm to spindown drives
- hdparm - old way of spinning down drives
- hddtemp - to get hddtemps
- fancontrol - to control PWM fan speed
- lm-sensors - package for pwm sensor detect

### Docker compose
- currently privbiliged mode is used, since I didnt find an easy way to bind the sysfs hwmon instances 
- all ENV variables are optional, but hddfancontrol will complain when something important is missing.
```
version: "3"
services:
  hddfancontrol:
    image: ghcr.io/fightforlife/docker_hddfancontrol:master
    restart: unless-stopped
    volumes:
      - /lib/modules:/lib/modules:ro
    privileged: true
    cap_add:
      - SYS_MODULE
    environment:
      - DRIVE_FILEPATHS=/dev/sdb1 /dev/sdc1 /dev/sdd1
      - FAN_PWM_FILEPATH=/sys/class/hwmon/hwmon2/pwm1 /sys/class/hwmon/hwmon2/pwm2
      - FAN_START_VALUE=70 80
      - FAN_STOP_VALUE=20 30
      - MIN_TEMP=40
      - MAX_TEMP=60
      - MIN_FAN_SPEED_PRCT=0
      - INTERVAL_S=60
      - CPU_PROBE_FILEPATH=/sys/devices/platform/coretemp.0/hwmon/hwmon0/tempY_input
      - CPU_TEMP_RANGE=50 70
      - SPIN_DOWN_TIME_S=900
      - VERBOSITY=debug
      - LOG_FILEPATH=/var/log/hddfancontrol.log
      - TEMP_QUERY_MODE=smartctl  #hddtemp,hdparm,drivetemp,smartctl 
      
      
```

### ToDo
- [X] Split the $ARGS environment variable into the individual configuration paramters
- [ ] Find a way to get rid of the priviliged mode and use the devices directly
- [X] incoperate lm-sensors into the container including the kernel modules
- [ ] run and expose hddtemp daemon
- [X] make way of fetching temp a config


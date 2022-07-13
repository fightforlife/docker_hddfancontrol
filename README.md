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
    image: fred92/hddfancontrol:master
    restart: unless-stopped
    volumes:
      - /lib/modules:/lib/modules:ro
    privileged: true
    cap_add:
      - SYS_MODULE
    environment:
      - DEVICES=/dev/sdb1 /dev/sdc1 /dev/sdd1
      - PWM_DEVICES=/sys/class/hwmon/hwmon2/pwm1 /sys/class/hwmon/hwmon2/pwm2
      - PWM_START=70 80
      - PWM_STOP=20 30
      - MIN_TEMP=40
      - MAX_TEMP=60
      - MIN_FAN=0
      - INTERVALL=10  (should be low if CPU is included)
      - SPINDOWN_TIME=900
      - TEMP_QUERY_MODE=smartctl
      - LOG_PATH=/var/log/hddfancontrol.log
      - CPU_TEMP_RANGE=45 60
      - CPU_TEMP_PROBE=/sys/devices/platform/coretemp.0/hwmon/hwmon1/temp1_input
      
```

### ToDo
- [X] Split the $ARGS environment variable into the individual configuration paramters
- [ ] Find a way to get rid of the priviliged mode and use the devices directly
- [X] incoperate lm-sensors into the container including the kernel modules
- [ ] run and expose hddtemp daemon
- [X] make way of fetching temp a config


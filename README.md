# docker_hddfancontrol
simple Docker image for hddfancontrol by desbma
https://github.com/desbma/hddfancontrol

This is a docker image which includes the following programs to run **hddfancontrol** by desbma.
- smartmontools - needed for the new --smartctl option, which uses smartmontolls instead of hdparm to spindown drives
- hdparm - old way of spinning down drives
- hddtemp - to get hddtemps
- fancontrol - to control PWM fan speed


### Current prerequisite
Since it is not good measure to load kernel modules inside docker you need to do the following before usign this container
- Installing the `lm-sensors` package for your distribution
- run `sensors-detect` with standard configuration
- load the detected kernel modules by adding them to /etc/modules (This can be done automatically in the step above)


### Docker compose
- The environment variable ARGS is used to give the needed paramters to hddfancontrol
- currently privbiliged mode is used, since I didnt find an easy way to bind the sysfs hwmon instances 
```
version: "2"
services:
  hddfancontrol:
    image: fred92/hddfancontrol:latest
    restart: unless-stopped
    privileged: true
    environment:
      - ARGS=-d /dev/sdb /dev/sdc /dev/sdd -p /sys/class/hwmon/hwmon2/pwm1 /sys/class/hwmon/hwmon2/pwm2 --pwm-start-value 70 80 --pwm-stop-value 20 30 --min-fan-speed-prct 0 -i 60 --spin-down-time 600 -l /var/log/hddfancontrol.log --smartctl
```

### ToDo
- [ ] Split the $ARGS environment variable into the individual configuration paramters
- [ ] Find a way to get rid of the priviliged mode and use the devices directly
- [ ] incoperate lm-sensors into the container including the kernel modules


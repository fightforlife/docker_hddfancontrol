
# docker_hddfancontrol v2
a Docker image for hddfancontrol v2 by desbma + hd-idle by adelolmo
Please checkout their apps here:
- https://github.com/desbma/hddfancontrol
- https://github.com/adelolmo/hd-idle

### v1 to v2 migration:
when switching from hddfancontrol v1 to v2 the command arguments have changed.
I adapted the ENV variales accordingly. Just changing the docker tag will not work.
Please check out the example docker compose file.


This docker image is built with the following steps:
- Builder: use alpine to fetch the latest versions from source and build both binaries.
-  Install needed dependencies to run binaries: lm-sensors, hdparm, smartmontools, sdparm,...
-   nclude the start_services.sh script to run the binaries.

The start_services.sh script does the following:
- detect all hwmon sensors and load the matching kernel modules (they need to be available in the hosts kernel)
- list available pwm fans and connect disks
- If no PWM config is given, the script will pause. Then you can exec "pwmconfig" inside the container to find the correct pwm paths and speed values.
- Start hddfancontrol with the provided parameters from ENV
- Start hd-idle with the provided parameters from ENV
- Wait for any process to terminate.

### Docker compose
- currently privbiliged mode is used, since I didnt find an easy way to bind the sysfs hwmon instances 
- you can run the container in read_only: true, which add a little security.
- The container is still running under root with priviliged: true. This is in no way secure.
- an example is available here: https://github.com/fightforlife/docker_hddfancontrol/blob/v2/docker-compose.yml

### ToDo
- [ ] Find a way to get rid of the priviliged mode and use the devices directly



#use official slim python image
FROM python:slim

#update repository
RUN apt-get update

#install needed packages
#hddtemp package is deprecated as of debian bookworm, see https://groups.google.com/g/linux.debian.bugs.dist/c/fRxG4xEJQUs
RUN apt-get install -y smartmontools hdparm fancontrol lm-sensors kmod git

#install hddfancontrol
RUN pip3 install setuptools
RUN git clone https://github.com/desbma/hddfancontrol
RUN cd hddfancontrol && \
    chmod +x setup.py && \
    python3 setup.py install
RUN rm -rf hddfancontrol


#start hddtemp daemon and expose port
#EXPOSE 7634
#CMD hddtemp -q -d -F /dev/sd*
COPY start_services.sh /usr/local/bin
RUN chmod +x /usr/local/bin/start_services.sh
CMD /usr/local/bin/start_services.sh

#use official slim python image
FROM python:slim

#update repository
RUN apt-get update

#install needed packages
RUN apt-get install -y smartmontools hdparm hddtemp fancontrol lm-sensors kmod

#install hddfancontrol
RUN pip3 install hddfancontrol

#start hddtemp daemon and expose port
#EXPOSE 7634
#CMD hddtemp -q -d -F /dev/sd*
COPY start_services.sh /usr/local/bin
RUN chmod +x /usr/local/bin/start_services.sh
CMD /usr/local/bin/start_services.sh

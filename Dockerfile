#use official slim python image
FROM python:slim-buster

#update repository
RUN apt-get update

#install needed packages
RUN apt-get install -y smartmontools hdparm hddtemp fancontrol

#install hddfancontrol
RUN pip3 install hddfancontrol

#start hddtemp daemon and expose port
#EXPOSE 7634
#CMD hddtemp -q -d -F /dev/sd*

CMD hddfancontrol $ARGS

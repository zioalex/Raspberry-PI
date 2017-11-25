FROM ubuntu:xenial
# docker run -ti -p 8000:8000 -v ~/workspace/Translator_kit/configs:/configs/ translator_kit  /bin/bash

# Run with PULSE NETWORK
# docker run -ti -p 8000:8000 --rm -v ~/workspace/Translator_kit/configs:/configs/ -e PULSE_SERVER="tcp:$(hostname -i|tr -d " "):4713" -e PULSE_COOKIE=/run/pulse/cookie -v ~/.config/pulse/cookie:/run/pulse/cookie translator_kit
# Works only the output

# docker run -ti -p 8000:8000 --rm -v ~/workspace/Translator_kit/configs:/configs/  -v /dev/shm:/dev/shm -v /etc/machine-id:/etc/machine-id  -v /run/user/$uid/pulse:/run/user/$uid/pulse -v /var/lib/dbus:/var/lib/dbus -v ~/.pulse:/home/$dockerUsername/.pulse translator_kit /bin/bash

# docker run -ti -p 8000:8000 --rm -v ~/workspace/Translator_kit/configs:/configs/ -v /run/user/$UID/pulse/native:/run/user/0/pulse/native -e PULSE_SERVER="unix:/run/user/0/pulse/native" translator_kit /bin/bash
MAINTAINER Alessandro Surace

ENV DEBIAN_FRONTEND noninteractive 

RUN sed -i "/deb .* xenial main restricted/ s/$/ multiverse/" /etc/apt/sources.list && apt-get -qq -y update

RUN apt-get -qq -y update && \
    apt-get -qq -y install pulseaudio icecast2 darkice python-setuptools && \
    apt-get clean

#RUN sed -i "/^# deb .* multiverse/ s/^# //" /etc/apt/sources.list && apt-get -qq -y update

#RUN easy_install supervisor && \
#    easy_install supervisor-stdout

ADD ./start.sh /start.sh

#VOLUME ["/config", "/var/log/icecast2", "/etc/icecast2"] 
VOLUME ["/configs","/var/log/icecast2"]

#ADD ./etc /etc
RUN chown -R icecast2 /var/log/icecast2

CMD ["/start.sh"]
EXPOSE 8000 

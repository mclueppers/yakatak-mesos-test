FROM ubuntu:14.04
MAINTAINER Martin Dobrev

RUN apt-get update
RUN apt-get -y install python2.7
RUN mkdir -p /usr/local/bin/apps

ADD apps /usr/local/bin/apps

EXPOSE 18888

ENTRYPOINT /usr/bin/python2.7 /usr/local/bin/apps/simple_server.py

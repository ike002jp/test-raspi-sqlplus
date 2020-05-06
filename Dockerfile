FROM ubuntu:latest

RUN apt-get update
RUN apt-get install -y unzip
RUN apt-get install -y libaio1
RUN apt-get install -y vim

WORKDIR /root

RUN mkdir ./toso
ADD . ./toso/

RUN unzip ./toso/src/instantclient-basic-linux.x64-19.6.0.0.0dbru.zip
RUN unzip ./toso/src/instantclient-sdk-linux.x64-19.6.0.0.0dbru.zip
RUN unzip ./toso/src/instantclient-sqlplus-linux.x64-19.6.0.0.0dbru.zip

RUN echo 'export ORACLE_HOME=/root/instantclient_19_6' >> ~/.bashrc
RUN echo 'export LD_LIBRARY_PATH=/root/instantclient_19_6:$LD_LIBRARY_PATH' >> ~/.bashrc
RUN echo "alias sqlplus='/root/instantclient_19_6/sqlplus'" >> ~/.bashrc

CMD pwd

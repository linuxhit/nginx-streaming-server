FROM ubuntu:20.04
COPY run.sh /run.sh
RUN chmod +x ./run.sh 
RUN /run.sh

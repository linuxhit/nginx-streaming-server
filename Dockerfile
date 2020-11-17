FROM ubuntu:20.04
COPY build.sh /build.sh
RUN chmod +x ./build.sh
RUN /build.sh

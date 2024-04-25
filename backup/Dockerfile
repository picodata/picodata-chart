FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update -qq && apt install -y \
    awscli

RUN mkdir /scripts 
COPY backup/picobackup.sh /scripts
WORKDIR /scripts
RUN chmod +x picobackup.sh
ENTRYPOINT [ "./picobackup.sh" ]

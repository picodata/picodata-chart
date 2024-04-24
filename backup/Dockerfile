FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    awscli && \
    apt-get clean all

RUN mkdir /scripts 
COPY backup/picobackup.sh /scripts
WORKDIR /scripts
RUN chmod +x picobackup.sh
ENTRYPOINT [ "./picobackup.sh" ]

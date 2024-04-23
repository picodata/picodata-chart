FROM ubuntu:22.04 
RUN apt-get update && apt-get install -y \\
    awscli

RUN mkdir /scripts 
COPY backup/picobackup.sh /scripts
WORKDIR /scripts
RUN chmod +x picobackup.sh
ENTRYPOINT [ "./picobackup.sh" ]

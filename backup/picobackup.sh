#!/bin/bash

BACKUP_PREFIX=picodata
BACKUP_FILENAME="${BACKUP_PREFIX}_$(date +%Y%m%d_%H%M%S).tar.gz"
BACKUP_PATH=${BACKUP_PATH}
S3_BUCKET=${S3_BUCKET}
S3_ENDPOINT="https://storage.yandexcloud.net"

aws configure set aws_access_key_id ${AWS_ACCESS_KEY_ID}
aws configure set aws_secret_access_key ${AWS_SECRET_ACCESS_KEY}
aws configure set default.region ru-central1

tar -zcvf ${BACKUP_FILENAME} ${BACKUP_PATH}

aws --endpoint-url=$S3_ENDPOINT s3 cp ${BACKUP_FILENAME} s3://${S3_BUCKET}


rm $BACKUP_FILENAME
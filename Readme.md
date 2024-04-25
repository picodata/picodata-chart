# s3 integration
docs:
https://github.com/yandex-cloud/k8s-csi-s3

### Install

cd backup/yandex-s3
helm repo add yandex-s3 https://yandex-cloud.github.io/k8s-csi-s3/charts
helm install csi-s3 yandex-s3/csi-s3 -f values.yml -n picodata
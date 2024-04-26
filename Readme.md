# s3 integration
docs:
https://github.com/yandex-cloud/k8s-csi-s3

### Install

Добавить ключи для s3 бакета:
```bash
kubectl apply -f backup/pico-s3-secret.yml
```

Установить csi-s3 драйвер в kubernetes кластер:
```bash
cd backup/yandex-s3
helm repo add yandex-s3 https://yandex-cloud.github.io/k8s-csi-s3/charts
helm install csi-s3 yandex-s3/csi-s3 -f values.yml -n picodata
```

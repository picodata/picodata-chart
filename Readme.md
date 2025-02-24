# Установка Picodata с помощью Helm

- [Установка кластера с конфигурацией по умолчанию](#установка-кластера-с-конфигурацией-по-умолчанию)
- [Аргументы командной строки helm](#аргументы-командной-строки-helm)
  — [Полезные опции](#полезные-опции)
- [Переопределение параметров и запуск своего кластера](#переопределение-параметров-и-запуск-своего-кластера)
  — [Параметры дисковой подсистемы для кластера](#параметры-дисковой-подсистемы-для-кластера)
  — [Задание портов для сервисов](#задание-портов-для-сервисов)
  — [Общие параметры для кластера](#общие-параметры-для-кластера)
  — [Определение конфигурации тиров](#определение-конфигурации-тиров)
  — [Определение конфигурации плагинов](#определение-конфигурации-плагинов)
- [Проброс порта psql через ingress-nginx](#проброс-порта-psql-через-ingress-nginx)
- [s3 Integration](#s3-integration)


Одним из самых распространенных способов управлять установкой приложений в
`kubernetes` является пакетный менеджер `helm`. Он позволяет шаблонизировать
манифесты, динамичестки конфигурировать приложение, разделять релизы и
управлять порядком установки в кластер.
Чарт `picodata` позволяет установить `picodata` в кластер `kubernetes`
одной командой, а также гибко конфигурировать кластер с помощью
переопределения `chart values` в едином файле.

---

## Установка кластера с конфигурацией по умолчанию

Чтобы протестировать `picodata`, первым делом нужно поднять кластер `kubernetes`
или `minikube`, а затем установить чарт. Для начала клонируем репозиторий:

```shell
git clone https://git.picodata.io/core/picodata-chart.git
```

Переходим в директорию с чартом:

```shell
cd picodata/
```

Наиболее простой вариант установки — это установка с параметрами по умолчанию.
Выполняем вызов `helm` без параметров.

```shell
helm upgrade --install picodata -n picodata . --create-namespace
```

helm chart выкладывается в репозиторий из которого его можно получить следующими командами:

```shell
helm pull oci://docker-public.binary.picodata.io/helm/picodata
helm upgrade --install picodata -n picodata <путь к tgz архиву> --create-namespace
```

### Аргументы командной строки helm

---

#### Полезные опции

Для примера основных опция `helm` можно рассмотреть команду:
```shell

helm upgrade my-release-name picodata \
  --install \
  --namespace my-namespace \
  --create-namespace
  --values my-values.yml \
  --version 0.0.3 \
  --devel \
  --debug \
  --wait \
  --atomic
```

Пояснение:

- `helm upgrade` — обновить уже установленный релиз.
- `my-release-name` — название релиза, в рамках которого будут сохраняться
    ревизии.
- `picodata` — название чарта, который мы устанавливаем (может быть путем в
  файловой системе, или путем в репозитории).
- `--install` — установить чарт если еще не установлен.
- `--namespace my-namespace` — установить релиз в неймспейс my-namespace.
- `--create-namespace` — создать неймспейс, указанный в опции `--namespace`,
если он еще не создан.
- `--values my-values.yml` — пусть к values, которые перезапишут дефолтные.
- `--version 0.0.1` — версия устанавливаемого чарта (версия приложения
захардкожена в конкретной версии чарта).
- `--devel` — позволяет устанавливать develop-версии чартов, например 0
.0.1-alpha, или 22.10-beta-test.
- `--debug` — вывести подробную информацию об установке и отрендеренные
манифесты.
- `--wait` — дождаться пока все поды будут запланированы планировщиком и
перейдут в статус Running.
- `--atomic` — атомарная установка. Если установка новой ревизий прошла
неуспешно (поды не перешли в состояние Running), то откатить на
предыдущую версию и удалить текущий релиз.

---

### Переопределение параметров и запуск своего кластера

Чтобы получить копию `values` для переопределения конфигурации по умолчанию,
нужно воспользоваться командой:

```shell
helm show values >> my-new-values.yml
```

В полученном файле `my-release-values.yml` есть следующие параметры, которые можно переопределить.

- Параметры образа, а также репозиторий, откуда будет получен образ `picodata`
- Образ собирается из на осонове rockylinux:8 из [Dockerfile](https://git.picodata.io/core/picodata/-/blob/master/docker/picodata.Dockerfile)

```yaml
image:
  repository: docker-public.binary.picodata.io
  pullPolicy: IfNotPresent
  # Если убрать тег в values, то будет использован тег, указанный в chartVersion,
  # или переданный в опции --version
  tag: 'picodata:master'

# Если кластер kubernetes находится в закрытом контуре и используется
# приватный репозиторий, то необходимо заранее создать imagePullSecrets
imagePullSecrets: []
```

#### Параметры `service account`

```yaml
serviceAccount:
  # Обозначает, должен ли быть создан service account
  create: true
  # Дополнительные аннотации
  annotations: {}
  # Имя service account, который будет использован текущим релизом.
  # Если не задавать имя, то оно будет сгенерировано автоматически.
  name: ''
```

- Параметры перезаписи имени.

```yaml
nameOverride: ''
fullnameOverride: ''
```

#### Параметры дисковой подсистемы для кластера

```yaml
  # Рабочая директория инстанса.
  instanceDir: /pico
  volumes:
    - name: picodata
      accessModes:
        - ReadWriteOnce
      # Точка монтирования рабочей директории инстанса.
      mountPath: /pico
      # Управление классамом хранилища
      storageClassName: yc-network-ssd
```

#### Задание портов для сервисов

```yaml
  service:
    type: ClusterIP
    ports:
        # Бинарный порт общения между инстансами
      - name: binary
        protocol: TCP
        port: 3301
        targetPort: 3301
        # Порт HTTP-сервера, где доступно WebUI, а также url для сбора метрик (/metrics)
      - name: http
        protocol: TCP
        port: 8081
        targetPort: 8081
        # Порт общения по протоколу Pgproto
      - name: psql
        protocol: TCP
        port: 5432
        targetPort: 5432
        # Если включен плагин radix. Для общения по протоколу redis
      - name: radix
        protocol: TCP
        port: 7379
        targetPort: 7379
```

#### Общие параметры для кластера

```yaml
  # Число реплик — инстансов с одинаковым набором хранимых данных — для каждого репликасета.
  default_replication_factor: 1
  # Число сегментов в кластере по умолчанию.
  default_bucket_count: 3000
  # Режим безопасного удаления рабочих файлов путем многократной перезаписи специальными битовыми последовательностями
  shredding: false
```

#### Определение конфигурации тиров

```yaml
  # В дефолтном values.yaml определен один тир
  tiers:
    - tierName: default
      # Фактор репликации к котому будет стремиться кластер.
      replication_factor: 1
      # Количество подов (инстансов) picodata
      replicas: 2
      # Признак тира <tier_name>, определяющий возможность инстансов участвовать в голосовании на выборах raft-лидера.
      can_vote: true
      # Размер диска для каждого инстанса
      diskSize: 1Gi
      plugin_dir: null
      audit: null
      memtx:
        # Объем памяти в байтах, выделяемый для хранения кортежей
        memory: 128M
      vinyl:
        # Максимальное количество оперативной памяти в байтах, которое использует движок хранения vinyl.
        memory: 67108864
        # Размер кэша в байтах для движка хранения vinyl.
        cache: 33554432
      # Модуль Pgproto реализует протокол PostgreSQL
      pg:
        # Признак использования протокола SSL при подключении к Pgproto.
        ssl: false
      log:
        level: info
        destination: null
        format: plain
      # Значения по-умолчанию для cpu/mem ресурсов.
      resources:
        limits:
          cpu: 200m
          memory: 256Mi
        requests:
          cpu: 100m
          memory: 128Mi
        # Дополнительные переменные окружения
        env:
        - name: PICODATA_LOG_LEVEL
          value: info
      # affinity для каждого тира
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: app
                    operator: In
                    values:
                      - services
      # Параметры ingress для каждого тира
      ingress:
        enabled: false
        className: 'nginx'
        annotations:
          kubernetes.io/tls-acme: "true"
          cert-manager.io/cluster-issuer: letsencrypt
        hosts:
          - host: picodata.local
            paths:
              - path: /
                pathType: ImplementationSpecific
        tls:
          - secretName: picodata-local-tls
            hosts:
              - picodata.local


  # livenessProbe/readinessProbe для кластера Picodata
  livenessProbe:
    tcpSocket:
      port: binary
    timeoutSeconds: 3
    periodSeconds: 20
    successThreshold: 1
    failureThreshold: 3
  readinessProbe:
    tcpSocket:
      port: binary
    timeoutSeconds: 3
    periodSeconds: 20
    successThreshold: 1
    failureThreshold: 3
  startupProbe:
    tcpSocket:
      port: binary
    periodSeconds: 30
    failureThreshold: 20
    timeoutSeconds: 3

  # Управление автоматическим горизонтальным масштабированием
  autoscaling:
    # По умолчанию автомасштабирование отключено
    enabled: false
    # Минимальное количество реплик (нужно конфигурировать совместно с
    # replicationFactor и replicasCount)
    minReplicas: 2
    maxReplicas: 100
    targetCPUUtilizationPercentage: 80
    targetMemoryUtilizationPercentage: 80

  nodeSelector: {}

  tolerations: []

  topologySpreadConstraints: {}
    # — maxSkew: 1
    #   topologyKey: kubernetes.io/hostname
    #   whenUnsatisfiable: DoNotSchedule
    #   matchLabelKeys:
    #     — router

```

#### Определение конфигурации плагинов

Более полная документация по плагинам доступна по [адресу](https://docs.picodata.io/picodata/devel/plugins/radix/).

Нужно поменять имя образа, собранного с плагином,  в разделе [image.tag](https://git.picodata.io/core/picodata-chart/-/blob/main/picodata/values.yaml?ref_type=heads#L4) и добавить порт в [service](https://git.picodata.io/core/picodata-chart/-/blob/main/picodata/values.yaml?ref_type=heads#L18)

```yaml
- name: radix
  protocol: TCP
  port: 7379
  targetPort: 7379
```

Далее подключиться к инстансу пикодаты

```bash
kubectl exec -it default-picodata-0 -n picodata -- bash
```

В контейнере подключиться к административной консоли инстанса:

```bash
picodata admin admin.sock
```

И выполнить sql комманды:

```sql
CREATE PLUGIN radix 0.2.0;
ALTER PLUGIN radix 0.2.0 ADD SERVICE radix TO TIER default;
ALTER PLUGIN radix MIGRATE TO 0.2.0;
ALTER PLUGIN radix 0.2.0 ENABLE;
```

Проверить правильность установки плагина:

```sql
SELECT * FROM _pico_plugin;
```

### Проброс порта psql через ingress-nginx

Официальныя [документация](https://kubernetes.github.io/ingress-nginx/user-guide/exposing-tcp-udp-services/)

Если использовать официальный helm chart [ingress-nginx](https://github.com/kubernetes/ingress-nginx), то достаточно добавить строки в values.yaml:

```yaml
tcp:
  "5432": "picodata/default-picodata-ext:5432"
```

и если load balancer в облаке YC, то еще указать префикс

```yaml
portNamePrefix: "psql"
```

А также в values.yaml данного чарта устрановить переменную `pg.expose` в `true`

### s3 Integration

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

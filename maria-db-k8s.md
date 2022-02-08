

## k8s mariaDB 설치

### 1. Persistent Volume 생성

$ vi db-pv.yaml

    ---  
    apiVersion:  v1  
    kind:  PersistentVolume  
    metadata:  
    name:  db-pv-volume  
    labels:  
    type:  local  
    spec:  
    storageClassName:  db-storage-class  
    capacity:  
    storage:  50Gi # 스토리지 용량 크기  
    accessModes:  
    - ReadWriteOnce # 하나의 Pod에서만 access가 가능하도록 설정, ReadWriteMany는 여러개 노드  
    hostPath:  
    path:  "/data/k8s/db/" # Host에 저장될 스토리지 공간
    
    $ kubectl create -f db-pv.yaml
    
    $ kubectl describe pv db-pv-volume

### 2. Persistent Volume Claim 생성

    $ vi db-pvc.yaml
    
    ---  
    apiVersion:  v1  
    kind:  PersistentVolumeClaim  
    metadata:  
    name:  db-pv-claim  
    spec:  
    storageClassName:  db-storage-class  
    accessModes:  
    - ReadWriteOnce  
    resources:  
    requests:  
    storage:  50Gi
    
    $ kubectl create -f db-pvc.yaml
    
    $ kubectl describe pvc db-pv-claim


### 3. DB 정보 k8s Secret 생성

    DB 암호화
    
    $ echo -n 'DB_PASSWORD' | base64
    
    S3ROTFVDb250YWluZXIhQCM=
    
    $ vi db-secret.yaml

    ---  
    apiVersion:  v1  
    kind:  Secret  
    metadata:  
    name:  mariadb-secret  
    data:  
    password:  S3ROTFVDb250YWluZXIhQCM=
    
    $ kubectl create -f db-secret.yaml
    
    $ kubectl get secret mariadb-secret
    
    $ kubectl describe secret mariadb-secret



### 4. MariaDB k8s Service 생성

    $ vi mariadb-svc.yaml
    
    ---  
    apiVersion:  v1  
    kind:  Service  
    metadata:  
    name:  mariadb  
    spec:  
    ports:  
    - port:  3306  
    selector:  
    app:  mariadb
    
    $ kubectl create -f mariadb-svc.yaml

### 5. MariaDB k8s Deployment 생성

    $ vi mariadb-deployment.yaml
    
    ---  
    apiVersion:  apps/v1  
    kind:  Deployment  
    metadata:  
    name:  mariadb  
    spec:  
    selector:  
    matchLabels:  
    app:  mariadb  
    strategy:  
    type:  Recreate  
    template:  
    metadata:  
    labels:  
    app:  mariadb  
    spec:  
    containers:  
    - image:  mariadb:10.7 # MariaDB 이미지  
    name:  mariadb  
    ports:  
    - containerPort:  3306 # Container 포트  
    name:  mariadb  
    volumeMounts:  
    - name:  mariadb-persistent-storage  
    mountPath:  /var/lib/mysql  
    env:  
    - name:  MYSQL_ROOT_PASSWORD  
    valueFrom:  
    secretKeyRef:  
    name: mariadb-secret  # Secret의 이름  
    key: password # Secret의 data에 들어간 key:value  
    volumes:  
    - name:  mariadb-persistent-storage  
    persistentVolumeClaim:  
    claimName:  db-pv-claim
    
    $ kubectl create -f mariadb-svc.yaml
    $ kubectl describe deployment mariadb
    $ kubectl get pods -l app=mariadb
    mariadb-57457bc89b-gkbbf 1/1 Running 0 3m14s

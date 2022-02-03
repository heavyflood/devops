


# redis cluster in kubernetes

kubernetes(k8s) 노드가 다음과 같이 구성되어 있다고 가정하고 설치한다.

1 maser  
3 worker  
  
# 참고

[https://kubernetes.io/ko/docs/concepts/workloads/controllers/statefulset/  
](https://kubernetes.io/ko/docs/concepts/workloads/controllers/statefulset/)[https://kubernetes.io/ko/docs/tutorials/configuration/configure-redis-using-configmap/  
](https://kubernetes.io/ko/docs/tutorials/configuration/configure-redis-using-configmap/)

[https://github.com/sanderploegsma/redis-cluster](https://github.com/sanderploegsma/redis-cluster)  

[https://yaml.org/spec/1.2/spec.html#id2794534](https://yaml.org/spec/1.2/spec.html#id2794534)

[https://yaml-multiline.info/](https://yaml-multiline.info/)

  

# redis-cluster.yaml 내용  

    apiVersion: v1
    
    kind: Namespace
    
    metadata:
    
    name: redis-cluster
    
    ---
    
    apiVersion: v1  
    kind: ConfigMap  
    metadata:  
    name: redis-cluster  
    labels:  
    app: redis-cluster  
    data:  
    fix-ip.sh: |  
    #!/bin/sh  
    CLUSTER_CONFIG="/data/nodes.conf"  
    if [ -f ${CLUSTER_CONFIG} ]; then  
    if [ -z "${POD_IP}" ]; then  
    echo "Unable to determine Pod IP address!"  
    exit 1  
    fi  
    echo "Updating my IP to ${POD_IP} in ${CLUSTER_CONFIG}"  
    sed -i.bak -e "/myself/ s/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/${POD_IP}/" ${CLUSTER_CONFIG}  
    fi  
    exec "$@"  
    # | (newline 유지하는 멀티라인)
    
    # + (마지막 newline 유지)  
    
    redis.conf: |+  
    cluster-enabled yes  
    cluster-require-full-coverage no  
    cluster-node-timeout 15000  
    cluster-config-file /data/nodes.conf  
    cluster-migration-barrier 1  
    appendonly no
    
    save ""
    
    protected-mode no
    
    requirepass "password123"
    
    masterauth "password123"
    
    ---  
    apiVersion: v1  
    kind: Service  
    metadata:  
    name: redis-cluster  
    labels:  
    app: redis-cluster  
    spec:  
    ports:  
    - port: 6379  
    targetPort: 6379  
    name: client  
    - port: 16379  
    targetPort: 16379  
    name: gossip
    
    # clusterIP 로 k8s 클러스터내부에서만 접근 가능한 Service(pod묶음)을 제공하자.  
    type: clusterIP
    
    # clusterIP 를 명시하지 않으면 Service 시작시 IP 가 자동할당된다.
    
    #clusterIP: None
    
    clusterIP: "10.10.10.123"
    
    selector:  
    app: redis-cluster  
    ---
    
    # StatefulSet 은 Pod 집합인 Deployment 와 스케일  
    apiVersion: apps/v1  
    kind: StatefulSet  
    metadata:  
    name: redis-cluster  
    labels:  
    app: redis-cluster  
    spec:  
    serviceName: redis-cluster  
    replicas: 4  
    selector:  
    matchLabels:  
    app: redis-cluster  
    template:  
    metadata:  
    labels:  
    app: redis-cluster  
    spec:  
    containers:  
    - name: redis  
    image: redis:6.2-rc
    
    args: ["--requirepass", "password123"]  
    ports:  
    - containerPort: 6379  
    name: client  
    - containerPort: 16379  
    name: gossip  
    command: ["/conf/fix-ip.sh", "redis-server", "/conf/redis.conf"]  
    readinessProbe:  
    exec:  
    command:  
    - sh  
    - -c  
    - "redis-cli -h $(hostname) ping"  
    initialDelaySeconds: 15  
    timeoutSeconds: 5  
    livenessProbe:  
    exec:  
    command:  
    - sh  
    - -c  
    - "redis-cli -h $(hostname) ping"  
    initialDelaySeconds: 20  
    periodSeconds: 3  
    env:  
    - name: POD_IP  
    valueFrom:  
    fieldRef:  
    fieldPath: status.podIP  
    volumeMounts:  
    - name: conf  
    mountPath: /conf  
    readOnly: false  
    - name: data  
    mountPath: /data  
    readOnly: false  
    volumes:  
    - name: conf  
    configMap:  
    name: redis-cluster  
    defaultMode: 0755  
    volumeClaimTemplates: # PersistentVolumesClaims(PVC) 100MiB 요청(생성)해서 pod 가 내려가도 데이터는 유지될 수 있도록 한다.  
    - metadata:  
    name: data  
    labels:  
    name: redis-cluster  
    spec:  
    accessModes: [ "ReadWriteOnce" ]  
    resources:  
    requests:  
    storage: 100Mi  

  
  

## redis 클러스터 master, worker, statefulset, service 생성

    kubectl apply -f redis-cluser.yaml  

  

## configmap, statefulset, service 확인

    kubectl describe cm --namespace redis-cluster  
    kubectl describe sts --namespace redis-cluster  
    kubectl describe svc --namespace redis-cluster  

  

## statefulset 에서 PersistentVolumeClaim(PVC) 상태 확인

 

    kubectl get pvc --namespace redis-cluster  

  

## POD 및 서비스 상태 확인

    kubectl get all --namespace redis-cluster  

## 클러스터링 구성

redis5 부터 redis-cli 에서 redis-trib.rb 의 기능을 사용할 수 있다. 

    redis 클러스터 명령 참고
    redis-cli --cluster help  

  

    

## redis 동작중인 pod 파악

    kubectl get pods --namespace redis-cluster | grep redis | awk '{print $1}' | head -1  

  

## jsonpath output 을 app=redis 인 pod 들의 IP 파악

참고

 [https://kubernetes.io/docs/reference/kubectl/jsonpath/](https://kubernetes.io/docs/reference/kubectl/jsonpath/)  

     
    kubectl get pods --namespace redis-cluster -l app=redis-cluster -o jsonpath='{range .items[*]}{.status.podIP}{":6379 "}{end}'
    
      
    
    pod ip:port 를 옵션으로 주어 클러스터링을 구성한다.

## cluster-replicas 복제(슬레이브) 개수 4개의 노드라면 2개 마스터, 2개 슬레이브가 된다.

    kubectl --namespace redis-cluster \
    exec -it redis-cluster-0 -- \
    redis-cli --cluster create --cluster-replicas 1 -a "password123" \
    $(kubectl --namespace redis-cluster get pods -l app=redis-cluster -o jsonpath='{range .items[*]}{.status.podIP}{":6379 "}{end}')

    Can I set the above configuration? (type 'yes' to accept): yes 입력

## redis cluster info 확인

    kubectl --namespace redis-cluster exec -it redis-cluster-0 -- redis-cli -a "password123" cluster info  

  

## redis cluster node 확인

    kubectl --namespace redis-cluster exec -it redis-cluster-0 -- redis-cli -a "password123" -c cluster nodes  

  

  

## redis-cluster-0 파드에서 redis-cli 로 clusterIP(고정) 에 접속해 테스트

    kubectl --namespace redis-cluster exec -it redis-cluster-0 -- redis-cli -h 10.10.10.123 -p 6379 -c -a "password123"
    10.10.10.123:6379> set aaa lemon
    OK
    10.10.10.123:6379> get aaa
    "lemon"
    10.10.10.123:6379> set bbb apple
    -> Redirected to slot [5287] located at 10.10.123.100: 6379
    OK
    10.10.123.100:6379> get bbb
    "apple"

  

## 노드 변경이 필요한 경우

    # replicas=6 로 노드(pod) 6개로 늘린다.
    기존보다 작으면 줄어든다. 줄일때는 노드 제거후 적용
    kubectl --namespace redis-cluster scale statefulset redis-cluster --replicas=6
  

## 추가된 노드에 # 10.10.10.10:6379 기존 존재하는 클러스터 노드에 마스터 노드 추가

    kubectl --namespace redis-cluster \
    exec -it redis-cluster-0 -- 
    redis-cli -a "password123" --cluster add-node 10.10.10.11:6379 10.10.10.10:6379

  

## 10.10.10.11:6379 마스터의 슬레이브가 추가

    kubectl --namespace redis-cluster \    
    exec -it redis-cluster-0 -- \    
    redis-cli -a "password123" --cluster add-node 10.10.10.12:6379 10.10.10.11:6379 --cluster-slave

  

## 슬롯 재분배 

    새 마스터 노드가 추가 된경우 --cluster-use-empty-masters 사용    
    kubectl --namespace redis-cluster \    
    exec -it redis-cluster-0 -- \    
    redis-cli -a "password123" --cluster rebalance 10.10.10.10:6379 --cluster-use-empty-masters

  

## 노드 빼는 경우(10.10.10.10:6379 노드에 접속해서 aaaaabbbbb 노드들 삭제)

    kubectl --namespace redis-cluster \    
    exec -it redis-clustqer-0 -- \    
    redis-cli -a "password123" --cluster del-node 10.10.10.12:6379 aaaaabbbbb

  

  

  

####  
  
  

## confimap 삭제

    kubectl delete cm redis-cluster --namespace redis-cluster  

  

## PersistentVolumeClaim(PVC) 삭제

    kubectl delete sts redis-cluster --namespace redis-cluster  

  

## pvc 삭제

    # kubectl get pvc 로 볼륨이름 파악    
    kubectl delete pvc 볼륨이름 --namespace redis-cluster
    
    # 또는 전체 삭제하는 경우    
    kubectl delete pvc --all --namespace redis-cluster

  

## service 모두 삭제

    kubectl delete service --all --namespace redis-cluster  

  

## pod 모두 삭제

 

    kubectl delete pods --all --namespace redis-cluster  

  

## unknown state pod 가 삭제 안되는 경우

    kubectl delete pods --all --grace-period=0 --force --wait=false --namespace redis-cluster  

  

## 네임스페이의 모든 리소스 삭제(단 secret,configmap,roels등과 같은 특정 리소스는 명시적으로 삭제해야 한다.)

    # all=pods,deployments,rs 등을 의미한다.    
    kubectl delete all --all --namespace redis-cluster
       
    # namespace 삭제    
    kubectl delete ns redis-cluster

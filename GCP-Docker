# GKE Cluster / Jenkins Container(Docker) Pipeline 

## Google Cloud SDK 설치

    curl -sSL https://sdk.cloud.google.com | bash

## gcloud config
    
    gcloud init

## get cluster credential
    
    gcloud container clusters get-credentials gke-cluster

## add serviceaccount
    kubectl -n kube-system create serviceaccount jenkins-serviceaccount
    kubectl -n kube-system create rolebinding jenkins-rolebinding --clusterrole=cluster-admin --serviceaccount=kube-system:jenkins-serviceaccount
    kubectl -n kube-system get secrets $(kubectl -n kube-system get serviceaccount jenkins-serviceaccount -o go-template --template='{{range .secrets}}{{.name}}{{"\n"}}{{end}}') -o go-template --template '{{index .data "token"}}' | base64 -d

## add serviceaccount credential to jenkins
    
    jenkins > Credentials
    
## Kubernetesfile.yml

    # SERVICE
    apiVersion: v1
    kind: Service
    metadata:
      name: ${APP_NAME}-service
    spec:                               # Service object를 노출하기 위한 방식을 설정
      type: LoadBalancer
      selector:                         # Service object가 요청을 전달할 Pod을 찾기위한 검색어 
        app: ${APP_NAME}                # app이름으로  Pod의 label이 같은 pod를 찾아 요청을 전달, 찾은 Pod이 여러개인 경우 load balancing 정책에 따라 하나의 Pod을 선택함.
      ports:
      - name: http
        protocol: TCP
        port: 80                        # 외부에서 접속 port ====> application 접속포트 확인하세요                                      
    #   nodePort: 30130                 # 클러스터 Node와의 통신 포트 -> 미지정시 가용한 포트에 랜덤하게 할당됨                                       
        targetPort: 9091                # Service object로 들어온 요청을 전달할 target이되는 Pod이 노출하고 있는 포트.(pod 내의 container 연결포트)                                       
                                        # ==============> targetPort는 수동설정  <==========================================
    ---
    
    # DEPOLOYMENT
    apiVersion: apps/v1
    kind: Deployment
    metadata:                           # Deployment object 자신의 고유 정보
      name: ${APP_NAME}                 # Deployment object에 대한 Unique-key 
    spec:
      replicas: 4                       # 초기 Pod의 개수를 설정
    #  minReadySeconds: 20              # Pod이 Ready 단계가 된 후, Available 단계가 될 때 까지의 시간 차이. readiness설정으로 주석철함
      revisionHistoryLimit: 2           # replicaset 이전버전 보관수
      strategy:
        type: RollingUpdate             # RollingUpdate에 대한 상세 설정. “Recreate” or “RollingUpdate”를 설정 가능 합니다. 기본값은 “RollingUpdate” 입니다. Recreate의 경우 Pod가 삭제된 후 재생성.
        rollingUpdate:                  
          maxSurge: 1                   # rolling update 중 정해진 Pod 수 이상으로 만들 수 있는 Pod의 최대 개수입니다. 기본값은 25%    
          maxUnavailable: 1             # rolling update 중 unavailable 상태인 Pod의 최대 개수를 설정 
      selector:                         # Deployment object가 관리해야할 Pod이 어떤 것인지 찾기 위해 selector 정보로 Pod의 label 정보를 비교하고 관리
        matchLabels:
          app: ${APP_NAME}
      template:                         # Deployment object가 생성할 Pod 관련 설정 
        metadata:
          labels:
            app: ${APP_NAME}
        spec:
          containers:
          - name: ${APP_NAME}
            image: ${IMAGE}
            imagePullPolicy: Always     # Always download images, **IfNotPresent : Use cached images first     
            ports:
            - name: http
              containerPort: 9091       # ==============>   targetPort와 맞춰주세요  <=====================                                
            resources:
              requests:                 # Pod 스케쥴링의 기준. 컨테이너가 요청할 최소한의 리소스에 대한 설정입니다. Spring Boot 애플리케이션의 경우는 메모리 값을 256M 이상으로 설정                                    
                memory: "256Mi"                                                
                cpu: "200m"
              limits:                   # 컨테이너가 최대한으로 사용할 리소스에 대한 설정입니다. 애플리케이션에 따라 적절한 CPU와 메모리 값으로 설정                                   
                memory: "1Gi"                                                
                cpu: "500m"
            livenessProbe:              
              exec:
                command: ["sh", "-c", "cd /"]              
              initialDelaySeconds: 30
              periodSeconds: 30
    #          timeoutSeconds: 1 
    #          successThreshold: 1
    #          failureThreshold: 3
    #          httpGet:
    #            path: /
    #            port: 8080
    #          tcpSocket:
    #            port: 8080
    #          initialDelaySeconds: 5
    #          periodSeconds: 5
    #          successThreshold: 1                          
            readinessProbe:
              exec:
                command: ["sh", "-c", "cd /"]  
              initialDelaySeconds: 30 # 컨테이너가 시작된 후 프로브를 보내기 전에 기다리는 시간
              periodSeconds: 15       # 검사를 보내는 빈도. 보통 10~20초 사이로 세팅
    #          timeoutSeconds: 1      # 해당 시간 이내 반드시 응답
    #          successThreshold: 1    # probe가 명령 수행 후 성공이라고 판단하기 위한 최소 횟수
    #          failureThreshold: 3    # probe가 명령 수행 후 실패라고 판단하기 위한 최소 횟수, probe가 횟수 이상 실패하면 컨테이너 중지 후 재시작
            lifecycle:                # 20 초의 동기식 유예 기간을 선택. 포드 종료 프로세스는이 대기 시간 후에 만 ​계속됨
              preStop:
                exec:
                  command: ["sh", "-c", "sleep 20"]             
          imagePullSecrets:
          - name: regcred    
    ---
    
    # HPA(Horizonal Pod AutoScaler)     # Horizonal Pod AutoScaler 적용      
    apiVersion: autoscaling/v2beta1
    kind: HorizontalPodAutoscaler
    metadata:
      name: ${APP_NAME}-hpa             # HorizontalPodAutoscaler object 자신의 고유 정보를 입력
    spec:                               # HorizontalPodAutoscaler object가 수행하는 내용에 대한 설정   
      maxReplicas: 6                    # 업스케일 시 생성할 수 있는 Pod의 최대수   
      minReplicas: 2                    # 다운스케일 시 생성할 수 있는 Pod의 최소수   
      scaleTargetRef:                   # HorizontalPodAutoscaler object가 동작할 대상에 대한 설정   
        apiVersion: apps/v1          
        kind: Deployment                  
        name: ${APP_NAME}
      metrics:
      - type: Resource
        resource:
          name: cpu
          targetAverageUtilization: 80
    #      targetAverageValue: 1k   
    ---
    
    ## Ingress          
    apiVersion: extensions/v1beta1
    kind: Ingress
    metadata:
      name: ${APP_NAME}-ingress
      annotations:
        kubernetes.io/ingress.global-static-ip-name: app-ip
      labels:
    spec:
      backend:
        serviceName: ${APP_NAME}-service
        servicePort: http      


## Jenkins Pipeline

    node {
      def groupName = ''
      def appName = ''
      def appVersion = ''
      def systemCode = ''
      def latestImage = ''
      def k8sAppName = ''
      def errorMessage = ''
      def jarFile = ''

      stage ('Checkout') {
            checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: '930c7210-7d53-4d19-a0cc-8211aced31cb', url: 'https://github.com/sicc-devops/demo.git']]])
      }

      stage('Initialize') {
        sh "chmod +x ./gradlew"
        appName = sh(script: "./gradlew properties -q | grep \"name\" | awk '{print \$2}'", returnStdout: true).trim()
        groupName = sh(script: "./gradlew properties -q | grep  \"group\" | awk '{print \$2}'", returnStdout: true).trim()
        appVersion = sh(script: "./gradlew properties -q | grep \"version:\" | awk '{print \$2}'", returnStdout: true).trim()
        k8sAppName = 'app'
        //latestImage = "devops-reg.ncp.sicc.co.kr/" + k8sAppName + ":" + appVersion + ".${BUILD_NUMBER}"
        latestImage = "heavyflood/demo" + ":" + appVersion + ".${BUILD_NUMBER}"
        jarFile = appName + '-' + appVersion + '.jar'
        echo latestImage
      }

      stage('Build') {
        sh "./gradlew build"
      }

      stage('Archive') {
        archiveArtifacts artifacts: '**/build/libs/'+ appName + '-' + appVersion +'*.jar', fingerprint: true
      }

      stage ('Deploy') {
          def script = "; envsubst < kubernetesfile.yaml > deployment.yaml"
          sh 'export APP_NAME=' + k8sAppName + ' IMAGE=' + latestImage + script
          sh 'cat deployment.yaml'
        sh 'mv build/libs/' + jarFile + ' ./app.jar'
            sh 'sudo docker login -u heavyflood -p **0118ghdtn'
            sh 'sudo docker image build -t app . '
            sh 'sudo docker image tag app ' + latestImage
            sh 'sudo docker image push ' + latestImage
            withEnv(['GCLOUD_PATH=/root/google-cloud-sdk/bin']) {
             //sh '$GCLOUD_PATH/gcloud auth configure-docker'
             //sh '$GCLOUD_PATH/gcloud config set project gke-devops'
             //sh '$GCLOUD_PATH/gcloud config set compute/zone us-central1-a'
             sh '$GCLOUD_PATH/gcloud container clusters get-credentials gke-cluster'
            }

             //sh 'curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl'
             //sh 'chmod +x ./kubectl && mv kubectl /usr/local/sbin'
             withKubeConfig([credentialsId: 'jenkins',
                        serverUrl: 'https://35.192.61.184'
                        ]) {
              sh 'kubectl apply -n default -f deployment.yaml'
            }

        //sh 'kubectl set image -n heavyflood deployment/app app='+ latestImage
        //sh 'docker run -d -p 9091:9091 --name app '+ latestImage
            echo "finished"
      }
    }

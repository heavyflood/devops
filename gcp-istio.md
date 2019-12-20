# GCP Istio-system

## kubectl

    $ yum update kubectl
    $ yum install kubectl


## 클러스터 생성

    $ gcloud container clusters create istio-cluster --zone us-central1-a

Credentials and permissions

    $ gcloud container clusters get-credentials istio-cluster
    $ kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user="$(gcloud config get-value core/account)"


## helm설치

    $ curl https://raw.githubusercontent.com/helm/helm/master/scripts/get > get_helm.sh
    $ chmod 700 get_helm.sh
    $ ./get_helm.sh
    $ kubectl -n kube-system create sa tiller
    $ kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
    $ helm init --service-account tiller

## istio 설치

    $ curl -L https://git.io/getLatestIstio | sh -
    $ cd istio-VERSION
    $ export PATH=$PWD/bin:$PATH
    $ helm template install/kubernetes/helm/istio-init --name istio-init | kubectl apply -f -
    $ kubectl wait --for=condition=complete job --all
    $ helm template install/kubernetes/helm/istio --name istio | kubectl apply -f -
    $ kubectl get service -n istio-system


## jenkins 컨테이너에 google-cloud-sdk 설치

    $ docker exec -it jenkins bash
    $ curl -sSL https://sdk.cloud.google.com | bash
    $ docker restart jenkins
    $ docker exec -it jenkins bash
    $ gcloud init
    $ gcloud container clusters get-credentials gke-cluster


## jenkins serviceaccount/rolebinding

    $ kubectl -n istio-system create serviceaccount jenkins-serviceaccount
    $ kubectl -n istio-system create rolebinding jenkins-rolebinding --clusterrole=cluster-admin --serviceaccount=istio-system:jenkins-serviceaccount
    $ kubectl -n istio-system get secrets $(kubectl -n istio-system get serviceaccount jenkins-serviceaccount -o go-template --template='{{range .secrets}}{{.name}}{{"\n"}}{{end}}') -o go-template --template '{{index .data "token"}}' | base64 -d

## istio-ingress-gateway에 고정 IP 할당

    kubectl patch svc istio-ingress-gateway -n istio-system --patch '{"spec": { "loadBalancerIP": "<your-reserved-static-ip>" }}'

## 파이프라인

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
            checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'f243bba8-af63-43e1-b1a0-483d9d0a401d', url: 'https://github.com/sicc-devops/demo.git']]])
    	}
    	
    	stage('Initialize') {
    		sh "chmod +x ./gradlew"
    		appName = sh(script: "./gradlew properties -q | grep \"name\" | awk '{print \$2}'", returnStdout: true).trim()
    		groupName = sh(script: "./gradlew properties -q | grep  \"group\" | awk '{print \$2}'", returnStdout: true).trim()
    		appVersion = sh(script: "./gradlew properties -q | grep \"version:\" | awk '{print \$2}'", returnStdout: true).trim()
    		k8sAppName = 'app'
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
    	    def script = "; envsubst < kubernetesfile-istio.yaml > deployment.yaml"
    	    sh 'export APP_NAME=' + k8sAppName + ' IMAGE=' + latestImage + script
    	    sh 'cat deployment.yaml'
    		sh 'mv build/libs/' + jarFile + ' ./app.jar'
            sh 'docker login -u heavyflood -p **0118ghdtn'
            sh 'docker image build -t app . '
            sh 'docker image tag app ' + latestImage
            sh 'docker image push ' + latestImage
            
            withEnv(['GCLOUD_PATH=/root/google-cloud-sdk/bin']) {
              sh '$GCLOUD_PATH/gcloud container clusters get-credentials istio-cluster'
            }
            
            sh 'curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl'
            sh 'chmod +x ./kubectl && mv kubectl /usr/local/sbin'
             
             withKubeConfig([credentialsId: 'jenkins-kube',
                        serverUrl: 'https://34.66.27.236'
                        ]) {
              sh 'kubectl apply -n istio-system -f deployment.yaml'
            }
             
    		//sh 'kubectl set image -n heavyflood deployment/app app='+ latestImage
    		//sh 'docker run -d -p 9091:9091 --name app '+ latestImage
            echo "finished"
    	}
    }


## Deployment.yaml

    # SERVICE
    apiVersion: v1
    kind: Service
    metadata:
      name: ${APP_NAME}-service
      labels:
        app: ${APP_NAME} 
    spec:
      selector: 
        app: ${APP_NAME}
      ports:
      - name: http
        protocol: TCP
        port: 9092                                      
        targetPort: 9092
        
    ---
    # DEPOLOYMENT
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: ${APP_NAME}
      labels:
        app: ${APP_NAME}
        version: v1
    spec:
      replicas: 2
      revisionHistoryLimit: 2           # replicaset 이전버전 보관수
      strategy:
        type: RollingUpdate             # RollingUpdate에 대한 상세 설정. “Recreate” or “RollingUpdate”를 설정 가능 합니다. 기본값은 “RollingUpdate” 입니다. Recreate의 경우 Pod가 삭제된 후 재생성.
        rollingUpdate:                  
          maxSurge: 1                   # rolling update 중 정해진 Pod 수 이상으로 만들 수 있는 Pod의 최대 개수입니다. 기본값은 25%    
          maxUnavailable: 1             # rolling update 중 unavailable 상태인 Pod의 최대 개수를 설정   
      selector:
        matchLabels:
          app: ${APP_NAME}
          version: v1
      template:
        metadata:
          labels:
            app: ${APP_NAME}
            version: v1
        spec:
          containers:
          - name: ${APP_NAME}
            image: ${IMAGE}
            imagePullPolicy: Always
            ports:
            - containerPort: 9092
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
            readinessProbe:
              exec:
                command: ["sh", "-c", "cd /"]  
              initialDelaySeconds: 30 # 컨테이너가 시작된 후 프로브를 보내기 전에 기다리는 시간
              periodSeconds: 15       # 검사를 보내는 빈도. 보통 10~20초 사이로 세팅
            lifecycle:                # 20 초의 동기식 유예 기간을 선택. 포드 종료 프로세스는이 대기 시간 후에 만 ​계속됨
              preStop:
                exec:
                  command: ["sh", "-c", "sleep 20"]           
            
    ---
    apiVersion: networking.istio.io/v1alpha3
    kind: Gateway
    metadata:
      name: ${APP_NAME}-gateway
    spec:
      selector:
        istio: ingressgateway # use istio default controller
      servers:
      - port:
          number: 80
          name: http
          protocol: HTTP
        hosts:
        - "*"
        
    ---
    apiVersion: networking.istio.io/v1alpha3
    kind: VirtualService
    metadata:
      name: ${APP_NAME}-virtualservice
    spec:
      hosts:
      - "*"
      gateways:
      - ${APP_NAME}-gateway
      http:
      - match:
        - uri:
            prefix: /caller
        route:
        - destination:
            host: ${APP_NAME}-service.istio-system.svc.cluster.local
            port:
              number: 9092  
              
              

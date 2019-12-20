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



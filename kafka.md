## 메세징 시스템

 웹어플리케이션 구동 시 요청/응답 형태의 동기 방식의 구조에서는 너무 많은 처리를 하다보면 대기요청이 쌓이게 되어 성능 저하로 이어지는데
  이에 대한 해결책의 하나로 비동기 메세징 처리 방식

- 메시지 지향 미들웨어(Message Oriented Middleware : MOM): 분산 시스템 간 메시지를 주고 받는    기능을 지원하는 소프트웨어나 하드웨어 인프라
 - 메시지 큐(Message Queue : MQ): MOM을 구현한 시스템
 - 브로커(Broker): Message Queue 시스템
 - AMQP(Advanced Message Queueing Protocol): 메시지 지향 미들웨어를 위한 프로토콜

메시지큐를 지원하는 API와 미들웨어
- Spring Integration
- JMS
- ActiveMQ
- RabbitMQ
- Kafka

## Kafka란?

Apache Kafka(아파치 카프카)는 LinkedIn에서 개발된 분산 메시징 시스템으로써 2011년에 오픈소스로 공개되었다. 
대용량의 실시간 로그처리에 특화된 아키텍처 설계를 통하여 기존 메시징 시스템보다 우수한 TPS를 보여주고 있다.

Kafka는 발행-구독(publish-subscribe) 모델을 기반으로 동작하며 크게 producer, consumer, broker로 구성된다.

Kafka의 broker는 topic을 기준으로 메시지를 관리한다. 
Producer는 특정 topic의 메시지를 생성한 뒤 해당 메시지를 broker에 전달한다. 
Broker가 전달받은 메시지를 topic별로 분류하여 쌓아놓으면, 해당 topic을 구독하는 consumer들이 메시지를 가져가서 처리하게 된다.


Kafka는 확장성(scale-out)과 고가용성(high availability)을 위하여 broker들이 클러스터로 구성되어 동작하도록 설계되어있다. 
심지어 broker가 1개 밖에 없을 때에도 클러스터로써 동작한다. 클러스터 내의 broker에 대한 분산 처리는 아래의 그림과 같이 Apache ZooKeeper가 담당한다.

## 기존 메세징 시스템과의 차이점

- 대용량의 실시간 로그 처리에 특화되어 설계된 메시징 시스템으로써 기존 범용 메시징 시스템대비 TPS가 매우 우수하다. 
  단, 특화된 시스템이기 때문에 범용 메시징 시스템에서 제공하는 다양한 기능들은 제공되지 않는다.
- 분산 시스템을 기본으로 설계되었기 때문에, 기존 메시징 시스템에 비해 분산 및 복제 구성을 손쉽게 할 수 있다.
- AMQP 프로토콜이나 JMS API를 사용하지 않고 단순한 메시지 헤더를 지닌 TCP기반의 프로토콜을 사용하여 프로토콜에 의한 오버헤드를 감소시켰다.
- Producer가 broker에게 다수의 메시지를 전송할 때 각 메시지를 개별적으로 전송해야하는 기존 메시징 시스템과는 달리, 
  다수의 메시지를 batch형태로 broker에게 한 번에 전달할 수 있어 TCP/IP 라운드트립 횟수를 줄일 수 있다.
- 메시지를 기본적으로 메모리에 저장하는 기존 메시징 시스템과는 달리 메시지를 파일 시스템에 저장한다.
- 파일 시스템에 메시지를 저장하기 때문에 별도의 설정을 하지 않아도 데이터의 영속성(durability)이 보장된다.
- 기존 메시징 시스템에서는 처리되지 않고 남아있는 메시지의 수가 많을 수록 시스템의 성능이 크게 감소하였으나, Kafka에서는 메시지를 파일 시스템에 저장하기 때문에 
  메시지를 많이 쌓아두어도 성능이 크게 감소하지 않는다. 또한 많은 메시지를 쌓아둘 수 있기 때문에, 실시간 처리뿐만 아니라 주기적인 batch작업에 사용할 데이터를 
  쌓아두는 용도로도 사용할 수 있다.
- Consumer에 의해 처리된 메시지(acknowledged message)를 곧바로 삭제하는 기존 메시징 시스템과는 달리 처리된 메시지를 삭제하지 않고 파일 시스템에 그대로 두었다가 
  설정된 수명이 지나면 삭제한다. 처리된 메시지를 일정 기간동안 삭제하지 않기 때문에 메시지 처리 도중 문제가 발생하였거나 처리 로직이 변경되었을 경우 consumer가 
  메시지를 처음부터 다시 처리(rewind)하도록 할 수 있다.
- 기존의 메시징 시스템에서는 broker가 consumer에게 메시지를 push해 주는 방식인데 반해, Kafka는 consumer가 broker로부터 직접 메시지를 가지고 가는 pull 방식으로 동작한다. 
  따라서 consumer는 자신의 처리능력만큼의 메시지만 broker로부터 가져오기 때문에 최적의 성능을 낼 수 있다.
- 기존의 push 방식의 메시징 시스템에서는 broker가 직접 각 consumer가 어떤 메시지를 처리해야 하는지 계산하고 어떤 메시지를 처리 중인지 트랙킹하였는데, 
  Kafka에서는 consumer가 직접 필요한 메시지를 broker로부터 pull하므로 broker의 consumer와 메시지 관리에 대한 부담이 경감되었다.
- 메시지를 pull 방식으로 가져오므로, 메시지를 쌓아두었다가 주기적으로 처리하는 batch consumer의 구현이 가능하다.

## Kafka 개요

 Topic과 Partition: 메세지는 topic으로 분류되고, topic은 여러개의 파티션으로 나눠 질 수 있다. 파티션내의 한 칸은 로그라고 불린다. 
  데이터는 한 칸의 로그에 순차적으로 append된다. 메세지의 상대적인 위치를 나타내는게 offset이다
- Producer, Consumer: Producer는 메세지를 생산하는 주체이다. 메세지를 만들고 Topic에 메세지를 쓴다. 
  Producer는 Consumer의 존재를 알지 못한다. 그냥 카프카에 메세지를 쓴다.
  Consumer는 소비자로써 메세지를 소비하는 주체이다. 역시 Producer의 존재를 모른다. 해당 topic을 구독함으로써, 자기가 스스로 조절해가면서 소비할 수 있는 것이다. 
  소비를 했다는 표시는 해당 topic내의 각 파티션에 존재하는 offset의 위치를 통해서 이전에 소비했던 offset위치를 기억하고 관리하고 이를 통해서, 
  혹시나 Consumer가 죽었다가 다시 살아나도, 전에 마지막으로 읽었던 위치에서 부터 다시 읽어들일 수 있다. 그렇기 때문에 fail-over에 대한 신뢰가 존재한다.
- Consumer Group: Consumer들의 묶음.
- Broker, Zookeeper: broker는 카프카의 서버를 칭한다. broker.id=1..n으로 함으로써 동일한 노드내에서 여러개의 broker서버를 띄울 수도 있다. 
  zookeeper는 이러한 분산 메세지 큐의 정보를 관리해 주는 역할을 한다. kafka를 띄우기 위해서는 zookeeper가 반드시 실행되어야 한다.
- Replication: topic 자체를 replication하는 것이 아니라 topic을 구성하는 각 파티션을 replication하는 것이다.
  Broker 3대를 띄우고 (replica-factor=3) 복제하는 경우를 보면, 
  복제는 Scale-out 방식이다.
  Broker 3대 중 leader는 단 1대이며, 나머지 2대를 follower다.
  Producer가 메시지를 쓰고 Consumer가 메시지를 읽는 것은 단지 leader가 담당한다.
  나머지 follower들은 leader와 sync를 맞추고 있다. 옵션에 따라 나머지 follower중에 하나가 leader 선출될 수 있다


## CentOS7에 Kafka Cluster 구성

- 공통

1) Kafka 다운로드(2020-01-29 현재 stable)

 Kafka의 동작은 Zookeeper에 의해 관리가 되기 때문에 Zookeeper 없이는 Kafka를 구동할 수 없다. 
      이 때문에 Kafka를 다운로드 하면 Zookeeper도 함께 들어있다. 물론 별도로 최신버전의 Zookeeper를 다운받아 사용해도 되지만, 
      Kafka에 들어있는 Zookeeper는 Kafka버전과 잘 동작하는 검증된 버전이므로 패키지 안에 있는 Zookeeper의 사용을 권장한다.

       $ wget http://apache.mirror.cdnetworks.com/kafka/2.4.0/kafka_2.13-2.4.0.tgz
       $ tar -zxvf kafka_2.13-2.4.0.tgz
       $ cd kafka_2.13-2.4.0

zookeeper 설정

    $ vi config/zookeeper.properties
    아래 내용 추가
    
    initLimit=5
    syncLimit=2
    
    server.1=192.168.137.101:2888:3888
    server.2=192.168.137.102:2888:3888
    server.3=192.168.137.103:2888:3888

    서버 #1
    $ mkdir /tmp/zookeeper
    $ echo 1 > /tmp/zookeeper/myid
    
    서버 #2
    $ mkdir /tmp/zookeeper
    $ echo 2 > /tmp/zookeeper/myid
    
    서버 #3
    $ mkdir /tmp/zookeeper
    $ echo 3 > /tmp/zookeeper/myid   

   

 Kafka 설정
  

    $ vi config/server.properties
    
      서버 #1
      broker.id=1
      listeners=PLAINTEXT://:9092
      advertised.listeners=PLAINTEXT://**192.168.137.101**:9092
      zookeeper.connect=192.168.137.101:2181, 192.168.137.102:2181, 192.168.137.103:2181
    
      서버 #2
      broker.id=2
      listeners=PLAINTEXT://:9092
      advertised.listeners=PLAINTEXT://**192.168.137.101**:9092
      zookeeper.connect=192.168.137.101:2181, 192.168.137.102:2181, 192.168.137.103:2181  
    
      서버 #3
      broker.id=3
      listeners=PLAINTEXT://:9092
      advertised.listeners=PLAINTEXT://**192.168.137.101**:9092
      zookeeper.connect=192.168.137.101:2181, 192.168.137.102:2181, 192.168.137.103:2181 

 

2) 실행
  Kafka를 구동하기 위해 먼저 Zookeeper를 구동 한다음 이후 Kafka를 구동해야 한다.

       $ bin/zookeeper-server-start.sh config/zookeeper.properties
       $ bin/kafka-server-start.sh config/server.properties


 **KAFKA 사용 하기전 해야하는 것**

    $ vim /kafka/config/server.properties
    delete.topic.enable = True

 **topic 만들기**

    bin/kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic x

**만들어졌는지 확인**

    bin/kafka-topics.sh --list --zookeeper localhost

**메세지 입력**

    bin/kafka-console-producer.sh --broker-list localhost:9092 --topic test

**메세지 확인**

    bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic x --from-beginning

**topic 제거하기**

    bin/kafka-topics.sh --delete --zookeeper localhost --topic x

**topic 제거 확인**

    bin/kafka-topics.sh --list --zookeeper localhost


## kafka-manager

**설치**

    wget https://github.com/yahoo/kafka-manager/archive/1.3.3.18.tar.gz
    tar -zxvf 1.3.3.18.tar.gz
    cd kafka-manager-1.3.3.18

    ./sbt clean dist ==> 어~엄청 오래 걸림

    unzip -d ~/apps/ target/universal/kafka-manager-1.3.3.18.zip

    conf/application.conf 파일에서 kafka-manager.zkhosts 값을 세팅
    ex) kafka-manager.zkhosts="zk001:2181"

**실행**

    ./bin/kafka-manager

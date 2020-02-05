# gRpc

gRPC는 Google에서 처음 개발한 공개 소스 원격 프로시저 호출(RPC) 시스템이다. 전송을 위해 HTTP/2 프로토콜을 사용하고 
인터페이스 설명 언어로 프로토콜 버퍼를 사용하며 인증, 양방향 스트리밍 및 흐름 제어, 바인딩 차단 또는 차단 해제 및 취소
및 시간 초과 기능을 제공한다. 그것은 많은 언어에 대한 크로스 플랫폼 클라이언트 및 서버 바인딩을 생성한다.

gRPC에서 클라이언트 응용 프로그램을 로컬 객체인 것처럼 다른 컴퓨터의 서버 응용 프로그램에서 메서드를 직접 호출 할 수 있으므로 
분산 응용 프로그램 및 서비스를 보다 쉽게 만들 수 있습니다. 
많은 RPC 시스템에서처럼  gRPC는 서비스를 정의하고 매개 변수와 리턴 유형을 사용하여 원격으로 호출 할 수 있는 메소드를 
지정한다는 아이디어를 기반으로 한다.

서버 측에서는 서버 인터페이스를 구현하고 gRPC 서버를 실행하여 클라이언트 호출을 처리한다. 
클라이언트 측에서 클라이언트는 서버와 동일한 메소드를 제공하는 스텁(일부 언어에서는 클라이언트라고 함)을 가지고 있습니다.

* 주요 사용 시나리오
마이크로 서비스 스타일 아키텍처에서 다중 언어 서비스를 효율적으로 연결
백엔드 서비스에 모바일 장치, 브라우저 클라이언트 연결
효율적인 클라이언트 라이브러리 생성

* 핵심 기능
1. 10개 언어로 된 관용적 클라이언트 라이브러리
2. 유선 및 간단한 서비스 정의 프레임워크로 매우 효율적.
3. http/2 프로토콜 기반 전송을 통한 양방향 스트리밍
4. 로드 밸런싱(load balancing), 추적(tracing), 상태 확인(health checking) 및 인증(authentication) 플러그인 지원

* 특징
gRPC는 HTTP/2를 기반으로 통신합니다. HTTP/2에서는 양방향 스트리밍이 가능합니다. 
즉, 일반적인 요청/응답 방식이 아니고 서버와 클라이언트가 서로 동시에 데이터를 스트리밍으로 주고 받을 수 있다는 것 입니다.
높은 메시지 압축률과 성능 HTTP/2의 또다른 장점 중 하나는 HTTP를 사용하는 전송보다 높은 헤더 압축률을 보장한다는 점입니다. 
gRPC에서는 HTTP/2에 의한 압축뿐만 아니라 protoBuf에 의한 메시지 정의에 의해서 메시지 크기를 획기적으로 줄일 수 있습니다. 
메시지의 크기가 줄어드는 것은 곧 네트워크 트래픽이 줄어드는 것을 의미하기 때문에 시스템 리소스를 절약하고 성능을 높일 수 있습니다.

* Protocol buffers(protoBuf)
프로토콜 버퍼는 구조화 된 데이터를 직렬화하기 위한 유연하고 효율적인 자동화 된 메커니즘이다. 
XML은 작지만 더 빠르고 단순하다. 데이터를 한번 구성하는 방법을 정의한 다음 특수 생성된 소스코드를 사용하여 
다양한 데이터 스트림간에 구조화 도니 데이터를 쉽게 읽고 쓸 수 있으며 다양한 언어를 사용 할 수 있다. 
이전형식으로 컴파일 된 배포된 프로그램을 손상시키지 않고 데이터 구조를 업데이트 할 수도 있다.

gRPC는 기본적으로 protocol Buffer를 사용한다. Protocol Buffer는 .proto 확장자를 사용하는 txt 파일에 
직렬화(serialize)하고자 하는 데이터 구조를 정의한다.

message Person {
  string name = 1;
  int32 id = 2;
  bool has_ponycopter = 3;
}
이렇게 proto 파일을 정의하고 나면, protocol buffer compiler인 protoc를 사용해서 원하는 언어로
(proto 파일 안에 정의해둔 언어로) 컴파일 할 수 있다. 예를 들어 c++를 선택하면 message Person은 Class Person으로 컴파일 된다.

* Bi-directional streaming and integrated auth
양방향 스트리밍 및 http/e 기반 전송을 통한 완벽하게 통합된 인증 플러그 기능 지원.
gRPC는 다양한 인증 메커니즘과 함께 작동하도록 설계되었으므로 gRPC를 사용하여 안전하게 다른 시스템과 통신 할 수 있다.
지원되는 메커니즘(Google 토큰 기반 인증을 사용하거나 사용하지 않는 SSL/TLS)을 사용하거나 제공된 코드를 확장하여 
자체 인증 시스템을 플러그인 할 수 있다. 
또한 gRPC는 채널을 만들거나 전화를 걸 때 필요한 모든 인증 정보를 자격증명으로 제공 할 수 있는 간단한 인증 API를 제공한다.

- 지원되는 인증 메커니즘
다음 인증 메커니즘이 gRPC에 내장되어 있습니다.
SSL/TLS : gRPC는 SSL/TLS 통합을 지원하며 SSL/TLS를 사용하여 서버를 인증하고 클라이언트와 서버간에 교환되는 
모든 데이터를 암호화한다. 클라이언트가 상호 인증을 위한 인증서를 제공 할 수 있는 선택적 메커니즘을 사용 할 수 있다.
Google 과의 토큰 기반 인증 : gRPC는 메타 데이터 기반 자격 증명을 요청 및 응답에 첨부하는 
일반 메커니즘(아래에서 설명 함)을 제공한다.
gRPC를 통해 Google API에 엑세스하는 동안 엑세스 토큰(일반적으로 OAuth2 토큰)을 얻는 추가 지원은 특정 인증 흐름에 대해 제공됩니다.


## gRpc 기본개념

* 4가지 service method
1. Unary RPC
서버에 single request를 보내면, 서버는 single response를 돌려준다. (일반 함수 호출과 같음)
rpc SayHello(HelloRequest) returns (HelloResponse){ ... }

2. Server streaming RPC 서버에 single request를 보내면, 서버는 stream을 돌려준다. Stream에는 message 시퀀스가 들어있다. 
클라이언트는 더 이상의 message가 없을 때까지 stream을 읽어들인다.
rpc LotsOfReplies(HelloRequest) returns (stream HelloResponse){ ... }

3. Client streaming RPC 클라이언트가 주어진 stream을 이용하여 message sequence를 서버에 보낸다. 
클라이언트는 메시지들을 모두 작성하고 나면, 서버가 읽고 response를 주기를 기다린다.
rpc LotsOfGreetings(stream HelloRequest) returns (HelloResponse){ ... }

4. 양방향 streaming RPC Read-write stream을 사용하여 클라이언트와 서버 두 측 모두 message sequence를 보낸다. 
두 stream은 독립적으로 동작하여, 클라이언트와 서버는 원하는 순서대로 읽어들일 수 있다. 
예를 들어 서버는 클라이언트의 모든 메시지를 읽은 뒤 response를 write할 수도, 아니면 번갈아 가며 한 메시지씩 
읽고 쓸 수도 있다. 각 stream에서 메시지의 순서는 보존된다
rpc BidiHello(stream HelloRequest returns (stream HelloResponse)


## API 사용하기

gRPC는 .proto 파일에 정의된 service 로 부터 client와 server side code를 만들어주는 protocol buffer compiler를 제공한다.

서버사이드 : 서버는 service에 정의된 method를 구현하고, 클라이언트의 호출을 대응하기 위해서 gRPC 서버를 운영한다. 
gRPC 구조가 들어오는 요청을 디코드하고, 서비스 method를 실행하며, service response를 인코드해준다.
클라이언트 사이드: 클라이언트는 (일부 언어에서는) stub이라고 불리는 로컬 오브젝트를 갖고 있다. 
stub은 서비스에 정의된 것과 같은 method를 구현한다. 클라이언트는 파라미터를 적절한 protocol buffer type으로 만들어 
stub에 있는 method를 호출하기만 하면 된다. gRPC가 서버로 요청 전송과 응답 반환을 관리해준다.


## 동기 vs 비동기

서버에서 응답이 올때까지 block 하는 동기식 RPC 호출은 RPC가 원하는 프로시져 콜의 추상화에 가장 가깝다. 
그러나 네트워크는 근본적으로 비동기식이고, 대부분의 경우 RPC가 현재 쓰레드를 블락하지 않도록 하는 것이 도움이 된다.
gRPC는 동기와 비동기를 둘다 지원한다.



## RPC 생명 주기

**Unary RPC**
- 클라이언트가 stub에 있는 메소드를 호출하면, 서버는 RPC가 동작한다는 알림을 받는다. 이때 클라이언트의 메타데이터, 메소드 이름, 
그리고 (가능하다면) 데드라인이 명시된다.
- 서버는 (response 전에 보내야하는) 스스로의 메타데이터를 바로 보내주거나, 혹은 클라이언트의 요청 메시지가 있을때까지 기다린다. 
어떤 것이 먼저 일어날지는 어플리케이션에 따라 다르다.
- 서버가 클라이언트의 요청 메시지를 받으면, response를 생성한다. client에 response를 전달 시, status code와 (옵션) status message, 
(옵션) meta 데이터가 따라 붙는다.
- Status 가 OK면 클라이언트를 response 받고, 이로서 client 쪽의 호출은 끝난다.

Server streaming RPC, Client streaming RPC 한쪽이 stream of response 혹은 stream of request 를 보낸다는 점을 제외하면, 
Unary RPC와 동일하다.

Bidirectional streaming RPC 클라이언트가 호출하고, 서버가 메타데이터와 메소드, 데드라인을 받은 후, 서버에서는 스스로의 metadata를 보낼지 
혹은 클라이언트가 요청을 전송하는 것을 기다릴지 선택한다.

이후에는 application에 다라 다른데, 클라이언트와 서버가 읽기와 쓰기를 어떤 순서로도 할 수 있기 때문이다. 
stream은 독립적으로 운영되므로 서버는 요청이 모두 올 때 까지 기다리거나 클라이언트와 핑퐁을 할수도 있다.


**데드라인 / 타임아웃**
위에서 클라이언트가 메소드 호출 시에 ~데드라인~ 이 포함된다고 했다. gRPC는 클라이언트들이 RPC 호출을 얼마나 기다릴 수 있는지 
적을수 있게 했다. (DEADLINE) 서버 측에서는, 특정 RPC가 타임아웃되었는지 혹은 RPC를 마칠때까지 얼마나 남았는지 쿼리할 수 있다.

**RPC 종료**
gRPC에서는 클라이언트와 서버가 RPC의 성공여부에 대해서 독립적이고 지역적인 판단을 내리고, 이 결론은 서로 맞지 않을 수도 있다. 
이는, 서버에서는 “ 나 내 response 다 보냈음 하하하하하 !” 해서 성공해도, 클라이언트에서는 “response 데드라인 이후에 왔어 ;
(“ 할 수도 있다는 것을 의미한다.

**RPC 취소하기**
클라이언트나 서버 둘다 RPC를 언제든지 종료할 수 있다. 취소 액션은 RPC를 바로 종료하여 추가적인 작업이 없도록 한다. 
취소는 ‘undo’의 개념은 아니다.

**Metadata**
메타데이터는 RPC call에 대한 정보이다(주로 string key- string value 형태를 띔)

**Channel**
gRPC 채널은 특정 호스트와 포트에, gRPC 서버와의 연결을 제공한다. 채널은 client stub을 생성할 때 사용한다. 
클라이언트는 기본 gRPC 형태를 변경하는 채널 인자를 설정할 수 있다. 예를 들어 메시지 압축 옵션 등. 
채널은 connected 와 idle 상태를 포함하여 상태값을 갖는다. 어떻게 채널을 닫는지는 언어에 따라 다르다.

**인증 (Authentication)**
gRPC는 두가지 인증 매커니즘을 지원한다.
SSL(Secure Socket Layer) / TLS(Transport Layer Security) 서버를 인증하고, 클라이언트와 서버 간 교환된 모든 데이터를 암호화하는데 사용한다.
Token기반 인증 (with Google) Google API 에 gRPC 접근할때는 OAuth2 token과 같은 access token이 필요하다.  여기서도 channel은 SSL/TLS로 보안됨.





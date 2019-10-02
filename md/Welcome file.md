## Installing Rails

    http://www.rubyinstaller.org/downlods
    
    ruby -v
    
    http://www.sqlite.org/downlods.html
    sqlite3 --version
    
    cd /ruby install 경로 
    ruby dk.rb init 
    ruby dk.rb install
    
    http://nodejs.org/downlod/
    node -v
    
    gem install rails # ruby on rails install
    rails --version
    
    ## Ruby Style

 Guide
===================================
## 자료형: 

    3가지의 자료형을 자동으로 인식 (numbers, boolean, strings)

## 연산자: 

    산술 : + (덧셈). - (뺄셈). * (곱셈). / (나눗셈) ** (거듭제곱 : 23은 2의 3승), % (나머지)
    관계: == (같다). != 다르다) >, >= (크다. 크거나 같다) |< <= (작다. 작거나 같다)
    대입: = (조건부대입, 변수가 비어있는 경우에만 대입)
    논리: && (AND), |(OR)
    3.

 ## 주석: 

    - 단일행주석: # 단일행 주석입니다
    - 복수행주석: 
    	- =begin
                   복수행주석
                   입니다.
                 =end
    
   ##  표준입출력

    - 출력:
      puts "hi, ruby" (자동개행)
      print "Hi, ruby" (개행불가)
    - 입력:
      my_input=gets.chomp(맨뒤의 Enter키 무시)
      my_input=gets(Enter키 누르기전까지 내용인식)
      
    

## 파일입출력

    - 파일생성: file=File.new('test.txt','w+')
    - 파일열기: file=File.open('test.txt','w+')
    - 파일읽기: 
    File.read('test.txt')
    File.readlines('test.txt')
    - 파일존재여부: File.file?('test.txt')
    - 파일정보 확인: if File.zero?("test.txt")
                      file = File.open("test.txt", "r+")
                      puts file.size
                    end
    - 파일닫기: file.close
    - 파일모드: 
    r(read-only)
    r+(read-write)
    w(write-only)
    w+(read-write)
    a(write-only)
    a+(read-write)
    - 파일 모드 확인:
     File.readable?("test.txt")
     File.writable?("test.txt")
     File.executable?("test.txt")
     
   
 ## 범위

      - 마침표 2개 
        [Syntax] 시작값 종료값 (종료값 포함) my_array = (1..5).to_a
    puts my_array #[1,2,3,4,5)
    - 마침표 3개 
    [Syntax] 시작값.. 종료값 (종료값 미포함)
    my_array = (1...5).to_a puts my_array # [1,2,3,4]
    
    
## 코드블록 

    - 한줄로 쓸 때: {#수행될 코드}
    - 여러행으로 쓸 때: do | 파라미터

## 제어문

    - 조건문 : 
    if elsif else end 
    puts "True" if true (한줄 문) -
    unless .. else .. end | puts "False" unless false (한줄 unless문) | | case .. when .. when .. else .. end 
    
    - 반복문 : 
    while .. end
    until . end 
    for 변수 in 시작값, 종료값 ~ end (종료값까지) 
    for 반복문 for 변수 in 시작값...종료값 ~ end (종료값 이전까지).
    loop do-end
    loop {-} 
    
  
  9. 컬렉션 : 

    - 배열:
    1차원 배열 
    my_array = [1.2.3]
    my_array[0] # 반환값은 1
    2차원 배열 
    my_2d_array = [[1,2,31.[4,5,6]] 
    my 2d array[0][1] # 반환값은 2
    배열 마지막에 원소 추가 
    my_array.push(4) # my_array는 [1,2,3,4]
    배열의 마지막 원소 추출
    my_array.pop
    - 해쉬(해쉬생성/정렬):
    배열과 유사하나 index를 문자로 사용가능
    일종의 key-value쌍의 맵관 동일
    my_hash = {"A"=> 1, "B"=>2, "C" => 3} 
    my_hash[C] # 반환값은 3
    my hash[Bj = 4 #키 B 의 값이 20에서 4로 변경됨
    my_hash = Hash.new # my_hash = 과 동일 기능 // 해쉬 생성
    my_hash.sort_by do |key, value|
        value 
    end
    해쉬를 사용하여 동일 Key를 사용할 때 메모리 낭비를 줄일 수 있다
    my_sym = animals 
    - 심볼
    여러 개의 해쉬에서 동일 Key를 사용해야 할 경우 유용하다
    my_hash1 = {":A"=>1. "B"=>2. "C" =>3}
    my_hash2 = {":A"=>4. "B" =>5, "C"=>6} # A,B,C는 my_hash1과 동일 메모리공간 사용!!
    puts my_hash1[:A]
    puts my_hash2[A] 
    - 반복자(.each, .tiles, .collect)
    배열이나 해쉬의 각 원소에 대해 순차적으로 코드블록의 내용을 수행한다.
    (해쉬에 사용)
    [Syntax] 해쉬명.each코드블록
    my_hash = {":A"=>1. "B"=>2. "C" =>3}
    my_hash.each do |key, value|
        puts "#{key}:#{value}"
    end
    (배열에 사용)
    my_array = [1,2,3]
    my_array.each do |x|
        puts x*2
    end // each
    
    정해진 횟수만큼 반복한다
    [Syntax] 횟수 times 코드블록
    5.times do 
        puts "Hi! Ruby." 
    end
    // times
    배열 등의 각 원소값에 동일 작업을 한다.
    arr1 = [1,2,3,4,5] 
    arr2 = arr1.collect! {x|x*2}
    
   
 ## 프로시져: 

    Proc 클래스를 사용하여 선언할 수 있다. 
    [Syntax] 프로시져명 = Proc.new 코드블록
    pr1 = Proc.new {{x,yl x*y}
    
    프로시져를 호출할 땐 &다 .call을 사용한다. 
    pr1 = Proc.new {\x.yl x*y} 
    &pr1 2,3 #결과는 6 # 혹은 pr1.call 2,3
    
    
  ## 람다
 

    매개변수로 코드블록를 넘길 때 사용한다. 
     [Syntax] lambda 코드블록

    (예 1) a = lambda {Ixl x*3) puts a.call 6 # 180이 출력된다.
    (예 2) str_array = ["leonardo", "donatello", "raphael", "michaelangelo") 
    symbolize = lambda { Iss.to_sym} # symbolize 에 람다로 코드블록 저장 
    symbols = str_array.collect(&symbolize) # str_array 의 각 원소를 심볼로 변경
    
  
## 메소드

    - 기본메소드: .length, .reverse, .upcase, .downcase, .capitalize, .include, .gsub, .split, .floor ...
    - Custom메소드: 
    def로 선언한다.메소드명은 소문자로 시작한다
    def my_method(name, age)
        puts "I'm #{name}, I'm #{age} years old"
    end
    
    메소드 호출은 메소드명으로 호출한다
    def my_method(name, age) 
        puts "I'm #{name}, I'm #{age} years old 
    end
    my_method("Mike", 26) # "Im Mike, I'm 26 years old"가 출력된다
    
    파라미터는 Default값 설정가능하다
    메소드 호출시 Argument를 지정하지 않으면 Default값으로 할당
    def my_method(name, age=30) 
        puts "I'm #{name}, I'm #{age} years old 
    end
    my_method("Mike", 26)
    my_method("Mike")
    파라미터에 Optional파라미터를 설정할 수 있다.
    def my_method(*my_info) 
        puts "I'm #{my_info[0]}, I'm #{my_info[1]} years old 
    end
    my_method("Mike", 26)
    return을 이용해 값을 반환할 수 있다
    def squares(a,b,c)
        return a*a, b*b, c*c
    end
    
    arr = squares(2,3,6)
    puts arr
    
    메소드는 다른 메소드의 Argument로 사용가능
    
    - 변수유형: 어디서든 접근이 가능하다. 변수명 앞에 $문자를 사용한다.
    $x = 5
    
    def change 
        $x = 3
    end
    
    change
    puts $x # 3
    
## 클래스

    - 선언/객체 생성: class키워드로 선언, 클래스명의 첫문자는 대문자로 해야 한다 
      class Animals 
      end
      # 클래스에는 initialize 메소드가 있어야 한다 
      class Pets 
        def initialize
           puts "Hi, my pet" 
        end 
                end
    
    -  클래스 객체 생성: 
        [Syntax] 객체명 = 클래스명 new 서연 객체 생성
        class Pets 
          def initialize
            puts "Hi, my pet" 
          end 
        end
        p1 = Pets.new  # Hi, my pet
        p2 = Pets.new  # Hi, my pet 
    
        - 변수명 앞에 문자를 사용한다:
          class Pets 
            def initialize(name, age)
              @name = name
              @age = age 
            end 
          end
         
          - Instance 메소드 : 클래스안의 일반적인 메소드
            클래스밖에서 Instance 변수로 접근하기 위해 Getter/Setter메소드가 사용된다
              class Pets 
                def initialize(name, age)
                  @name = name
                  @age = age 
                end
                def get_name
                 @name 
                end
                def set_name=(name) # Setter
                  @name = name 
                end
            end
            p1 = Pets.new("Bbobby", 3) 
            p2 = Pets.new("Noorie", 6)
            p1.set_name("asdasd")
            puts.p1.get_name
            
            - Getter/Setter는 한줄표현가능:
            attr_reader - Getter 메소드와 동일
            attr_writer - Setter 메소드와 동일
            attr_accessor - Getter와 Setter 메소드 한번에
            class Pets # 왼쪽 소스의 Getter와 Setter를 name으로 한번에 구현
              attr_accessor name
              def initialize(name, age)
                @name = name
                @age = age 
              end
            end
            
            p1 = Pets.new("Bbobby", 3) 
            p2 = Pets.new("Noorie", 6)
            p1.name("asd")
           
            - 클래스 메소드: 클래스 자기자신이 직접호출할 수 있는 메소드
            self 키워드를 통해 정의할 수 있다
            class Pets 
                def self.greeting
                    puts "Hi, my pet" 
                end 
            end 
            Pets.greeting # 클래스명을 통해 직접 호출
            - 클래스 상수(Const): 변하지 않는 값, 대문자로 시작해야하며 모두 대문자로 명명
            class Calc
              PI = 3.14
            end
            puts Calc::PI # 3.14
            - to_s 메소드: 클래스객체를 출력시, 호출되는 메소드로 클래스내에 자동으로 Built-In
            - 상속: 
            상속받으면 부모클래스의 메소드 등을 사용가능: < 기호를 사용하여 상속받는다 
            class Dog < Animal # Dog class는 Animal 클래스를 상속받음
            부모, 자식클래스에 동일이름의 메소드가 있을 때는 자기 클래스의 메소드가 우선순위가 높다
            super 메소드를 사용하면 부모클래스의 메소드도 수행된다
            class Animal
              def initialize(name)
                @name = name
              end
            end
            
            class Cat < Animal
              def initialize(name, age)
                super(name)
                @age = age
              end
              def to_s
                "#{@name} is # {@age} t"
              end
            end
            - 접근제어: public, private, protected 지원
            public: 모든 클래스는 별도 지정하지 않으면 기본적으로 public 이다.
            private: 클래스 내부에서만 접근 가능하다.
            class Person 
              def initialize(age)
                @age = age end def show
                puts "#{@age} years = #{days_lived) days" 근제어
              end 
              private 
              def days_lived
                @age * 365 
              end 
            end
            protected: 클래스 자신과 자식클래스만 접근가능하다
       
     
## 모듈: 
    - 정의: 필요할때 로딩하여 사용할 수 있게 만어진 Ruby(.rb)파일
    [Syntax]
    module명
    end
    - 로딩: 모듈을 로드할 때는 require를 사용한다
    [Syntax] require '모듈명' # 필요시 디렉토리경로 써야 함
    클래스 안에서 모듈을 로드할 때는 include 를 사용한다
    module My_module
      def greeting
         puts "HI"
      end
    end
    class A
      include My_module
    end
    - 모듈을 사용할떄는 다음 구문형식 사용
    [Syntax1]
    모듈명.메소드명
    [Syntax2]
    모듈명::메소드명

## 구조체

    -Structs : 
      Struct클래스를 통해 선언한다
      initialize메소드와 accessor를 자동으로 생성해준다.
        
      Str = Struct.new(-a, :b) 
      s1 = Str.new(1,2)
      s2 = Str.new("1","2")
      puts s1.a #1이 출력된다. 
      puts s2.b #"2"가 출력된다.
    
    -OStruct: 
      Structs와 비슷하다. 
      속성을 갖지 않는다.
      OpenStruct 클래스를 통해 선언한다.
    
      require 'ostruct'
    
      person = OpenStruct.new
      person.name = 'John'
      person.age = 42
      person.salary = 250
      pusts person.name # John
    
    
    
        	    
        

	

    
<!--stackedit_data:
eyJoaXN0b3J5IjpbLTEzNTkxNDE2NzYsLTQ3MjA1MDE3MV19
-->
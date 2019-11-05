
# Redis Clustering

   preview
   
    Server #1: 
        master: 192.168.2.128:6379
        slave: 192.168.2.128:6380
    Server #2: 
        master: 192.168.2.129:6379
        slave: 192.168.2.129:6380
    Server #3: 
        master: 192.168.2.130:6379
        slave: 192.168.2.130:6380


## 서버별 설치 내용

**1. pre-install**

- 필수패키지 설치

      [root@localhost ~]# yum update -y
      [root@localhost ~]# yum install wget net-tools make gcc tcl libc*-dev -y
      [root@localhost ~]# yum install ruby -y
      [root@localhost ~]# gem update
      [root@localhost ~]# ruby -v
        ruby 2.0.0p648 (2015-12-16) [x86_64-linux]

- 리눅스 설정

      [root@localhost ~]# vi /etc/selinux/config
        SELINUX=disabled
      [root@localhost ~]# systemctl stop firewalld
      [root@localhost ~]# systemctl disable firewalld
      [root@localhost ~]# reboot

2. install redis

- install

      [root@localhost ~]# wget http://download.redis.io/redis-stable.tar.gz
      [root@localhost ~]# tar xvzf redis-stable.tar.gz
      [root@localhost ~]# cd redis-stable
      [root@localhost redis-stable]# make install
      [root@localhost redis-stable]# make test
         \o/ All tests passed without errors!        <--- 이 메세지가 나오면 OK

- config file setting

      [root@localhost redis-stable]# mkdir /root/redis-stable/conf
      [root@localhost redis-stable]# cp /root/redis-stable/redis.conf /root/redis-stable/conf/c_slave.conf
      [root@localhost redis-stable]# cp /root/redis-stable/redis.conf /root/redis-stable/conf/a_master.conf
      [root@localhost redis-stable]# mv /root/redis-stable/redis.conf /root/redis-stable/conf/redis.conf.bak

1) master (/root/redis-stable/conf/a_master.conf)

       # bind 127.0.0.1    <-- 주석처리
       protected-mode no
       port 6379
       pidfile /var/run/redis_6379.pid
       cluster-enabled yes
       cluster-config-file /root/redis-stable/conf/nodes-6379.conf
       cluster-node-timeout 15000

2)slave ( /root/redis-stable/conf/c_slave.conf)

    # bind 127.0.0.1    <-- 주석처리
    protected-mode no
    port 6380
    pidfile /var/run/redis_6380.pid
    cluster-enabled yes
    cluster-config-file /root/redis-stable/conf/nodes-6380.conf
    cluster-node-timeout 15000

- Setting Aliases

      [root@localhost ~]# vim ~/.bash_profile
    
      ##Master port 6379
      alias mstart='redis-server /root/redis-stable/conf/a_master.conf &'
      alias mstop='redis-cli -p 6379 shutdown'
      alias mrediscli='redis-cli -c -p 6379'
    
      ##Slave port 6380
      alias sstart='redis-server /root/redis-stable/conf/c_slave.conf &'
      alias sstop='redis-cli -p 6380 shutdown'
      alias srediscli='redis-cli -c -p 6380'
    
      [root@localhost ~]# source ~/.bash_profile

- install ruby for redis

      [root@localhost ~]# gem install redis -v 3.3.5

3. Start redis

       [root@localhost ~]# mstart
       [root@localhost ~]# sstart

# clustering

1. Make Cluster
- 아무 서버에서나 수행하면 됨.

      [root@localhost ~]# /root/redis-stable/src/redis-trib.rb create 192.168.2.128:6379 192.168.2.129:6379 192.168.2.130:6379
      WARNING: redis-trib.rb is not longer available!
      You should use redis-cli instead.
    
      All commands and features belonging to redis-trib.rb have been moved
      to redis-cli.
      In order to use them you should call redis-cli with the --cluster
      option followed by the subcommand name, arguments and options.
    
      Use the following syntax:
      redis-cli --cluster SUBCOMMAND [ARGUMENTS] [OPTIONS]
    
    
      [root@localhost src]# redis-cli --cluster create --cluster-replicas 1 192.168.2.128:6379 192.168.2.129:6379 192.168.2.130:6379 192.168.2.128:6380 192.168.2.129:6380 192.168.2.130:6380


- Cluster 확인

      [root@localhost conf]# redis-cli
      127.0.0.1:6379> cluster nodes
      c30755dfaaa7de3b529a6c160788ca1db8c2f9c5 192.168.2.129:6379@16379 master - 0 1572325726060 2 connected 5461-10922
      22f3ad2e09151cb03aabd56e43d7056e2ec38287 192.168.2.128:6379@16379 master - 0 1572325727065 1 connected 0-5460
      25083ce77c0eb6012094c2e5183802e62c3d46a2 192.168.2.130:6379@16379 myself,master - 0 1572325727000 3 connected 10923-16383

2. Add Slave

       redis-cli add-node --slave --master-id 22f3ad2e09151cb03aabd56e43d7056e2ec38287 192.168.2.128:6380 192.168.2.128:6379
       redis-cli add-node --slave --master-id c30755dfaaa7de3b529a6c160788ca1db8c2f9c5 192.168.2.129:6380 192.168.2.129:6379
       redis-cli add-node --slave --master-id 25083ce77c0eb6012094c2e5183802e62c3d46a2 192.168.2.130:6380 192.168.2.130:6379



**- Cluster 해제**

1. reset

       127.0.0.1:6379> cluster reset

2. Redis master/slave 중지

       [root@localhost src]# mstop
       [root@localhost src]# sstop

3. config 삭제

       [root@localhost conf]# rm nodes-6379.conf
       [root@localhost conf]# rm nodes-6380.conf

4. Redis master/slave 시작

       [root@localhost src]# mstart
       [root@localhost src]# sstart

5. 클러스터링

       [root@localhost src]# redis-cli --cluster create --cluster-replicas 1 192.168.2.128:6379 192.168.2.129:6379 192.168.2.130:6379 192.168.2.128:6380 192.168.2.129:6380 192.168.2.130:6380


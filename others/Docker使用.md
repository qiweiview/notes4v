
## 容器篇
### 在ubuntu15容器中输出hello world
```
docker run ubuntu:15.10 /bin/echo "Hello world"

#参数解析
docker: Docker 的二进制执行文件。

run:与前面的 docker 组合来运行一个容器。

ubuntu:15.10指定要运行的镜像，Docker首先从本地主机上查找镜像是否存在，如果不存在，Docker 就会从镜像仓库 Docker Hub 下载公共镜像。

/bin/echo "Hello world": 在启动的容器里执行的命令
```
### 创建交互式容器
```
runoob@runoob:~$ docker run -it ubuntu:15.10 /bash

#参数解析
-t:在新容器内指定一个伪终端或终端。

-i:允许你对容器内的标准输入 (STDIN) 进行交互。


/* 此时已进入一个容器的系统，按ctrl+D或exist退出*/
```

### 创建一个以进程方式运行的容器
```
docker run -d ubuntu:15.10 /bin/sh -c "while true; do echo hello world; sleep 1; done"

```

### 查看运行容器
```
docker ps
```

### 查看所有容器
```
docker ps -a
```

### 查看最后一次创建的容器
```
docker ps -l 
```

### 移除容器
```
docker rm 2b1b7a428627  
```

### 查看容器控制才输出
```
docker logs 2b1b7a428627
```

### 停止容器
```
docker stop 2b1b7a428627
```


### 运行容器
```
docker star 2b1b7a428627
```

### 创建一个web容器
```
docker pull training/webapp  # 载入镜像
docker run -d -P training/webapp python app.py

#参数说明
-d:让容器在后台运行。

-P（大写）:是容器内部端口随机映射到主机的高端口。
-p（小写） : 是容器内部端口绑定到指定的主机端口。


docker run -d -p 3513:5000 training/webapp python app.py/*映射到3513端口上*/

```

### 查看端口映射关系
```
docker port bf08b7f2cd89
```

### 查看容器内运行进程
```
docker top bf08b7f2cd89
```

### 检测web容器运行状态
```
docker inspect bf08b7f2cd89
```
## 镜像篇
### 列出主机所有镜像
```
docker images

runoob@runoob:~$ docker images           
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
ubuntu              14.04               90d5884b1ee0        5 days ago          188 MB
php                 5.6                 f40e9e0f10c8        9 days ago          444.8 MB

#参数说明

REPOSITORY：表示镜像的仓库源

TAG：镜像的标签

IMAGE ID：镜像ID

CREATED：镜像创建时间

SIZE：镜像大小

#同一仓库源可以有多个 TAG，代表这个仓库源的不同个版本，如ubuntu仓库源里，有15.10、14.04等多个不同的版本，我们使用 REPOSITORY:TAG 来定义不同的镜像。
```

### 运行镜像

1. 所以，我们如果要使用版本为15.10的ubuntu系统镜像来运行容器时，命令如下：
```
runoob@runoob:~$ docker run -t -i ubuntu:15.10 /bin/bash 
root@d77ccb2e5cca:/#
```
2. 如果要使用版本为14.04的ubuntu系统镜像来运行容器时，命令如下：
```
runoob@runoob:~$ docker run -t -i ubuntu:14.04 /bin/bash 
root@39e968165990:/# 
```
```
##如果你不指定一个镜像的版本标签，例如你只使用 ubuntu，docker 将默认使用 ubuntu:latest 镜像
```

### 获取一个镜像
```
docker pull ubuntu:13.10
```

### 查找镜像
```
 docker search httpd
 
 #结果参数
NAME:镜像仓库源的名称

DESCRIPTION:镜像的描述

OFFICIAL:是否docker官方发布
```

### 创建镜像
1. 从已经创建的容器中更新镜像，并且提交这个镜像



提交容器副本
```
docker commit -m="has update" -a="runoob" e218edb10161 runoob/ubuntu:v2

#参数介绍
-m:提交的描述信息

-a:指定镜像作者

e218edb10161：容器ID

runoob/ubuntu:v2:指定要创建的目标镜像名
```

2. 使用 Dockerfile 指令来创建一个新的镜像

构建镜像
```
touch Dockerfile #创建文件
输入：
FROM    centos:6.7
MAINTAINER      Fisher "fisher@sudops.com"

RUN     /bin/echo 'root:123456' |chpasswd
RUN     useradd runoob
RUN     /bin/echo 'runoob:123456' |chpasswd
RUN     /bin/echo -e "LANG=\"en_US.UTF-8\"" >/etc/default/local
EXPOSE  22
EXPOSE  80
CMD     /usr/sbin/sshd -D


docker build -t runoob/centos:6.7 etc/dockerFile

#参数说明
-t ：指定要创建的目标镜像名

etc/dockerFile ：Dockerfile 文件所在目录，可以指定Dockerfile 的绝对路径
```

### 为创建的容器添加标签
```
docker tag 860c279d2fec runoob/centos:dev

参数说明
860c279d2fec:指的是image id
runoob/centos:镜像名
dev:标签名
```

### 绑定容器端口及地址
```
docker run -d -p 127.0.0.1:5000:5000/udp training/webapp python app.py
#通过访问127.0.0.1:5001来访问容器的5000端口


-P（大写） :是容器内部端口随机映射到主机的高端口。
-p（小写） : 是容器内部端口绑定到指定的主机端口。
```

### 自定义命名容器
```
docker run -d -P --name runoob training/webapp python app.py
```

# 应用篇
运行fastDFS

```
#下载镜像
docker pull mypjb/fastdfs

#创建文件夹
mkdir /home/fastdfs

#运行镜像
docker run --add-host fastdfs.net:106.12.111.159 --name fastdfs --net=host -e TRACKER_ENABLE=1 -e NGINX_PORT=3513 -v /home/fastdfs:/storage/fastdfs -it mypjb/fastdfs

#退出重启
docker restart fastdfs

#开启端口
firewall-cmd --zone=public --add-port=81/tcp --permanent;firewall-cmd --reload;
```
## 删除悬虚镜像
```
docker image prune
```
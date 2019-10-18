# CentOS7安装Docker
## 安装一些必要的系统工具：
```
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
```
## 添加软件源信息：
```
sudo yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
```
## 更新 yum 缓存：
```
sudo yum makecache fast
```
## 安装 Docker-ce：
```
sudo yum -y install docker-ce
```
## 启动 Docker 后台服务
```
sudo systemctl start docker
```
## 测试运行 hello-world
```
[root@runoob ~]# docker run hello-world
```
## 启动 Docker CE
```
$ sudo systemctl enable docker
$ sudo systemctl start docker
```


# CentOS6安装Docker

* Download the packages you need:
* docker-io是早期的docker版本，安装会冲突
```
RHEL6

curl -O -sSL https://get.docker.com/rpm/1.7.1/centos-6/RPMS/x86_64/docker-engine-1.7.1-1.el6.x86_64.rpm

RHEL7

curl -O -sSL https://get.docker.com/rpm/1.7.1/centos-7/RPMS/x86_64/docker-engine-1.7.1-1.el7.centos.x86_64.rpm
```
 

 

* Use yum to install it on your system
```
yum localinstall --nogpgcheck docker-engine-1.7.1-1.el6.x86_64.rpm
```
 

* Once its completed we can start Docker:
```
service docker start
```

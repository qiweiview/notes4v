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
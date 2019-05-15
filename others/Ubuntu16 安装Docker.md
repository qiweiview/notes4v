# Ubuntu 16.04 安装 Docker

## 1.选择国内的云服务商，这里选择阿里云为例
```
curl -sSL http://acs-public-mirror.oss-cn-hangzhou.aliyuncs.com/docker-engine/internet | sh -
```
## 2.安装所需要的包
```
sudo apt-get install linux-image-extra-$(uname -r) linux-image-extra-virtual
```
## 3.添加使用 HTTPS 传输的软件包以及 CA 证书
```
sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates
```
## 4.添加GPG密钥
```
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
```
## 5.添加软件源
```
echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" | sudo tee /etc/apt/sources.list.d/docker.list
```
## 6.添加成功后更新软件包缓存

```
sudo apt-get update
```
## 7.安装docker
```
sudo apt-get install docker-engine
```
## 8.启动 docker
```
sudo systemctl enable docker
sudo systemctl start docker
```
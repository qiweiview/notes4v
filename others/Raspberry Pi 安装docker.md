## 使用 APT 安装
### 1. 由于 apt 源使用 HTTPS 以确保软件下载过程中不被篡改。因此，我们首先需要添加使用 HTTPS 传输的软件包以及 CA 证书。

(这句不知道为啥要跑)
```
curl -fsSL get.docker.com -o get-docker.sh && sh get-docker.sh
```

```
$ sudo apt-get update

$ sudo apt-get install \
     apt-transport-https \
     ca-certificates \
     curl \
     gnupg2 \
     lsb-release \
     software-properties-common
```
鉴于国内网络问题，强烈建议使用国内源，官方源请在注释中查看。

### 2. 为了确认所下载软件包的合法性，需要添加软件源的 GPG 密钥。
```
$ curl -fsSL https://mirrors.ustc.edu.cn/docker-ce/linux/raspbian/gpg | sudo apt-key add -


# 官方源
# $ curl -fsSL https://download.docker.com/linux/raspbian/gpg | sudo apt-key add -
```
### 3. 然后，我们需要向 source.list 中添加 Docker CE 软件源：
```
$ sudo add-apt-repository \
    "deb [arch=armhf] https://mirrors.ustc.edu.cn/docker-ce/linux/raspbian \
    $(lsb_release -cs) \
    stable"


# 官方源
# $ sudo add-apt-repository \
#    "deb [arch=armhf] https://download.docker.com/linux/raspbian \
#    $(lsb_release -cs) \
#    stable"
```
以上命令会添加稳定版本的 Docker CE APT 源，如果需要测试或每日构建版本的 Docker CE 请将 stable 改为 test 或者 nightly。

## 安装 Docker CE
### 4. 更新 apt 软件包缓存，并安装 docker-ce。
```
$ sudo apt-get update

$ sudo apt-get install docker-ce
```

## 启动 Docker CE
```
$ sudo systemctl enable docker
$ sudo systemctl start docker
```
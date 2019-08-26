# Jenkins+Docker持续集成

## Docker安装
```
docker run --name devops-jenkins --user=root -p 8080:8080 -p 50000:50000 -v /home/jenkins:/var/jenkins_home -d jenkins/jenkins:lts
```

## Ubuntu安装
* 首先，我们将存储库密钥添加到系统。
```
wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | sudo apt-key add -
```

* 添加密钥后，系统将返回OK 。 接下来，我们将Debian包存储库地址附加到服务器的sources.list ：
```
echo deb http://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list
```

* 当这两个都到位时，我们将运行update ，以便apt-get将使用新的存储库：
```
sudo apt-get update
```

* 最后，我们将安装Jenkins及其依赖项，包括Java：
```
sudo apt-get install jenkins
```

* 使用systemctl我们将启动Jenkins：
```
sudo systemctl start jenkins
```

* 由于systemctl不显示输出，我们将使用其status命令来验证它是否成功启动：
```
sudo systemctl status jenkins
```

* ，输出的开始应显示服务处于活动状态，并配置为启动时启动：
```
● jenkins.service - LSB: Start Jenkins at boot time
  Loaded: loaded (/etc/init.d/jenkins; bad; vendor preset: enabled)
  Active:active (exited) since Thu 2017-04-20 16:51:13 UTC; 2min 7s ago
    Docs: man:systemd-sysv-generator(8)
```



## 私有仓库Registry安装
```
docker run --name devops-registry -p 5000:5000 -v /home/registry:/var/lib/registry -d registry
```

## Jenkins配置
### 选择安装默认插件
### 注册管理员
### 安装相关插件
* Role-based Authorization Strategy
* SSH	 
* docker-build-step	 
* Email Extension Template
* Generic Webhook Trigger

### 配置Jenkins属性及相关权限
* 系统设置-Global Tool Configuration-配置jdk(需要oracle账号和密码)
![](https://i.loli.net/2019/08/12/WtNRs42O3gbmfUu.png)
* maven配置
![](https://i.loli.net/2019/08/12/zGWL8af2qi4uK1o.png)
* ssh设置
![](https://i.loli.net/2019/08/12/oXgSYya6iRr1uQ7.png)
* docker配置
![](https://i.loli.net/2019/08/12/s2AP6bSHwnDhQ8j.png)

设置docker远程访问（这个会将docker暴露在公网上，很不安全）
```
vim /usr/lib/systemd/system/docker.service
在ExecStart=/usr/bin/docker daemon 后追加 -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock

如：
ExecStart=/usr/bin/docker daemon -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock
```



## 运行脚本

* local shell
```
sudo cp $WORKSPACE/zephyr-bootdemo/target/*.jar  /home/jenkins_jar
sudo docker build -f /home/jenkins_jar/Dockerfile -t zephyrfr:latest /home/jenkins_jar
sudo docker tag zephyrfr cnigcc.cn:5000/zephyrfr
sudo docker push cnigcc.cn:5000/zephyrfr
```

* remote shell
```
 sudo docker pull cnigcc.cn:5000/zephyrfr
 sudo docker stop  zephyrfr
 sudo docker rm  zephyrfr
 sudo docker run -d --name zephyrfr -p 9000:9000 cnigcc.cn:5000/zephyrfr
```


* 判断创建Dockerfile文件
```
if [ -f /home/jenkins_jar/Dockerfile ]
then sudo echo "exist"
else sudo echo -e  "FROM openzipkin/jre-full:1.8.0_201 \nCOPY zephyrfr.jar /home \nENTRYPOINT [\"java\",\"-jar\",\"/home/zephyrfr.jar\"]" > Dockerfile
fi
```






# 问题 
## 1. 执行sudo命令时出现“sudo: no tty present and no askpass program specified”

* 执行
```
$ sudo visudo
```
* 在文件的末尾加上一行 
```
jenkins ALL=(ALL) NOPASSWD: ALL
```

* 保存文件（注意保存的时候修改文件名，文件名后缀不要加上默认的.tmp，即可覆盖原文件） 
```Ctrl+O```
* 退出编辑 
```Ctrl+X```
* 重启Jenkins服务 
```$ /etc/init.d/jenkins restart```

## 2. jdk版本太低无法编译高版本项目

修改配置里的jdk使用本地jdk（会报不是jdk目录，但是还是可以用）


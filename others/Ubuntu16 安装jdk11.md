## 如何在Ubuntu 16.04 LTS（Xenial）上安装Oracle Java 11
由Rahul K.撰写，于2018年10月7日更新
 JAVA java，Java 11，Java 11 LTS，Ubuntu 16.04 
Java是用于系统软件开发和Web应用程序的流行编程语言。您需要安装Java Development Kit（JDK）和Java Runtime Environment（JRE）来设置Java开发环境。JDK编译源java文件并生成java类文件。JRE用于运行该中间类文件。本教程将指导您在Ubuntu 16.04 LTS Xenial系统上安装Oracle Java 11 LTS版本。
### 第1步 - 预先存在
在开始安装之前，以sudo用户身份登录shell并安装一些必需的软件包。
sudo -i
apt install wget libasound2 libasound2-data

### 第2步 - 下载Java 11
从官方下载页面下载最新的Java SE Development Kit 11 LTS debian文件，或使用以下命令从命令行下载。
deb安装包拖到服务器

### 第3步 - 在Ubuntu 16.04上安装Java 11
使用默认的Debian软件包安装程序（dpkg）在系统上安装下载的Java。只需在终端上执行以下命令即可
dpkg -i jdk-11_linux-x64_bin.deb

***然后将Java 11配置为系统上的默认版本（重要，地址要对应）。***
![ubuntu1804.png](https://i.loli.net/2019/01/19/5c42c9d45b90a.png)
update-alternatives --install / usr / bin / java java / usr / lib / jvm / jdk-11 / bin / java 2
update-alternatives --config java



根据上面的截图，安装了3个版本。Java 11列在数字3上，因此输入3并按Enter键。现在，Java 11作为默认Java版本安装在我的Ubuntu 16.04系统上。
还有一些其他二进制文件设置为JDK安装的默认值。执行命令将javac和jar设置为默认值：
update-alternatives --install / usr / bin / jar jar / usr / lib / jvm / jdk-11 / bin / jar 2
update-alternatives --install / usr / bin / javac javac / usr / lib / jvm / jdk-11 / bin / javac 2
update-alternatives --set jar / usr / lib / jvm / jdk-11 / bin / jar
update-alternatives --set javac / usr / lib / jvm / jdk-11 / bin / javac

### 第4步 - 验证Java版本
现在使用以下命令检查系统上已安装的Java版本。
java -version

java版“11”2018-09-25
Java（TM）SE运行时环境18.9（版本11 + 28）
Java HotSpot（TM）64位服务器VM 18.9（版本11 + 28，混合模式）

### 第5步 - 设置Java环境变量
大多数基于Java的应用程序使用环境变量来工作。创建如下脚本。现在为Java设置所有必需的环境变量。此文件将在系统重新引导时自动重新加载设置。
sudo nano /etc/profile.d/jdk.sh

添加/更新以下值：
export J2SDKDIR = / usr / lib / jvm / java-11
export J2REDIR = / usr / lib / jvm / java-11
export PATH = $ PATH：/ usr / lib / jvm / java-11 / bin：/ usr / lib / jvm / java-11 / db / bin
export JAVA_HOME = / usr / lib / jvm / java-11
export DERBY_HOME = / usr / lib / jvm / java-11 / db

保存文件并退出。现在也将这些设置加载到当前活动shell
来源/etc/profile.d/jdk.sh

您已在Ubuntu 16.04 LTS系统上成功安装了Java 11。
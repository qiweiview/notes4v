# sonarqube教程

## 安装

### 创建账号
```
#创建账号并授权
useradd sonar
passwd sonar

#授予sudo权限
visudo
#在文件末尾增加
sonar    ALL=(ALL)       ALL
```

### 环境变量
```
#修改profile文件
sudo vi /etc/profile

#在文件末尾增加变量：SONAR_HOME
export SONAR_HOME=/usr/sonar/sonarqube-7.5

#使变量生效
source /etc/profile

#测试
echo $SONAR_HOME
```

### 配置文件
```
#修改配置文件
sudo vi $SONAR_HOME/conf/sonar.properties

#在配置文件开头增加以下配置

#数据库配置
sonar.jdbc.username=sonar
sonar.jdbc.password=Sonar@2019
sonar.jdbc.url=jdbc:mysql://localhost:3306/sonar?useConfigs=maxPerformance&rewriteBatchedStatements=true&characterEncoding=utf8&useUnicode=true&serverTimezone=GMT%2B08:00

#文件配置
sonar.path.data=/sonar/data
sonar.path.temp=/sonar/temp

#Web配置
sonar.web.host=0.0.0.0
sonar.web.port=9000
sonar.web.context=/
```

### 启动
```
#切换到sonar账号
su sonar

#启动
sh $SONAR_HOME/bin/linux-x86-64/sonar.sh start

#启动完成会看到以下输出
Starting SonarQube...
Started SonarQube.

#如果未完成启动可以使用console命令查看启动过程中的问题
sh $SONAR_HOME/bin/linux-x86-64/sonar.sh console
```

## 使用
* 项目目录下运行
```
mvn sonar:sonar  -Dsonar.host.url=http://10.16.0.102:9000  -Dsonar.login=352d356b92aa96ab7d9ba7096c666a87a7b457ce
```

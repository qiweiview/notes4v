# Linux设置JAVA_HOME.md

* vim /etc/profile #在打开的文件末尾添加如下内容
```
export JAVA_HOME=/home/znn/development/jdk1.8.0_111
export CLASSPATH=.:$JAVA_HOME/lib:$JRE_HOME/lib
export PATH=$JAVA_HOME/bin:$PATH
```
```
echo "export JAVA_HOME=/home/znn/development/jdk1.8.0_111">>/etc/profile
echo "export CLASSPATH=.:$JAVA_HOME/lib:$JRE_HOME/lib">>/etc/profile
echo "export PATH=$JAVA_HOME/bin:$PATH">>/etc/profile
```
* source /etc/profile 　　　#使配置文件立即生效

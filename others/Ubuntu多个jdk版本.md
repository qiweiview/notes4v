# Ubuntu多个jdk版本

## apt-get install 不会覆盖安装不同版本的jdk

## 查看安装的所有jdk版本
```
update-java-alternatives --list
```

## 设置默认的jdk
```
sudo update-java-alternatives --set
```

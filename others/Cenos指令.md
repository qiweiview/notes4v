1. 更新源
```
vi /etc/yum.repos.d/CentOS-Base.repo
//把新的源配置粘贴进去
yum makecache
```
2. 安装wget
```
yum -y install wget
```
# GitLab教程

## 离线安装
* [下载](https://packages.gitlab.com/gitlab/gitlab-ce)
* 脚本
```
curl -s https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh | sudo bash
```
* 安装
```
sudo yum install xxx.rpm
```

* 修改端口
```
sudo vi /etc/gitlab/gitlab.rb

external_url "http://192.168.200.200:8000"
```

* 修改仓库地址
```
vim /opt/gitlab/embedded/service/gitlab-rails/config/gitlab.yml  

host:xxx
```

* 应用设置，重启
```
gitlab-ctl reconfigure

gitlab-ctl restart
```

* 关闭防火墙
```
systemctl stop firewalld
```

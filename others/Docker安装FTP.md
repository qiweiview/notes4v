# Docker安装FTP
参考地址：https://github.com/stilliard/docker-pure-ftpd/wiki/Basic-example-walk-through
## 拉取镜像
```
docker pull stilliard/pure-ftpd:hardened

```

运行容器
```
docker run -d --name ftpd_server -p 21:21 -p 30000-30009:30000-30009 -e "PUBLICHOST=0.0.0.0" -v /home/ftpusers/test:/home/ftpusers/test stilliard/pure-ftpd:hardened
```
* **30000-30009** 表示同时容纳(30009-30000)/2=5个用户
* **-v /home/ftp:/home/ftpusers/bob** 映射文件夹

进入容器
```
docker exec -it ftpd_server /bin/bash
```

添加ftp用户
```
pure-pw useradd test -u ftpuser -d /home/ftpusers/test
chown ftpuser:ftpgroup /home/ftpusers/test
pure-pw mkdb

```


# Docker安装FTP
参考地址：https://github.com/stilliard/docker-pure-ftpd/wiki/Basic-example-walk-through
## 拉取镜像
```
docker pull stilliard/pure-ftpd:hardened

```

运行容器
```
docker run -d --name ftpd_server -p 21:21 -p 30000-30009:30000-30009 -e "PUBLICHOST=localhost" -e "ADDED_FLAGS=-d -d"  -v /home/ftp:/home/ftpusers/bob stilliard/pure-ftpd:hardened
```
* **30000-30009** 表示同时容纳(30009-30000)/2=5个用户
* **-v /home/ftp:/home/ftpusers/bob** 映射文件夹

进入容器
```
docker exec -it ftpd_server sh -c "export TERM=xterm && bash"
```

添加ftp用户
```
pure-pw useradd qiwei -f /etc/pure-ftpd/passwd/pureftpd.passwd -m -u ftpuser -d /home/ftpusers/bob
```


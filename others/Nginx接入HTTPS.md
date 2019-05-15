# Nginx接入HTTPS

将域名 www.XXX.com 的

**证书文件:**
```
1_www.domain.com_bundle.crt 
```
**私钥文件:**
```
2_www.domain.com.key
```
保存到同一个目录，例如 
```
/usr/local/nginx/conf 
```
目录下。

修改 Nginx 根目录下 ***conf/nginx.conf*** 文件，内容如下：

```
#普通请求重定向到https
server{
        listen 80;
        server_name www.domain.com;
        return 301 https://www.domain.com$request_uri;
}
 server {
        listen 443 ssl http2;
        server_name www.domain.com; #填写绑定证书的域名
        ssl on;
        ssl_certificate 1_www.domain.com_bundle.crt;
        ssl_certificate_key 2_www.domain.com.key;
        ssl_session_timeout 5m;
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2; #按照这个协议配置
        ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:HIGH:!aNULL:!MD5:!RC4:!DHE;#按照这个套件配置
        ssl_prefer_server_ciphers on;
        location / {
            root   html; #站点目录
            index  index.html index.htm;
        }
    }
```   
docker 中同时打开80口和443口
```
docker run -d -p 80:80 -p 443:443 -v /home/ftp/nginx/dist:/home xxxx
```
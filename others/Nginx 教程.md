# Nginx教程

## nginx基本配置
```
http {
    server {
        location / {
            root /data/www;
        }
        location /images/ {
            root /data;
        }
    }
}
```


## nginx二级域名反向代理
```
server {  
    listen 80;
    server_name 12328.test.com;

    location / {
        proxy_set_header   X-Real-IP $remote_addr;
        proxy_set_header   Host      $http_host;
        proxy_pass         http://127.0.0.1;
    }
}
    server {  
    listen 80;
    server_name test.com;

    location / {
        proxy_set_header   X-Real-IP $remote_addr;
        proxy_set_header   Host      $http_host;
        proxy_pass         http://weibo.com;
    }
}

 ```
如果有几个匹配的location块，nginx将选择具有最长前缀来匹配location块。 上面的location块提供最短的前缀长度为1，因此只有当所有其他location块不能提供匹配时，才会使用该块。
 
 它将是以/images/(位置/也匹配这样的请求，但具有较短前缀，也就是“/images/”比“/”长)的请求来匹配。
 
 这已经是一个在标准端口80上侦听并且可以在本地机器上访问的服务器( http://localhost/ )的工作配置。 响应以/images/开头的URI的请求，服务器将从/data/images目录发送文件。 例如，响应http://localhost/images/logo.png请求，nginx将发送服务上的/data/images/logo.png文件。 如果文件不存在，nginx将发送一个指示404错误的响应。 不以/images/开头的URI的请求将映射到/data/www目录。 例如，响应http://localhost/about/example.html请求时，nginx将发送/data/www/about/example.html文件。
 ```
 location ~ \.(gif|jpg|png)$ {
    root /data/images;
}
```
该参数是一个正则表达式，匹配所有以.gif，.jpg或.png结尾的URI。正则表达式之前应该是~字符。 相应的请求将映射到/data/images目录。
 
 
 ### nginx代理配置
 ```
 server {
    location / {
        proxy_pass http://localhost:8080/;
    }

    location ~ \.(gif|jpg|png)$ {
        root /data/images;
    }
}
```
此服务器将过滤以.gif，.jpg或.png结尾的请求，并将它们映射到/data/images目录(通过向root指令的参数添加URI)，并将所有其他请求传递到上面配置的代理服务器。


## nginx转发默认忽略带下划线的头
解决办法：http部分增加
```
underscores_in_headers on;
```

## nginx Vue History Mode 404问题
修改配置
```
   location /{

        root   /data/nginx/html;
        index  index.html index.htm;

        if (!-e $request_filename) {
            rewrite ^/(.*) /index.html last;
            break;
        }
    }
```

## 使用ngx_http_auth_basic_module配置basic auth认证



1. 生成用户密码文件
使用htpasswd创建用户密码文件：
```
htpasswd -c -d filename username
```

如果没有安装 htpasswd，使用以下命令安装：
```
apt install apache2-utils
```

2. 配置basic auth
在location中添加如下配置：
```
location / {
    auth_basic "登录认证";
    auth_basic_user_file /usr/local/nginx/conf/htpasswd;
}
```
3. 重启nginx
```
nginx -s reload
```

## nginx文件服务器

修改配置文件
```
    root /home; #这个是在server级的
    location / {
        autoindex on;
        autoindex_exact_size on;#文件大小
        autoindex_localtime on;#创建时间
    }

```

## 负载均衡
```
http {

upstream tomcats {
        server 14.215.177.39:80;
        server 117.21.216.80:80;
        server 27.152.185.199:80;
    }
    
 server {
        listen       80;
        server_name  localhost;

       

         location / {
            proxy_pass http://tomcats;
        }
    
```

## TCP,UDP转发
```

    server {
        listen     12345;
        #TCP traffic will be forwarded to the "stream_backend" upstream group
        proxy_pass stream_backend;
    }

    server {
        listen     12346;
        #TCP traffic will be forwarded to the specified server
        proxy_pass backend.example.com:12346;
    }

    server {
        listen     53 udp;
        #UDP traffic will be forwarded to the "dns_servers" upstream group
        proxy_pass dns_servers;
    }
    # ...
}
```

# Nginx教程

* 如果有几个匹配的location块，nginx将选择具有最长前缀来匹配location块

## 前后端分离部署方案
```
 upstream back{
    server 127.0.0.1:8081;
    }
```
```
location / {
            root   html;
            index  index.html index.htm;
        }
		
		location ^~ /server-api/{
            proxy_pass http://back/;
            proxy_send_timeout 1800;
            proxy_read_timeout 1800;
            proxy_connect_timeout 1800;
            client_max_body_size 2048m;
            proxy_http_version 1.1;  
            proxy_set_header Upgrade $http_upgrade;  
            proxy_set_header Connection "Upgrade"; 
            proxy_set_header  Host              $http_host;   # required for docker client's sake
            proxy_set_header  X-Real-IP         $remote_addr; # pass on real client's IP
            proxy_set_header  X-Forwarded-For   $proxy_add_x_forwarded_for;
            proxy_set_header  X-Forwarded-Proto $scheme;
        }
```


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


## nginx二级域名转发
```
location / {
            #root   html;
            #index  index.html index.htm;
            
            #处理二级域名fund.cmbchina.com转发
            if ($http_host ~* "^(.*?)\.qw607\.com$") {    #正则表达式
                set $domain $1;                     #设置变量
            }
            if ($domain ~* "fund") {
               proxy_pass http://192.168.1.22:88;      #域名中有fund，转发到88端口
            }
            
            #if ($domain ~* "cms") {
            #   proxy_pass http://192.168.1.22:99;      #域名中有cms，转发到9090端口
            #}


            proxy_set_header Host            $host;
            proxy_set_header X-Real-IP       $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            #将代理服务器收到的用户的真实IP信息传给后端服务器
            
            #默认转发(不符合上文if条件的，默认转发至以下)
            proxy_pass http://localhost:8090/cmbwww/;
        }
```


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

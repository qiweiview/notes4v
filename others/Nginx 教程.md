# Nginx教程

## nginx upload module
* [下载nginx](http://nginx.org/download/nginx-1.17.9.tar.gz)
* [下载nginx upload module](http://www.grid.net.ru/nginx/download/nginx_upload_module-2.2.0.tar.gz)
```
./configure --add-module=../nginx_upload_module-2.2.0 --with-cc-opt="-Wno-error"
make
make install 
```

* 编译异常
```
./configure --with-cc-opt="-Wno-error"
```

* 配置文件
```
 location /test {
              proxy_pass http://qw607.com;
         }

        location = /upload {

    upload_store_access all:rw;
    upload_pass /test?path=$upload_tmp_path&name=$upload_file_name; #//表示Nginx接收完上传的文件后，然后交给后端处理的地址
    upload_cleanup 400 404 499 500-505; #//表示当发生这些http status代码的情况下，会把上传的文件删除
    upload_store /home/view/nginx/file_dir 1; #//上传模块接收到的文件临时存放的路径， 1 表示方式，该方式是需要在/tmp/upload_tmp下创建以0到9为目录名称的目录，上传时候会进行一个散列
处理。
    #upload_store_access user:r; #//指定访问模式
    #upload_limit_rate 128k; #//设定上传速度上限
    upload_set_form_field "${upload_field_name}_name" $upload_file_name; #//设定后续脚本语言访问的变量，其中${upload_field_name}对照本例子就是addfile。比如后台PHP就可以通过$_POST['addfile_name']来获取上传文件的名称。
    upload_set_form_field "${upload_field_name}_content_type" $upload_content_type; #//同上
    upload_set_form_field "${upload_field_name}_path" $upload_tmp_path;  #//由于在upload_store设置了临时文件存放根路径，该路径就是经过散裂后上传文件存在真实路径，比如后续处理可以>根据这值把上传文件拷贝或者移动到指定的目录下。
    upload_pass_form_field "^.*$"; #//
    #upload_pass_args on; #// 打开开关，意思就是把前端脚本请求的参数会传给后端的脚本语言，比如：http://192.168.1.203:7100/upload/?k=23.PHP脚本可以通过$_POST['k']来访问。
}

```

* 要在  /home/view/nginx/file_dir目录创10个文件夹给hash
## 如果有几个匹配的location块，nginx将选择具有最长前缀来匹配location块


## 配置重定向
```
server {
    rewrite 规则 定向路径 重写类型;
}
```
* 规则：可以是字符串或者正则来表示想匹配的目标url
* 定向路径：表示匹配到规则后要定向的路径，如果规则里有正则，则可以使用$index来表示正则里的捕获分组
* 重写类型：
```
last ：相当于Apache里德(L)标记，表示完成rewrite，浏览器地址栏URL地址不变
break；本条规则匹配完成后，终止匹配，不再匹配后面的规则，浏览器地址栏URL地址不变
redirect：返回302临时重定向，浏览器地址会显示跳转后的URL地址
permanent：返回301永久重定向，浏览器地址栏会显示跳转后的URL地址
```

```
# 根地址重定向
rewrite / /index/index.html

# 访问 /last.html 的时候，页面内容重写到 /index.html 中
rewrite /last.html /index.html last;

# 访问 /break.html 的时候，页面内容重写到 /index.html 中，并停止后续的匹配
rewrite /break.html /index.html break;

# 访问 /redirect.html 的时候，页面直接302定向到 /index.html中
rewrite /redirect.html /index.html redirect;

# 访问 /permanent.html 的时候，页面直接301定向到 /index.html中
rewrite /permanent.html /index.html permanent;
```
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

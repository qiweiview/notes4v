# Ubuntu 配置FastDFS


教程地址：https://blog.csdn.net/KokJuis/article/details/76147489


在/usr/local目录下

# 1. 下载使用包
```
//依赖库
wget -c "https://codeload.github.com/happyfish100/libfastcommon/tar.gz/V1.0.39" -O libfastcommon-1.0.39.tar.gz
//nginx配置包
wget -c "https://codeload.github.com/happyfish100/fastdfs-nginx-module/tar.gz/V1.20" -O fastdfs-nginx-module-1.20.tar.gz
//主程序
wget -c "https://codeload.github.com/happyfish100/fastdfs/tar.gz/V5.11" -O fastdfs-5.11.tar.gz
//nginx
wget -c "https://nginx.org/download/nginx-1.15.5.tar.gz" -O nginx-1.15.5.tar.gz

```
# 2. 安装依赖库(并不是所有系统都缺unzip和gcc还有make)
ubuntu
```
apt-get install make
apt-get install gcc 
apt-get install unzip 
apt-get install libpcre3 libpcre3-dev
apt-get install zlib1g  zlib1g-dev
apt-get install openssl libssl-dev 
```
centos
```
yum install unzip zip  gcc-c++
#ginx模块依赖
yum -y install pcre pcre-devel
yum -y install zlib zlib-devel
yum -y install openssl openssl-devel
yum -y install perl*//有的机子这个缺失
```
# 3. 安装libfastcommon库
```
tar -zxvf libfastcommon....xxxx//解压包
cd libfastcommon....xxxx//进入目录
./make.sh//编译
./make.sh install//安装

//做软链接
ln -s /usr/lib64/libfastcommon.so /usr/local/lib/libfastcommon.so

ln -s /usr/lib64/libfastcommon.so /usr/lib/libfastcommon.so

ln -s /usr/lib64/libfdfsclient.so /usr/local/lib/libfdfsclient.so

ln -s /usr/lib64/libfdfsclient.so /usr/lib/libfdfsclient.so
```

# 4. 安装fastdsf主程序
```
tar -zxvf fastdsf....xxxx//解压包
cd fastdsf....xxxx//进入目录
./make.sh//编译
./make.sh install//安装
//安装成功后在/etc/fdfs中，可以看到一堆配置文件
cp client.conf.sample client.conf
cp storage.conf.sample storage.conf
cp tracker.conf.sample tracker.conf
//备份三分后面用
```

# 5.安装Tracker（fastdsf可以配置成三个角色tracker,storage,client）
创建Tracker服务器的数据存储和日志文件架以用于后面配置
```
mkdir /opt/fastdfs_tracker
```
编辑/etc/fdfs目录下的tracker.conf配置文件:
```
disabled=false //启用配置文件（默认启用）
port=22122 //设置tracker的端口号，通常采用22122这个默认端口
base_path=/opt/fastdfs_tracker//设置tracker的数据文件和日志目录
http.server_port=6666 //设置http端口号，默认为8080
```
保存后创建软链接
```
ln -s /usr/bin/fdfs_trackerd /usr/local/bin
ln -s /usr/bin/stop.sh /usr/local/bin
ln -s /usr/bin/restart.sh /usr/local/bin
```
启动
```
service fdfs_trackerd start
```
（实验腾讯云服务器启动得用：）
```
/usr/bin/fdfs_trackerd /etc/fdfs/tracker.conf start 
```
（腾讯云服务器重启得用：）
```
/usr/bin/fdfs_trackerd /etc/fdfs/tracker.conf restart
```

查看端口22122已被检测
```
netstat -unltp|grep fdfs
```
# 6. 安装Storage（在另外的服务器上也可以单机）

创建文件夹(同Tracker相比我多建了一个目录，因为Storage还需要一个文件存储路径，用于存放接收的文件：)
```
mkdir /opt/fastdfs_storage
mkdir /opt/fastdfs_storage_data
```
修改/etc/fdfs目录下的storage.conf配置文件
```
disabled=false //启用配置文件（默认启用）
group_name=group1 //组名，根据实际情况修改
port=23000 #设置storage的端口号，默认是23000，同一个组的storage端口号必须一致
base_path=/opt/fastdfs_storage //设置storage数据文件和日志目录
store_path_count=1 //存储路径个数，需要和store_path个数匹配
store_path0=/opt/fastdfs_storage_data //实际文件存储路径
tracker_server=192.168.111.11:22122 //tracker 服务器的 IP地址和端口号，如果是单机搭建，IP不要写127.0.0.1，否则启动不成功（此处的ip是我的CentOS虚拟机ip）
http.server_port=8888 //设置 http 端口号
```
设置软引用
```
ln -s /usr/bin/fdfs_storaged /usr/local/bin
```
启动服务器
```
service fdfs_storaged start
```
百度云上面使用(怀疑和平台无关，和ubuntu系统版本有关)
```
/usr/bin/fdfs_storaged /etc/fdfs/storage.conf start
```
查看端口23000已被监控
```
netstat -unltp|grep fdfs
```
查看storage是否注册到tracker服务器上（看到：storage服务器ip ACTIV表示注册成功）
```
/usr/bin/fdfs_monitor /etc/fdfs/storage.conf
```
# 7.使用client访问

编辑/etc/fdfs目录下的client.conf 文件
```
base_path=/opt/fastdfs_tracker //tracker服务器文件路径
tracker_server=192.168.111.11:22122 //tracker服务器IP地址和端口号
http.tracker_server_port=6666 // tracker 服务器的 http 端口号，必须和tracker的设置对应起来
```
上传文件
```
/usr/bin/fdfs_upload_file  /etc/fdfs/client.conf  /opt/BLIZZARD.jpg
//返回一串地址，在storage服务器上找到对应的文件
```
# 8. 为Storage配置Nginx

解压安装nginx
```
tar -zxvf nginx-1.8.1.tar.gz
tar -zxvf fastdfs-nginx-module-1.20.tar.gz
```
进入解压出来的nginx目录进行配置
```
./configure --prefix=/usr/local/nginx --add-module=/usr/local/fastdfs-nginx-module-1.20/src
```
编译安装
```
make
make install
```
注意：上一步如果报错找不到文件夹,编辑 fastdfs-nginx-module-1.20/src/config 文件然后再从“进入解压出来的nginx目录进行配置”开始执行
```
vim fastdfs-nginx-module-1.20/src/config
```
修改：
```
ngx_module_incs="/usr/include/fastdfs /usr/include/fastcommon/"

CORE_INCS="$CORE_INCS /usr/include/fastdfs /usr/include/fastcommon/"
```

安装完在/usr/local/nginx中就可以看到nginx的安装目录了

修改nginx配置，进入conf目录修改nginx.conf
```
server {
listen       9999;
 
location ~/group1/M00 {
      root /opt/fastdfs_storage_data/data;
      ngx_fastdfs_module;
}
}
```
进入FastDFS的安装目录/usr/local/fastdfs-5.05目录下的conf目录，将http.conf和mime.types拷贝到/etc/fdfs目录下
```
cp -r /usr/local/fastdfs-5.11/conf/http.conf /etc/fdfs/
cp -r /usr/local/fastdfs-5.11/conf/mime.types /etc/fdfs/
```
把fastdfs-nginx-module安装目录中src目录下的mod_fastdfs.conf也拷贝到/etc/fdfs目录下：
```
cp -r /usr/local/fastdfs-nginx-module-1.20/src/mod_fastdfs.conf /etc/fdfs/
```
编辑刚拷贝的这个mod_fastdfs.conf文件
```
base_path=/opt/fastdfs_storage //保存日志目录
tracker_server=192.168.111.11:22122 //tracker服务器的IP地址以及端口号
storage_server_port=23000 //storage服务器的端口号
url_have_group_name = true //文件 url 中是否有 group 名
store_path0=/opt/fastdfs_storage_data // 存储路径
group_count = 3 //设置组的个数，事实上这次只使用了group1
```
设置了group_count = 3，接下来就需要在文件尾部追加这3个group setting：
```
[group1]
group_name=group1
storage_server_port=23000
store_path_count=1
store_path0=/opt/fastdfs_storage_data
 
[group2]
group_name=group2
storage_server_port=23000
store_path_count=1
store_path0=/opt/fastdfs_storage_data
 
[group3]
group_name=group3
storage_server_port=23000
store_path_count=1
store_path0=/opt/fastdfs_storage_data
```
建立 M00 至存储目录的符号连接
```
ln  -s  /opt/fastdfs_storage_data/data  /opt/fastdfs_storage_data/data/M00
```
启动nginx
```
/usr/local/nginx/sbin/nginx
```
访问,可以看到上传成功的图片（但是这是访问storage的服务器，在节点不止一个的时候我们不能这么访问，得通过tracker）
```
http://106.12.111.159:9999/group1/M00/00/00/rBAABFvV0MeAXSVpABDDfcsgA64105.jpg
```

# 9. 为Tracker配置Nginx
解压安装nginx
```
tar -zxvf nginx-1.8.1.tar.gz
tar -zxvf fastdfs-nginx-module-1.20.tar.gz
```
进入解压出来的nginx目录进行配置
```
./configure --prefix=/usr/local/nginx --add-module=/usr/local/fastdfs-nginx-module-1.20/src
```
编译安装
```
make
make install
```
注意：上一步如果报错找不到文件夹,编辑 fastdfs-nginx-module-1.20/src/config 文件然后再从“进入解压出来的nginx目录进行配置”开始执行
```
vim fastdfs-nginx-module-1.20/src/config
```
修改：
```
ngx_module_incs="/usr/include/fastdfs /usr/include/fastcommon/"

CORE_INCS="$CORE_INCS /usr/include/fastdfs /usr/include/fastcommon/"
```

安装完在/usr/local/nginx中就可以看到nginx的安装目录了





修改nginx的配置文件，进入conf目录并打开nginx.conf文件加入以下配置
```
//在http节点下，添加upstream节点。

upstream fdfs_group1 {
     server 127.0.0.1:9999;
}
 
location /group1/M00 {
     proxy_pass http://fdfs_group1;
}
```

进入FastDFS的安装目录/usr/local/fastdfs-5.05目录下的conf目录，将http.conf和mime.types拷贝到/etc/fdfs目录下
```
cp -r /usr/local/fastdfs-5.11/conf/http.conf /etc/fdfs/
cp -r /usr/local/fastdfs-5.11/conf/mime.types /etc/fdfs/
```
把fastdfs-nginx-module安装目录中src目录下的mod_fastdfs.conf也拷贝到/etc/fdfs目录下：
```
cp -r /usr/local/fastdfs-nginx-module-1.20/src/mod_fastdfs.conf /etc/fdfs/
```

**注意：到这里为止以上都和storage的nginx服务器安装操作相同**


编辑刚拷贝的这个mod_fastdfs.conf文件
```
base_path=/opt/fastdfs_storage //指定日志地址
tracker_server=192.168.111.11:22122//修改tracker服务地址，也就是本机ip,
```


启动nginx
```
/usr/local/nginx/sbin/nginx
```
## Docker集群部署

文章地址：https://my.oschina.net/zjg23/blog/909141
所有机器运行
```
git clone https://git.oschina.net/zjg23/fastdfs_in_docker.git;#从git服务器下载工程
mkdir -p /home/fastdfs/{tracker,storage}                     #这两个路径用来挂载到docker容器，尤其是/home/fastdfs/storage路径要保证有足够的存储空间
cd fastdfs_in_docker
docker build -t zjg23/fastdfs:2.0 .                          #构建镜像
```

构建tracker
```
docker run -d --name fdfs_tracker -v /home/fastdfs/tracker:/export/fastdfs/tracker --net=host -e TRACKER_BASE_PATH=/export/fastdfs/tracker -e TRACKER_PORT=22123 zjg23/fastdfs:2.0 sh /usr/local/src/tracker.sh
```

构建storage
```
2.3.1 192.168.5.129上执行：
docker run -d --name fdfs_storage -v /home/fastdfs/storage:/export/fastdfs/storage --net=host -e STORAGE_PORT=23001 -e STORAGE_BASE_PATH=/export/fastdfs/storage -e STORAGE_PATH0=/export/fastdfs/storage -e TRACKER_SERVER=192.168.5.128:22123 -e GROUP_COUNT=2 -e HTTP_SERVER_PORT=8080 -e GROUP_NAME=group1 zjg23/fastdfs:2.0 sh /usr/local/src/storage.sh


2.3.2 192.168.5.130上执行：
docker run -d --name fdfs_storage -v /home/fastdfs/storage:/export/fastdfs/storage --net=host -e STORAGE_PORT=23001 -e STORAGE_BASE_PATH=/export/fastdfs/storage -e STORAGE_PATH0=/export/fastdfs/storage -e TRACKER_SERVER=192.168.5.128:22123 -e GROUP_COUNT=2 -e HTTP_SERVER_PORT=8080 -e GROUP_NAME=group1 zjg23/fastdfs:2.0 sh /usr/local/src/storage.sh


2.3.3 192.168.5.131上执行：
docker run -d --name fdfs_storage -v /home/fastdfs/storage:/export/fastdfs/storage --net=host -e STORAGE_PORT=23001 -e STORAGE_BASE_PATH=/export/fastdfs/storage -e STORAGE_PATH0=/export/fastdfs/storage -e TRACKER_SERVER=192.168.5.128:22123 -e GROUP_COUNT=2 -e HTTP_SERVER_PORT=8080 -e GROUP_NAME=group2 zjg23/fastdfs:2.0 sh /usr/local/src/storage.sh


2.3.4 192.168.5.132上执行：
docker run -d --name fdfs_storage -v /home/fastdfs/storage:/export/fastdfs/storage --net=host -e STORAGE_PORT=23001 -e STORAGE_BASE_PATH=/export/fastdfs/storage -e STORAGE_PATH0=/export/fastdfs/storage -e TRACKER_SERVER=192.168.5.128:22123 -e GROUP_COUNT=2 -e HTTP_SERVER_PORT=8080 -e GROUP_NAME=group2 zjg23/fastdfs:2.0 sh /usr/local/src/storage.sh
```

进入容器内部
```
docker exec -it e8f7 /bin/sh
```

注意storage的的防火墙会影响tracker
```
#查看端口开放详情
netstat -pan|grep 23001
#开启端口
firewall-cmd --zone=public --add-port=81/tcp --permanent;firewall-cmd --reload
```
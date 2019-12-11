# rinetd端口转发


## 安装
[下载地址](https://pkgs.org/)
```
 rpm  -ivh  rinetd-0.62-9.el7.nux.x86_64.rpm
```

## 配置
* 默认地址/etc/rinetd.conf
```
# 本机80口转发到118.25.52.76 777口
0.0.0.0 80 118.25.52.76 777
```

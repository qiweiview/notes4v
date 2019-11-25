# systemctl教程

## 配置文件
配置文件主要放在/usr/lib/systemd/system目录，也可能在/etc/systemd/system目录
```
[Unit]
Description=elasticsearch
[Service]
User=elasticsearch
LimitNOFILE=100000
LimitNPROC=100000
Environment="JAVA_HOME=/usr/local/jdk/jdk1.8.0_231"
ExecStart=/usr/local/elk/elasticsearch-7.3.1/bin/elasticsearch
[Install]
WantedBy=multi-user.target
```

## 重载配置
```
sudo systemctl daemon-reload
```

## 设置为开启启动
```
systemctl enable elasticsearch
```
# Docker安装RabbitMQ

## 拉取镜像
```
docker pull rabbitmq:management
```


## 运行镜像
```
docker run -d -p 5672:5672 -p 15672:15672 --name rabbitmq r
```

访问
```
xxx:15672
#用户名和密码都guest
```
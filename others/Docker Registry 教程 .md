# Docker Registry 教程

## 运行
```
$ docker run -d -p 5000:5000 --restart=always --name registry registry
```

## 标记镜像
```
docker tag ze:latest 127.0.0.1:5000/ze:latest
```

## 推送镜像
```
docker push 127.0.0.1:5000/ze:latest
```

## 查看仓库种的镜像
```
127.0.0.1:5000/v2/_catalog
```

## 备注
*  Docker 默认不允许非 HTTPS 方式推送镜像。我们可以通过 Docker 的配置选项来取消这个限制，或者查看下一节配置能够通过 HTTPS 访问的私有仓库。
* 对于使用 systemd 的系统，请在 /etc/docker/daemon.json 中写入如下内容（如果文件不存在请新建该文件）
```
{
  "registry-mirror": [
    "https://dockerhub.azk8s.cn"
  ],
  "insecure-registries": [
    "cnigcc.cn:5000"
  ]
}
```

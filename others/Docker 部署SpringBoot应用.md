
Dockerfile
---

1. 文件
```
FROM sapmachine/jdk11
ENTRYPOINT  ["java","-jar","/home/logcenter-0.0.1-SNAPSHOT.jar"]
```

2. 建立
```
docker build -t xxname .
```


保证外部可访问
---
#### run.sh
```
docker run -d -p 8001:8001 -v /home/ftp/toolserver:/home  toolserver  --eureka.instance.hostname=118.25.52.76
```
#### 运行sh
```
chmod +x ./run.sh

./run.sh
```

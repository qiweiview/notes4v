# PostgreSql教程


## 下载
* https://www.enterprisedb.com/downloads/postgres-postgresql-downloads
* 默认配置安装，默认监听5432

## windows 注册为服务
```
# 注册服务
C:\Program Files\PostgreSQL\13\bin\pg_ctl register

# 启动服务
services.msc
```

## 修改默认密码
```
ALTER USER postgres WITH PASSWORD 'postgres';
```

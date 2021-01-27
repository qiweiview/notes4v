# Kong教程

## Docker部署

* 首先创建kong-net容器网络，默认设置为bridge
```
docker network create kong-net
```

* 部署Postgres，kong默认使用Postgres做持久层
```
docker run -d --name kong-database \
--network=kong-net \
-p 5432:5432 \
-e "POSTGRES_USER=kong" \
-e "POSTGRES_DB=kong" \
-e "POSTGRES_PASSWORD=123456" \
-v /home/java_user/kong/data/postgres:/var/lib/postgresql/data \
postgres:9.6
```
--network指定docker网络
POSTGRES_USER指定数据库用户名kong
POSTGRES_PASSWORD指定数据库密码
POSTGRES_DB指定库名
-v 挂载数据卷

* 短暂启动kong的数据库初始化镜像
```
docker run --rm \
--network=kong-net \
-e "KONG_DATABASE=postgres" \
-e "KONG_PG_HOST=kong-database" \
-e "KONG_PG_PASSWORD=123456" \
-e "KONG_CASSANDRA_CONTACT_POINTS=kong-database" \
kong kong migrations bootstrap
```
KONG_DATABASE指定数据库类型
KONG_PG_HOST指定host, 由于network与数据库为同一容器网络下可以使用容器名访问
KONG_PG_PASSWORD指定密码

* 启动kong
```
docker run -d --name kong \
--network=kong-net \
-e "KONG_DATABASE=postgres" \
-e "KONG_PG_HOST=kong-database" \
-e "KONG_PG_PASSWORD=123456" \
-e "KONG_CASSANDRA_CONTACT_POINTS=kong-database" \
-e "KONG_PROXY_ACCESS_LOG=/dev/stdout" \
-e "KONG_ADMIN_ACCESS_LOG=/dev/stdout" \
-e "KONG_PROXY_ERROR_LOG=/dev/stderr" \
-e "KONG_ADMIN_ERROR_LOG=/dev/stderr" \
-e "KONG_ADMIN_LISTEN=0.0.0.0:8001, 0.0.0.0:8444 ssl" \
-v /home/kong/data/log/kong:/var/log \
-p 8000:8000 \
-p 8443:8443 \
-p 8001:8001 \
-p 8444:8444 \
kong
```
KONG_DATABASE指定数据库类型
KONG_PG_HOST指定数据库host
KONG_PG_PASSWORD指定密码
KONG_PROXY_ACCESS_LOG指定代理访问日志
KONG_ADMIN_ACCESS_LOG指定admin接口日志
KONG_PROXY_ERROR_LOG指定代理错误日志
KONG_ADMIN_LISTEN kong管理api的http和https端口设置
-v 挂载数据卷
基本和kong服务默认的配置项参数一直， 只需要加上'KONG_'前缀

### 启动konga
konga是非官方gui， 但是相比dashboard功能丰富页面美观，是目前开源项目中最好的选择

* 首先初始化konga相关的数据， 主要是账户和一些基本设置信息保存
```
docker run --rm \
    --network=kong-net \
    pantsel/konga -c prepare -a postgres -u postgresql://kong:123456@kong-database:5432/konga_db
```
数据库url格式 postgresql://用户名:数据库密码@kong-database:端口/库名

* 启动konga
```
docker run -p 1337:1337 --name konga  --network=kong-net \
             -e "DB_ADAPTER=postgres" \
             -e "DB_HOST=kong-database" \
             -e "DB_PORT=5432" \
             -e "DB_USER=kong" \
             -e "DB_PASSWORD=123456" \
             -e "DB_DATABASE=konga_db" \
             -e "KONGA_LOG_LEVEL=debug" \
             -e "NODE_ENV=production" \
             pantsel/konga
```
DB_ADAPTER设置数据库类型
DB_HOST设置数据库host
DB_PORT指定端口号
DB_USER指定用户名
DB_PASSWORD指定密码
DB_DATABASE指定库名
KONGA_LOG_LEVEL设置日志级别
NODE_ENV环境配置

* 完成![img](https://segmentfault.com/img/remote/1460000021280694)

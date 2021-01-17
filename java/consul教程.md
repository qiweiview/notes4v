# consul教程

## 开发模式运行指令
```
consul agent -dev   -enable-script-checks -config-dir=D:\Application\consul\consul.d
```
## 服务文件定义
* check定义了健康检查,argsl里的指令会被拼接
```
{
	"services": [
		{
			"id": "red0",
			"name": "app_service",
			"tags": [
				"primary"
			],
			"address": "118.25.52.76",
			"port": 80,
			"checks": [
				{
					"args": [
						"curl",
						"118.25.52.76"
					],
					"interval": "5s"
				}
			]
		},
		{
			"id": "red1",
			"name": "app_service",
			"tags": [
				"delayed",
				"secondary"
			],
			"address": "118.25.52.76",
			"port": 80,
			"checks": [
				{
					"args": [
						"curl",
						"118.25.52.76"
					],
					"interval": "5s"
				}
			]
		}
	]
}
```

## dns服务查询

* Consul的 DNS只返回健康的实例结果
* 可以查询A类型记录和SRV类型的DNS记录
* 可以按标签筛选
```
#筛选rails标签
rails.web.service.consul
```

## 键值

### 设置值
* consul不会使用flag只是做标记
* 允许文档式存储即redis下的config
```
consul kv put -flags=42 redis/config/users/admin abcd1234
```
* 支持cas
```
consul kv put -cas -modify-index=716 foo bar
```
### 获取值
```
consul kv get -detailed  name
```

### 递归循环所有值
```
consul kv get -recurse
```

### 删除值
* ,支持递归删除
```
consul kv delete dd

kv delete -recurse redis
```

## 集群

* 完成Consul的安装后,必须运行agent. agent可以运行为server或client模式.每个数据中心至少必须拥有一台server . 建议在一个集群中有3或者5个server.部署单一的server,在出现失败时会不可避免的造成数据丢失

* 服务端
```
consul agent -server -bootstrap-expect=1 -data-dir=/tmp/consul -node=agent-one -bind=192.168.100.101 -enable-script-checks=true -config-dir=/etc/consul.d
```
* 客户端
```
consul agent -data-dir=/tmp/consul -node=agent-two -bind=192.168.100.102 -enable-script-checks=true -config-dir=/etc/consul.d
```

* 加入集群
```
consul join 192.168.100.101
```

## UI界面
```
consul agent -ui
```

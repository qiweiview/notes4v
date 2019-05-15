
下载mongo镜像
```
docker pull mongo
```

运行容器
```
docker run -d -p 27017:27017 -v /home/mongo/mongo_configdb:/data/configdb -v /home/mongo/mongo_db:/data/db --name mongo 525bd --auth
```

进入容器
```
docker exec -i 69d1 bash
```
进入mongo
```
mongo
```
切换到admin
```
use admin
```

创建账户
```
db.createUser({ user: 'qiwei', pwd: 'wdwdwd', roles: [ { role: "userAdminAnyDatabase", db: "admin" } ] });
```

创建新的数据库并指定用户
```
db.auth("qiwei","wdwdwd");

use sina

db.createUser({ user: 'sina', pwd: 'wdwdwd', roles: [{ role: "readWrite", db: "sina" }] });
```


# npm综合


## http代理查看
```
npm config get proxy
npm config get https-proxy
```


## 设置代理
```
npm config set proxy http://server:port
 
npm config set https-proxy http://server:port
```

## 删除代理
```
npm config set proxy null
npm config set https-proxy null
```

## 镜像仓库
```
# 设置为淘宝镜像
npm config set registry http://registry.npm.taobao.org/

# 设置回默认的官方镜像
npm config set registry https://registry.npmjs.org/
```

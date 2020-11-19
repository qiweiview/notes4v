## 安装
```
apt-get install ufw
```

## 启动
```
ufw enable
```

## 添加规则
```
ufw allow 80
```


## 查看规则号
```
sudo ufw status numbered
```

## 删除规则
```
sudo ufw delete 规则号
```

## 批量删除
```
for i in 6 5 3 2;do yes|ufw delete $i;done
```

## 查看状态
```
ufw status
```

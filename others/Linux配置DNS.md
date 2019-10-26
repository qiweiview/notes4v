# Linux配置DNS

## 设置NAT模式

```
# 添加IP
ip add

# 跳转目录
 cd /etc/sysconfig/network-scripts/
 
 # 编辑文件
 vi ifcfg-ens33
 
 # 设置内容
 ONBOOT = yes
 
 # 重启
 shutdown -r now
```


[相关材料](https://blog.csdn.net/jasonhector/article/details/78657532)

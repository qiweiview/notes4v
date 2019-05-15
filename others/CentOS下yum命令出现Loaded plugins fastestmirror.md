fastestmirror是yum的一个加速插件，这里是插件提示信息是插件不能用了。 
步骤：

1. 修改插件的配置文件 
# vi /etc/yum/pluginconf.d/fastestmirror.conf 
```
将enabled=1改为enabled=0
```
2. 修改yum的配置文件 vi /etc/yum.conf  
```
将plugins=1改为plugins=0
```

3. reboot

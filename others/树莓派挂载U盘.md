# 树莓派挂载U盘

## 查看所有设备
```
fdisk -l
```

## 创建要映射的文件夹
```
mkdir /uspan
```

## 进行挂载
```
mount /dev/sda /uspan
```

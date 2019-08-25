# NFS教程


## Server
```
sudo apt-get update
sudo apt-get install nfs-kernel-server
```


在第一个示例中，我们将创建一个通用的NFS安装，它使用默认的NFS行为，使客户机上具有root权限的用户很难与使用这些客户机超级用户权限的主机进行交互。 您可以使用类似的方式来存储使用内容管理系统上传的文件，或者为用户创建容易共享项目文件的空间。

首先，做一个共享目录名为nfs ：
```
sudo mkdir /var/nfs/general -p
```
因为我们与创造它sudo ，该目录由root拥有这里的主机上。
```
ls -la /var/nfs/general
4 drwxr-xr-x  2 root   root    4096 Jul 25 15:26 .
```
NFS将翻译任何root在客户机上操作的nobody:nogroup凭证作为一种安全措施。 因此，我们需要更改目录所有权以匹配这些凭据。
```
sudo chown nobody:nogroup /var/nfs/general
```

接下来，我们将深入到NFS配置文件中来设置这些资源的共享。

打开/etc/exports在以root权限文本编辑器文件中：
```
sudo nano /etc/exports
```
该文件具有显示每个配置行的一般结构的注释。 语法基本上是：
```
directory_to_share    client(share_option1,...,share_optionN)
```
我们需要为我们计划共享的每个目录创建一行。 由于我们的例子中客户端的IP 203.0.113.256 ，我们的防线看起来像下面这样。 确保更改IP以匹配您的客户端：


```
/var/nfs/general    203.0.113.256(rw,sync,no_subtree_check)
/home       203.0.113.256(rw,sync,no_root_squash,no_subtree_check)
```
我们正在使用的除外两个目录相同的配置选项no_root_squash 。 让我们来看看每个人的意思。

* RW：此选项使客户端计算机的读写访问卷。
同步 ：此选项强制NFS回答之前更改写入磁盘。 这导致更稳定和一致的环境，因为答复反映了远程卷的实际状态。 但是，它也降低了文件操作的速度。
* no_subtree_check：此选项可防止子树检查，这是一个过程，其中主机必须检查文件是否确实仍然在为每个请求导出的树可用。 这可能会导致在客户端打开文件时重命名文件时出现许多问题。 在几乎所有情况下，最好禁用子树检查。
* no_root_squash会 ：默认情况下，NFS翻译从根用户的请求到远程服务器上的非特权用户。 这样做的目的是安全功能，以防止客户端上的root帐户使用主机作为根文件系统。 * no_root_squash禁止这种行为对某些股票。
完成更改后，保存并关闭文件。 然后，要使共享可用于您配置的客户端，请使用以下命令重新启动NFS服务器：
```
sudo systemctl restart nfs-kernel-server
```

修改防火墙，开启2049

## Client
```
sudo apt-get update
sudo apt-get install nfs-common
```


我们将为我们的挂载创建两个目录：
```
sudo mkdir -p /nfs/general
sudo mkdir -p /nfs/home
```

现在，我们有一些地方把远程共享，我们已经打开了防火墙，我们可以解决我们的主机服务器，这本指南是安装股203.0.113.0 ，就像这样：
```
sudo mount 203.0.113.0:/var/nfs/general /nfs/general
sudo mount 203.0.113.0:/home /nfs/home
```

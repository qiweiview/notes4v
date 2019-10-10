# Ansible教程

## [Ubuntu安装](https://docs.ansible.com/ansible/latest/installation_guide/index.html)
```
$ sudo apt update
$ sudo apt install software-properties-common
$ sudo apt-add-repository --yes --update ppa:ansible/ansible
$ sudo apt install ansible
```



## 配置主机和组
* 编辑/etc/ansible/hosts设置控制主机地址
* 括号中的标题是组名，用于对系统进行分类并确定您在什么时候，什么目的控制什么系统
* [需要设置免密码登陆](https://github.com/qiweiview/notes4v/blob/master/others/SSH%E5%85%8D%E5%AF%86%E7%99%BB%E9%99%86.md)
```
[vhost]
192.0.2.50
aserver.example.org
bserver.example.org
```

### yml版
```
all:
  hosts:
    mail.example.com:
  children:
    webservers:
      hosts:
        foo.example.com:
        bar.example.com:
    dbservers:
      hosts:
        one.example.com:
        two.example.com:
        three.example.com:
```

## ping 服务器
```
$ ansible all -m ping
$ ansible vhost -m ping
```


## 在节点上运行指令
```
$ ansible all -a "/bin/echo hello"
$ ansible vhost -a "/bin/echo hello"
```

## [Ansible指令](https://docs.ansible.com/ansible/latest/user_guide/command_line_tools.html)

* 指令相关参数
```
-m：要执行的模块，默认为command
-a：模块的参数
-u：ssh连接的用户名，默认用root，ansible.cfg中可以配置
-k：提示输入ssh登录密码，当使用密码验证的时候用
-s：sudo运行
-U：sudo到哪个用户，默认为root
-K：提示输入sudo密码，当不是NOPASSWD模式时使用
-C：只是测试一下会改变什么内容，不会真正去执行
-c：连接类型(default=smart)
-f：fork多少进程并发处理，默认为5个
-i：指定hosts文件路径，默认default=/etc/ansible/hosts
-I：指定pattern，对已匹配的主机中再过滤一次
--list-host：只打印有哪些主机会执行这个命令，不会实际执行
-M：要执行的模块路径，默认为/usr/share/ansible
-o：压缩输出，摘要输出
--private-key：私钥路径
-T：ssh连接超时时间，默认是10秒
-t：日志输出到该目录，日志文件名以主机命名
-v：显示详细日志
```


## 文件相关
### 拷贝文件
```
ansible vhost -m copy -a "src=/etc/hosts dest=/tmp/hosts"
```
### 修改权限
```
ansible vhost -m file -a "dest=/srv/foo/a.txt mode=600"
```
### 创建文件夹
```
ansible vhost -m file -a "dest=/path/to/c mode=755 owner=mdehaan group=mdehaan state=directory"
```

### 删除目录和文件（递归）
```
ansible vhost -m file -a "dest=/path/to/c state=absent"
```

## 管理软件包
* 有一些适用于yum和apt的模块

## 管理服务
### 在所有Web服务器上重新启动服务：
```
ansible webservers -m service -a "name=httpd state=restarted"
```

## [Ansible剧本](https://docs.ansible.com/ansible/latest/user_guide/playbooks_intro.html#about-playbooks)

* command不支持管道符，shell支持
* Ansible facts主要用于获取远程系统的数据,从而可以在playbook中作为变量使用.
* 每个任务都应该有一个name，该字符包含在运行剧本的输出中。这是人类可读的输出

### 调用
```
ansible-playbook  run1.yml
```

### 范例
```
---
- hosts: vhost
  remote_user: root
  vars:  #申明变量
          word: nihao
  vars_files: #引用外部参数文件
    - /usr/local/ansibleFile/param.yml
  tasks:
  - name: sahi
    template: src=/home/r.f  dest=/home
    register: foo_result   #注册变量供其他任务使用
  - name: say
    shell: echo {{foo_result}} >>/home/{{word}}  #使用申明和注册的变量
  - name: say2
    shell: echo {{ ansible_eth0.ipv4.address }}{{password}} >>/home/ip_adress
    #使用系统中Facts采集的变量，使用ansible hostname -m setup查看所有
  - name: twhen
    shell: echo {{ansible_os_family}} >> /home/system_num
    when: word == "nihao" # 可以使用系统的变量，申明的变量，注册的变量

```

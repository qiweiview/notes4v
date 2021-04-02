# Linux指令

## 限制用户指令
* 将脚本放入/etc/profile.d
```
#!/bin/bash
m=`whoami`

# 允许的指令集
bin_allow=(ls ping cp rm mv)
usr_bin_allow=(java)


if [[ "${m}" == "develop" ]];then
    echo -e "\e[01;33m* ** 欢迎登录，开发者。  ** *\e[00m"
    ## 创建命令集合
    mkdir -p $HOME/bin
    rm -f $HOME/bin/*
    
    # 循环连接/bin
    for bae in ${bin_allow[@]}
    do
	    ln -s /bin/$bae  $HOME/bin
    done

    # 循环连接/usr/bin
    for ubae in ${usr_bin_allow[@]}
    do
	    ln -s /usr/bin/$ubae  $HOME/bin
    done
    

    ## 设置环境变量
    cat << EOF > $HOME/.newbash_profile
		export HISTFILESIZE=500000000
		export HISTSIZE=99999999
		export HISTTIMEFORMAT="%Y/%m/%d_%H:%M:%S :"
		export PATH=$HOME/bin
EOF
		## 使用自定义profile文件
    chown ${m}:${m} $HOME/.newbash_profile
    exec bash --restricted --noprofile --rcfile $HOME/.newbash_profile
fi

```
## 修改bash
```
usermod -s /bin/bash
```

## 创建用户
```
useradd -d /home/cron/log -m develop
```
## 设置私钥文件登录
```
# step 1
ssh-keygen

# step 2
cd .ssh
cat id_rsa.pub >> authorized_keys

# step 3
vim /etc/ssh/sshd_config 
#PubkeyAuthentication yes

# step 4
service sshd restart
```

## 系统信息查看
```
# cpu 信息
cat /proc/cpuinfo | grep 'model name' | sort | uniq

# cpu 内核数
cat /proc/cpuinfo |grep "cores"|uniq|awk '{print $4}'

# 内存
cat /proc/meminfo

# 磁盘

```

## 启动禁止脚本
* 启动
```

if [[ -n "$JAVA_HOME" ]] && [[ -x "$JAVA_HOME/bin/java" ]]; then
  JAVA="$JAVA_HOME/bin/java"
elif type -p java; then
  JAVA=java
else
  echo "Error: JAVA_HOME is not set and java could not be found in PATH." 1>&2
  exit 1
fi

NDC="${BASH_SOURCE-$0}"
NDC="$(dirname "${NDC}")"
NDCDIR="$(
  cd "${ZOOBIN}"
  pwd
)"
CONIFG="$NDCDIR/config.yml"
LIB="$NDCDIR/jndc_server-1.0.jar"

nohup  "$JAVA" -jar "$LIB" "$CONIFG"  "jndcccccccccc" >/dev/null 2>&1  &

#echo 'start jndc success'
```

* 停止
```
ps -ef | grep jndcccccccccc | grep -v grep | cut -c 9-15 | xargs kill -s 9;
echo 'stop jnfc success'
```

# 统计文件数
```
ls -l | grep "^-" | wc -l
```

### 磁盘大小排行
```
du -s * | sort -nr | head
```

### firewall 添加端口
```
firewall-cmd --add-port=80/tcp --permanent     ##永久添加80端口 
```

### 远程文件传输
```
 sshpass -p xxxpassws scp /home/scp/hi ubuntu@qw607.com:
```

### 递归删除
```
rm -rf /home/test
```

### 查看端口
```
lsof -i tcp:81
```

## 通过进程名查看对应进程
* 先用pgrep [str] 命令进行模糊匹配，找到匹配该特征串的进程ID；

* 其次根据进程ID显示指定的进程信息，ps --pid [pid]；

* 因为查找出来的进程ID需要被作为参数传递给ps命令，故使用xargs命令，通过管道符号连接；

* 最后显示进程详细信息，需要加上-u参数。
```
pgrep java | xargs ps -u --pid
```


### 查看进程信息
* ll是ls -l简写
```
ll /proc/pid
```

### 开启端口
```
firewall-cmd --zone=public --add-port=81/tcp --permanent;firewall-cmd --reload;
```


## 查看内存使用前10
```
ps auxw|head -1;ps auxw|sort -rn -k4|head -10 
```

## CPU占用最多的前10个进程： 
```
ps auxw|head -1;ps auxw|sort -rn -k3|head -10 
```

## 创建一个大文件
* 生成一个1000M的test文件，文件内容为全0（因从/dev/zero中读取，/dev/zero为0源）
```
dd if=/dev/zero of=test1 bs=1M count=1000
```

## 获取当前时间
```
time=$(date "+%Y-%m-%d %H:%M:%S")
echo time
```

## 管道操作
```
ps -ef | grep tqsdyyewzdn | grep -v grep | cut -c 9-15 | xargs kill -s 9
```

## 后台运行不带日志
```
nohup xxx >/dev/null 2>&1  &

```

## 磁盘大小排行
```
du -s * | sort -nr | head
```

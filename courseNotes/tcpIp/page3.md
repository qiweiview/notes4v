### 网络应用体系结构


#### 客户机/服务器结构（Client-Sever,CS）

例如：运行浏览器访问网页

* 服务器：

7*24小时服务

永久访问地址

* 客户机：

间歇访问

动态IP



#### 点对点结构（Peer-to-Peer,P2P）
优点：高度可伸缩

缺点：难管理

* 没有永远在线服务器
* 任意节点可以直接通讯
* 节点间歇性接入网络
* 节点可能改变IP

#### 混合结构（Hybrid）
Napster(软件):
* 文件传输使用P2P，文件搜索采用C/S
* 每个节点向中央服务器登记自己的内容
* 每个节点向中央服务器登记提交查询请求

### 网络应用进程通信
* 客户机进程：发起通信的进程
* 服务机进程：等待通通信请求的进程
* P2P也是有客户机和服务机

#### Socket套接字
* 进程通过使用socket发送/接收消息，实现通信
* 传输基础设施向进程提供的API：协议选择和参数设置

#### 进程间如何寻址
* 不同主机上的进程通信，每个进程必须拥有标识符（IP+端口）
* 主机上每个需要通信的进程分配一个端口

#### 应用层协议
* 网络应用需要遵循应用协议
* 公开协议：由RFC（request for comments）定义（HTTP）(SMTP)
* 私有协议：多数P2P文件共享应用

* 消息类型：请求消息，响应消息
* 消息语法：有哪些字段，字段如何描述
* 消息语义
* 规则

#### 网络应用对传输服务需求

* 数据丢失/可靠性
可容忍：视频，网络电话
不可容忍(100%可靠)：电子邮件，文件传输，telnet

* 时间延迟
通话，网游

* 带宽
在线视频

#### TCP服务
* 面向连接：客户机服务器进程需要建立连接
* 可靠传输：不丢包不乱序
* 流量控制：发送方不会发送过快
* 拥塞控制：网络负载过重时候限制发送方发送速度
* 不提供时延保障
* 不提供最小带宽保障

#### UDP服务
* 无连接
* 不可靠数据传输
* 不提供：可靠保障，流量控制，拥塞控制，延迟保障，带宽保障
 
### Web应用（World Wide Web）(Tim Berners-Lee)

#### Web对象寻址

通过URL（Uniform Resource Locator）统一资源定位器

协议://host:port/path

#### Http协议
* 超文本传输协议
* C/S结构
* 版本：1.0 RFC 1945    1.1 RFC 2068
* 使用TCP传输协议
* 无状态协议：服务器不维护客户端行为
* 连接类型：

非持久性连接：每个TCP连接最多允许传输一个对象（HTTP1.0）

持久性连接：每个TCP连接允许传输多个对象（HTTP1.1）
RTT（Round Trip Time）客户端发送一个很小的数据包到服务器并返回所经历的时间

1. 无流水的持久性连接：客户端只有收到前一个响应后才发送新的请求，每个对象耗时1RTT
2. 带流水机制的持久连接：客户端遇到一个引用对象就尽快发出（理想情况下，收到所有引用对象耗时1RTT）

* 请求消息
ASCII码编写（可以直接读取）

HTTP/1.0:
GET,POST,HEAD(不要把请求的对象放响应里)

HTTP/1.1:
GET,POST.HEAD,PUT(把消息体里的文件上传到指定的路径),DELETE(删除url所制定的文件)

* 响应消息
ASCII码编写（可以直接读取）

* Cookie

组件：
1. HTTP响应消息的cookie头部行
2. HTTP请求消息的cookie头部行
3. 保存在客户端主机上的cookie文件，由浏览器管理
4. Web服务器端的后台数据

* 缓存/代理服务器
如果所请求对象在缓存中，缓存返回对象，否则缓存服务器向原始服务器发送HTTP请求，获取对象，然后返回给客户端并保存该对象

缓存既充当客户端，也充当服务器

一般由ISP架设

条件性GET解决缓存有效性：在请求消息中声明持有版本日期if-modified-since:<date>(如果缓存版本是最新的，则相应消息不包含对象304 Not Modified,使用带宽很少)


在不访问服务器的前提下满足客户端的HTTP请求
1. 缩短客户请求响应时间
2. 减少机构/组织的流量
3. 在大范围内实现有效的内容分发（CDN）

### Email应用

* 邮件客户端

FoxMail,浏览器

* 邮件服务器

为用户分配邮箱

消息队列：存储待发送email

* SMTP协议（采用TCP）（端口25）（发送协议）

1. 邮件服务器之间传递消息所使用的协议
2. 采用命令响应模式：
```
命令：ASCII文本

响应：状态码+语句（只能包含7位ASCII码）

例如：telnet smtp.qq.com 25
```
3. 使用持久性连接

4. 使用CRLF.CRLF(Carriage-Return Line-Feed回车键换行)确定消息的结束

* SMTP消息格式

head:TO,From,Subject
body:消息本身（只能是ASCII）

MIME:多媒体邮件扩展

通过在邮件头部（head）增加额外的行以申明MIME的内容类型
```
MIME-Version:1.0
Content-Transfer-Encoding:base64
Content-Type:image/jpeg

base64 encoded data
。。。。。。
。。。。。。
base64 encoded data
```

* POP3（Post Office Protocol）协议
1. 认证/授权(客户端<- ->服务器)和下载
2. 认证过程
```
客户端命令：
User:用户名
Pass:密码
服务端响应：
+OK
-ERR
```
3. 事物阶段
```
List:列出消息数量
Retr:用编号获取消息
Dele:删除消息
Quit:退出
```
4. 下载并删除模式：换了客户端无法重读，下载并保持模式：不同客户端都可以保留消息
5. 是无状态协议


* IMAP(Internet Mail Access Protocol)

1. 所有消息保存在服务器
2. 允许用户利用文件夹组织消息
3. 支持跨会话的用户状态（有状态）
4. 相较于POP3更高级更复杂


### DNS应用（Domain Name System）（应用层协议）（域名和IP映射）

* 多层命名服务器构成的分布式数据库

集中式存在问题：
1. 单点失败问题
2. 流量问题
3. 距离问题
4. 维护性问题

采用分布式和层次式：
```
Root DNS Server
↓
com DNS servers   org DNS servers edu DNS servers
↓
yahoo.com DNS servers  amazon.com DNS servers  pbs.org DNS servers   poly.edu DNS servers
```

```
例如访问：www.amazon.com
本地域名解析服务器无法解析域名时
↓
客户端查询Root服务器找到com域名解析服务器
客户端查询com服务器找到amazon.com域名解析服务器
客户端查询amazon.com服务器找到www.amazon,com域名IP地址
```

全球有13个根域名服务器
Network Solutions维护com顶级域名服务器
Educause维护edu

每个ISP都有一个本地域名服务器（默认域名解析服务器）

本地域名解析服务器：
当主机进行DNS查询时，查询被发送到本地域名服务器，作为代理，将查询转发给顶级域名解析服务器系统
```
1. 递归查询（直接由Root去找然后返回）
2. 迭代查询（Root返回下一级）

```

缓存记录和更新：本地域名服务器一般会缓存顶级域名服务器的映射（因此根域名服务器不经常被访问）

DNS记录（RR resource records）：
```
RR format :(name,value,type,ttl)

Type=A
Name:主机域名
Value:IP地址

Type=NS
Name:域（edu.cn）
Value:该域权威域名解析服务器的主机域名

Type=CNAME
Name:某一真实域名的别名
Value:真实的域名

Type=MX
Name:邮件地址
Value:相对应name的邮件服务器

```

DNS协议（查询回复性的协议）（查询回复格式相同）(DNS在进行区域传输的时候使用TCP协议，域名解析时使用UDP协议)

DNS的规范规定了2种类型的DNS服务器，一个叫主DNS服务器，一个叫辅助DNS服务器。在一个区中主DNS服务器从自己本机的数据文件中读取该区的DNS数据信息，而辅助DNS服务器则从区的主DNS服务器中读取该区的DNS数据信息。当一个辅助DNS服务器启动时，它需要与主DNS服务器通信，并加载数据信息，这就叫做区传送（zone transfer）


```
identification：16位查询编号，回复使用相同的编号
flags:查询或回复，期望递归，递归可用，权威回答
questions:name type
answers:
authority:
additional information:
```

注册域名

1. 向域名管理机构提供你的权威域名接信息服务器的名字和IP地址
2. 域名管理机构向com顶级域名解析服务器中插入两条记录
```
networkkytopia.com , dns1.networkkytopia.com , NS
dns1.networkkytopia.com , 212.212.212.1 , A
```
3. 在权威域名解析人服务器中福为www.networkkytopia.com加入Type A记录，为networkkytopia.com加入Type MX记录（邮件）


* 负载均衡


### P2P应用(文件分发)

* 没有服务器
* 任何端系统之间直接通信
* 节点阶段性接入Internet
* 节点可能更换IP


#### 文件分分发
* 客户机/服务器：需要串行地发送N个副本（传输时间随节点数目线性增长）
* P2P架构：至少发送一个副本（趋向一个极值）


BT协议：（上传速率高，获取更好的交易伙伴，更好的获取文件）

tracker:跟踪参与torrent的节点

torrent:交换同一个文件的文件块的节点组

* 文件划分256KB的chunk
* 节点加入torrent(积累文件)（向tracker注册以获得节点清单）
* 下载同事节点需要向其他节点上传chunk
* 节点可能加入或离开

获取chunk

1. 给定任意课不同节点持有的文件的不同chunk集合
2. 定期查询每个邻居所持有的chunk列表
3. 节点发送请求获取缺失的chunk（稀缺优先）

发送chunk（tit-for-tat）

1. 向4个邻居(正在向其发送chunk的速度最快的4个邻居)(每10秒评估一次)发送chunk
2. 每30秒随机选择一个其他节点向其发送chunk

#### P2P索引（信息到节点位置的映射）

* 集中式索引：

节点接入时，通知中央服务器(IP,内容)

缺点：
1. 内容检索是集中的，存在单点失效
2. 成为动态瓶颈
3. 版权问题

* 分布式索引（洪泛式查询，会大量消耗网络带宽，导致网络拥塞）
1. 完全分布式架构
2. 每个节点对它共享的文件进行索引，且只对它共享的文件进行索引
3. 覆盖网络（逻辑网络）（如果查询命中，则利用反向路径发回查询节点）

缺点：
1. 洪泛式查询，会大量消耗网络带宽，导致网络拥塞

* 层次式覆盖网络（介于集中式和洪泛之间）（Skype）

1. 有普通节点和超级节点
2. 普通节点和超级节点中是集中式
3. 超级节点和超级节点中是洪泛式 

### Socket（套接字）编程（针对端系统）（应用层和传输层间）（操作系统体提供的API）(微软采用套接字接口API形成另一个API叫WINSOCK)

* 最初面向BSD UNIX-Berkley（TCP/IP）
* 通信模型（C/S）
* （对外）通过“IP+端口”标识不同套接字：
而（对内）操作系统使用“套接字描述符（socket descriptor）（小整数）”管理套接字
```
类似文件的抽象
当应用进程创建套接字时，操作系统分配一个数据结构存储该套接字相关信息

返回套接字描述符

family:PF INET
service:sock_stream
local:
remote:
local port:
remote port:
```
使用地址结构sockaddr_in申明端点地址变量
```
sockaddr_in
{
u_char sin_len;//地址长度
u_char sin_family;//地址族（TCP/IP:AF_INET）
u_short sin_port;//端口号
struct in_addr sin_addr;//IP地址
char sin_zero[8];//未用，置0
}
```

#### WinSock（方法API）
WSAStartup开始（初始化Windows Sockets API）
WSACleanup结束（释放所使用的Windows Sockets DLL）

方法API
```
socket（协议族，套接字类型，协议号）
套接字类型：
1. SOCK_STREAM TCP
2. SOCK_DGRAN UDP
3. SOCK_RAW 原始套接字，面向网络层(需要有特殊权限root/admin)


close关闭套接字

bind（套接字描述符，本地端点地址，地址长度）服务端需要绑定地址
可以使用INADDR_ANY地址通配符指定端点地址，解决多网卡绑定多IP

listen(套接字描述符，缓存队列大小)置服务器端处于监听状态,只用于服务端

connetct(套接字描述符，端点地址，地址长度)只用于客户端
TCP客户端发起连接
UDP客户端，不发起连接，仅指定服务端地址

accept(套接字描述符，端点地址，地址长度)只用于服务端，用于从请求队列中取出排在最前面的一个客户端请求，并创建一个新的套接字来与客户端套接字创建连接通道
会创建一个新的套接字与客户端联系，并提供服务（可以并发服务）

send() tcp发送

sendto() udp接收

recv() tcp发送

recvfrom() udp接收


```

#### 客户端软件设计

常用函数
```
inet_addr()实现十进制IP地址转32位IP地址
gethostbyname()实现域名到32位IP地址转换（返回一个指向结构hostent的指针）

struct hostent{
char FAR*       h_name;//official host name
char FAR* FAR*  h_aliases;//other aliases
short           h_addrtype;//address type
short           h_lengty;//address length
short FAR* FAR* h_addr_list;//list of address  
} 

getservbyname()将服务名（HTTP）转换成熟知的端口号

getprotobyname()将协议名转换成协议号
```

TCP客户端软件
1. 确定服务器IP和端口
2. 创建套接字
3. 连接服务器
4. 遵循应用层协议进行通讯
5. 关闭释放连接

UDP客户端软件
1. 确定服务器IP和端口（不一定第一次用）
2. 创建套接字
3. 指定服务器端点地址，构造UDP数据报
4. 遵循应用层协议进行通讯
5. 关闭释放套接字

双协议服务（TCP,UDP）使用13端口

#### 服务端软件设计

* 循环无连接服务器

1. 创界套接字
2，绑定端点地址（INADDR_ANY+端口号）
3. 反复接收来自客户端的请求
4. 遵循应用协议，构造响应报文，发送给客户
5. 通过recvfrom()获取客户端端点地址

* 循环面向谅解服务器

1. 创建（主）套接字，并板顶熟知端口号
2. 设置（主）套接字为被动监听模式，准备用于服务器
3. 调用accept函数接收下一个连接请求，创建新的套接字用于该客户建立按连接
4. 遵循应用层协议，反复接收客户端请求，构造并发送响应（通过新套接字）
5. 完成特定客户服务后，关闭与该客户之间的连接，返回步骤3

* 并发无连接服务器

1. 主线程创建套接字，并绑定熟知端口号
2. 反复调用recvfrom()接收下一个客户端请求，并创建新线程处理该客户端响应
3. 子线程接收请求，依据应用层协议构造响应报文，并调用send,然后退出子线程
4. 主线程用于创建子线程

* 并发面向连接服务器

1. 创建（主）套接字，并板顶熟知端口号
2. 设置（主）套接字为被动监听模式，准备用于服务器
3. 反复调用accept函数，接收下一个连接请求，并创建一个新的子线程处理客户响应
4. 子线程接收客户的服务请求，（通过创建新的套接字）,依据应用层协议与特定客户进行及哦啊胡，然后关闭释放连接并退出（线程终止）






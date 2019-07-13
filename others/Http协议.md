# Http部分

## 请求过程
* DNS解析
* TCP连接
* 发送HTTP请求
* 服务器处理请求并返回HTTP报文
* 浏览器解析渲染页面
* 连接结束

## 三次握手
![](https://i.loli.net/2019/07/05/5d1f21066f19692913.png)

* 第一次握手：Client 什么都不能确认；Server 确认了对方发送正常，自己接收正常

* 第二次握手：Client 确认了：自己发送、接收正常，对方发送、接收正常；Server 确认了：对方发送正常，自己接收正常

* 第三次握手：Client 确认了：自己发送、接收正常，对方发送、接收正常；Server 确认了：自己发送、接收正常，对方发送、接收正常

所以三次握手就能确认双发收发功能都正常，缺一不可

## 四次挥手
![](https://i.loli.net/2019/07/05/5d1f2153588e062585.png)


## 为什么客户端最后还要等待2MSL？
MSL（Maximum Segment Lifetime），TCP允许不同的实现可以设置不同的MSL值。

第一，保证客户端发送的最后一个ACK报文能够到达服务器，因为这个ACK报文可能丢失，站在服务器的角度看来，我已经发送了FIN+ACK报文请求断开了，客户端还没有给我回应，应该是我发送的请求断开报文它没有收到，于是服务器又会重新发送一次，而客户端就能在这个2MSL时间段内收到这个重传的报文，接着给出回应报文，并且会重启2MSL计时器。

第二，防止类似与“三次握手”中提到了的“已经失效的连接请求报文段”出现在本连接中。客户端发送完最后一个确认报文后，在这个2MSL时间中，就可以使本连接持续的时间内所产生的所有报文段都从网络中消失。这样新的连接中不会出现旧连接的请求报文。

## 为什么建立连接是三次握手，关闭连接确是四次挥手呢？

建立连接的时候， 服务器在LISTEN状态下，收到建立连接请求的SYN报文后，把ACK和SYN放在一个报文里发送给客户端。
而关闭连接时，服务器收到对方的FIN报文时，仅仅表示对方不再发送数据了但是还能接收数据，而自己也未必全部数据都发送给对方了，所以己方可以立即关闭，也可以发送一些数据给对方后，再发送FIN报文给对方来表示同意现在关闭连接，因此，己方ACK和FIN一般都会分开发送，从而导致多了一次。

## URI和URL的区别是什么?
* URI(Uniform Resource Identifier) 是同一资源标志符，可以唯一标识一个资源。
* URL(Uniform Resource Location) 是同一资源定位符，可以提供该资源的路径。它是一种具体的 URI，即 URL 可以用来标识一个资源，而且还指明了如何 locate 这个资源。
* URI的作用像身份证号一样，URL的作用更像家庭住址一样。URL是一种具体的URI，它不仅唯一标识资源，而且还提供了定位该资源的信息。
* URL是URI子集

## Request报文
![](https://i.loli.net/2019/07/05/5d1f22f3d5aaa73948.png)

## Response报文
![](https://i.loli.net/2019/07/05/5d1f23f8362c295056.png)

## Content-Type
* multipart/form-data表单（boundary=AaB03x表示使用这个字符进行分割）
* multipart/byteranges包含多个范围（head里有个Content-Range属性）（206）

## 状态码
* 1xx正在处理
* 2xx正确处理
* 3xx需要附加操作，如重定向
* 4xx服务器无法处理请求
* 5xx服务器处理请求出错

## Cache-Control

* 禁止进行缓存
缓存中不得存储任何关于客户端请求和服务端响应的内容。每次由客户端发起的请求都会下载完整的响应内容。
Cache-Control: no-store

* 强制确认缓存
如下头部定义，此方式下，每次有请求发出时，缓存会将此请求发到服务器（译者注：该请求应该会带有与本地缓存相关的验证字段），服务器端会验证请求中所描述的缓存是否过期，若未过期（注：实际就是返回304），则缓存才使用本地缓存副本。
Cache-Control: no-cache

* 私有缓存和公共缓存
"public" 指令表示该响应可以被任何中间人（译者注：比如中间代理、CDN等）缓存。若指定了"public"，则一些通常不被中间人缓存的页面（译者注：因为默认是private）（比如 带有HTTP验证信息（帐号密码）的页面 或 某些特定状态码的页面），将会被其缓存。

而 "private" 则表示该响应是专用于某单个用户的，中间人不能缓存此响应，该响应只能应用于浏览器私有缓存中。
Cache-Control: private
Cache-Control: public

* 缓存过期机制
过期机制中，最重要的指令是 "max-age=<seconds>"，表示资源能够被缓存（保持新鲜）的最大时间。相对Expires而言，max-age是距离请求发起的时间的秒数。针对应用中那些不会改变的文件，通常可以手动设置一定的时长以保证缓存有效，例如图片、css、js等静态资源。

详情看下文关于缓存有效性的内容。
Cache-Control: max-age=31536000

* 缓存验证确认
当使用了 "must-revalidate" 指令，那就意味着缓存在考虑使用一个陈旧的资源时，必须先验证它的状态，已过期的缓存将不被使用。详情看下文关于缓存校验的内容。

Cache-Control: must-revalidate

## Set-Cookie

* Name=Value

* Expires=<date> 可选
cookie 的最长有效时间，形式为符合 HTTP-date 规范的时间戳。参考 Date 可以获取详细信息。如果没有设置这个属性，那么表示这是一个会话期 cookie 。一个会话结束于客户端被关闭时，这意味着会话期 cookie 在彼时会被移除。然而，很多Web浏览器支持会话恢复功能，这个功能可以使浏览器保留所有的tab标签，然后在重新打开浏览器的时候将其还原。与此同时，cookie 也会恢复，就跟从来没有关闭浏览器一样。

* Max-Age=<non-zero-digit> 可选
在 cookie 失效之前需要经过的秒数。一位或多位非零（1-9）数字。一些老的浏览器（ie6、ie7 和 ie8）不支持这个属性。对于其他浏览器来说，假如二者 （指 Expires 和Max-Age） 均存在，那么 Max-Age 优先级更高。

* Domain=<domain-value> 可选
指定 cookie 可以送达的主机名。假如没有指定，那么默认值为当前文档访问地址中的主机部分（但是不包含子域名）。与之前的规范不同的是，域名之前的点号会被忽略。假如指定了域名，那么相当于各个子域名也包含在内了。

* Path=<path-value> 可选
指定一个 URL 路径，这个路径必须出现在要请求的资源的路径中才可以发送 Cookie 首部。字符  %x2F ("/") 可以解释为文件目录分隔符，此目录的下级目录也满足匹配的条件（例如，如果 path=/docs，那么 "/docs", "/docs/Web/" 或者 "/docs/Web/HTTP" 都满足匹配的条件）。

* Secure 可选
一个带有安全属性的 cookie 只有在请求使用SSL和HTTPS协议的时候才会被发送到服务器。然而，保密或敏感信息永远不要在 HTTP cookie 中存储或传输，因为整个机制从本质上来说都是不安全的，比如前述协议并不意味着所有的信息都是经过加密的。
注意：非安全站点（http:）已经不能再在 cookie 中设置 secure 指令了（在Chrome 52+ and Firefox 52+ 中新引入的限制）。

* HttpOnly 可选
设置了 HttpOnly 属性的 cookie 不能使用 JavaScript 经由  Document.cookie 属性、XMLHttpRequest 和  Request APIs 进行访问，以防范跨站脚本攻击（XSS）。

* SameSite=Lax （SameSite=Strict）可选 
允许服务器设定一则 cookie 不随着跨域请求一起发送，这样可以在一定程度上防范跨站请求伪造攻击（CSRF）。

## SSL （Secure Socket Layer，安全套接字层）
* 位于可靠的面向连接的网络层协议和应用层协议之间的一种协议层。SSL通过互相认证、使用数字签名确保完整性、使用加密确保私密性，以实现客户端和服务器之间的安全通讯。该协议由两层组成：SSL记录协议和SSL握手协议。

## TLS：(Transport Layer Security，传输层安全协议)
用于两个应用程序之间提供保密性和数据完整性。该协议由两层组成：TLS记录协议和TLS握手协议。


## SSL和TSL和HTTPS

* SSL是Netscape开发的专门用户保护Web通讯的，目前版本为3.0。
* 最新版本的TLS 1.0是IETF(工程任务组)制定的一种新的协议，它建立在SSL 3.0协议规范之上，是SSL 3.0的后续版本。两者差别极小，可以理解为SSL
* 3.1，它是写入了RFC的。在TLS与SSL3.0之间存在着显著的差别，主要是它们所支持的加密算法不同，所以TLS与SSL3.0不能互操作。
* HTTPS，也称作HTTP over TLS。TLS的前身是SSL，TLS 1.0通常被标示为SSL 3.1，TLS 1.1为SSL 3.2，TLS 1.2为SSL 3.3

## HTTP认证
* BASIC认证
* DIGEST认证
* SSL客户端认证
* 表单认证

## SPDY
* 会话层

## Web攻击
* XSS（Cascading Style Sheets跨站脚本攻击）

demo1
```
<input type="text" value=""><script>alert('XSS');</script>">
<button>搜索</button>
<div>
  您搜索的关键词是："><script>alert('XSS');</script>
</div>
```
demo2
```
<a href="javascript:alert(&#x27;XSS&#x27;)">跳转...</a>
```

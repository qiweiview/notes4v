1. 访问不到方法首先要从你的controller能否被扫描到出发,
2. 没有引入Thymeleaf模板依赖会404

图中显示创建springboot项目自带的这两个的文件要注意把他俩拿出来放到父包下面也就是图中这个位置。如果你的这两个文件在子包里或者说平级的一个包里就会影响controller无法被扫描到，从而导致无法访问到你的方法。




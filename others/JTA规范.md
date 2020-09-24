# JTA规范

* Java事务API（JTA：Java Transaction API）和它的同胞Java事务服务（JTS：Java Transaction Service），为J2EE平台提供了分布式事务服务（distributed transaction）的能力
* 某种程度上，可以认为JTA规范是XA规范的Java版，其把XA规范中规定的DTP模型交互接口抽象成Java接口中的方法，并规定每个方法要实现什么样的功能
* 在DTP模型中，规定了模型的五个组成元素：应用程序(Application)、资源管理器(Resource Manager)、事务管理器(Transaction Manager)、通信资源管理器(Communication Resource Manager)、 通信协议(Communication Protocol)。
* 而在JTA规范中，模型中又多了一个元素Application Server

## 事务管理器(transaction manager)：
* 处于图中最为核心的位置，其他的事务参与者都是与事务管理器进行交互。事务了管理器提供事务声明，事务资源管理，同步，事务上下文传播等功能。
* JTA规范定义了事务管理器与其他事务参与者交互的接口，而JTS规范定义了事务管理器的实现要求，因此我们看到事务管理器底层是基于JTS的。

## 应用服务器(application server)：
* 顾名思义，是应用程序运行的容器。
* JTA规范规定，事务管理器的功能应该由application server提供，如上图中的EJB Server。一些常见的其他web容器，如：jboss、weblogic、websphere等，都可以作为application server，这些web容器都实现了JTA规范。
* 特别需要注意的是，并不是所有的web容器都实现了JTA规范，如tomcat并没有实现JTA规范，因此并不能提供事务管理器的功能

## 应用程序(application)：
* 简单来说，就是我们自己编写的应用，部署到了实现了JTA规范的application server中，之后我们就可以我们JTA规范中定义的UserTransaction类来声明一个分布式事务。
* 通常情况下，application server为了简化开发者的工作量，并不一定要求开发者使用UserTransaction来声明一个事务，开发者可以在需要使用分布式事务的方法上添加一个注解，就像spring的声明式事务一样，来声明一个分布式事务。
* ***特别需要注意的是，JTA规范规定事务管理器的功能由application server提供。但是如果我们的应用不是一个web应用，而是一个本地应用，不需要被部署到application server中，无法使用application server提供的事务管理器功能。又或者我们使用的web容器并没有事务管理器的功能，如tomcat。对于这些情况，我们可以直接使用一些第三方的事务管理器类库，如JOTM和Atomikos。将事务管理器直接整合进应用中，不再依赖于application server。***

## 资源管理器(resource manager)：
* 理论上任何可以存储数据的软件，都可以认为是资源管理器RM。最典型的RM就是关系型数据库了，如mysql，另外一种比较常见的资源管理器是消息中间件，如ActiveMQ、RabbitMQ等， 这些都是真正的资源管理器。  
* 事实上，将资源管理器(resource manager)称为资源适配器(resource adapter)似乎更为合适。因为在java程序中，我们都是通过client来于RM进行交互的，例如：我们通过mysql-connector-java-x.x.x.jar驱动包，获取Conn、执行sql，与mysql服务端进行通信；通过ActiveMQ、RabbitMQ等的客户端，来发送消息等。
* 正常情况下，一个数据库驱动供应商只需要实现JDBC规范即可，一个消息中间件供应商只需要实现JMS规范即可。 而引入了分布式事务的概念后，DB、MQ等在DTP模型中的作用都是RM，二者是等价的，需要由TM统一进行协调。
* ***为此，JTA规范定义了一个XAResource接口，其定义RM必须要提供给TM调用的一些方法。之后，不管这个RM是DB，还是MQ，TM并不关心，因为其操作的是XAResource接口。而其他规范(如JDBC、JMS)的实现者，同时也对此接口进行实现。如MysqlXAConnection，就实现了XAResource接口。***

## 通信资源管理器(Communication Resource Manager)：
* 这个是DTP模型中就已经存在的概念，对于需要跨应用的分布式事务，事务管理器彼此之间需要通信，这是就是通过CRM这个组件来完成的。JTA规范中，规定CRM需要实现JTS规范定义的接口。
* 下图更加直观的演示了JTA规范中各个模型组件之间是如何交互的： 
[![wzU4Z8.md.png](https://s1.ax1x.com/2020/09/24/wzU4Z8.md.png)](https://imgchr.com/i/wzU4Z8)



 

说明如下：
1、application 运行在application server中
2、application 需要访问3个资源管理器(RM)上资源：1个MQ资源和2个DB资源。
3、由于这些资源服务器是独立部署的，如果需要同时进行更新数据的话并保证一致性的话，则需要使用到分布式事务，需要有一个事务管理器来统一协调。
4、Application Server提供了事务管理器的功能
5、作为资源管理器的DB和MQ的客户端驱动包，都实现了XAResource接口，以供事务管理器调用


## JTA规范--接口定义
* JTA是java扩展包，在应用中需要额外引入相应的jar包依赖
```
<dependency>
    <groupId>javax.transaction</groupId>
    <artifactId>jta</artifactId>
    <version>1.1</version>
</dependency>
```

* 作为DTP模型中Application开发者的我们，并不需要去实现任何JTA规范中定义的接口，只需要使用TM提供的UserTransaction实现，来声明、提交、回滚一个分布式事务即可。
* 以下案例演示了UserTransaction接口的基本使用：构建一个分布式事务，来操作位于2个不同的数据库的数据，假设这两个库中都有一个user表。
```
UserTransaction userTransaction=...
        try{
            //开启分布式事务
            userTransaction.begin(); 
           
            //执行事务分支1
            conn1 = db1.getConnection();
            ps1= conn1.prepareStatement("INSERT into user(name,age) VALUES ('tianshouzhi',23)");
            ps1.executeUpdate();
            
            //执行事务分支2
            conn2 = db2.getConnection();
            ps2 = conn2.prepareStatement("INSERT into user(name,age) VALUES ('tianshouzhi',23)");
            ps2.executeUpdate();
            //提交，两阶段提交发生在这个方法内部
            userTransaction.commit();
        }catch (Exception e){
            try {
                userTransaction.rollback();//回滚
            } catch (SystemException ignore) {
            }
        }
```





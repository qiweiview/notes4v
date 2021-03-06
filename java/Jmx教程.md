# Jmx教程

## 远程运行指令
* 防火墙规则要开
* -Dcom.sun.management.jmxremote.port 和 Dcom.sun.management.jmxremote.rmi.port 都要指定，否则使用其他端口，防火墙没开的话连不上。
* 连接不上，检查进程pid占用的端口有没有开
* -Djava.rmi.server.hostname=111.111.111.111要绑定，不能是0.0.0.0不然会一直断掉连不上
```
java -Dcom.sun.management.jmxremote.port=8088 -Dcom.sun.management.jmxremote.rmi.port=8088 -Dcom.sun.management.jmxremote.authenticate=false  -Dcom.sun.management.jmxremote.ssl=false -Djava.rmi.server.hostname=114.67.111.177 Run
```

* 常用列表
``` 
-Dcom.sun.management.jmxremote.port=8088 
-Dcom.sun.management.jmxremote.rmi.port=8088 
-Dcom.sun.management.jmxremote.authenticate=false  
-Dcom.sun.management.jmxremote.ssl=false 
-Djava.rmi.server.hostname=114.67.111.177 
-Dcom.sun.management.jmxremote.access.file=Path_to_access_file/jmxremote.access
-Dcom.sun.management.jmxremote.password.file=Path_to_password_file/jmxremote.password
```

## 密码文件
* jmxremote.access
```
monitorRoleUser   readonly
controlRoleUser   readwrite 
```

* jmxremote.password
```
monitorRoleUser password1
controlRoleUser password2
```


## 类
* MBean
* 运行主类
```
package jmx;

import javax.management.*;
import java.lang.management.ManagementFactory;

public class Run {
    public static void main(String[] args) throws Exception {
        // 创建MBeanServer
        MBeanServer mbs = ManagementFactory.getPlatformMBeanServer();

        // 新建MBean ObjectName, 在MBeanServer里标识注册的MBean
        ObjectName name = new ObjectName("view:type=View");

        // 创建MBean,Echo类需要实现相关接口
        View mbean = new View();

        //注册以后可以通过Jconsole等工具查看
        // 在MBeanServer里注册MBean, 标识为ObjectName(com.dxz.mbean:type=Echo)
        mbs.registerMBean(mbean, name);
        mbean.addNotificationListener(new ViewNotificationListener(), null, null);    //重点


        Thread.sleep(Long.MAX_VALUE);
    }

    public static class  View  extends NotificationBroadcasterSupport implements ViewMBean  {
        private int n;

        @Override
        public String toString() {
            return "View{" +
                    "n=" + n +
                    '}';
        }

        @Override
        public int printSum() {
            return n;
        }

        @Override
        public void addNum(Integer i, Integer z) {
            n = i + z;
        }

        @Override
        public void printThread() {
            Thread thread = Thread.currentThread();
            Notification n = new Notification(//创建一个信息包
                    "jack.hi",//给这个Notification起个名称
                    this, //由谁发出的Notification
                    3306,//一系列通知中的序列号,可以设任意数值
                    System.currentTimeMillis(),//发出时间
                    "the thread is"+thread.getName());//发出的消息文本
            //发出去
            sendNotification(n);

        }

        @Override
        public Integer getN() {
            return n;
        }
    }

    public interface ViewMBean {
        int printSum();
        void addNum(Integer i,Integer z);
        void printThread();
        Integer getN();

    }
    public static class ViewNotificationListener implements NotificationListener {
        @Override
        public void handleNotification(Notification n, Object handback) {
            System.out.println("type=" + n.getType());
            System.out.println("source=" + n.getSource());
            System.out.println("seq=" + n.getSequenceNumber());
            System.out.println("send time=" + n.getTimeStamp());
            System.out.println("message=" + n.getMessage());

            if (handback != null) {
                if (handback instanceof jmx.View) {
                    jmx.View hello = (jmx.View) handback;
                    System.out.println(hello);
                }
            }

        }
    }

}

```

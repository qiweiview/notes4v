# Instrumentation教程


## [参考1](https://www.ibm.com/developerworks/cn/java/j-lo-jse61/index.html)
## [参考2](https://zhuanlan.zhihu.com/p/51909016)

* 示例客户端
```

public class Premain {

    /**
     * 启动前客户端方法（只会运行一次）
     * @param agentArgs
     * @param inst
     */
    public static void premain(String agentArgs, Instrumentation inst) {
        System.out.println("premain:"+ Arrays.toString(inst.getAllLoadedClasses()));
    }

    public static void premain(String agentArgs) {

    }

    /**
     * 运行时客户端方法
     * @param agentArgs
     * @param inst
     */
    public static void agentmain (String agentArgs, Instrumentation inst) {
        System.out.println("agentmain:"+ Arrays.toString(inst.getAllLoadedClasses()));
    }
    public static void agentmain (String agentArgs) {


    }
}

```


## jdk6虚拟机启动后的动态 instrument
* 应用启动后，连接至应用

### 客户端MANIFEST.MF配置
```
Manifest-Version: 1.0
Created-By: 12.0.1 (Oracle Corporation)
Agent-Class: Agentmain
```


### Attach API 连接虚拟机
```
package t2;


import com.sun.tools.attach.*;

import java.io.IOException;
import java.util.HashSet;
import java.util.List;

public class JVMMonitor {
    public static void main(String[] args) throws IOException, AttachNotSupportedException, AgentLoadException, AgentInitializationException {

        HashSet<VirtualMachineDescriptor> set = new HashSet<>();
        List<VirtualMachineDescriptor> list = VirtualMachine.list();
        for (VirtualMachineDescriptor l : list) {
            if ("Job".equals(l.displayName())){
                VirtualMachine attach = VirtualMachine.attach(l);
                attach.loadAgent("Agentmain.jar");//加载工作目录下的
                attach.detach();
            }
        }


    }
}
```


## jdk5代理客户端
* 需要在main启动前绑定


### Premain

* 打包客户端jar
```
javac ./Premain.java
jar cvf Premain.jar  ./*.class
```

* MANIFEST.MF文件中配置前置类
```
Manifest-Version: 1.0 
Premain-Class: Premain
```

* 结合被监测jar包运行
```
//666为客户端的参数，-cp 指定查找用户类文件的位置
java -javaagent:Premain.jar=666  -cp Job.jar Job
```

* 客户端代码
```

import java.io.IOException;
import java.lang.instrument.ClassFileTransformer;
import java.lang.instrument.IllegalClassFormatException;
import java.lang.instrument.Instrumentation;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.security.ProtectionDomain;




public class Premain {
    public static void premain(String agentArgs, Instrumentation inst) {
        System.out.println("agentArgs----->"+agentArgs);
        inst.addTransformer(new InnerTransformer());
    }


    //每个类被读取时候都会调用这个方法，是否重写字节码
    public static class InnerTransformer implements ClassFileTransformer {
        @Override
        public byte[] transform(ClassLoader loader, String className, Class<?> classBeingRedefined, ProtectionDomain protectionDomain, byte[] classfileBuffer) throws IllegalClassFormatException {
            if (!className.equals("TransClass")) {
                System.out.println("---------->" + className);
                return null;
            }
            try {
                return Files.readAllBytes(Paths.get("D:\\class_test_home\\t1\\TransClass.class.2"));
            } catch (IOException e) {
                e.printStackTrace();
                return null;
            }

        }
    }





}
```


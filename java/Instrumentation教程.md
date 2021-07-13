# Instrumentation教程



## [zhihu](https://zhuanlan.zhihu.com/p/51909016)


## 打印已加载类的字节码的客户端
```

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.lang.instrument.ClassFileTransformer;
import java.lang.instrument.IllegalClassFormatException;
import java.lang.instrument.Instrumentation;
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.security.ProtectionDomain;


public class ClassDumper {

    public static void agentmain(String agentArgs, Instrumentation inst) {
        System.out.println(agentArgs);

        DumpClassFileTransformer dumpClassFileTransformer = new DumpClassFileTransformer();

        MyInvocationHandler inter = new MyInvocationHandler(new MyFly());
        Class[] classes = {FlyInterface.class, Comparable.class};
        FlyInterface sell = (FlyInterface) Proxy.newProxyInstance(FlyInterface.class.getClassLoader(), classes, inter);
        sell.fly();
        Class<? extends FlyInterface> aClass = sell.getClass();

        inst.addTransformer(dumpClassFileTransformer, true);
        try {
            inst.retransformClasses(aClass);
        } catch (Exception e) {
            System.out.println(" not found java_ssist_test.crate_method.Egg on  agentmain");
        }
        inst.removeTransformer(dumpClassFileTransformer);
    }

    public interface FlyInterface {
        void fly();

    }

    public static class MyFly implements FlyInterface{

        @Override
        public void fly() {
            System.out.println("im view i want to fly");
        }
    }

    public static class MyInvocationHandler implements InvocationHandler {

        private Object obj;

        public MyInvocationHandler(Object obj) {
            this.obj = obj;
        }

        @Override
        public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
            System.out.println("before");
            Object result = method.invoke(obj, args);
            System.out.println("after");
            return result;
        }
    }



    public static class DumpClassFileTransformer implements ClassFileTransformer {
        @Override
        public byte[] transform(ClassLoader loader, String className, Class<?> classBeingRedefined, ProtectionDomain protectionDomain, byte[] classfileBuffer) throws IllegalClassFormatException {

           String name="D:\\WorkSpace\\java_focus\\src\\main\\java\\instrumentation\\dump.class";
            File file = new File(name);
            System.out.println(file+"_"+name);
            FileOutputStream fileOutputStream = null;
            try {
                if (!file.exists()) {
                    file.createNewFile();
                }
                fileOutputStream = new FileOutputStream(file);
                fileOutputStream.write(classfileBuffer);
            } catch (IOException e) {
                e.printStackTrace();
            } finally {
                if (fileOutputStream != null) {
                    try {
                        fileOutputStream.close();
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            }

            return null;
        }
    }
}
```


## 示例客户端（包含pre 和agent）
* 如果 canRetransform 为 true，那么重转换类时也将调用该转换器
```

public class Premain {
    public static int count = 0;
    public static Class tClass;

    /**
     * 启动前客户端方法（只会运行一次）
     *
     * @param agentArgs
     * @param inst
     */
    public static void premain(String agentArgs, Instrumentation inst) {
        System.out.println("premain:" + Arrays.toString(inst.getAllLoadedClasses()));
    }

    public static void premain(String agentArgs) {

    }

    /**
     * 运行时客户端方法
     *
     * @param agentArgs
     * @param inst
     */
    public static void agentmain(String agentArgs, Instrumentation inst) {
        MyClassFileTransformer myClassFileTransformer = new MyClassFileTransformer();
        inst.addTransformer(myClassFileTransformer, true);
        try {
            inst.retransformClasses(Class.forName("java_ssist_test.crate_method.Egg"));
        } catch (Exception e) {
            System.out.println(" not found java_ssist_test.crate_method.Egg on  agentmain");
        }
        inst.removeTransformer(myClassFileTransformer);

        System.out.println("try transformer:" + inst.isRetransformClassesSupported());

        try {
            Class<?> aClass2 = Class.forName("java_ssist_test.crate_method.Egg");
            System.out.println(count + ":" + (tClass == aClass2));
            tClass = aClass2;
            Method sayHi = aClass2.getDeclaredMethod("fly", String.class);
            Object o = aClass2.newInstance();
            Object invoke = sayHi.invoke(o, "view");
            System.out.println("get return: " + invoke);

        } catch (Exception e) {
            System.out.println("for name fail cause " + e);
        }

        System.out.println("agentmain:" + Arrays.toString(inst.getAllLoadedClasses()));
    }


    public static void agentmain(String agentArgs) {


    }


    public static class MyClassFileTransformer implements ClassFileTransformer {


        @Override
        public byte[] transform(ClassLoader loader, String className, Class<?> classBeingRedefined, ProtectionDomain protectionDomain, byte[] classfileBuffer) throws IllegalClassFormatException {
            if (!className.equals("java_ssist_test/crate_method/Egg")) {
                System.out.println("pass class ---------->" + className);
                return null;
            } else {
                count++;

                System.out.println("do recode by" + count);
                try {
                    return Files.readAllBytes(Paths.get("D:\\WorkSpace\\java_focus\\java_ssist_test\\crate_method\\Egg.class"));
                } catch (Exception exception) {
                    throw new RuntimeException();
                }
            }
        }
    }
}
```


## jdk6虚拟机启动后的动态 instrument
* 应用启动后，连接至应用

### 客户端MANIFEST.MF配置
```
Manifest-Version: 1.0
Created-By: 12.0.1 (Oracle Corporation)
Agent-Class: instrumentation.Premain
Can-Retransform-Classes: true
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


# Instrumentation教程

## jdk5代理客户端



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

# grpc教程


## 范例
* pom
* 先打包，插件将生成支持类
```
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.grpc</groupId>
    <artifactId>mistra</artifactId>
    <version>1.0-SNAPSHOT</version>

    <properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <grpc.version>1.34.1</grpc.version>
    </properties>


    <dependencies>
        <dependency>
            <groupId>io.grpc</groupId>
            <artifactId>grpc-netty</artifactId>
            <version>${grpc.version}</version>
        </dependency>

        <dependency>
            <groupId>io.grpc</groupId>
            <artifactId>grpc-protobuf</artifactId>
            <version>${grpc.version}</version>
        </dependency>

        <dependency>
            <groupId>io.grpc</groupId>
            <artifactId>grpc-stub</artifactId>
            <version>${grpc.version}</version>
        </dependency>

    </dependencies>

    <build>
        <extensions>
            <extension>
                <groupId>kr.motd.maven</groupId>
                <artifactId>os-maven-plugin</artifactId>
                <version>1.5.0.Final</version>
            </extension>
        </extensions>


        <plugins>

            <plugin>
                <groupId>org.xolstice.maven.plugins</groupId>
                <artifactId>protobuf-maven-plugin</artifactId>
                <version>0.5.1</version>
                <configuration>
                   
                   <!-- 设置扫描proto文件路径 --><protoSourceRoot>${basedir}/src/main/resources/proto</protoSourceRoot>
                    <protocArtifact>com.google.protobuf:protoc:3.5.1-1:exe:${os.detected.classifier}</protocArtifact>
                    <pluginId>grpc-java</pluginId>
                    <pluginArtifact>io.grpc:protoc-gen-grpc-java:1.11.0:exe:${os.detected.classifier}</pluginArtifact>
                </configuration>
                <executions>
                    <execution>
                        <goals>
                            <goal>compile</goal>
                            <goal>compile-custom</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>

            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <configuration>
                    <source>1.8</source>
                    <target>1.8</target>
                </configuration>
            </plugin>
        </plugins>
    </build>

</project>
```

* 服务端
```
public class MistraServer {

    private int port = 8001;
    private Server server;

    private void start() throws IOException {
        server = ServerBuilder.forPort(port)
                .addService((BindableService) new MistraHelloWorldImpl())
                .build()
                .start();

        System.out.println("------------------- 服务端服务已开启，等待客户端访问 -------------------");

        Runtime.getRuntime().addShutdownHook(new Thread() {
            @Override
            public void run() {

                System.err.println("*** shutting down gRPC server since JVM is shutting down");
                MistraServer.this.stop();
                System.err.println("*** server shut down");
            }
        });
    }

    private void stop() {
        if (server != null) {
            server.shutdown();
        }
    }

    private void blockUntilShutdown() throws InterruptedException {
        if (server != null) {
            server.awaitTermination();
        }
    }

    public static void main(String[] args) throws IOException, InterruptedException {
        final MistraServer server = new MistraServer();
        //启动服务
        server.start();
        //服务一直在线，不关闭
        server.blockUntilShutdown();
    }

    // 定义一个实现服务接口的类
    private class MistraHelloWorldImpl extends MistraServiceGrpc.MistraServiceImplBase {

        @Override
        public void sayHello(MistraRequest mistraRequest, StreamObserver<MistraResponse> responseObserver) {
            // 具体其他丰富的业务实现代码
            System.out.println("收到来自客户端请求: " + mistraRequest.getName());
            MistraResponse reply = MistraResponse.newBuilder().setMessage(("你好，我是服务器")).build();
            responseObserver.onNext(reply);
            responseObserver.onCompleted();
        }
    }
}
```

* 客户端
```

import com.grpc.mistra.generate.MistraRequest;
import com.grpc.mistra.generate.MistraResponse;
import com.grpc.mistra.generate.MistraServiceGrpc;
import io.grpc.ManagedChannel;
import io.grpc.ManagedChannelBuilder;

import java.util.concurrent.TimeUnit;

/**
 * @Author: WangRui
 * @Date: 2018/11/27
 * Time: 14:46
 * Description:
 */
public class MistraClient {

    private final ManagedChannel channel;
    private final MistraServiceGrpc.MistraServiceBlockingStub blockingStub;

    public MistraClient(String host, int port) {
        channel = ManagedChannelBuilder.forAddress(host, port)
                .usePlaintext()
                .build();

        blockingStub = MistraServiceGrpc.newBlockingStub(channel);
    }

    public void shutdown() throws InterruptedException {
        channel.shutdown().awaitTermination(5, TimeUnit.SECONDS);
    }

    public void sendRequest(String name) {
        MistraRequest request = MistraRequest.newBuilder().setName(name).build();
        MistraResponse response = blockingStub.sayHello(request);
        System.out.println("收到来自服务器响应： "+response.getMessage());

    }

    public static void main(String[] args) throws InterruptedException {
        MistraClient client = new MistraClient("127.0.0.1", 889);
        client.sendRequest("hi im view" );
    }
}

```

# Nexus教程

## 安装
* 依赖java环境
* [下载](https://help.sonatype.com/repomanager3/download?_ga=2.236817288.820904134.1574663962-1451200743.1574663962)
```
/bin/nexus start
/bin/nexus stop
```
* 访问地址
```
ip:8081
```

* 默认的密码位置,登陆后修改密码
```
/usr/local/sonatype-work/nexus3/admin.password
```

* 配置仅有上传和查看权限的角色
![MxcCFS.png](https://s2.ax1x.com/2019/11/26/MxcCFS.png)

* maven setting.xml
```
  <servers> 
     <server>
      <id>Nexus Repository</id>
      <username>xxx</username>
      <password>xxx</password>
    </server>
  </servers> 

    <mirror>
      <id>nexus</id>
      <mirrorOf>*</mirrorOf>
      <url>http://114.67.111.177:8081/repository/maven-public/</url>
     </mirror>
```

## 使用
* 使用者pom.xml
```
<!-- 远程仓库 -->
 <repositories>
        <repository>
            <id>nexus</id>
            <name>nexus</name>
            <url>http://114.67.111.177:8081/repository/maven-public/</url>
        </repository>
 </repositories>
```

* 构建者pom.xml
```
    <groupId>com.qw607</groupId>
    <artifactId>xxx</artifactId>
    <version>1.0.1-SNAPSHOT</version>
    <!-- -SNAPSHOT则会创建快照版本 -->
    
    
<!-- 构建插件 -->
 <build>
        <plugins>
            <!-- 编译指定jdk版本号 -->
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.8.1</version>
                <configuration>
                    <source>1.8</source>
                    <target>1.8</target>
                    <encoding>UTF-8</encoding>
                    <showWarnings>true</showWarnings>
                </configuration>
            </plugin>
            <!-- 部署插件 -->
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-deploy-plugin</artifactId>
                <version>3.0.0-M1</version>
            </plugin>
            <!-- 部署带上源文件, 可以在引入依赖时看到源码, 以及源码上的注释信息 -->
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-source-plugin</artifactId>
                <version>3.0.1</version>
                <configuration>
                    <includePom>true</includePom>
                    <excludeResources>true</excludeResources>
                    <attach>true</attach>
                </configuration>
                <executions>
                    <execution>
                        <id>attach-sources</id>
                        <goals>
                            <goal>jar</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
        </plugins>
    </build>
    
    
 <!-- 配置上私服地址, 前面带上用户名密码, 目的是可以通过 mvn deploy 命令直接发布上传，id对应setting文件中server的id,否则会401密码错误 -->
    <distributionManagement>
        <repository>
            <id>Nexus Repository</id>
            <url>http://114.67.111.177:8081/repository/maven-releases/</url>
        </repository>
        <snapshotRepository>
            <id>Nexus Repository</id>
            <url>http://114.67.111.177:8081/repository/maven-snapshots/</url>
        </snapshotRepository>
    </distributionManagement>
```

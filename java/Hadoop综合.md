# Hadoop综合

## vim   ~/.bashrc
```
export JAVA_HOME=/usr/local/jdk11
export PATH=$JAVA_HOME/bin:$PATH
export PATH=$PATH:/usr/local/hadoop/bin:/usr/local/hadoop/sbin
export HADOOP_HOME=/usr/local/hadoop
```

## 打包
```
 <build>
        <plugins>


            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-shade-plugin</artifactId>
                <version>3.2.4</version>
                <executions>
                    <execution>
                        <phase>package</phase>
                        <goals>
                            <goal>shade</goal>
                        </goals>
                        <configuration>
                            <transformers>
                                <transformer implementation="org.apache.maven.plugins.shade.resource.ManifestResourceTransformer">
                                    <mainClass>com.LogAnalysisRunner</mainClass>
                                </transformer>
                            </transformers>
                        </configuration>
                    </execution>
                </executions>
            </plugin>


        </plugins>
    </build>
```

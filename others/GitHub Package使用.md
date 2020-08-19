# GitHub Package使用

## 配置
* setting.xml
* [获取password](https://github.com/settings/tokens)
```

<servers>
    <server>
      <id>github</id>
      <username>qiweiview</username>
      <password>xxxx</password>
    </server>
  </servers>

<profiles>
    <profile>
      <id>github</id>
      <repositories>
        <repository>
          <id>central</id>
          <url>https://repo1.maven.org/maven2</url>
          <releases><enabled>true</enabled></releases>
          <snapshots><enabled>true</enabled></snapshots>
        </repository>
        <repository>
          <id>github</id>
          <name>qiweiview</name>
          <url>https://maven.pkg.github.com/qiweiview/ndc/</url>
        </repository>
      </repositories>
    </profile>
  </profiles>
  
```

* pom.xml
```
 <distributionManagement>
        <repository>
            <id>github</id>
            <name>qiweiview</name>
            <url>https://maven.pkg.github.com/qiweiview/ndc/</url>
        </repository>
    </distributionManagement>
```

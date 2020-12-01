# WebService教程

## WSDL反推接口
* 使用wsimport生成对应的接口
```
D:\Application\jdk1.8.0_221\bin\wsimport "D:\nx\EdaDataTransfer.xml" -keep -p wsdl_to_interfaces -s "D:\nx"
```

## 使用CXF框架+SOAP协议
* 依赖
```
<dependency>
    <groupId>org.apache.cxf</groupId>
    <artifactId>cxf-core</artifactId>
    <version>3.0.4</version>
</dependency>
<dependency>
    <groupId>org.apache.cxf</groupId>
    <artifactId>cxf-rt-bindings-soap</artifactId>
    <version>3.0.4</version>
</dependency>
<dependency>
    <groupId>org.apache.cxf</groupId>
    <artifactId>cxf-rt-databinding-jaxb</artifactId>
    <version>3.0.4</version>
</dependency>
<dependency>
    <groupId>org.apache.cxf</groupId>
    <artifactId>cxf-rt-frontend-jaxws</artifactId>
    <version>3.0.4</version>
</dependency>
<dependency>
    <groupId>org.apache.cxf</groupId>
    <artifactId>cxf-rt-frontend-simple</artifactId>
    <version>3.0.4</version>
</dependency>
<dependency>
    <groupId>org.apache.cxf</groupId>
    <artifactId>cxf-rt-transports-http</artifactId>
    <version>3.0.4</version>
</dependency>
<dependency>
    <groupId>org.apache.cxf</groupId>
    <artifactId>cxf-rt-transports-udp</artifactId>
    <version>3.0.4</version>
</dependency>
<dependency>
    <groupId>org.apache.cxf</groupId>
    <artifactId>cxf-rt-ws-addr</artifactId>
    <version>3.0.4</version>
</dependency>
<dependency>
    <groupId>org.apache.cxf</groupId>
    <artifactId>cxf-rt-wsdl</artifactId>
    <version>3.0.4</version>
</dependency>
<dependency>
    <groupId>org.apache.cxf</groupId>
    <artifactId>cxf-rt-ws-policy</artifactId>
    <version>3.0.4</version>
</dependency>
<!-- https://mvnrepository.com/artifact/org.apache.neethi/neethi -->
<dependency>
    <groupId>org.apache.neethi</groupId>
    <artifactId>neethi</artifactId>
    <version>3.0.3</version>
</dependency>
<dependency>
    <groupId>org.apache.cxf</groupId>
    <artifactId>cxf-rt-transports-http-jetty</artifactId>
    <version>3.0.3</version>
</dependency>
```

* 接口定义
```
@WebService
public interface IUserWebService {
    User getUserByName(@WebParam(name="userName") String userName);
    
```
* 接口实现
```
public class UserWebServiceImpl implements IUserWebService {

```
* 服务启动
```
public class WebServiceApp {

    public static void main(String[] args) {
        // webservice接口
        IUserWebService userService = new UserWebServiceImpl();
        // 访问地址
        String address="http://localhost:8080/userWebService";
        // 发布服务
        Endpoint.publish(address, userService);
        System.out.println("web service 已启动");
   }
}
```
* 访问获取wsdl
```
http://localhost:8080/userWebService?wsdl
```
* 客户端访问
```
   JaxWsProxyFactoryBean svr = new JaxWsProxyFactoryBean();
        // 服务端接口
        svr.setServiceClass(IUserWebService.class);
        // 服务端地址
        svr.setAddress("http://localhost:8080/userWebService");
        IUserWebService userWebService = (IUserWebService) svr.create();
```

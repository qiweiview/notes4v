# JackSon教程


## 工具
```

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.TreeNode;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

public class Jackson {


    private static final ObjectMapper objectMapper = new ObjectMapper();


    /**
     * 对象转字符串
     * @param o
     * @return
     */
    public static String toJson(Object o){
        try {
            return objectMapper.writeValueAsString(o);
        } catch (JsonProcessingException e) {
            throw new RuntimeException("to json fail cause:"+e.getMessage());
        }
    }


    /**
     * 字符串转对象
     * @param o
     * @param tClass
     * @param <T>
     * @return
     */
    public static <T>T toObject(String  o,Class<T> tClass){
        try {
            return objectMapper.readValue(o,tClass);
        } catch (JsonProcessingException e) {
            throw new RuntimeException("to json fail cause:"+e.getMessage());
        }
    }

    /**
     * 字符串转查找树
     * @param o
     * @return
     */
    public static JsonNode readTree(String  o){
        try {
            return objectMapper.readTree(o);
        } catch (JsonProcessingException e) {
            throw new RuntimeException("to tree fail cause:"+e.getMessage());
        }
    }

    /**
     * 节点转对象
     * @param o
     * @param tClass
     * @param <T>
     * @return
     */
    public static <T>T nodeToObject(TreeNode o, Class<T> tClass){
        try {
            return objectMapper.treeToValue(o,tClass);
        } catch (JsonProcessingException e) {
            throw new RuntimeException("node To Object fail cause:"+e.getMessage());
        }
    }
}
```

## 忽略无法识别属性
```
@JsonIgnoreProperties(ignoreUnknown = true)
public class FeiShuUser {

```


* ObjectMapper 对象是线程安全的
## 依赖
```
<dependency>
            <groupId>com.fasterxml.jackson.core</groupId>
            <artifactId>jackson-databind</artifactId>
            <version>2.10.0</version>
        </dependency>
```


## 序列化LocalDateTime

### 方法一
```
 @JsonSerialize(using = NativeLocalDateTimeSerializer.class)
    private LocalDateTime createDate;
```

```
public class NativeLocalDateTimeSerializer extends StdSerializer<LocalDateTime> {


    protected NativeLocalDateTimeSerializer() {
        super(LocalDateTime.class);
    }

    @Override
    public void serialize(LocalDateTime localDateTime, JsonGenerator jsonGenerator, SerializerProvider serializerProvider) throws IOException {
        jsonGenerator.writeString(localDateTime.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
    }
}

```

### 方法二
* 依赖
```
 <!-- https://mvnrepository.com/artifact/com.fasterxml.jackson.datatype/jackson-datatype-jsr310 -->
        <dependency>
            <groupId>com.fasterxml.jackson.datatype</groupId>
            <artifactId>jackson-datatype-jsr310</artifactId>
            <version>2.12.1</version>
        </dependency>
```
* 配置
```
 @Bean(name = "jacksonObjectMapper")
    public ObjectMapper getObjectMapper() {
        ObjectMapper objectMapper = new ObjectMapper();
        objectMapper.registerModule(new JavaTimeModule());
        return objectMapper;
    }
```

* 注解
```
 @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private  LocalDateTime updateDate;
```


## 字符串转数组
```
public static <T> List<T> str2ObjectArray(String s, Class<T> tClass) {
        Class arrayClass = ReflectionCache.getClassCache(tClass).getArrayClass();
        try {
            T[] array = (T[]) objectMapper.readValue(s, arrayClass);//Array type of the "tClass" 
            List<T> list = new ArrayList<>();
            for (int i = 0; i < array.length; i++) {
                list.add(array[i]);
            }
            return list;
        } catch (JsonProcessingException e) {
            throw new RuntimeException(e);
        }
    }
```


## 字符串转对象
```
String jsonStr="{\"itemid\":\"28521\",\"type\":\"0\",\"snmp_community\":\"\",\"snmp_oid\":\"\",\"hostid\":\"10262\",\"name\":\"内存\",\"key_\":\"vm.memory.size[pused]\",\"delay\":\"30s\",\"history\":\"90d\",\"trends\":\"365d\",\"status\":\"0\",\"value_type\":\"0\",\"trapper_hosts\":\"\",\"units\":\"%\",\"snmpv3_securityname\":\"\",\"snmpv3_securitylevel\":\"0\",\"snmpv3_authpassphrase\":\"\",\"snmpv3_privpassphrase\":\"\",\"formula\":\"\",\"error\":\"\",\"lastlogsize\":\"0\",\"logtimefmt\":\"\",\"templateid\":\"28517\",\"valuemapid\":\"0\",\"params\":\"\",\"ipmi_sensor\":\"\",\"authtype\":\"0\",\"username\":\"\",\"password\":\"\",\"publickey\":\"\",\"privatekey\":\"\",\"mtime\":\"0\",\"flags\":\"0\",\"interfaceid\":\"3\",\"port\":\"\",\"description\":\"\",\"inventory_link\":\"0\",\"lifetime\":\"30d\",\"snmpv3_authprotocol\":\"0\",\"snmpv3_privprotocol\":\"0\",\"state\":\"0\",\"snmpv3_contextname\":\"\",\"evaltype\":\"0\",\"jmx_endpoint\":\"\",\"master_itemid\":\"0\",\"timeout\":\"3s\",\"url\":\"\",\"query_fields\":[],\"posts\":\"\",\"status_codes\":\"200\",\"follow_redirects\":\"1\",\"post_type\":\"0\",\"http_proxy\":\"\",\"headers\":[],\"retrieve_mode\":\"0\",\"request_method\":\"0\",\"output_format\":\"0\",\"ssl_cert_file\":\"\",\"ssl_key_file\":\"\",\"ssl_key_password\":\"\",\"verify_peer\":\"0\",\"verify_host\":\"0\",\"allow_traps\":\"0\",\"lastclock\":\"1573725231\",\"lastns\":\"161993930\",\"lastvalue\":\"23.5029\",\"prevvalue\":\"23.5029\"}";
ObjectMapper objectMapper = new ObjectMapper();
HashMap hashMap = objectMapper.readValue(jsonStr, HashMap.class);
```



## 对象转字符串
```
ObjectMapper objectMapper = new ObjectMapper();
Car car = new Car("yellow", "renault");
objectMapper.writeValue(new File("target/car.json"), car);
```



## 查询其中某个值
```
JsonNode jsonNode = objectMapper.readTree(jsonStr);
        JsonNode result = jsonNode.get("result");
       for(JsonNode o:result){
           System.out.println(o);
       }
```



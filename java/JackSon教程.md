# JackSon教程

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

## 字符串转对象
```
String jsonStr="{\"itemid\":\"28521\",\"type\":\"0\",\"snmp_community\":\"\",\"snmp_oid\":\"\",\"hostid\":\"10262\",\"name\":\"内存\",\"key_\":\"vm.memory.size[pused]\",\"delay\":\"30s\",\"history\":\"90d\",\"trends\":\"365d\",\"status\":\"0\",\"value_type\":\"0\",\"trapper_hosts\":\"\",\"units\":\"%\",\"snmpv3_securityname\":\"\",\"snmpv3_securitylevel\":\"0\",\"snmpv3_authpassphrase\":\"\",\"snmpv3_privpassphrase\":\"\",\"formula\":\"\",\"error\":\"\",\"lastlogsize\":\"0\",\"logtimefmt\":\"\",\"templateid\":\"28517\",\"valuemapid\":\"0\",\"params\":\"\",\"ipmi_sensor\":\"\",\"authtype\":\"0\",\"username\":\"\",\"password\":\"\",\"publickey\":\"\",\"privatekey\":\"\",\"mtime\":\"0\",\"flags\":\"0\",\"interfaceid\":\"3\",\"port\":\"\",\"description\":\"\",\"inventory_link\":\"0\",\"lifetime\":\"30d\",\"snmpv3_authprotocol\":\"0\",\"snmpv3_privprotocol\":\"0\",\"state\":\"0\",\"snmpv3_contextname\":\"\",\"evaltype\":\"0\",\"jmx_endpoint\":\"\",\"master_itemid\":\"0\",\"timeout\":\"3s\",\"url\":\"\",\"query_fields\":[],\"posts\":\"\",\"status_codes\":\"200\",\"follow_redirects\":\"1\",\"post_type\":\"0\",\"http_proxy\":\"\",\"headers\":[],\"retrieve_mode\":\"0\",\"request_method\":\"0\",\"output_format\":\"0\",\"ssl_cert_file\":\"\",\"ssl_key_file\":\"\",\"ssl_key_password\":\"\",\"verify_peer\":\"0\",\"verify_host\":\"0\",\"allow_traps\":\"0\",\"lastclock\":\"1573725231\",\"lastns\":\"161993930\",\"lastvalue\":\"23.5029\",\"prevvalue\":\"23.5029\"}";
ObjectMapper objectMapper = new ObjectMapper();
HashMap hashMap = objectMapper.readValue(jsonStr, HashMap.class);
```

## 字符串转数组
```
JsonNode jsonNode = objectMapper.readTree(jsonStr);
        JsonNode result = jsonNode.get("result");
       for(JsonNode o:result){
           System.out.println(o);
       }
```

## 对象转字符串
```
ObjectMapper objectMapper = new ObjectMapper();
Car car = new Car("yellow", "renault");
objectMapper.writeValue(new File("target/car.json"), car);
```



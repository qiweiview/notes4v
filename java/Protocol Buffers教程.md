#  Protocol Buffers教程

* protocol buffers （ProtoBuf）是一种语言无关、平台无关、可扩展的序列化结构数据的方法，它可用于（数据）通信协议、数据存储等
* 可以通过 ProtoBuf 定义数据结构，然后通过 ProtoBuf 工具生成各种语言版本的数据结构类库，用于操作 ProtoBuf 协议数据

## java使用范例

* 定义数据格式文件
```
// 指定protobuf的版本，proto3是最新的语法版本
syntax = "proto3";

// 定义数据结构，message 你可以想象成java的class，c语言中的struct
message Response {
  string data = 1;   // 定义一个string类型的字段，字段名字为data, 序号为1
  int32 status = 2;   // 定义一个int32类型的字段，字段名字为status, 序号为2
}
```
* [编译器编译](https://github.com/protocolbuffers/protobuf/releases) 出语言库代码
```
.\protoc --java_out=\.  .\response.proto
```

* 引入依赖
```
        <dependency>
            <groupId>com.google.protobuf</groupId>
            <artifactId>protobuf-java</artifactId>
            <version>3.14.0</version>
        </dependency>
```

* 序列化与反序列化
```

    public static void main(String[] args) {
        ResponseOuterClass.Response.Builder builder = ResponseOuterClass.Response.newBuilder();
        builder.setData("hello www.tizi365.com");
        builder.setStatus(200);

        ResponseOuterClass.Response response = builder.build();

        byte[] byteArray = response.toByteArray();
        System.out.println(new HexDumpEncoder().encode(byteArray));

        try {
            ResponseOuterClass.Response newResponse = ResponseOuterClass.Response.parseFrom(byteArray);
            System.out.println(newResponse);
        } catch (Exception e) {
            
        }
    }
```


## 数据描述文件语法
* syntax关键词定义使用的是proto3语法版本，如果没有指定默认使用的是proto2
```
package foo.bar;// 定义包名

syntax = "proto3";

message 消息名 {
    消息体
}
```
* 数据类型在javad中对应
```
double	 	double
float	 	float
int32	    int	
uint32	    int	
uint64	    long	
sint32	    int	
sint64	    long
fixed32	    int	
fixed64	    long
sfixed32	int	 //总是4个字节
sfixed64	long //总是8个字节
bool	 	bool
string	    String //一个字符串必须是UTF-8编码或者7-bit ASCII编码的文本
bytes	    ByteString //可能包含任意顺序的字节数据
```

###  枚举定义
```
enum PhoneType //枚举消息类型，使用enum关键词定义,一个电话类型的枚举类型
{
    MOBILE = 0; //proto3版本中，首成员必须为0，成员不应有相同的值
    HOME = 1;
    WORK = 2;
}

// 定义一个电话消息
message PhoneNumber
{
    string number = 1; // 电话号码字段
    PhoneType type = 2; // 电话类型字段，电话类型使用PhoneType枚举类型
}
```

### 数组定义

```
//整数数组的例子
message Msg {
  // 只要使用repeated标记类型定义，就表示数组类型。
  repeated int32 arrays = 1;
}
//字符串数组
message Msg {
  repeated string names = 1;
}
```

### 已定义数据类引用
```
// 定义Result消息
message Result {
  string url = 1;
  string title = 2;
  repeated string snippets = 3; // 字符串数组类型
}

// 定义SearchResponse消息
message SearchResponse {
  // 引用上面定义的Result消息类型，作为results字段的类型
  repeated Result results = 1; // repeated关键词标记，说明results字段是一个数组
}
```

### 消息嵌套
```
message SearchResponse {
  // 嵌套消息定义
  message Result {
    string url = 1;
    string title = 2;
    repeated string snippets = 3;
  }
  // 引用嵌套的消息定义
  repeated Result results = 1;
}
```

### 文件引用
```
//保存文件: result.proto

syntax = "proto3";
// Result消息定义
message Result {
  string url = 1;
  string title = 2;
  repeated string snippets = 3; // 字符串数组类型
}
```
```
//保存文件: search_response.proto

syntax = "proto3";
// 导入Result消息定义
import "result.proto";

// 定义SearchResponse消息
message SearchResponse {
  // 使用导入的Result消息
  repeated Result results = 1; 
}
```

### map定义,
* Map 字段不能使用repeated关键字修饰。
* key_type可以是任何整数或字符串类型（除浮点类型和字节之外的任何标量类型）。请注意，枚举不是有效的key_type。
* value_type 可以是除另一个映射之外的任何类型。
```
map<key_type, value_type> map_field = N;
```
* 范例
```
syntax = "proto3";
message Product
{
    string name = 1; // 商品名
    // 定义一个k/v类型，key是string类型，value也是string类型
    map<string, string> attrs = 2; // 商品属性，键值对
}
```

# ElasticSearch教程


## keyword和text区别
* keyword：存储数据时候，不会分词建立索引
* text：存储数据时候，会自动分词，并生成索引（这是很智能的，但在有些字段里面是没用的，所以对于有些字段使用text则浪费了空间）。


## Index
* Elastic 会索引所有字段，经过处理后写入一个反向索引（Inverted Index）。查找数据的时候，直接查找该索引。因此，Elastic 数据管理的顶层单位就叫做 Index（索引）。它是单个数据库的同义词。每个 Index （即数据库）的名字必须是小写


## Document
* Index 里面单条的记录称为 Document（文档）。许多条 Document 构成了一个 Index。
* Document 使用 JSON 格式表示，下面是一个例子。
```
{
  "user": "张三",
  "title": "工程师",
  "desc": "数据库管理"
}
```
* 同一个 Index 里面的 Document，不要求有相同的结构（scheme），但是最好保持相同，这样有利于提高搜索效率


## Mapping
* 映射是定义文档及其包含的字段的存储和索引方式的过程
1. (应将哪些字符串字段视为全文字段。)
2. (哪些字段包含数字，日期或地理位置)
3. (日期值的格式)
4. (用于控制动态添加字段的映射的自定义规则)
* 每个索引都有一种映射类型，用于确定文档的索引方式。
* Elasticsearch的mapping一旦创建，只能增加字段，而不能修改已经mapping的字段
```
PUT my_index 
{
  "mappings": {
    "properties": { 
      "title":    { "type": "text"  }, 
      "name":     { "type": "text"  }, 
      "age":      { "type": "integer" },  
      "created":  {
        "type":   "date", 
        "format": "strict_date_optional_time||epoch_millis"
      }
    }
  }
}
```


## Mapping参数

### coerceedit
* 强制尝试清理脏值以适合字段的数据类型


### copy_to
* 参数允许您将多个字段的值复制到组字段中，然后可以将其作为单个字段进行查询
* 无法递归复制
* 原始_source不会显示复制的值
```
PUT my_index
{
  "mappings": {
    "properties": {
      "first_name": {
        "type": "text",
        "copy_to": "full_name" 
      },
      "last_name": {
        "type": "text",
        "copy_to": "full_name" 
      },
      "full_name": {
        "type": "text"
      }
    }
  }
}


GET my_index/_search
{
  "query": {
    "match": {
      "full_name": { 
        "query": "John Smith",
        "operator": "and"
      }
    }
  }
}
```


### enabled
* 有时您只想存储字段而不对其进行索引
* 启用的设置（仅适用于顶级映射定义和对象字段）会导致Elasticsearch完全跳过对字段内容的解析

### index
* 选项控制是否索引字段值。
它接受true或false，默认为true。
未编制索引的字段不可查询


### ignore_above
* 长度超过ignore_above设置的字符串将不会被索引或存储。对于字符串数组，ignore_above将分别应用于每个数组元素，并且不会索引或存储比ignore_above更长的字符串元素


## 在索引时，分析器查询顺序
* 分析器在字段映射中定义。
* 索引设置中名为default的分析器。
* 标准分析仪。


## 在查询时，分析器查询顺序
* analyzer在full-text query中定义。
* search_analyzer在字段mapping中定义。
* analyzer在字段映射中定义。
* 索引设置中名为default_search的分析器。
* 索引设置中名为default的分析器。
* 标准分析仪。

## 中文分词

[下载安装IK分词](https://github.com/medcl/elasticsearch-analysis-ik/)

* 重启后就会自动安装插件





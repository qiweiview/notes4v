# ElasticSearch教程


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



## 列出每个 Index 所包含的 Type。
```
GET /_mapping?pretty=true
```

## 查看运行状态
```
GET /_cat/health?v
```

* 绿色 - 一切都很好（集群功能齐全）
* 黄色 - 所有数据都可用，但尚未分配一些副本（群集功能齐全）
* 红色 - 某些数据由于某种原因不可用（群集部分功能）

## 查看所有节点(集群中)
```
GET /_cat/nodes?v
```

## 查看所有索引
```
GET /_cat/indices?v
```

## 创建索引Index
* 可以直接向 Elastic 服务器发出 PUT 请求。下面的例子是新建一个名叫weather的 Index。
```
PUT /customer?pretty
```

## 列出当前节点所有索引
```
GET /_cat/indices?v
```

## 删除索引index
```
DELETE /customer?pretty
```

## 中文分词

[下载安装IK分词](https://github.com/medcl/elasticsearch-analysis-ik/)

* 重启后就会自动安装插件

## 新增一条记录
```
PUT /customer/_create/1?pretty
{
  "name": "John Doe"
}
```

## 新增或替换一条记录（不知道和更新有什么区别）
```
PUT /customer/_doc/1?pretty
{
  "name": "Jay Doe"
}
```

## 更新一条记录
* 每当我们进行更新时，Elasticsearch都会删除旧文档，然后一次性对应用了更新的新文档编制索引。

更新文档
```
POST /customer/_update/1?pretty
{
  "doc": { "name": "Jane Doe" }
}
```

脚本处理
```
POST /customer/_update/1?pretty
{
  "script" : "ctx._source.age += 5"
}
```
* 在上面的示例中，ctx._source指的是即将更新的当前源文档

## 不指定ID创建索引文档(注意用的是post)
```
POST /customer/_doc?pretty
{
  "name": "Jane Doe"
}

```

## 查看记录
```
GET /customer/_doc/1?pretty
```

## 删除一条记录
```
DELETE /customer/_doc/2?pretty
```

## 批量操作

* Bulk API不会因其中一个操作失败而失败。
* 如果单个操作因任何原因失败，它将继续处理其后的其余操作。
* 批量API返回时，它将为每个操作提供一个状态（按照发送的顺序），以便您可以检查特定操作是否失败


* 添加了2个索引分别为1，2，文档内容为name-John Doe
```
POST /customer/_bulk?pretty
{"index":{"_id":"1"}}
{"name": "John Doe" }
{"index":{"_id":"2"}}
{"name": "Jane Doe" }
```
* 更新第一个文档，删除第二个文档
```
POST /customer/_bulk?pretty
{"update":{"_id":"1"}}
{"doc": { "name": "John Doe becomes Jane Doe" } }
{"delete":{"_id":"2"}}
```

## 查询记录
* 返回所有文档
```
GET /bank/_search?q=*&sort=account_number:asc&pretty
```

* 响应
```
{
    "took": 3,
    "timed_out": false,
    "_shards": {
        "total": 1,
        "successful": 1,
        "skipped": 0,
        "failed": 0
    },
    "hits": {
        "total": {
            "value": 1,
            "relation": "eq"
        },
        "max_score": 1.3112575,
        "hits": [
            {
                "_index": "my_content",
                "_type": "_doc",
                "_id": "1",
                "_score": 1.3112575,
                "_source": {
                    "content": "小刘今天非常烦恼"
                }
            }
        ]
    }
}
```

* took - Elasticsearch执行搜索的时间（以毫秒为单位）

* timed_out  - 告诉我们搜索是否超时
* _shards  - 告诉我们搜索了多少个分片，以及搜索成功/失败分片的计数
点击 - 搜索结果
* hits.total  - 一个对象，包含有关符合我们搜索条件的文档总数的信息
* hits.hits  - 搜索结果的实际数组（默认为前10个文档）
* hits.sort  - 每个结果的排序键的排序值（如果按分数排序则丢失）
* hits._score和max_score  - 暂时忽略这些字段

## 查询语法DSL

### 只查特定字段
```
GET /bank/_search
{
  "query": { "match_all": {} },
  "_source": ["account_number", "balance"]
}
```

### 查特定条件
```
This example returns the account numbered 20:

GET /bank/_search
{
  "query": { "match": { "account_number": 20 } }
}
```

### 且条件满足

都满足
```
GET /bank/_search
{
  "query": {
    "bool": {
      "must": [
        { "match": { "address": "mill" } },
        { "match": { "address": "lane" } }
      ]
    }
  }
}
```
 都不满足
```
GET /bank/_search
{
  "query": {
    "bool": {
      "must_not": [
        { "match": { "address": "mill" } },
        { "match": { "address": "lane" } }
      ]
    }
  }
}
```

### 或条件满足
```
GET /bank/_search
{
  "query": {
    "bool": {
      "should": [
        { "match": { "address": "mill" } },
        { "match": { "address": "lane" } }
      ]
    }
  }
}
```


### 混合
```
This example returns all accounts of anybody who is 40 years old but doesn’t live in ID(aho):

GET /bank/_search
{
  "query": {
    "bool": {
      "must": [
        { "match": { "age": "40" } }
      ],
      "must_not": [
        { "match": { "state": "ID" } }
      ]
    }
  }
}
```

### 过滤区间
```
GET /bank/_search
{
  "query": {
    "bool": {
      "must": { "match_all": {} },
      "filter": {
        "range": {
          "balance": {
            "gte": 20000,
            "lte": 30000
          }
        }
      }
    }
  }
}
```

### 聚合
```
GET /bank/_search
{
  "size": 0,
  "aggs": {
    "group_by_state": {
      "terms": {
        "field": "state.keyword"
      }
    }
  }
}
```
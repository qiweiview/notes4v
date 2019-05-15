
## 拉取镜像
```
 docker pull solr
```

## 创建映射文件夹
```
mkdir -p /home/solr
```

## 运行容器
```
 docker run -p 8983:8983 -v /home/solr:/opt/solr/mydata  -d xxx
```

## 创建核
```
solr create_core -c xxx
```

## 配置分词器

1. 复制jar
```
复制lucene-analyzers-smartcn-7.2.0.jar（contrib/analysis-extras/lucene-libs目录下）到server/solr-webapp/webapp/WEB-INF/lib
```

2. 在managed-schema（在server/solr/xxx/conf目录下，这里选的自定义core即xxx）文件中添加新分词器

```
<fieldType name="text_hmm_chinese" class="solr.TextField" positionIncrementGap="100">
        <analyzer type="index">
            <tokenizer class="org.apache.lucene.analysis.cn.smart.HMMChineseTokenizerFactory"/>
        </analyzer>
        <analyzer type="query">
            <tokenizer class="org.apache.lucene.analysis.cn.smart.HMMChineseTokenizerFactory"/>
        </analyzer>
    </fieldType>


<field name="stu_id" type="text_hmm_chinese"  indexed="true" stored="true"/>

```


3. 重启应用

## 配置身份验证
创建security.json放在server/solr中后重启应用
```
{
"authentication":{  #1
   "blockUnknown": true, #2
   "class":"solr.BasicAuthPlugin",
   "credentials":{"solr":"IV0EHq1OnNrj6gvRCwvFwTrZ1+z1oBbnQdiVC3otuq0= Ndd7LKvVBAaZIF0QAVi1ekCfAJXr1GGfLtRUXhgrF8c="} #3
},
"authorization":{
   "class":"solr.RuleBasedAuthorizationPlugin",
   "permissions":[{"name":"security-edit",
      "role":"admin"}], #4
   "user-role":{"solr":"admin"} #5
}}
```

1. 启用基本身份验证和基于规则的授权插件。
2. 参数 "blockUnknown": true 表示不允许未经身份验证的请求通过。
3. 已定义了一个名为 "solr" 的用户，其中有密码 "SolrRocks"。
4. "admin" 角色已定义，并且具有编辑安全设置的权限。
5. "solr" 用户已被定义为 "admin" 角色。


添加用户
```
#url
http://cnigcc.cn:8983/solr/admin/authentication

#head
Authorization   Basic base64(name:password)
Content-Type    application/json

#body
{
	"set-user": {"test2" :"test666"}
}

```

删除用户
```
#url
http://cnigcc.cn:8983/solr/admin/authentication

#head
Authorization   Basic base64(name:password)
Content-Type    application/json

#body
{
"delete-user": ["tom","harry"]
}

```

设置角色


set-user-role：将用户映射到权限。
***要删除用户的权限，您应该将角色设置为null***。没有命令来删除用户角色。
提供给命令的值只是一个用户ID和一个或多个用户应具有的角色。
例如，***以下内容将“admin”和“dev”角色授予给用户“solr”***，并从用户ID“harry”中删除所有角色：
```
#url
http://cnigcc.cn:8983/solr/admin/authentication

#head
Authorization   Basic base64(name:password)
Content-Type    application/json

#body
{
   "set-user-role" : {"solr": ["admin","dev"],
                      "harry": null}
}

```

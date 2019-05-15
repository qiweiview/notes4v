## MongoDb指令

1. 创建数据库
```
use view_db
```
2. 查看所有数据库
```
show db
```
3. 查看当前数据库
```
db
```
4. 插入一条数据
```
db.view_db.insert({"name":"菜鸟教程"})//往view_db集合插入一条，没有view_db集合会自动创建
```
5. 删除数据库
```
user view_db//切换到要删除的数据库
db.dropDatabase()//删除
```
6. 查看当前数据库内所有表格
```
show tables
```
7. 创建集合
```
db.createCollection(name, options)

//name: 要创建的集合名称
//options: 可选参数, 指定有关内存大小及索引的选项

 db.createCollection("mycol", { capped : true, autoIndexId : true, size : 
   6142800, max : 10000 } )
   
//创建固定集合 mycol，整个集合空间大小 6142800 KB, 文档最大个数为 10000 个   

```
8. 查看已有集合
```
show collections
```
9. 删除集合
```
db.collection.drop()//如果成功删除选定集合，则 drop() 方法返回 true，否则返回 false
```
10. 插入一个文档
```
db.mylist.insert({title: 'MongoDB 教程', 
    description: 'MongoDB 是一个 Nosql 数据库',
    by: '菜鸟教程',
    url: 'http://www.runoob.com',
    tags: ['mongodb', 'database', 'NoSQL'],
    likes: 100
})
//往mylist插入一个文档，如果不存在则会自动创建

//通过定义变量
document=({title: 'MongoDB 教程', 
    description: 'MongoDB 是一个 Nosql 数据库',
    by: '菜鸟教程',
    url: 'http://www.runoob.com',
    tags: ['mongodb', 'database', 'NoSQL'],
    likes: 100
});

db.mylist.insert(document)

```
11. 插入多条
```
var res = db.mylist.insertMany([{"b": 3}, {'c': 4}])
res
可以用for循环执行语句
```
12. 更新数据
```
db.mylist.update({'title':'xiaohua'},{$set:{'age':'666'}})//只会修改找到的第一条
db.col.update({'title':'MongoDB 教程'},{$set:{'title':'MongoDB'}},{multi:true})//会修改找到的所有
```
13. 删除数据
```
db.mylist.remove({'title':'MongoDB 教程'})//删除找到的所有
db.mylist.remove({'title':'MongoDB 教程'},1)//删除找到的第一条
```
14. 查看数据
```
db.mylist.find().pretty()//格式化查看

db.mylist.find({"name":"xiaoming","age":"12"}).pretty()//格式化查看name为xioaming且age为12的数据

db.mylist.find({$or:[{"by":"菜鸟教程"},{"title": "MongoDB 教程"}]}).pretty()//by为菜鸟教程或title为MongoDB 教程的数据

db.col.find({"likes": {$gt:50}, $or: [{"by": "菜鸟教程"},{"title": "MongoDB 教程"}]}).pretty()//where likes>50 AND (by = '菜鸟教程' OR title = 'MongoDB 教程')

1. 等于	{<key>:<value>}	例：db.mylist.find({"by":"菜鸟教程"}).pretty()	sql-->where by = '菜鸟教程'
2. 小于	{<key>:{$lt:<value>}}例：	db.mylist.find({"likes":{$lt:50}}).pretty()	sql-->where likes < 50
3. 小于或等于	{<key>:{$lte:<value>}}例：	db.mylist.find({"likes":{$lte:50}}).pretty()	sql-->where likes <= 50
4. 大于	{<key>:{$gt:<value>}}例：	db.mylist.find({"likes":{$gt:50}}).pretty()	sql-->where likes > 50
5. 大于或等于	{<key>:{$gte:<value>}}例：	db.mylist.find({"likes":{$gte:50}}).pretty()	sql-->where likes >= 50
6. 不等于	{<key>:{$ne:<value>}}例：	db.mylist.find({"likes":{$ne:50}}).pretty()    sql-->where likes != 50



$gt -------- greater than  >

$gte --------- gt equal  >=

$lt -------- less than  <

$lte --------- lt equal  <=

$ne ----------- not equal  !=

$eq  --------  equal  =



获取 "mylist" 集合中 title 为 String 的数据
db.mylist.find({"title" : {$type : 2}})
或
db.mylist.find({"title" : {$type : 'string'}})


db.mylist.find().limit(5)//只查前五条
db.mylist.find().skip(5)//跳过前五条数据



db.mylist.find().sort({"likes":-1})//根据like降序排序

skip(), limilt(), sort()三个放在一起执行的时候，执行的顺序是先 sort(), 然后是 skip()，最后是显示的 limit()。
```

创建索引
```
db.mylist.createIndex({"age":1})
```

15. 聚合函数
```

```

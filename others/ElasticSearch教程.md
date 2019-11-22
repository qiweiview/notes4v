# ElasticSearch教程

## 概念
* Elasticsearch使用称为倒排索引的数据结构

## 中文分词

[下载安装IK分词](https://github.com/medcl/elasticsearch-analysis-ik/)

* 重启后就会自动安装插件


## 仅保留固定时间数据
```
#指定天数日期日期
DATA=`date -d "1 month ago" +%Y.%m.%d`

#当前日期
time=`date`


#执行api接口
curl -XDELETE http://127.0.0.1:9200/*-${DATA}

if [ $? -eq 0 ];then
echo $time"-->del $DATA log success.."
else
echo $time"-->del $DATA log fail.."
fi
```


* 使用crontab执行定时任务，每天凌晨执行
```
crontab -e

0 0 * * * /home/linrui/XXXXXXXX.sh > /dev/null 2>&1
```




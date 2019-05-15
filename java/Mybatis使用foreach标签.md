```
 where scenic_id in  
            <foreach collection="ids" item="item" open="(" close=")" separator=",">  
                #{item}  
            </foreach>  
```
* collection：传入的集合
* item：单次循环输出的对象
* open：循环左边
* close：循环右边
* separator：循环间隔
### Vue事件获取触发者对象：

```
<i @click="iconToogle($event)" class="iconfont icon-xuanzhong1"></i>

function (event){   

    console.log($(event.target)

}, 
```
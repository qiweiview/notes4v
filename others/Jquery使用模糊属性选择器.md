# 示例代码：
```
$("span[class^='stage-']")


//getElementsByClassName出来的对象是HTMLCollection，无法直接foreach

Array.from(document.getElementsByClassName('checkPoint')).forEach(v=>{
                    if (v.checked==true){
                        console.log(v);
                    }
                });

```
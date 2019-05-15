# vue综合

标准格式
```
  var vm = new Vue({
        el: '#vue_det',
        data: {
        return{
            site: "菜鸟教程",
            url: "www.runoob.com",
            alexa: "10000"
            }
        },
        methods: {
            details() {
                return  this.site + " - 学的不仅是技术，更是梦想！";
            }
        }
    })
```
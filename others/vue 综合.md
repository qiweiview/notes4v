# vue综合


## 异步下载
```
//resonse 是base64字符串
async download(response) {
                const base64Response = await fetch(`data:image/jpeg;base64,${response.data}`);
                const blob = await base64Response.blob();
                console.log(blob)
                let url = window.URL.createObjectURL(blob)
                let link = document.createElement('a')
                link.style.display = 'none'
                link.href = url
                link.setAttribute('download', response.fileName)
                document.body.appendChild(link)
                link.click()
            },
```

## 异步
```
uploadFile(blob, index, start, end) {
						var xhr;
						var fd;
						var chunk;
						var sliceIndex = blob.name + index;
						chunk = blob.slice(start, end); //切割文件 
						this.blob2Base64(chunk).then(function(result) {
							console.log(result)
						})


					},
					blob2Base64(blob) {
						return new Promise(function(resolve, reject) {
							var reader = new FileReader();
							reader.readAsDataURL(blob);
							reader.onloadend = function() {
								var base64data = reader.result;
								resolve(base64data.substr(base64data.indexOf(',') + 1))
							}
						})

					}
```
## 标准格式
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

## click传入对象
```
<el-button @click="copyPost(scope.row,$event)">复制</el-button>
```

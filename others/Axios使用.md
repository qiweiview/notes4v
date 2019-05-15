# Axios使用


## axios
```
 axios({
                    method:"GET",
                    baseURL: this.requestParam.agreementType+this.requestParam.url,
                    timeout: 1000,
                    headers: headers
                },Qs.stringify({hello:"world"})) .then(function (response) {
                    console.log(response);
                })
                    .catch(function (error) {
                        console.log(error);
                    });
```


## get

```
执行 GET 请求

// 为给定 ID 的 user 创建请求
axios.get('/user?ID=12345')
  .then( (response)=> {
    console.log(response);
  })
  .catch(function (error) {
    console.log(error);
  });
```
## post
```
执行POST请求
axios.post('/user', {
    firstName: 'Fred',
    lastName: 'Flintstone'
  })
  .then( (response)=> {
    console.log(response);
  })
  .catch(function (error) {
    console.log(error);
  });
```

## 异步上传
```

                this.formDate = new FormData();
                this.formDate.append('file', file.file);
                let config = {
                    headers: {
                        'Content-Type': 'multipart/form-data'
                    },
                    responseType: 'blob'
                }
                
                axios.post("/office/uploadFile", this.formDate,config).then( res => {
                    this.download(res.data);
                }).catch( res => {
                    console.log(res)
                })

```




## 带配置参数（异步下载）
```
axios({
    method: 'post',
    url: 'api/user/',
    data: {
        firstName: 'Fred',
        lastName: 'Flintstone'
    },
    responseType: 'blob'
}).then(response => {
    this.download(response.datta)
}).catch((error) => {

})

******download********
 download (data) {
        if (!data) {
            return
        }
        let url = window.URL.createObjectURL(new Blob([data]))
        let link = document.createElement('a')
        link.style.display = 'none'
        link.href = url
        link.setAttribute('download', 'excel.xlsx')

        document.body.appendChild(link)
        link.click()
    }
```




### 解决aixos中 'Content-Type':'application/json'问题
* 方法一：
```
 const params = new URLSearchParams();
                params.append('username', '123');
                params.append('password', '123');
                params.append('imageCode',vm.form.imageCode);
                axios({
                    url:'/login',
                    method: 'post',
                    data: f,
                    headers:{
                        'Content-Type':'application/x-www-form-urlencoded'
                    }

                })
                    .then(respanse=>{
                        console.log(respanse.data);
                    })
```
这种方法的conten-type 会变成application/x-www-form-urlencoded
* 方法二：
```
 const f=new FormData();
                f.append("username",'123');
                f.append("password",'123');
                f.append("imageCode",vm.form.imageCode);
 axios.post('/login',f)
                    .then( (response)=> {
                        window.location.href=response.data;
                        console.log(response);
                    })
                    .catch(function (error) {
                        console.log(error);
                    });*/
```
这种方法的conten-type 会变成multipart/form-data
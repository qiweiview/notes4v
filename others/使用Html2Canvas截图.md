## 使用Html2Canvas截图

[文档地址](https://html2canvas.hertzen.com/)

引入资源
```
npm install --save html2canvas
```

获取截屏页面
```
html2canvas(document.querySelector("#capture")).then(canvas => {
    document.body.appendChild(canvas)

//也可以直接转换base64设置进标签里
var jpegUrl = canvas.toDataURL("image/jpeg");
var pngUrl = canvas.toDataURL(); // PNG is the default
document.getElementById("target").setAttribute("src",pngUrl)
});
```
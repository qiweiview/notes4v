# js 校正 iphone 照片旋转方向

iphone 竖着拍的照片，实际存储却是横着的，然后在照片 EXIF 里记录了90度向右旋转的信息。<br>
本方法的主要目的就是把它变成真正竖着的照片，输入一个 &lt;input type="file"&gt; 选中的 file 文件， 输出一个调整过方向的 blob 文件。<br>
blob 格式是 file 格式的父级，一样可以用于 form 表单提交。<br>


## 引入文件
```
#安装 exif.js
#安装 canvas-to-blob.min.js

import Exif from 'exif-js'
import canvas from 'blueimp-canvas-to-blob'
```
 
## 调用代码
```
 iphone_photo_rotation_adjust(input.files[0], 800/*可选 指定输出图像的最大宽度或高度*/).then(function(blob){
    var form_data=new FormData();
    form_data.append('photo',blob,'blob.png');
    // ...
  })
```

## 核心代码(输出为png使图片变得巨大无比，暂未知原因)
```
photoCorrection(orientation, file, max_width_or_height, mime_type) {


                return new Promise(function (resolve, reject) {




                    // case 1: normal
                    // case 2: horizontal flip
                    // case 3: 180° rotate left
                    // case 4: vertical flip
                    // case 5: vertical flip + 90 rotate right
                    // case 6: 90° rotate right
                    // case 7: horizontal flip + 90 rotate right
                    // case 8: 90° rotate left
                    // iphone photo has 1 3 6 8

                    let data_url = URL.createObjectURL(file)

                    let img = document.createElement('img')
                    img.src = data_url

                    let canvas = document.createElement('canvas')
                    let ctx = canvas.getContext('2d')

                    img.onload = function () {

                        let result_width, result_height

                       /* *****尺寸模块****** */
                        if (max_width_or_height && (img.width > max_width_or_height || img.height > max_width_or_height)) {
                            if (img.width > img.height) {
                                let ratio = max_width_or_height / img.width
                                result_width = img.width * ratio
                                result_height = img.height * ratio
                            }
                            else {
                                let ratio = max_width_or_height / img.height
                                result_width = img.width * ratio
                                result_height = img.height * ratio
                            }
                        }
                        else {
                            result_width = img.width
                            result_height = img.height
                        }

                        /* *****判断处理模块****** */
                        if (orientation === 3) {
                            canvas.width = result_width
                            canvas.height = result_height
                            ctx.translate(result_width, result_height)
                            ctx.rotate(Math.PI);
                        } else if (orientation === 6) {
                            canvas.width = result_height
                            canvas.height = result_width
                            ctx.translate(result_height, 0)
                            ctx.rotate(Math.PI / 2);
                        } else if (orientation === 8) {
                            canvas.width = result_height
                            canvas.height = result_width
                            ctx.translate(0, result_width)
                            ctx.rotate(-Math.PI / 2);
                        } else {
                            canvas.width = result_width
                            canvas.height = result_height
                        }

                        /* *****输出模块****** */
                        ctx.drawImage(img, 0, 0, result_width, result_height)
                        mime_type = mime_type || 'image/jpeg'
                        try {
                            canvas.toBlob(function (blob) {
                                resolve(blob)
                            }, mime_type)
                        } catch (e) {
                            alert("iphone not support")
                        }
                    }
                    if (img.complete) {
                        img.onload()
                    }


                })

           }
```
----------------------------------------------------------------------------------


<br>

基于 exif.js ( https://github.com/exif-js/exif-js 用于读取照片旋转方向 ) <br>
和 canvas-to-blob.min.js ( https://github.com/blueimp/JavaScript-Canvas-to-Blob 用于让 safari 支持 canvas.toBlob 方法)
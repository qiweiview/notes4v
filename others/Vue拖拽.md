# Vue拖拽

* 标签
```
<textarea ref="select_frameL" style="font-family: sans-serif;resize: none;width: 100%;height: 250px" type="textarea"
 :autosize="{ minRows: 5, maxRows: 8}" placeholder="请输入或拖拽放入待解析json" v-model="inputJsonL">
</textarea>
```
* 调用
```
this.bingDrop("select_frameL", "inputJsonL");
```

* 方法
```
bingDrop(targetName, replaceContent) {
					let _this = this;

					this.$refs[targetName].ondragleave = (e) => {

						e.preventDefault(); //阻止离开时的浏览器默认行为
					};
					this.$refs[targetName].ondrop = (e) => {
						e.preventDefault(); //阻止拖放后的浏览器默认行为
						const data = e.dataTransfer.files; // 获取文件对象
						if (data.length < 1) {
							return; // 检测是否有文件拖拽到页面     
						}

						let hasFile = false
						for (let i = 0; i < e.dataTransfer.files.length; i++) {
							console.log(e.dataTransfer.files[i]);
							if (window.FileReader && !hasFile) {
								let reader = new FileReader();
								reader.onloadend = function(evt) {
									if (evt.target.readyState == FileReader.DONE) {
										_this[replaceContent] = evt.target.result
									}
								};
								// 包含中文内容用gbk编码
								reader.readAsText(e.dataTransfer.files[i], 'utf-8');
								hasFile = true
							} else {
								console.log("忽略文件：", e.dataTransfer.files[i])
							}
						}

					};

					this.$refs[targetName].ondragenter = (e) => {

						e.preventDefault(); //阻止拖入时的浏览器默认行为
					};

					this.$refs[targetName].ondragover = (e) => {

						e.preventDefault(); //阻止拖来拖去的浏览器默认行为
					};
				}
```

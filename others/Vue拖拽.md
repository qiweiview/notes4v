# Vue拖拽

```
<textarea ref="select_frame" style="font-family: sans-serif;resize: none;width: 100%;height: 250px" type="textarea"
					 :autosize="{ minRows: 5, maxRows: 8}" placeholder="请输入或拖拽放入待解析json" v-model="inputJsonL">
					</textarea>
```

```
mounted() {
				let _this = this;

				this.$refs.select_frame.ondragleave = (e) => {

					e.preventDefault(); //阻止离开时的浏览器默认行为
				};
				this.$refs.select_frame.ondrop = (e) => {
					e.preventDefault(); //阻止拖放后的浏览器默认行为
					const data = e.dataTransfer.files; // 获取文件对象
					if (data.length < 1) {
						return; // 检测是否有文件拖拽到页面     
					}


					for (let i = 0; i < e.dataTransfer.files.length; i++) {
						console.log(e.dataTransfer.files[i]);
						if (window.FileReader) {
							let reader = new FileReader();
							reader.onloadend = function(evt) {
								if (evt.target.readyState == FileReader.DONE) {
									_this.inputJsonL = evt.target.result
								}
							};
							// 包含中文内容用gbk编码
							reader.readAsText(e.dataTransfer.files[i], 'utf-8');
						}
					}

				};

				this.$refs.select_frame.ondragenter = (e) => {

					e.preventDefault(); //阻止拖入时的浏览器默认行为
				};

				this.$refs.select_frame.ondragover = (e) => {

					e.preventDefault(); //阻止拖来拖去的浏览器默认行为
				};
			},
```

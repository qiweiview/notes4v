# Vue上传demo
```
<!DOCTYPE html>
<html>
	<head>
		<title>文件上传</title>
		<meta charset="UTF-8">
		<meta http-equiv="X-UA-Compatible" content="IE=Edge">
		<meta name="viewport" content="width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no">
		<meta name="format-detection" content="telephone=no" />
		<!-- import CSS -->
		<link rel="stylesheet" href="https://unpkg.com/element-ui/lib/theme-chalk/index.css">
	</head>
	<body>
		<div id="app">
			<button @click=clickIF>点击选择文件</button>
			<input ref="IF" type="file" hidden @change="fileChange($event)" />
		</div>
	</body>
	<!-- import Vue before Element -->
	<script src="https://unpkg.com/vue/dist/vue.js"></script>
	<!-- import JavaScript -->
	<script src="https://unpkg.com/element-ui/lib/index.js"></script>
	<script src="https://cdn.bootcss.com/axios/0.19.2/axios.min.js"></script>
	<script>
		new Vue({
			el: '#app',
			data: function() {
				return {

				}
			},
			mounted: function() {

			},
			methods: {
				clickIF() {
					this.$refs['IF'].click();
				},
				fileChange(event) {
					var formData = new FormData()
					formData.append("image", event.target.files[0])
					axios.post('/yourPath', formData, {
						headers: {
							'Content-Type': 'multipart/form-data'
						}
					})
				}
			}
		})
	</script>
</html>

```

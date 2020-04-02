# js循环日期区间

```
<!DOCTYPE html>
<html>
	<head>
		<title>日期区间</title>
		<meta charset="UTF-8">
		<meta http-equiv="X-UA-Compatible" content="IE=Edge">
		<meta name="viewport" content="width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no">
		<meta name="format-detection" content="telephone=no" />
		<!-- import CSS -->
		<link rel="stylesheet" href="https://unpkg.com/element-ui/lib/theme-chalk/index.css">
	</head>
	<body>
		<div id="app">

		</div>
	</body>
	<!-- import Vue before Element -->
	<script src="https://unpkg.com/vue/dist/vue.js"></script>
	<!-- import JavaScript -->
	<script src="https://unpkg.com/element-ui/lib/index.js"></script>
	<script>
		Date.prototype.format = function() {
			var s = '';
			var mouth = (this.getMonth() + 1) >= 10 ? (this.getMonth() + 1) : ('0' + (this.getMonth() + 1));
			var day = this.getDate() >= 10 ? this.getDate() : ('0' + this.getDate());
			s += this.getFullYear() + '-'; // 获取年份。
			s += mouth + "-"; // 获取月份。
			s += day; // 获取日。
			return (s); // 返回日期。
		}
		new Vue({
			el: '#app',
			data: function() {
				return {

				}
			},
			mounted: function() {
				this.getAll('2019-02-27', '2020-04-02');
			},
			methods: {
				getAll(begin, end) {
					var ab = begin.split("-");
					var ae = end.split("-");
					var db = new Date();
					db.setUTCFullYear(ab[0], ab[1] - 1, ab[2]);
					var de = new Date();
					de.setUTCFullYear(ae[0], ae[1] - 1, ae[2]);
					var unixDb = db.getTime();
					var unixDe = de.getTime();
					for (var k = unixDb; k <= unixDe;) {
						console.log((new Date(parseInt(k))).format());
						k = k + 24 * 60 * 60 * 1000;
					}
				}
			}
		})
	</script>
</html>

```

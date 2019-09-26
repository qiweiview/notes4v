# Vue使用Cookie

## [参考](https://www.npmjs.com/package/vue-cookies)

```
<script src="https://unpkg.com/vue-cookies@1.5.12/vue-cookies.js"></script>
```

```
this.$cookies.config(new Date(2222,02,02).toUTCString())
				let rs = $cookies.get("hello")
				console.log(rs)
				$cookies.set('hello', 'world');
```

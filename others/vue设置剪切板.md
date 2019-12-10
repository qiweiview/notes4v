# vue设置剪切板.md


## 依赖
```
npm install --save vue-clipboard2
```

```
import Vue from 'vue'
import VueClipboard from 'vue-clipboard2'

Vue.use(VueClipboard)
```

## 使用
```
copyStr(str) {
      const _this = this
      this.$copyText(str).then(function(e) {
        _this.$message.success('复制成功')
      }, function(e) {
        _this.$message.success('复制失败')
      })
    }
```

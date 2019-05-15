## element-ui 绑定事件无效
通过使用native修饰覆盖组件原有事件

```
 <el-input v-model="form.name" placeholder="输入账号" maxlength="16" @keyup.native.enter="submitForm()"clearable></el-input>
```

## 回车刷新页面
```
<el-form @submit.native.prevent>
</el-form>
```

# el-tag标签点击失效
```
使用native覆盖默认事件
<el-tag class="commonLabel" v-for="tag in commonTag"type="info"   @click.native="changeCommonTag(tag)">{{tag}}</el-tag>
```

# 引入失败
```
link 用 <link href='xxx' />
script用 <script src='xxx'> </script>
```
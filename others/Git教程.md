# Git教程

* 一般来讲，作为远端备份或公共版本库时，应该使用git init --bare
* 之所以叫裸仓库是因为这个仓库只保存git历史提交的版本信息，而不允许用户在上面进行各种git操作，如果你硬要操作的话，只会得到下面的错误（”This operation must be run in a work tree”）
```
git init -bare xxx.git
git add ledo.css
git add ledo.js
git commit -m "first commit"
git remote add origin https://github.com/qiweiview/Right_click_event.git
git push -u origin master
```
* 注意使用ssh前得先把本机的公钥设置到仓库里

## 分支操作

* 查看分支：git branch

* 创建分支：git branch <name>

* 切换分支：git checkout <name>或者git switch <name>

* 创建+切换分支：git checkout -b <name>或者git switch -c <name>

* 合并某分支到当前分支：git merge <name>

* 删除分支：git branch -d <name>

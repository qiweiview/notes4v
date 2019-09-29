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


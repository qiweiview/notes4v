# 基础用法
```
git init
git add ledo.css
git add ledo.js
git commit -m "first commit"
git remote add origin https://github.com/qiweiview/Right_click_event.git
git push -u origin master
```
注意使用ssh前得先把本机的公钥设置到仓库里

默认情况下，公钥的文件名是以下之一：
```
id_dsa.pub
id_ecdsa.pub
id_ed25519.pub
id_rsa.pub
```
```
ls -al~ / .ssh  
＃列出.ssh目录中的文件（如果存在）
```
赋值公钥到剪切板
```
clip < ~/.ssh/id_rsa.pub
# Copies the contents of the id_rsa.pub file to your clipboard
```
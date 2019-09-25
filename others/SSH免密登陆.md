# SSH免密登陆

## 生成密钥
* SSH密钥会保存在home目录下的.ssh/id_rsa文件中．SSH公钥保存在.ssh/id_rsa.pub文件中．
```
ssh-keygen -t rsa
```

## 将SSH公钥上传到Linux服务器 
* 可以使用ssh-copy-id命令来完成
* 输入远程用户的密码后，SSH公钥就会自动上传了．SSH公钥保存在远程Linux服务器的.ssh/authorized_keys文件中
```
ssh-copy-id username@remote-server
```

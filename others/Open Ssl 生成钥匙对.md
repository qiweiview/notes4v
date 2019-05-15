# Open Ssl 生成钥匙对

## 生成密钥
```
openssl genrsa -out jwt_private_key.pem 2048
```
## 读取密钥生成公钥
```
openssl rsa -in jwt_private_key.pem -out jwt_public_key.pem  -pubout
```
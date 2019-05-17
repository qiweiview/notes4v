## 创建Rsa钥匙对

### 生成2048位RSA秘钥，使用3des加密秘钥文件private.pem
```
openssl genrsa -des3 -out private.pem 2048
```

### 导出公钥，默认为PKCS#8结构
```
openssl rsa -in private.pem -outform PEM -pubout -out public.pem
```

### 导出PKCS#1结构的公钥，注意openssl版本，老版本可能不支持
```
openssl rsa -in private.pem -outform DER -RSAPublicKey_out -out public_pcks1.cer
```

### 导出无加密保护的私钥
```
openssl rsa -in private.pem -out private_unencrypted.pem -outform PEM
```

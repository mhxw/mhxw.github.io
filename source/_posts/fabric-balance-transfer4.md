---
title: 【Hyperledger第四讲】Hyperledger Fabric SDK示例 fabric-samples-《balance-transfer》
date: 2018/12/18 21:00:00
tags: 
- blockchain
- hyperledger
category: 
- Technology
- Blockchain
- Hyperledger
---

### 准备环境
---
hyperledger fabric运行网络、postman（测试API工具）、nodejs8.9.4
<!-- more -->
### 目录结构分析
---
![balance-transfer目录结构分析](https://upload-images.jianshu.io/upload_images/5946072-fd506d6f8e59ae4d.png)
```
├── app  // 与fabric网络交互的实现
│   ├── create-channel.js
│   ├── helper.js
│   ├── install-chaincode.js
│   ├── instantiate-chaincode.js
│   ├── invoke-transaction.js
│   ├── join-channel.js
│   ├── network-config-aws.json
│   ├── network-config.json
│   └── query.js
├── app.js   // 定义与fabric网络交互的API
├── artifacts  // 启动fabric网络需要的配置
│   ├── base.yaml
│   ├── channel
│   ├── docker-compose.yaml
│   └── src
├── config.js
├── config.json
├── node_modules
│   └── .......
├── package.json
├── package-lock.json
├── README.md
├── runApp.sh
└── testAPIs.sh
```

### 运行示例
---
1. 下载示例
```
git clone https://github.com/hyperledger/fabric-samples.git
cd fabric-samples
```
2. 启动脚本
- 进入到balance-transfer目录，运行runApp.sh脚本，fabric网络以及node服务都会运行起来
```
cd balance-transfer
./runApp.sh
```
![./runApp.sh执行结果](https://upload-images.jianshu.io/upload_images/5946072-5dc33da411ab616e.png)

3. 测试脚本
- 在另一个终端运行testAPIs.sh测试脚本，使用API来操作fabric网络，它主要做了：
>- 创建channel
>- 安装chaincode
>- 初始化chaincode
>- 执行chaincode
>- 各种查询

```
./testAPIs.sh
```
- 运行结果（部分省略）
```
POST request Create channel  ...

{"success":true,"message":"Channel 'mychannel' created Successfully"}

POST request Join channel on Org1

{"success":true,"message":"Successfully joined peers in organization Org1 to the channel:mychannel"}

POST request Join channel on Org2

{"success":true,"message":"Successfully joined peers in organization Org2 to the channel:mychannel"}

POST Install chaincode on Org1

{"success":true,"message":"Successfully install chaincode"}

POST Install chaincode on Org2

{"success":true,"message":"Successfully install chaincode"}

POST instantiate chaincode on peer1 of Org1

{"success":true,"message":"Successfully instantiate chaingcode in organization Org1 to the channel 'mychannel'"}

POST invoke chaincode on peers of Org1

Transacton ID is 2eded4ef539d54b6822ba214788c5ae1515985d9c3628fdd259f5e0ab53582e5


GET query chaincode on peer1 of Org1

a now has 90 after the move

GET query Block by blockNumber

GET query Transaction by TransactionID

GET query ChainInfo

GET query Installed chaincodes

["name: mycc, version: v0, path: github.com/example_cc/go"]

GET query Instantiated chaincodes

["name: mycc, version: v0, path: github.com/example_cc/go"]

GET query Channels

{"channels":[{"channel_id":"mychannel"}]}

Total execution time : 90 secs ...
```
**参考文档**
---
```
https://blog.csdn.net/zhayujie5200/article/details/79684032
https://blog.csdn.net/qq_27818541/article/details/78246947
https://blog.csdn.net/weixin_41926234/article/details/80626078
```
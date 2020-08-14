---
title: 【Hyperledger第五讲】Hyperledger Fabric Node SDK详解
date: 2018/12/25 22:00:00
tags: 
- blockchain
- hyperledger
category: 
- 技术点滴
- 区块链
- Hyperledger
---

### Fabric Node SDK主要功能
---
SDK for Node.js有三个最顶层（top-level）的模块：API, fabric-client 和 fabric-ca-client。具体细节见官方文档及源码。
<!-- more -->
1. API
该模块给开发者提供了可插拔API，以提供SDK主要接口的可替换实现，包括CryptoSuite, key, KeyValueStore。每个接口都有内置的默认实现。

2. fabric-client
该模块提供了用户客户端与Fabric区块链网络组件（peer，orderer，event等）的交互。主要功能有：

- 创建channel
- 发送信息使peer节点加入channel
- 在peer中安装（install）chaincode
- 在channel上实例化 chaincode，分为两步：提案（ propose ）和交易（transact）
- 提交（submit）一个交易（需要调用chaincode），和上面一样分为两步
- 多种查询功能：状态（通过chaincode），交易，区块，channel，chaincode
- 监控事件（monitoring events）：包括peer，block，transactions，custom的events
- 有签名能力的用户对象（ User object）的序列化（serializable）
- 配置信息的分层（hierarchical configuration settings）
- 还提供可插拔（pluggable）的日志工具（logging utility）、加密工具（CryptoSuite）和状态存储方法（State Store），可以支持与 peer 或 orderer 的 TLS / non-TLS 链接
3. fabric-ca-client
该模块主要用于成员资格的管理，主要功能如下：
- 注册（register ）新用户
- 登录（enroll）用户并且获得由Fabric CA签名（CA私钥完成）的登录证书（enrollment certificate）
- 通过登录id（enrollment id）来注销 (revoke) 一个用户
- 可定制的（customizable）持久储存（persistence store）
### Fabric Node SDK具体接口
--- 
Node SDK主要的模块及其中重要的方法如下：
1. Client
- getUserContext() / setUserContext()：从本地读取/写入用户信息
- 创建其他各种类的示例
2. CAClient
- register()：登记
- enroll()：注册
3. Channel
- sendTransactionProposal()：发送提案
- sendTransaction()：发送交易
- queryByChaincode()：调用链码查询
- 各种与区块、交易有关的查询功能
4. Peer
- sendProposal()：发送交易提案到Peer节点
5. Orderer
- sendBrodcast()：发送数据到Ordere节点
- sendDeliver()：从Orderer节点获取数据

**参考文档**
```
https://fabric-sdk-node.github.io/release-1.4/index.html
```

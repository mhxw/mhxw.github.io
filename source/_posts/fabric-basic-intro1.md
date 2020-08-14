---
title: 【Hyperledger第一讲】HyperLedger Fabric基础介绍和架构原理
date: 2018/12/01 21:00:00
tags: 
- blockchain
- hyperledger
category: 
- 技术点滴
- 区块链
- Hyperledger
---

## **简单概述**
---
Hyperledger Fabric是由IBM公司主导开发的一个面向企业级客户的开源项目。与比特币和以太坊这类公有链不同，Hyperledger Fabric网络中的节点必须经过授权认证后才能加入，从而避免了POW资源开销，大幅提高了交易处理效率，满足企业级应用对处理性能的诉求。同时，为了满足灵活多变的应用场景，Hyperledger Fabric采用了高度模块化的系统设计理念，将权限认证模块（MSP）、共识服务模块（Ordering Service）、背书模块（Endorsing peers）、区块提交模块（committing peers）等进行分离部署，使开发者可以根据具体的业务场景替换模块，实现了模块的插件式管理（plug-in/plug-out）。所以，Hyperledger Fabric是一个私有链／联盟链的开发框架，而且系统的运行不需要token支持。
<!-- more -->
## **关键组件**
---
1. Ledger：账本，节点维护的区块链和状态数据库

2. World state：世界状态，经过数次交易后最新的键值对

3. Channel: 通道，私有的子网络，通道中的节点共同维护账本，实现数据的隔离和保密。 每个channel对应一个账本，由加入该channel的peer维护，一个peer可以加入多个channel，维护多个账本。

4. Network：交易处理节点之间的P2P网络，用于维持区块链账本的一致性。

5. Org：Orginazation，管理一系列成员的组织。一个channel内可以有多个组织。

6. Chainnode：链码，运行在节点内的程序，目前支持Go、Nodejs、Java，运行在隔离的容器中，提供业务逻辑接口，对账本进行查询或更新

7. Endorse：背书阶段，指一个节点执行了一个交易并对结果进行签名后返回响应的过程（负责校验某个交易是否合法）。

8. Ordering Service：排序服务，将交易排序后放入区块中，并广播给网络各节点

9. PKI：Public Key Infrastructure，一种遵循标准的利用公钥加密技术为电子商务的开展提供一套安全基础平台的技术和规范

10. MSP：Membership Service Provider，成员管理服务，基于PKI实现，为网络成员生成证书，并管理身份

## **共识算法**
---
在所有peers中，交易信息必须按照一致的顺序写入账本（区块链的基本原则）。例如，比特币通过POW机制，由最先完成数学难题的节点决定本次区块中的信息顺序，并广播给全网所有节点，以此来达成账本的共识。而Hyperledger Fabric采用了更加灵活、高效的共识算法，以适应企业场景下，对高TPS的要求。目前，Hyperledger Fabric有三种交易排序算法可以选择。

Solo：只有一个order服务节点负责接收交易信息并排序，这是最简单的一种排序算法，一般用在实验室测试环境中。Sole属于中心化的处理方式。

Kafka：是Apache的一个开源项目，主要提供分布式的消息处理／分发服务，每个kafka集群由多个服务节点组成。Hyperledger Fabric利用kafka对交易信息进行排序处理，提供高吞吐、低延时的处理能力，并且在集群内部支持节点故障容错。

SBFT：简单拜占庭算法，相比于kafka，提供更加可靠的排序算法，包括容忍节点故障以及一定数量的恶意节点。目前，Hyperledger Fabric社区正在开发该算法。

## **节点架构**
---
Fabric的节点具有不同身份并提供不同职能，下面是网络节点的示意图。

![网络节点的示意图](https://upload-images.jianshu.io/upload_images/5946072-b4688b29c507f2dc.png)

一、Peer节点
1. 记账节点（Committing peer）：所有的Peer节点都是记账 (committer) 节点，负责验证从排序服务接收到区块中的交易，维护账本的副本。

2. 背书节点（Endoring peer）：部分Peer节点会执行交易并对结果签名背书，充当背书 (Endorsement) 节点。背书节点是动态的角色，只有在应用
程序向它发起背书请求的时候才是背书节点，其他时候只是普通的记账节点，只负责验证交易并记账。Peers节点是一个逻辑的概念，endorser和committer可以同时部署在一台物理机上。

3. 主节点(Leader Peer)：代表的是与排序节点通信的节点，负责从排序服务节点处获取最新的区块并在组织内部同步。

二、Orderer节点
1. 排序服务节点接收包含背书签名的交易，并进行排序、打包生成区块，广播给Peer节点，保证同一个链上的节点接收到相同的消息，并且有相同的逻辑顺序。

2. 排序服务可以支持多链的交易处理，实现了多通道的数据隔离，保证只有同一个链的peer才能访问链上的数据。

3. 排序服务可选择集中式（Solo）或分布式（Kafka）协议，其中Kafka集群可以实现崩溃故障容错（CFT）。

三、CA节点
1. CA节点是Fabric的证书颁发机构（Certificate Authority）。

2. CA节点接收客户端的注册申请，返回注册密码用于用户登陆，以便获取身份证书。

3. 在区块链网络上所有的操作都会验证用户的身份。

四、Client节点
1. 客户端节点代表最终用户操作的实体，它必须连接到某一个Peer节点或者排序服务节点上与区块链网络进行通信。

2. 客户端节点向背书节点提交交易提案，收集到足够背书后，向排序服务广播交易，进行排序，生成区块。

## **数据存储**
---
Fabric区块链系统的数据存储主要由一项文件存储（区块数据）和三项数据库组成，结构如下图。

![数据存储结构](https://upload-images.jianshu.io/upload_images/5946072-4634a6f72e40172a.png)

一、区块数据

1. 区块（block）数据时以二进制文件的形式存储的，每个账本数据存储在节点文件系统的不同目录下

2. 区块数据存储是通过区块文件管理器（blockfileMgr）实现的，它来决定区块存储于哪个目录下的哪个文件

3. 区块文件管理器创建的文件名以“blockifle_”为前缀，6位数字位后缀，比如blockfile_000000，默认的区块文件大小为64MB，如果当前文件大小超过该值，则区块写入下一个文件中。

二、区块索引

1. Fabric提供多种索引方式，以方便能快速找到所需要区块数据。每次提交区块后都会更新索引数据库。索引方式（键）有：
- 区块编号 （Block Number）
- 区块哈希 （Block Hash）
- 交易编号 （Tx ID）

2. 索引的内容（值）是文件位置指针（File Location Pointer），结构如下：
- fileSuffixNum：所在文件的编号
- offset：文件内的偏移量
- bytesLength：内容占用的字节数

三、状态数据库

1. 状态数据（State Database）记录的是交易执行的结果，最新的状态代表了通道上所有键的最新值，所以又称为“世界状态”。

2. 交易或查询操作调用链码会根据当前状态数据库来完成。

3. 状态数据库支持查询单个键的数据，多个键的数据以及一个范围内的数据，如果使用的是CouchDB，还可以支持复杂的条件查询。

四、历史数据

历史数据（History Database）：记录的是每个状态数据的历史信息，每个历史信息以一个四元祖表示：

- namespace: 代表不同的chaincodeID
- writeKey：要写入数据的键
- blockNo：要写入数据所在的区块编号
- tranNo：要写入数据所在区块内的交易编号


## **交易流程**
---
以下是Fabric的经典交易流程，所有涉及到对账本数据更新的操作都是基于这个交易流程来完成的。

![交易流程图](https://upload-images.jianshu.io/upload_images/5946072-02de9417949c25e3.png)

1. 发送交易提案
客户端通过SDK接口，向背书节点（endorsing peer）发送交易提案（Proposal），提案中包含交易所需参数。

![发送交易提案](https://upload-images.jianshu.io/upload_images/5946072-10e5adf2246f4b38.png)

2. 模拟执行交易提案
每个endorsing peer节点模拟处理交易，此时并不会将交易信息写入账本。然后，endorser peer会验证交易信息的合法性，并对交易信息签名后，返回给client。此时的交易信息只是在client和单个endorser peer之间达成共识，并没有完成全网共识，各个client的交易顺序没有确定，可能存在双花问题，所以还不能算是一个“有效的交易”。同时，client需要收到“大多数”endorser peer的验证回复后，才算验证成功，具体的背书策略由智能合约代码控制，可以由开发者自由配置。

每个执行都会产生对状态数据读出和写入的数据集合，叫做读写集（RWsets），读写集是交易中记录的主要内容

![模拟执行交易提案](https://upload-images.jianshu.io/upload_images/5946072-25369980dbb83ddf.png)

3. 返回提案响应
背书节点会对读写集进行背书(Endorse)签名，生成提案响应(Proposal response)并返回给应用程序

4. 交易排序
client将签名后的交易信息发送给order service集群进行交易排序和打包。Order service集群通过共识算法，对所有交易信息进行排序，然后打包成区块。Order service的共识算法是以组件化形态插入Hyperledger系统的，也就是说开发者可以自由选择合适的共识算法。

背书节点会对读写集进行背书(Endorse)签名，生成提案响应(Proposal response)并返回给应用程序


5. 交易验证并提交
ordering service将排序打包后的区块广播发送给committing peers，由其做最后的交易验证，并写入区块链。ordering service只是决定交易处理的顺序，并不对交易的合法性进行校验，也不负责维护账本信息。只有committing peers才有账本写入权限。
应用程序根据接收到的提案响应生成交易，并发送给排序服务节点。排序服务打包一组交易到一个区块后，分发给各记账节点。

每个节点会对区块中的所有交易进行验证，包括验证背书策略以及版本冲突验证（防止双花），验证不通过的交易会被标记会无效（Invalid）

账本更新：节点将读写集更新到状态数据库 ，将区块提交到区块链上

6. 通知交易结果给客户端
各记账节点通知应用程序交易的成功与否，交易完成。

**参考文档**
---
```
http://www.hulupan.com/qukuailian/blockchain2183.html
```
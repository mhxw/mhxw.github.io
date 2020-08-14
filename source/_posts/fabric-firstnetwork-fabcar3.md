---
title: 【Hyperledger第三讲】Hyperledger Fabric1.x运行first-network和fabcar以及常见问题解决（持续更新）
date: 2018/12/03 21:05:00
tags: 
- blockchain
- hyperledger
category: 
- 技术点滴
- 区块链
- Hyperledger
---

## 基础环境搭建
---
> 操作系统：阿里云Ubuntu16.04
Git、Golang、Nodejs
Docker环境支持：docker、docker-compose
Fabric组件Docker镜像
fabric-samples源码库
Nodejs： 8.9.4
```
#先看这个搭建Hyperledger Fabric基础环境
https://blog.csdn.net/holechain/article/details/88795776
#（看到安装docker-compose完成即可，接下来看此篇）
```
<!-- more -->
## 安装Node.js
---
### 1. 首先，使用下面的命令来安装 nvm（第一种方式，两种选其一即可）
```
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash
```
- 下载并安装完成后用户退出重新登录或者重新 source 一下环境变量
```
source ~/.bashrc
```
- 查看当前的版本
```
 nvm ls
```
- 首次安装没有版本，使用`nvm install `安装指定版本的 node
```
nvm install v8.9.4
```
- 再次查看 node 版本信息
```
 nvm list
```
- 博主之前已经安装`v6.9.5`，目前`->`所指是`v6.9.5`版本，需要切换成`v8.9.4`版本
```
nvm use v8.9.4
```
![查看 node 版本信息和切换node版本](http://p1.pstatp.com/large/pgc-image/0a2c89f2bc8346e083b63fb2ea2bb227)
### 2. 手动安装Node.js（第二种方式）
```
wget wget https://nodejs.org/dist/v8.9.4/node-v8.9.4-linux-x64.tar.gz
tar -zxvf node-v8.9.4-linux-x64.tar.gz
sudo mv node-v8.9.4-linux-x64 /usr/local/node
sudo ln -s /usr/local/node/bin/node /usr/local/bin/node
sudo ln -s /usr/local/node/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm
```
### 3. 测试是否安装成功，以及`Node.js`并设置镜像加速
```
node -v
npm -v
npm config set registry https://registry.npm.taobao.org
```
## 构建网络
---
- 创建`fabric-samples`目录
```
mkdir -p github.com/hyperledger/fabric-samples
```
- 进入`fabric-samples`下
```
git clone https://github.com/hyperledger/fabric-samples.git
```
- 查看版本分支
```
git tag
```
![查看版本分支](http://p1.pstatp.com/large/pgc-image/1331a19f7d804e62910fd2ca5ade9662)
- 切换项目版本
```
git checkout  release1.0
```
- 查看当前项目的版本
```
git branch
```
- 如果你要删除已命名的分支，执行下方代码
```
git branch -d release1.0
```
- 打开下方网址（下载`fabric-samples`目录下`bin`目录中所需要的文件）
```
https://nexus.hyperledger.org/content/repositories/releases/org/hyperledger/fabric/hyperledger-fabric
```
- 下载`hyperledger-fabric-linux-amd64-1.0.5.tar.gz`压缩包
![下载Linux对应压缩包](http://p1.pstatp.com/large/pgc-image/6214f3d1303b4ac8a09ef770175ecbeb)
```
wget https://nexus.hyperledger.org/content/repositories/releases/org/hyperledger/fabric/hyperledger-fabric/linux-amd64-1.0.5/hyperledger-fabric-linux-amd64-1.0.5.tar.gz
```
- 解压到`fabric-samples`目录下
```
tar -zxvf hyperledger-fabric-linux-amd64-1.0.5.tar.gz -C /home/go/src/github.com/hyperledger/fabric-samples
```
***第一种方式：***
start
- 下载`dockerimages`执行文件复制并在`fabric-samples`中创建bootstrap.sh
![执行init.sh文件](http://p1.pstatp.com/large/pgc-image/212977dd9df94b388ce606c5757f8737)
- 在浏览器打开下方网站，复制该文件的内容到init.sh中（目的是下载fabric所需要的docker镜像）
```
https://raw.githubusercontent.com/hyperledger/fabric/v1.0.5/scripts/bootstrap.sh 
```
- 复制好之后，bootstrap.sh保存
```
vim bootstrap.sh
```
- 赋予权限
```
chmod -R 777 bootstrap.sh
```
- 运行文件（`1.0.5`是指定fabric的docker镜像版本）
```
./bootstrap.sh 1.0.5
```
***第二种方式：***
```
wget https://raw.githubusercontent.com/hyperledger/fabric/master/scripts/bootstrap.sh
cat bootstrap.sh | bash -s 1.0.5
```
***第三种方式：（需要kx上网）***
```
curl -sSL https://goo.gl/6wtTN5 | sudo bash -s 1.0.5
```
end

-  进入`first-network`目录中
```
cd first-network
```
![是否已经构建，如果构建关闭重新构建](http://p1.pstatp.com/large/pgc-image/212977dd9df94b388ce606c5757f8737)
- 目录分析
>- .env：存储一些环境变量
>- base：存储docker-compose的一些公共服务
>- byfn.sh：执行脚本
>- configtx.yaml和crypto-config.yaml：根据之前生成的2个工具，生成相应的配置文件，用来启动网络，放到当前目录的channel-artifacts和crypto-config里面
>- dockper-compose：用于启动网络
>- scripts：存放测试脚本，做的事：创建通道、加入通道，安装链码，实例化链码，链码交互
- 关闭网络，自动清除配置和docker进程
```
./byfn.sh -m down
```
- 执行以下命令构建网络
```
./byfn.sh -m generate
#./byfn.sh -m generate -i 1.1.0
```

### 1.  生成创世区块
- 指定按照yaml文件生成配置（`crypto-config.yaml`：用于配置组织节点的个数）
```
../bin/cryptogen generate --config=./crypto-config.yaml
```
- 在`first-network`目录下设置变量：（设置工作目录）
```
export FABRIC_CFG_PATH=$PWD
```
![设置变量并创建初始区块](http://p1.pstatp.com/large/pgc-image/564f2bd840c7446ab83270f033d1385f)
- 生成系统链的创世区块：（`-profile`指定联盟配置，`outputBlock`指定存放的位置，`genesis.block`指整个网络的创世区块）
```
../bin/configtxgen -profile TwoOrgsOrdererGenesis -outputBlock ./channel-artifacts/genesis.block
```
### 2.  生成应用通道的配置信息
- 生成通道的创世交易：`-profile`指定业务联盟，`-outputCreateChannelTx`指存放的路径，创建的名字叫`mychannel`

```
export CHANNEL_NAME=mychannel
../bin/configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/channelID $CHANNEL_NAME
```
![生成应用通道的配置信息](http://p1.pstatp.com/large/pgc-image/68d104a6e300406589e14d373dbf7a39)

### 3. 生成锚节点配置更新文件
- 生成两个组织锚节点的交易信息
```
../bin/configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org1MSP
```
```
../bin/configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org2MSP
```
## 操作网络
---
编辑`docker-compose-cli.yaml`，注释`command`命令
```
vim docker-compose-cli.yaml
```
运行`docker-compose-cli.yaml`
![image.png](http://p1.pstatp.com/large/pgc-image/cd82e418313647eb844ba63de6dca17a)

```
CHANNEL_NAME=$CHANNEL_NAME TIMEOUT=600 docker-compose -f docker-compose-cli.yaml up -d
```
### 1. 创建和加入通道

- 与客户端交互操作
```
docker exec -it cli bash
```
- 创建通道（`-o`指定与哪个orderer节点通信，`-c`指定创建的通道名称，`-f`指定使用的文件）
```
export CHANNEL_NAME=mychannel
peer channel create -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx --tls $CORE_PEER_TLS_ENABLED --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
```
![image.png](http://p1.pstatp.com/large/pgc-image/7bdfed4ff04c4def82c18291c8b818dd)

- 查看orderer节点的运行日志
```
docker logs orderer.example.com
```
- 加入通道
```
peer channel join -b mychannel.block
```
- 查看peer加入的通道列表
```
peer channel list
```
### 2.  安装并实例化链码
---
- 安装链码（`-n`指定链码安装的名字，`-v`指定version，`-l`指定使用语言，`-p`指定安装链码的所在路径）
```
peer chaincode install -n mycc -v 1.0 -p github.com/hyperledger/fabric/examples/chaincode/go/chaincode_example02
```
- 实例化链码
```
peer chaincode instantiate \
-o orderer.example.com:7050 \
--tls $CORE_PEER_TLS_ENABLED \
--cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem \
-C $CHANNEL_NAME \
-n mycc \
-v 1.0 \
-c  '{"Args":["init","a","100","b","200"]}' \
-P "OR    ('Org1MSP.member','Org2MSP.member')"
```
- 查询
```
peer chaincode query -C $CHANNEL_NAME -n mycc -c '{"Args":["query","a"]}'
```
![查询结果](http://p1.pstatp.com/large/pgc-image/558236b06391421aae54e49fe9d7acac)
- 转账
```
peer chaincode invoke \
-o orderer.example.com:7050 \
--tls $CORE_PEER_TLS_ENABLED \
--cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem \
-C $CHANNEL_NAME \
-n mycc \
-c '{"Args":["invoke","a","b","10"]}'
```
点击`exit`退出`docker`容器
```
./byfn.sh -m down
```
###参数说明：
- -o：指定order服务节点地址
- --tls：是否开启TLS验证
- --cafile：指定TLS_CA证书的所在路径
- -C：指定通道名称
- -n：指定链码名称
- -c：指定调用链码的所需参数
- -p：指定安装链码的所在路径
- -P：指定背书策略
#Node.js和fabcar交互
---
进入`fabric-samples`目录下的`fabcar`目录中
```
cd fabric-samples/fabcar
```
查看`package.json`文件
![查看`package.json`文件](http://p1.pstatp.com/large/pgc-image/6b61b325d2c043b19ee736be236324bc)
```
cat package.json
```
## Fabcar启动
----
- 进入first-network中执行
```
./byfn.sh -m down
```
- 关闭活跃容器
```
docker rm -f  $(docker ps -a)
```
- 清理缓存的网络
```
docker network prune
```
- 删除fabcar智能合约的底层链码图像，如果是第一次运行这个项目可以不执行（可以通过 docker  images来查询需要删除的镜像）
```
docker rmi dev-peer0.org1.example.com-fabcar-1.0-5c906e402ed29f20260ae42283216aa75549c571e2e380f3615826365d8269ba
```
- 在`fabcar`目录中安装客户端
```
npm install
```
![npm install 中1](http://p1.pstatp.com/large/pgc-image/54542927eb3c4ca8ae8e809a018a86e2)
![npm install 中2](http://p1.pstatp.com/large/pgc-image/54542927eb3c4ca8ae8e809a018a86e2)
- 启动网络
```
./startFabric.sh  node
```
![./startFabric.sh  node](http://p1.pstatp.com/large/pgc-image/9559029fbff84d028fea1cf95e2dbd7a)
- 执行完成后，注册管理用户（首先应用的admin用户应该向ca-server发送一个证书登记请求，接受一个对于这个user的登记证书（eCert），后续我们会根据使用这个admin注册和认证一个新的user）
```
node enrollAdmin.js
```
![node encrollAdmin.js运行成功](http://p1.pstatp.com/large/pgc-image/9559029fbff84d028fea1cf95e2dbd7a)
- 实现registerUser.js，生成用户账户（创建一个普通用户user1，这个用户用来查询和更新账本。admin用户身份用来创建user1用户）
```
node registerUser.js
```
![node registerUser.js运行成功](http://p1.pstatp.com/large/pgc-image/8e7e27a0b538467aa85ca6a1f71a2f29)
- 现在我们可以运行JavaScript程序。首先，运行query.js 程序，返回账本上所有汽车列表。应用程序中预先加载了一个queryAllCars函数，用于查询所有车辆，因此我们可以简单地运行程序：
```
node query.js
```
![node query.js运行成功](http://p1.pstatp.com/large/pgc-image/8279337eed6e41238d6a8020541825a3)
- 如果想返回某个车辆信息，编辑query.js，我们将函数`queryAllCars`更改为`queryCar`并将特定的“Key” 传递给args参数。在这里，我们使用`CAR4`。 所以我们编辑后的query.js程序现在应该包含以下内容：

![编辑query.js](http://p1.pstatp.com/large/pgc-image/8279337eed6e41238d6a8020541825a3)
- 重新运行query.js
```
node query.js
```
![image.png](http://p1.pstatp.com/large/pgc-image/4a072657521b4eba9272c1497fdc9875)

## FAQ
---
1.  运行`./byfn.sh -m down`出现错误的解决方法：
```
https://segmentfault.com/a/1190000014221967
```
2.  执行`node registerUser.js `出现错误：`Failed to register: Error: fabric-ca request register failed with errors [[{"code":0,"message":"No identity type provided. Please provide identity type"}]]`
![执行`node registerUser.js `出现错误](http://p1.pstatp.com/large/pgc-image/3edeefe1819e48c29622f83a027829c8)
- 大概的意思是需要我们提供一个可验证的type。 只需编辑 `node registerUser.js `文件
```
vim registerUser.js
```
- 把`returnfabric_ca_client.register({enrollmentID: 'user1', affiliation:'org1.department1'}, admin_user);`替换为下方代码
```
returnfabric_ca_client.register({enrollmentID: 'user1', affiliation:'org1.department1',role: 'client'}, admin_user);
```
![ node registerUser.js替换](http://p1.pstatp.com/large/pgc-image/615e91e3eb134b6fadeea55a5e49a1e6)
- 点击保存重新运行即可
3. 设置`marbles . step 4 error error: Caught exception: TypeError: Cannot read property 'getConnectivityState' of undefined`出错
```
npm uninstall grpc
rm -rf node_modules/
npm install
```
4. ![node registerUser.js](http://p1.pstatp.com/large/pgc-image/430c83ad81004198bce8ef787e12d74d)
![image.png](http://p1.pstatp.com/large/pgc-image/38c4162040b24bbbaeb398ac5be46c0a)

![image.png](http://p1.pstatp.com/large/pgc-image/dbf34b18c1a744a18b4df1fa8f57b500)

## 参考文档
---
```
https://github.com/IBM-Blockchain/marbles/blob/master/docs/use_local_hyperledger.md
https://hyperledger-fabric.readthedocs.io/en/release-1.0/chaincode4noah.html
https://hyperledger-fabric.readthedocs.io/en/release-1.0/write_first_app.html
https://blog.csdn.net/qq_27348837/article/details/87362268
```
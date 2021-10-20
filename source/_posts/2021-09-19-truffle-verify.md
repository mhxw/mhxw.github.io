---
title: 在 BscScan 上使用 Truffle 验证合约？
date: 2021/09/19 22:00:00
tags:
- EtherScan
- BscScan
- PolygonScan
- Truffle
category:
- 智能合约
---

## 参考案例

https://github.com/huangsuyu/verify-example

## 验证合约

### 1. 获取 API 密钥

https://bscscan.com/myapikey

### 2.安装插件

```bash
npm install -D truffle-plugin-verify
yarn add -D truffle-plugin-verify
```

<!-- more -->

### 3. 配置插件 truffle-config.js

在js中添加以下内容：

```
  plugins: [
    'truffle-plugin-verify'
  ],
  api_keys: {
    bscscan: BSCSCANAPIKEY
  },
```

### 4.将生成的API key 粘贴到对应位置

### 5. 部署合约

```
truffle compile
truffle migrate --network testnet
```

### 6.验证合约

```bash
truffle run verify {contract-name}@{deployed-address} --network testnet
```
---
title: Windows 上搭建本地私链测试环境-Grafana
date: 2020/09/06 21:00:00
tags: 
- grafana
- solidity
- npm
category: 
- 智能合约
---

Grafana 是一款可用于开发、部署和测试 DAPP 的工具。Grafana有2种模式，一种是桌面版程序，另一种是命令行工具。

### 安装 Grafana GUI

1. 下载并安装

https://github.com/trufflesuite/ganache-ui/releases

<!-- more -->

2. 如果是首次打开，将看到以下画面

点击`QUICKSTART` 下拉列表选择启动以太坊节点还是 Corda 网络，然后点击`QUICKSTART`按钮

![](/images/htigiw-1.png)

启动后可以看到默认创建的10个账户，每个账户有100ETH测试余额。

![](/images/htigiw-2.png)

默认是 127.0.0.1，只有本地能访问，修改为 WLAN 局域网内可以访问。

然后点击右上角`SAVE AND RESTART` 按钮即可

![](/images/htigiw-3.png)

## 其他扩展

一般我使用的时候会指定其助记词，方便remix协调进行本地测试。

- 点击导航中的 `ACCOUNTS & KEYS` 标签
- 输入助记词
- 点击 `SAVE AND RESTART` 按钮

![](/images/htigiw-4.png)

### 安装 Grafana-cli

1. Grafana-cli 需要nodejs环境支持，你需要提前安装好nodejs。

2. 安装命令行工具

```bash
yarn add -g ganache-cli
 ```

测试是否安装成功

```bash
ganache-cli
Ganache CLI v6.12.2 (ganache-core: 2.13.2)

Available Accounts
==================
(0) 0x988dd84720cAA7800EA9238c40cDe70dd742FDB5 (100 ETH)
(1) 0x847e1CDF10f1536d82E29127E325e18B72376622 (100 ETH)
(2) 0x50B4593e2d398c847793800A776b22090E597bA0 (100 ETH)
(3) 0xbD9e7E15DD4742e0307F1a48447E158Caca55b96 (100 ETH)
(4) 0x17587644d95469A6350F469cc2F61bc1eFd2Ec18 (100 ETH)
(5) 0xcfDDa4eE474E12D637062bcAb1192b9cEc6413Df (100 ETH)
(6) 0x1796834121a6d23143A8512103Ed40a7FDEEC02F (100 ETH)
(7) 0xd71fa6F6a05075F417185Ff1ECDf64B934eFf35F (100 ETH)
(8) 0x1f1D337F5CFdD98E9387f83F5160BdA8610414ae (100 ETH)
(9) 0x7Ed47D8eEDC7ea89255C48fc6D3770d3201cAf40 (100 ETH)

Private Keys
==================
(0) 0x3fc18c32e6017e4d476c319ea680c7da4d0be6cd80e3d2ec73a077ec42e8e8c4
(1) 0x24fa6950fd42cd606f930fb0fe5fb5d5018c1860429e2f078b3a32ed580eed0f
(2) 0xceb0848a858c36f56205d314fa4749038f82df680997265d318b065f74353611
(3) 0x0f45414a6b0f4f00427387285f216193c99520d8154649ffcc845ee1148d9dcb
(4) 0xab8e53620017549024e71557437180ec8051704fbe7ba9523fb6a7f0ada907f0
(5) 0x2ab38d69af95c77ff0fc37c3ae785a21b14eea420ce8b1f21065e8361470dc96
(6) 0x8b3de86adb04689b529ec04deaa9336898098935ab0801c203e4b964b490ddc0
(7) 0xe75f05d2f244a0b4e7a605665331a9d6b77978b484fd951f60ad7c9a3238a0a5
(8) 0xb17db4754e3fe58a7f31826104ffb6e77320f05e4c50b1ec0979da12cebe77b2
(9) 0x27be30607ab722436247997b671ba7a3696185c86ebdd0adcbac5ad1569c7df0

HD Wallet
==================
Mnemonic:      suggest cage magnet amused punch business arrange confirm speed tackle burst install
Base HD Path:  m/44'/60'/0'/0/{account_index}

Gas Price
==================
20000000000

Gas Limit
==================
6721975

Call Gas Limit
==================
9007199254740991

Listening on 127.0.0.1:8545
>
```


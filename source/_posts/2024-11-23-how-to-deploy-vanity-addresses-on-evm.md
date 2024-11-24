---
title: 如何在EVM上部署靓号地址 (How to Deploy Vanity Addresses on EVM)
date: 2024/11/23 12:00:00
category:
- EVM
---

> 本篇仅对普通合约(非代理合约进行)进行讲解。

## 简介

以太坊的靓号地址是具有特定模式的钱包地址或合约地址，通常包含可识别的字符或以一系列零开头。这些地址可以增加唯一性和美观性，但生成它们需要特定工具以及对以太坊 CREATE2 操作码的了解。

本文将解释如何使用 [create2crunch](https://github.com/0age/create2crunch) 工具部署靓号地址。这是一个基于 Rust 的程序，用于寻找能够在以太坊虚拟机（EVM）链上生成高效靓号地址的盐值。

<!-- more -->

## 什么是 CREATE2？

CREATE2 是以太坊中的一个操作码，允许将合约部署到可预测的地址。与原始的 CREATE 操作码不同，CREATE2 根据以下信息计算合约地址：

1. Deployer Address (Factory address)
   部署者地址（工厂合约地址）

2. Salt (A user-defined unique value)
   盐值（用户定义的唯一值）

3. Keccak-256 Hash of the contract's initialization code
   合约初始化代码的 Keccak-256 哈希值

```bash
keccak256(0xFF ++ deployerAddress ++ salt ++ keccak256(initCode))
```

这种可预测性使其成为生成靓号地址的理想选择，因为在部署合约之前就可以确定目标地址。

## 安装和配置 create2crunch

### 步骤1：克隆仓库

```shell
git clone https://github.com/0age/create2crunch
cd create2crunch
```

### 步骤2：安装前置依赖

确保已安装 Rust。如果没有，使用 Rustup 安装：

```shell
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

安装完成后，进入仓库目录并构建程序：

```shell
cargo build --release
```

### 步骤3：定义关键参数

在运行程序前，需定义以下变量：

1. Factory Address: The address of the factory or contract that will execute CREATE2. For example:
   工厂地址：将执行 CREATE2 的工厂合约地址。例如：

```shell
export FACTORY="0x0000000000ffe8b47b3e2130213b802212439497"
```

2. Caller Address: Your deployer address or the address authorized by the factory to deploy contracts:
   调用者地址：你的部署地址，或工厂授权的地址：

```shell
export CALLER="0xYourDeployerAddressHere"
```

3. Init Code Hash: The Keccak-256 hash of your contract's initialization code. You can calculate this hash using any Keccak-256 hashing tool or a script:
   初始化代码哈希值：你的合约初始化代码的 Keccak-256 哈希值。可使用任意 Keccak-256 哈希工具或脚本计算：

比如使用golang

```Go
   func TestGenInitCode(t *testing.T) {
       bytecode := "your_bytecode_here" // 可以从foundry的out文件夹下的合约abi中找到bytecode字段获取，如下图
       decode, err := hexutil.Decode(bytecode)
       if err != nil {
           t.Error(err)
           return
       }
       initCodeHash := crypto.Keccak256Hash(decode)
       t.Log(initCodeHash)
   }
```

![bytecode字段](/images/2024-11-23-01.png)

```shell
export INIT_CODE_HASH="0xYourContractInitCodeHashHere"
```

### 步骤4：运行 create2crunch

使用上述参数运行程序：

```shell
cargo run --release $FACTORY $CALLER $INIT_CODE_HASH
```

该工具将搜索可生成靓号地址的盐值。结果（包括盐值、生成的地址及其稀有性评分）将保存到 efficient_addresses.txt 文件中。

## 验证结果

获得结果后，必须验证盐值并确保生成的地址符合预期。如果工厂合约提供了通过盐值模拟地址生成的 view 方法，务必在部署前使用它确认靓号地址。
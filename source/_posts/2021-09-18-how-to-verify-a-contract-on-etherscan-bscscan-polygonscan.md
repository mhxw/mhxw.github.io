---
title: 如何在 EtherScan、BscScan、PolygonScan 浏览器验证合约？
date: 2021/09/18 22:00:00
tags:
- EtherScan
- BscScan
- PolygonScan
category:
- 智能合约
---

在浏览器上验证合约有多种方式，例如Hardhat或者Truffle方式。

<!-- more -->

## 常见错误

### Unable to generate Contract ByteCode and ABI 无法生成合约字节码和ABI

这是一个通用的错误，并没有提供任何原因的指示。

当你遇到这个错误时，请逐一检查以下内容，确保它与你用来部署的内容完全一致：合约源代码、编译器版本、编译器优化和运行数、构造函数参数、库的地址。

### Definition of base has to precede definition of derived contract 

出现此情况你应该检查合约的顺序，父合约在前面，子合约在后面

以下是错误的

```bash
contract Ownable is Context {}
contract Context {}
```

正确的顺序应该是：

```bash
contract Context {}
contract Ownable is Context {}
```
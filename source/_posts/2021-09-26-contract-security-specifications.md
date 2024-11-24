---
title: 合约安全规范和漏洞防范
date: 2021/09/26 22:00:00
category:
- 智能合约
---

## 重放攻击

在区块链世界中，恶意代码数不胜数。如果你的合约包含了跨合约调用，就要特别当心，要确认外部调用是否可信，尤其当其逻辑不为你所掌控的时候。

如果缺乏防人之心，那些“居心叵测”的外部代码就可能将你的合约破坏殆尽。比如，外部调用可通过恶意回调，使代码被反复执行，从而破坏合约状态，这种攻击手法就是著名的Reentrance Attack（重放攻击）。

<!-- more -->

#### 代码规范

- https://docs.soliditylang.org/en/latest/style-guide.html

#### 安全防范

- https://docs.soliditylang.org/en/latest/security-considerations.html

- https://solidity-cn.readthedocs.io/zh/develop/security-considerations.html

#### 合约攻击预防

- https://ethernaut.openzeppelin.com/
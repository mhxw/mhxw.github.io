---
title: 如何部署靓号 EVM 地址[全面指南] (How to Deploy Vanity EVM Addresses [Comprehensive Guide])
date: 2024/11/24 21:00:00
category:
- EVM
---

在以太坊虚拟机（EVM）中，合约地址的生成基于部署者地址和交易数据的哈希，因此可以通过一些技巧生成具有特定特点的“靓号”地址。这种技术被广泛应用于个性化品牌展示、降低用户错误操作的可能性，甚至是提高项目的营销吸引力。

<!-- more -->

## 靓号地址生成机制
   在 EVM 中，合约地址的生成取决于以下两种机制：

1. 普通部署：
- 使用 CREATE 指令，生成的地址为：
    ```code
    keccak256(rlp([sender, nonce]))
    ```
   - sender：部署者地址
   - nonce：部署者的交易计数
2. 确定性部署：
- 使用 CREATE2 指令，生成的地址为：
    ```shell
    keccak256(0xff ++ sender ++ salt ++ keccak256(bytecode))
    ```
- sender：部署者地址（工厂合约地址）
- salt：任意 32 字节数据，用于影响地址生成
- bytecode：合约的初始化字节码

通过 `CREATE2` 的 `salt` 和 `bytecode`，我们可以更精细地控制合约地址。

## 使用 UUPS 模式生成靓号

> zora之前使用[DeterministicUUPSProxyDeployer](https://etherscan.deth.net/address/0xf68e8da655bedeb3cfbdae7871ca82d603523447)合约进行UUPS部署，后来改成通过[DeterministicDeployerAndCaller](https://etherscan.deth.net/address/0x813f62e6b808aac8c36868898f84a3e944378d83)部署。
> 本小节将以 DeterministicUUPSProxyDeployer 为例进行讲解，而下一小节中，关于透明代理和普通合约代理的内容，将以 DeterministicDeployerAndCaller 为例进行说明。

在以太坊中，通过 CREATE2 的确定性部署机制，可以为 UUPS 合约生成“靓号”地址。为此，可以借助 Zora 官方提供的 DeterministicUUPSProxyDeployer 合约实现高效部署。

本节将结合 OpenZeppelin 的 UUPS 代理合约与 Zora 的 DeterministicUUPSProxyDeployer 合约，逐步讲解如何生成靓号地址。在操作前，请确保熟悉上述合约的代码逻辑。

以openzeppelin 的uups代理合约为例，在部署代理合约时候，构造函数需要传入参数。构造函数的参数会拼接在合约初始化代码后面，这个后面会用到。

- DeterministicUUPSProxyDeployer

https://github.com/ourzora/zora-protocol/blob/748be1ab013b658924248af76dc39aafa4a2faf8/packages/shared-contracts/src/deployment/DeterministicUUPSProxyDeployer.sol

- UUPS

https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v5.2/contracts/proxy/ERC1967/ERC1967Proxy.sol#L26

实操你可以查看此交易

https://explorer.zora.energy/tx/0xbb5023241d778352ae5963c977382b8eeae91afc9ef0ca4c543b2e12a2fe4738
https://explorer.zora.energy/tx/0x9157f50c80a93ae135267644e6fd4ae9b5b558fce2f86557445fe0aeda535d09

以 [ZoraMintsManager](https://explorer.zora.energy/address/0x77777779acd6a96C0c57272112921A0b833c38fD?tab=contract) 的 UUPS 代理合约 为例，代理合约的构造函数如下：

```solidity
    constructor(address _logic) ERC1967Proxy(_logic, "") {}
```

该构造函数在部署时需要传入两个关键参数：

- `_logic`：实现合约的地址。

在 EVM 中，合约的构造函数参数会被拼接到初始化代码（`creation code`）的末尾，这一点对于生成靓号地址尤为重要。

### 1. 调用safeCreate2AndUpgradeToAndCall函数

开发者通过调用DeterministicUUPSProxyDeployer合约的safeCreate2AndUpgradeToAndCall函数进行部署。

```solidity
    /// Creates a contract using create2, and then calls an initialization function on it.
    /// First 20 bytes of salt must match the msg.sender
    /// @param proxySalt Salt to create the contract with
    /// @param proxyCode contract creation code
    /// @param initialImplementation address to upgrade to
    /// @param postUpgradeCall what to call on the contract after upgrading
    /// @param _expectedAddress expected address of the created contract
    function safeCreate2AndUpgradeToAndCall(
        bytes32 proxySalt,
        bytes memory proxyCode,
        address initialImplementation,
        bytes memory postUpgradeCall,
        address _expectedAddress
    ) external payable {
        _requireContainsCaller(msg.sender, proxySalt);

        _getOrCreateProxyShim();

        bytes memory _proxyCreationCode = proxyCreationCode(proxyCode);

        // create the proxy
        address proxyAddress = Create2.deploy(0, proxySalt, _proxyCreationCode);

        if (proxyAddress != _expectedAddress) {
            revert FactoryProxyAddressMismatch(_expectedAddress, proxyAddress);
        }

        UUPSUpgradeable(proxyAddress).upgradeToAndCall(initialImplementation, postUpgradeCall);
    }
```

里面涉及传参数有：

- proxySalt：
  - CREATE2 的盐值，用于影响合约地址。
  - 需提前通过工具生成合适的盐值以匹配靓号条件。
- proxyCode：
  - 代理合约的初始化代码（creation code），不包含构造函数参数。
  - 这是代理的核心逻辑字节码，通常为编译后的代理合约代码
- initialImplementation：已经部署的实现合约地址。
- postUpgradeCall：部署代理合约后需要进行更新实现合约地址以及初始化的数据。
- _expectedAddress：开发者期望的代理合约地址。

### 2. `_requireContainsCaller(msg.sender, proxySalt);`

这行代码的逻辑是要求 proxySalt 的前 20 字节必须包含调用者（`msg.sender`）的地址。这样可以确保部署时的 `proxySalt` 和调用者绑定，防止其他人冒用该 `proxySalt` 来生成合约。

```solidity
    function _requireContainsCaller(address signer, bytes32 salt) private pure {
        // prevent contract submissions from being stolen from tx.pool by requiring
        // that the first 20 bytes of the submitted salt match msg.sender.
        if (address(bytes20(salt)) != signer) {
            revert InvalidSalt(signer, salt);
        }
    }
```

### 3. `_getOrCreateProxyShim();`

这行代码通过 `CREATE2` 获取或创建一个 `ProxyShim` 合约。`ProxyShim` 是一个轻量级 UUPS 实现合约，用作代理合约的占位实现地址。在多链部署中，使用固定的 `ProxyShim` 地址可以确保代理地址一致，后续通过升级机制替换为实际实现合约。

```solidity
    function _getOrCreateProxyShim() private returns (ProxyShim proxyShim) {
        // check if initial implementation has been created
        // get create 2 address for initial implementation
        address _proxyShimAddress = proxyShimAddress();

        if (_proxyShimAddress.code.length > 0) {
            proxyShim = ProxyShim(_proxyShimAddress);
        } else {
            // create initial implementation at determinstic address
            proxyShim = new ProxyShim{salt: INITIAL_IMPLEMENTATION_SALT}();
        }
    }
```

```solidity
contract ProxyShim is UUPSUpgradeable {
    address immutable canUpgrade;

    constructor() {
        // defaults to msg.sender being address(this)
        canUpgrade = msg.sender;
    }

    function _authorizeUpgrade(address) internal view override {
        require(msg.sender == canUpgrade, "not authorized");
    }
}
```

### 4. bytes memory _proxyCreationCode = proxyCreationCode(proxyCode);

这行代码的作用是将代理合约的初始化代码（proxyCode）与其构造函数参数拼接，生成完整的合约部署代码的`creation bytecode`。

> 如果代理合约是 OpenZeppelin 提供的标准 UUPS 代理合约，其构造函数的参数和初始化逻辑通常是这样的：
> 如果构造函数需要两个参数（逻辑合约地址和初始化数据），完整的构造函数调用数据（即 data 参数）通常通过 abi.encode 编码：
> bytes memory data = abi.encode(_logic, _data);


```solidity
    /// Initialization code for the proxy, including the constructor args
    function proxyCreationCode(bytes memory transparentProxyCode) public view returns (bytes memory) {
        return abi.encodePacked(transparentProxyCode, proxyConstructorArgs());
    }

    /// Constructor args when creating the proxy
    function proxyConstructorArgs() public view returns (bytes memory) {
        return abi.encode(proxyShimAddress());
    }

    bytes32 constant INITIAL_IMPLEMENTATION_SALT = bytes32(0x0000000000000000000000000000000000000000000000000000000000000000);

    /// Address of the proxy shim contract that is used to upgrade the factory proxy
    function proxyShimAddress() public view returns (address) {
        return Create2.computeAddress(INITIAL_IMPLEMENTATION_SALT, keccak256(type(ProxyShim).creationCode));
    }
```

### 5. 通过create2方式创建代理合约地址

这段代码通过 CREATE2 指令部署代理合约，随后验证生成的合约地址是否与预期地址 _expectedAddress 一致。

```solidity
        // create the proxy
        address proxyAddress = Create2.deploy(0, proxySalt, _proxyCreationCode);

        if (proxyAddress != _expectedAddress) {
            revert FactoryProxyAddressMismatch(_expectedAddress, proxyAddress);
        }
```

### 6. 执行upgradeToAndCall

这段代码的目的是设置代理合约的实现合约地址，并通过调用逻辑合约中的初始化函数完成必要的初始化操作。

```solidity
UUPSUpgradeable(proxyAddress).upgradeToAndCall(initialImplementation, postUpgradeCall);
```

![实操你可以查看此交易](/images/2024-11-24-01.png)

## 使用透明代理模式生成靓号

可以采用zora官方部署的[`DeterministicDeployerAndCaller`](https://etherscan.deth.net/address/0x813f62e6b808aac8c36868898f84a3e944378d83)合约。

> DeterministicDeployerAndCaller 合约支持UUPS、透明代理、普通合约等其他类型合约部署。

https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v5.2/contracts/proxy/transparent/TransparentUpgradeableProxy.sol#L79

### 1. 调用safeCreate2AndCall函数

开发者通过调用`DeterministicDeployerAndCaller`合约的`safeCreate2AndCall`或者`permitSafeCreate2AndCall`函数进行部署。

```solidity
    /// Creates a contract using create2, and then calls an initialization function on it.
    /// First 20 bytes of salt must match the msg.sender
    /// @param salt Salt to create the contract with
    /// @param code contract creation code
    /// @param postCreateCall what to call on the contract after deploying it
    /// @param _expectedAddress expected address of the created contract
    function safeCreate2AndCall(bytes32 salt, bytes memory code, bytes memory postCreateCall, address _expectedAddress) external payable returns (address) {
        _requireContainsCaller(msg.sender, salt);

        return _safeCreate2AndCall(salt, code, postCreateCall, _expectedAddress);
    }

    function permitSafeCreate2AndCall(
        bytes memory signature,
        bytes32 salt,
        bytes memory code,
        bytes memory postCreateCall,
        address _expectedAddress
    ) external payable returns (address) {
        address signer = ECDSA.recover(hashDigest(salt, code, postCreateCall), signature);

        _requireContainsCaller(signer, salt);

        return _safeCreate2AndCall(salt, code, postCreateCall, _expectedAddress);
    }
```


里面涉及传参数有：

- signature: 用户采用permit方式进行部署，即链下采用eip712 方式对信息进行签名，链上验证有效性。
- salt：
  - CREATE2 的盐值，用于影响合约地址。
  - 需提前通过工具生成合适的盐值以匹配靓号条件。
- code：
  - 代理合约的初始化代码（creation code）。如果构造函数有参数，则初始化代码中已包含这些参数（若要实现多链地址统一，构造函数参数必须保持一致）。
  - 这是代理的核心逻辑字节码，通常为编译后的代理合约代码
- postCreateCall：部署代理合约后需要进行更新实现合约地址以及初始化的数据。
- _expectedAddress：开发者期望的代理合约地址。

### 2. `_requireContainsCaller(msg.sender, proxySalt);`

这行代码的逻辑是要求 proxySalt 的前 20 字节必须包含调用者（`msg.sender`）的地址。这样可以确保部署时的 `proxySalt` 和调用者绑定，防止其他人冒用该 `proxySalt` 来生成合约。

```solidity
    function _requireContainsCaller(address signer, bytes32 salt) private pure {
        // prevent contract submissions from being stolen from tx.pool by requiring
        // that the first 20 bytes of the submitted salt match msg.sender.
        if (address(bytes20(salt)) != signer) {
            revert InvalidSalt(signer, salt);
        }
    }
```

### 3. `_safeCreate2AndCall`

- 计算 CREATE2 地址
- 地址验证
- 通过 CREATE2 部署合约
- 调用初始化逻辑 ()

```solidity
    function _safeCreate2AndCall(bytes32 salt, bytes memory code, bytes memory postCreateCall, address _expectedAddress) private returns (address) {
        address deterministicAddress = Create2.computeAddress(salt, keccak256(code), address(this));
        if (_expectedAddress != deterministicAddress) {
            revert FactoryProxyAddressMismatch(_expectedAddress, deterministicAddress);
        }

        // create the proxy
        address proxyAddress = Create2.deploy(0, salt, code);

        (bool success, bytes memory returnData) = proxyAddress.call(postCreateCall);

        if (!success) {
            revert CallFailed(returnData);
        }

        return proxyAddress;
    }
```

## 部署普通合约生成靓号

可以采用zora官方部署的[`DeterministicDeployerAndCaller`](https://etherscan.deth.net/address/0x813f62e6b808aac8c36868898f84a3e944378d83)合约。

- 实操可看此交易

https://explorer.zora.energy/tx/0xc6052fda04d0a80c66700e1d774873f63f89f73198411371d894419b47b17c87

### 1. call safeCreate2AndCall or permitSafeCreate2AndCall

开发者通过调用`DeterministicDeployerAndCaller`合约的`safeCreate2AndCall`或者`permitSafeCreate2AndCall`函数进行部署。

里面涉及传参数有：

- signature: 用户采用permit方式进行部署，即链下采用eip712 方式对信息进行签名，链上验证有效性。
- salt：
  - CREATE2 的盐值，用于影响合约地址。
  - 需提前通过工具生成合适的盐值以匹配靓号条件。
- code：
  - 合约的初始化代码（creation code）。如果构造函数有参数，则初始化代码中已包含这些参数（若要实现多链地址统一，构造函数参数必须保持一致）。
  - 这是代理的核心逻辑字节码，通常为编译后的代理合约代码
- postCreateCall：部署代理合约后需要进行更新实现合约地址以及初始化的数据。
- _expectedAddress：开发者期望的代理合约地址。

### 2. `_requireContainsCaller(msg.sender, proxySalt);`

这行代码的逻辑是要求 proxySalt 的前 20 字节必须包含调用者（`msg.sender`）的地址。这样可以确保部署时的 `proxySalt` 和调用者绑定，防止其他人冒用该 `proxySalt` 来生成合约。

```solidity
    function _requireContainsCaller(address signer, bytes32 salt) private pure {
        // prevent contract submissions from being stolen from tx.pool by requiring
        // that the first 20 bytes of the submitted salt match msg.sender.
        if (address(bytes20(salt)) != signer) {
            revert InvalidSalt(signer, salt);
        }
    }
```

### 3. `_safeCreate2AndCall`

- 计算 CREATE2 地址
- 地址验证
- 通过 CREATE2 部署合约
- 调用初始化逻辑

```solidity
    function _safeCreate2AndCall(bytes32 salt, bytes memory code, bytes memory postCreateCall, address _expectedAddress) private returns (address) {
        address deterministicAddress = Create2.computeAddress(salt, keccak256(code), address(this));
        if (_expectedAddress != deterministicAddress) {
            revert FactoryProxyAddressMismatch(_expectedAddress, deterministicAddress);
        }

        // create the proxy
        address proxyAddress = Create2.deploy(0, salt, code);

        (bool success, bytes memory returnData) = proxyAddress.call(postCreateCall);

        if (!success) {
            revert CallFailed(returnData);
        }

        return proxyAddress;
    }
```


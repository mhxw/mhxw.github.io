---
title: 如何针对嵌套结构体进行EIP712签名？ (How to Sign Nested Structs with EIP-712?)
date: 2023/11/29 12:00:00
tags:
  - EIP712
category:
  - EVM
---

本篇文章会给大家介绍如何对嵌套结构体进行签名（EIP712 TypedData Encoding With Nested Array of Structs）。本文案例是结构体中嵌套其他结构体数组，与结构体中嵌套其他结构体处理方式一样。

<!-- more -->

如果你对EIP712相关概念和知识了解不多，可以先阅读下面这篇文章。

https://mirror.xyz/xyyme.eth/cJX3zqiiUg2dxB1nmbXbDcQ1DSdajHP5iNgBc6wEZz4

在某个项目中，需要将下面代码块中的`StrategyRequest` 结构体进行EIP712签名，不过在测试中，发现和使用ethers v6 生成的structHash 不一致，最后是如何排查解决的呢？

```solidity
    enum OptionType {
        LONG_CALL,
        LONG_PUT,
        SHORT_CALL,
        SHORT_PUT
    }

    struct Option {
        uint256 positionId;
        // underlying asset address
        address underlying;
        // option strike price (with 18 decimals)
        uint256 strikePrice;
        int256 premium;
        // option expiry timestamp
        uint256 expiryTime;
        // order size
        uint256 size;
        // option type
        OptionType optionType;
        bool isActive;
    }

    struct Future {
        uint256 positionId;
        // underlying asset address
        address underlying;
        // (with 18 decimals)
        uint256 entryPrice;
        // future expiry timestamp
        uint256 expiryTime;
        // order size
        uint256 size;
        bool isLong;
        bool isActive;
    }

    struct StrategyRequest {
        address admin;
        uint256 timestamp;
        uint256 mergeId;
        CollateralInfo[] collaterals;
        Option[] option;
        Future[] future;
    }
```

一、首先查看结构体typehash是否正确。由于该结构体是多层嵌套不同结构体，按照EIP712标准，当struct 里面还有 struct 的情况，**内部struct 的签名对象类型哈希中的结构体对象名称**需要按照字母从a到z拼接；因此StrategyRequest结构体中的内部结构体排序之后为：1：CollateralInfo，2：Future，3：Option； 代码如下：

``` 
//keccak256("StrategyRequest(address admin,uint256 timestamp,uint256 mergeId,CollateralInfo[] collaterals,Option[] option,Future[] future)CollateralInfo(address collateralToken,uint256 collateralAmount)Future(uint256 positionId,address underlying,uint256 entryPrice,uint256 expiryTime,uint256 size,bool isLong,bool isActive)Option(uint256 positionId,address underlying,uint256 strikePrice,int256 premium,uint256 expiryTime,uint256 size,uint256 optionType,bool isActive)");
bytes32 public constant STRATEGY_REQUEST_TYPE_HASH =
        0xc9571297085db7b4ed482bfb5dc48ceb0aa85911a4dd114186601baab392814c;
```

二、生成其他结构体的typehash

```solidity
    //keccak256("CollateralInfo(address collateralToken,uint256 collateralAmount)");
    bytes32 public constant COLLATERAL_INFO_TYPE_HASH =
        0x9ad6f6e9b22cfe4c61d51d75600afaaae0fe0f7dbc24f035d03f68b7f87920fa;

    //keccak256("Future(uint256 positionId,address underlying,uint256 entryPrice,uint256 expiryTime,uint256 size,bool isLong,bool isActive)");
    bytes32 public constant FUTURE_TYPE_HASH = 0xcdff66689589cd15845093f3be135b778815fc2b8dfa35ff5112e645191afe86;

    //keccak256("Option(uint256 positionId,address underlying,uint256 strikePrice,int256 premium,uint256 expiryTime,uint256 size,uint256 optionType,bool isActive)");
    bytes32 public constant OPTION_TYPE_HASH = 0xbc63504838568be333400315a4bfe079d052fe27fe59b4bdac11192ccbca3e47;
```

三、结构体hash

在一个结构体中里面没有其他结构体情况下，structHash生成采用以下方式：

```solidity
    struct StrategyRequest {
        address admin;
        uint256 timestamp;
        uint256 mergeId;
    }

    function _structHash(StrategyRequest memory strategy) internal pure returns (bytes32) {
        bytes32 structHash = keccak256(
            abi.encode(
                Constants.STRATEGY_REQUEST_TYPE_HASH,
                strategy.admin,
                strategy.timestamp,
                strategy.mergeId
            )
        );
        return structHash;
    }
```

在一个结构体中里面有其他结构体情况下，structHash生成采用以下方式：

1、首先把其他结构体的每个字段进行整体abi.encode之后进行keccak256

2、如果涉及内部字段是数组结构体参数，需要先实现第1步，然后将所有的keccak256 hash 进行abi.encode 之后再进行keccak256

3、将keccak256后的变量作为参数放置到structHash 中的abi.encode中

4、最后再进行keccak256之后即可生成structHash

```solidity
    function _structHash(StrategyTypes.StrategyRequest memory strategy) internal pure returns (bytes32) {
        bytes32 structHash = keccak256(
            abi.encode(
                Constants.STRATEGY_REQUEST_TYPE_HASH,
                strategy.admin,
                strategy.timestamp,
                strategy.mergeId,
                _hashCollateral(strategy.collaterals),
                _hashOption(strategy.option),
                _hashFuture(strategy.future)
            )
        );
        return structHash;
    }


    function _hashStrategy(StrategyTypes.StrategyRequest memory strategy) internal view returns (bytes32) {
        bytes32 structHash = _structHash(strategy);
        return _hashTypedDataV4(structHash);
    }

    function _hashCollateral(StrategyTypes.CollateralInfo[] memory collaterals) internal pure returns (bytes32) {
        uint256 len = collaterals.length;
        bytes32[] memory collateralsHashes = new bytes32[](len);
        for (uint256 i; i < len; ) {
            collateralsHashes[i] = keccak256(abi.encode(Constants.COLLATERAL_INFO_TYPE_HASH, collaterals[i]));
            unchecked {
                ++i;
            }
        }
        bytes32 collateralsHash = keccak256(abi.encodePacked(collateralsHashes));
        return collateralsHash;
    }

    function _hashOption(StrategyTypes.Option[] memory options) internal pure returns (bytes32) {
        uint256 len = options.length;
        bytes32[] memory optionsHashes = new bytes32[](len);
        for (uint256 i; i < len; ) {
            optionsHashes[i] = keccak256(
                abi.encode(
                    Constants.OPTION_TYPE_HASH,
                    options[i].positionId,
                    options[i].underlying,
                    options[i].strikePrice,
                    options[i].premium,
                    options[i].expiryTime,
                    options[i].size,
                    options[i].optionType,
                    options[i].isActive
                )
            );
            unchecked {
                ++i;
            }
        }
        bytes32 optionsHash = keccak256(abi.encodePacked(optionsHashes));
        return optionsHash;
    }

    function _hashFuture(StrategyTypes.Future[] memory futures) internal pure returns (bytes32) {
        uint256 len = futures.length;
        bytes32[] memory futuresHashes = new bytes32[](len);
        for (uint256 i; i < len; ) {
            futuresHashes[i] = keccak256(
                abi.encode(
                    Constants.FUTURE_TYPE_HASH,
                    futures[i].positionId,
                    futures[i].underlying,
                    futures[i].entryPrice,
                    futures[i].expiryTime,
                    futures[i].size,
                    futures[i].isLong,
                    futures[i].isActive
                )
            );
            unchecked {
                ++i;
            }
        }
        // 这里使用abi.encodePacked和 abi.encode都可以，因为里面参数为bytes32数组，打包之后效果一样
        bytes32 futuresHash = keccak256(abi.encodePacked(futuresHashes));
        return futuresHash;
    }
```

四、使用ethers输出日志和链上结果比较

```typescript
  const domain = {
    name: "XXX Protocol",
    version: "1",
    chainId: 10,
    verifyingContract: "0x1f9090aae28b8a3dceadf281b0f12828e676c326",
  };

  const types = {
    StrategyRequest: [
      { name: "admin", type: "address" },
      { name: "timestamp", type: "uint256" },
      { name: "mergeId", type: "uint256" },
      { name: "collaterals", type: "CollateralInfo[]" },
      { name: "option", type: "Option[]" },
      { name: "future", type: "Future[]" },
    ],
    CollateralInfo: [
      { name: "collateralToken", type: "address" },
      { name: "collateralAmount", type: "uint256" },
    ],
    Future: [
      { name: "positionId", type: "uint256" },
      { name: "underlying", type: "address" },
      { name: "entryPrice", type: "uint256" },
      { name: "expiryTime", type: "uint256" },
      { name: "size", type: "uint256" },
      { name: "isLong", type: "bool" },
      { name: "isActive", type: "bool" },
    ],
    Option: [
      { name: "positionId", type: "uint256" },
      { name: "underlying", type: "address" },
      { name: "strikePrice", type: "uint256" },
      { name: "premium", type: "int256" },
      { name: "expiryTime", type: "uint256" },
      { name: "size", type: "uint256" },
      { name: "optionType", type: "uint256" },
      { name: "isActive", type: "bool" },
    ],
  };

  const data = {
    admin: "0x45ee97cD5f227EdC94376A71a094F1D05ad0d151",
    timestamp: 1701092243,
    mergeId: 6,
    collaterals: [
      {
        collateralToken: "0x6495ce3e8808d7f4edf7e6e61e97099473b7a962",
        collateralAmount: "8",
      },
      {
        collateralToken: "0x6495ce3e8808d7f4edf7e6e61e97099473b7a962",
        collateralAmount: "8",
      }
    ],
    future: [
      {
        positionId: 0,
        underlying: "0x650c92218306ef82c9ebdb5297ff2288f05c24a8",
        entryPrice: "19200000000000000000000",
        expiryTime: "1703836800",
        size: "2000000000000000000",
        isLong: true,
        isActive: true,
      },
    ],
    option: [
      {
        positionId: 0,
        underlying: "0x650c92218306ef82c9ebdb5297ff2288f05c24a8",
        strikePrice: "19200000000000000000000",
        premium: "44000000000000000000",
        expiryTime: "1703836800",
        size: "2000000000000000000",
        optionType: 0,
        isActive: true,
      },
    ],
  };

  let strategyManagerAddr = config[network.name].strategyManager;
  const eip712FacetInterface = await ethers.getContractAt("EIP712Facet", strategyManagerAddr);
  console.log("hashDomain:\t", ethers.TypedDataEncoder.hashDomain(domain));

  // let structHash = await eip712FacetInterface.structHash(data);
  // console.log("structHash1:\t", structHash.toString());

  const hashStruct = ethers.TypedDataEncoder.hashStruct("StrategyRequest", types, data);
  console.log("structHash2:\t", hashStruct);

  // let result = await eip712FacetInterface.hashStrategy(data);
  // console.log("typeDataHash1:\t", result.toString());

  const typeDataHash = ethers.TypedDataEncoder.hash(domain, types, data);
  console.log("typeDataHash2:\t", typeDataHash);
```

参考链接

https://eips.ethereum.org/EIPS/eip-712
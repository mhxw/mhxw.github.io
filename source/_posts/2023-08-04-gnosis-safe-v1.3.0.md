---
title: Gnosis Safe v1.3.0 多签原理 (The Multi-Signature Principle Behind Gnosis Safe v1.3.0)
date: 2023/08/04 21:00:00
tags:
  - EIP712
category:
  - EVM
---

Gnosis Safe 是一款链上多签钱包解决方案，主要逻辑是组合单个或多个用户（用户地址可以是EOA，也可以是合约账户）对同一笔交易签名，签名验证成功后，执行相关交易。

<!-- more -->

我们基于Safe 合约v1.3.0 进行分析。

https://github.com/safe-global/safe-smart-account/tree/v1.3.0/contracts

https://dashboard.tenderly.co/tx/mainnet/0xefbe3ff4c387f679980e6536cebf75b16081da954c77c62d019325e596bdf7f1/debugger?trace=0.0.1.0.3

## EIP 712
签名数据遵循EIP712 标准，EIP712 定义了4个字段，分别为 `hashStruct` 、`encodeType`、`encodeData`、`domainSeparator`。

![EIP 712 结构图](/images/2023-08-04-01.png)

```solidity
typeHash=keccak256(Struct)
hashStruct= keccak256(abi.encode(typeHash,encodeData(Struct)))
```

EIP 712 中定义的结构体

```solidity
EIP712Domain(uint256 chainId,address verifyingContract)
SafeTx(address to,uint256 value,bytes data,uint8 operation,uint256 safeTxGas,uint256 baseGas,uint256 gasPrice,address gasToken,address refundReceiver,uint256 nonce)
```

EIP712结构体1：EIP712Domain

```solidity
// https://github.com/safe-global/safe-contracts/blob/v1.3.0/contracts/GnosisSafe.sol#L350
# 首先是encodeType 
bytes32 DOMAIN_SEPARATOR_TYPEHASH = keccak256("EIP712Domain(uint256 chainId,address verifyingContract)");
# 然后是encodeData
uint chain_id;
assembly{
chain_id := chainid()
}

bytes memory encodeData = abi.encode(
DOMAIN_SEPARATOR_TYPEHASH,
chain_id,
address(this));
最后是得到domainSeparatorHash
bytes32 domainSeparatorHash = keccak256(encodeData);
```

EIP712结构体2：SafeTx

```solidity
// https://github.com/safe-global/safe-contracts/blob/v1.3.0/contracts/GnosisSafe.sol#L350
首先是encodeType:
bytes32 SAFE_TX_TYPEHASH = keccak256("SafeTx(address to,uint256 value,bytes data,uint8 operation,uint256 safeTxGas,uint256 baseGas,uint256 gasPrice,address gasToken,address refundReceiver,uint256 nonce)");
然后是encodeData:
注意到data中由bytes类型，针对这种不固定长度的数据类型，编码时直接取其hash值作为编码数据
bytes memory safeTxEncodeData = abi.encode(
	SAFE_TX_TYPEHASH,
	address(to),
	uint256(value),
	keccak256(data),
	uint256(uint8(operation)),
	uint256(safeTxGas),
	uint256(baseGas),
	uint256(gasPrice),
	address(gasToken),
	address(refundReceiver),
	uint256(nonce)
)
最后是得到safeTxHash
bytes32 safeTxHash = keccak256(safeTxEncodeData);
```

最后，EIP712得到的结构化编码信息如下：

EIP712 继承了EIP191，EIP的sign_data格式为

```
0x19 <1 byte version> <version specific data> <data to sign>.
```

0x01 表示EIP712 的版本号。

![版本号](/images/2023-08-04-02.png)

```
abi.encodePacked(bytes1(0x19), bytes1(0x01), domainSeparatorHash, safeTxHash);
```

## 签名的三种类型

在GnosisSafe中，所有的签名都编码为{bytes32 r}{btyes32 s}{uint8 v}，共计65个bytes，通过v值的不同来区分不同的签名类型。

- 如果v值为0则为合约签名

- 如果v值为1则为预签名

- 其他情况下则为eoa签名，当v值大于30，用来匹配eth_sign方式；否则为正常签名。

https://github.com/safe-global/safe-contracts/blob/v1.3.0/contracts/GnosisSafe.sol#L256

### EOA的ECDSA签名

EOA 签名遵循RLP编码方式。

恢复标识符`v` 是EOA签名的最后一个字节，平常情况下v不是 27 (`0x1b`) 就是 28 (`0x1c`)。恢复标识符非常重要，因为我们使用的是椭圆曲线算法，仅凭`r` 和 `s` 可计算出曲线上的多个点，因此会恢复出两个不同的公钥（及其对应地址）。`v` 会告诉我们应该使用这些点中的哪一个。

在大多数实现中，v 在内部只是 0 或 1，而 27 是在签署比特币消息时加上的任意数。以太坊也接受了这一点。

从 EIP-155 开始，我们还使用链 ID 来计算 v 值。这可以防止跨链重放攻击：以太坊上签署的交易无法在以太坊经典上使用，反之亦然。目前，恢复标识符只用来签署交易而非消息。

safe中的v值若大于30，恢复标识符使用v-4匹配eth-sign方式，27和28直接匹配`ecrecover`。

```
EOA的签名由三部分组成，r,s,v. 其中v值在EIP-155后的定义为：由{0,1}+27 -> {0,1} + chian_id*2 + 35
```

- `eth_sign` 方式

``` 
r:
0x73d9a99698688c42837ef63fb3f57b18a979704bf00635d816460f018ec8cf1e
s: 0x19242f7cc0f0aecce37b81a6b4e84712c43a024f2cc03f27924257b120ff1074
v: 0x1f
=> 编码后的签名为：
bde0b9f486b1960454e326375d0b1680243e031fd4fb3f070d9a3ef9871ccfd5
7d1a653cffb6321f889169f08e548684e005f2b0c3a6c06fba4c4a68f5e00624
31
```

- 正常方式签名

``` 
r: 0xbde0b9f486b1960454e326375d0b1680243e031fd4fb3f070d9a3ef9871ccfd5
s: 0x7d1a653cffb6321f889169f08e548684e005f2b0c3a6c06fba4c4a68f5e00624 
v: 0x1c
=> 编码后的签名为：
bde0b9f486b1960454e326375d0b1680243e031fd4fb3f070d9a3ef9871ccfd5
7d1a653cffb6321f889169f08e548684e005f2b0c3a6c06fba4c4a68f5e00624
28
```

#### 签名验证

```solidity
if (v > 30) {
   // 若v值大于30，需要减去4以适配eth_sign方式
   // If v > 30 then default va (27,28) has been adjusted for eth_sign flow
   // To support eth_sign and similar we adjust v and hash the messageHash with the Ethereum message prefix before applying ecrecover
   currentOwner = ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", dataHash)), v - 4, r, s);
} else {
   // Default is the ecrecover flow with the provided data hash
   // Use ecrecover with the messageHash for EOA signatures
   currentOwner = ecrecover(dataHash, v, r, s);
}
```

### 合约账户签名

如果safe合约的管理员是一个合约账户，且采用合约账户签名的话，他需要支持EIP-1271签名方式。EIP-1271签名是利用智能合约对一笔交易进行签名，其会返回一个验证签名的地址以及需要验证的动态数组bytes, 故在GnosisSafe的编码规则中，让v值为0，r值为验证签名的地址，`s`值为`bytes类型签名数据的offset`，类似于abi编码。

``` 
动态数组bytes的内容为：
bytes public data = new bytes();
data.push(0xdeadbeaf)
则data中的内容为：
{bytes32 offset}{bytes32 length}{bytes data}
r: 0000000000000000000000000000000000000000000000000000000000000001 // 支持EIP-1271的验证合约地址
s: 00000000000000000000000000000000000000000000000000000000000000c3 // 动态位置 bytes offset
v: 00
=>编码后的签名为：
0000000000000000000000000000000000000000000000000000000000000001
00000000000000000000000000000000000000000000000000000000000000c3
00
0000000000000000000000000000000000000000000000000000000000000008
00000000000000000000000000000000000000000000000000000000deadbeaf
```

#### 签名验证

``` 
// bytes4(keccak256("isValidSignature(bytes32,bytes)")
bytes4 internal constant EIP1271_MAGIC_VALUE = 0x1626ba7e;
require(ISignatureValidator(currentOwner).isValidSignature(data, contractSignature) == EIP1271_MAGIC_VALUE, "GS024");
```

### 预签名（Pre-validated signatures）


预签名中设计v值为1，预签名可通过Gnosis Safe内部维护的`map(address=>map(bytes32=>bool))`，来确认某个账户对一笔交易哈希是否以及预先签名。

Gnosis Safe提出了一个名为链上签名的解决方案，其要解决的问题是智能合约没有私钥，无法对一笔交易签名。它的解决方案是在状态合约中维护一个全局变量：

```solidity
// Mapping to keep track of all hashes (message or transaction) that have been approve by ANY owners
mapping(address => mapping(bytes32 => uint256)) public approvedHashes;
```

然后该safe多签钱包的一个Owner账户通过调用合约的`approveHash`方法，传递要签名的交易hash，来实现链上对一笔交易签名。

```solidity
/**
 * @dev Marks a hash as approved. This can be used to validate a hash that is used by a signature.
 * @param hashToApprove The hash that should be marked as approved for signatures that are verified by this contract.
 */
function approveHash(bytes32 hashToApprove) external {
    require(owners[msg.sender] != address(0), "GS030");
    approvedHashes[msg.sender][hashToApprove] = 1;
    emit ApproveHash(hashToApprove, msg.sender);
}
```

另外一种`v`值为1的情况是交易执行者也可以采用此签名方式，只需验证msg.sender 是否为r 中的owner

```solidity
else if (v == 1) {
  // If v is 1 then it is an approved hash
  // When handling approved hashes the address of the approver is encoded into r
  currentOwner = address(uint160(uint256(r)));
  // Hashes are automatically approved by the sender of the message or when they have been pre-approved via a separate transaction
  require(msg.sender == currentOwner || approvedHashes[currentOwner][dataHash] != 0, "GS025");
}
```

这里的签名信息编码如下：

``` 
r: 0x0000000000000000000000000501be0da35990fbf5c434c29186a7966846c0d5 //该比交易哈希的验证者地址
s: 0x0000000000000000000000000000000000000000000000000000000000000000 //占位符
v: 0x01
=>
000000000000000000000000cc98f267c3830011dd56ce448e13ddb4cc747711
0000000000000000000000000000000000000000000000000000000000000000
1
```

#### 签名验证

``` 
// Hashes are automatically approved by the sender of the message or when they have been pre-approved via a separate transaction
require(msg.sender == currentOwner || approvedHashes[currentOwner][dataHash] != 0, "GS025");
```

因此，用于`execTransaction` 的签名字节是

``` 
"0x" + 
"000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000c300" + // encoded EIP-1271 signature
"0000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000001" + // encoded pre-validated signature
"bde0b9f486b1960454e326375d0b1680243e031fd4fb3f070d9a3ef9871ccfd57d1a653cffb6321f889169f08e548684e005f2b0c3a6c06fba4c4a68f5e006241c" + // encoded ECDSA signature
"000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000deadbeef"     // length of bytes + data of bytes
```

## EOA 链下构造签名

### 生成safeTxHash

github.com/safe-global/safe-contracts/blob/v1.3.0/contracts/GnosisSafe.sol#L408

传入相关参数(可以使用safe的sdk)，生成safeTxHash

```solidity
/// @dev Returns hash to be signed by owners.
/// @param to Destination address.
/// @param value Ether value.
/// @param data Data payload.
/// @param operation Operation type.
/// @param safeTxGas Fas that should be used for the safe transaction.
/// @param baseGas Gas costs for data used to trigger the safe transaction.
/// @param gasPrice Maximum gas price that should be used for this transaction.
/// @param gasToken Token address (or 0 if ETH) that is used for the payment.
/// @param refundReceiver Address of receiver of gas payment (or 0 if tx.origin).
/// @param _nonce Transaction nonce.
/// @return Transaction hash.
function getTransactionHash(
    address to,
    uint256 value,
    bytes calldata data,
    Enum.Operation operation,
    uint256 safeTxGas,
    uint256 baseGas,
    uint256 gasPrice,
    address gasToken,
    address refundReceiver,
    uint256 _nonce
) public view returns (bytes32) {
    return keccak256(encodeTransactionData(to, value, data, operation, safeTxGas, baseGas, gasPrice, gasToken, refundReceiver, _nonce));
}
```

通过safe合约的owner EOA地址对getTransactionHash函数返回的messageHash 进行签名。

### 组装拼接签名

如果我们的签名策略是2/3，那么需要收集2个eoa owner地址的链下签名，最后将这些签名信息拼接作为signatures字段参数。

签名信息拼接是按照多签合约管理员弓腰地址从小到大排序，每个signature对应65字节。

```solidity
/// @dev Allows to execute a Safe transaction confirmed by required number of owners and then pays the account that submitted the transaction.
///      Note: The fees are always transferred, even if the user transaction fails.
/// @param to Destination address of Safe transaction.
/// @param value Ether value of Safe transaction.
/// @param data Data payload of Safe transaction.
/// @param operation Operation type of Safe transaction.
/// @param safeTxGas Gas that should be used for the Safe transaction.
/// @param baseGas Gas costs that are independent of the transaction execution(e.g. base transaction fee, signature check, payment of the refund)
/// @param gasPrice Gas price that should be used for the payment calculation.
/// @param gasToken Token address (or 0 if ETH) that is used for the payment.
/// @param refundReceiver Address of receiver of gas payment (or 0 if tx.origin).
/// @param signatures Packed signature data ({bytes32 r}{bytes32 s}{uint8 v})
function execTransaction(
    address to,
    uint256 value,
    bytes calldata data,
    Enum.Operation operation,
    uint256 safeTxGas,
    uint256 baseGas,
    uint256 gasPrice,
    address gasToken,
    address payable refundReceiver,
    bytes memory signatures
) public payable virtual returns (bool success) {
```

## Safe合约签名消息

https://github.com/safe-global/safe-smart-account/blob/v1.3.0/contracts/handler/CompatibilityFallbackHandler.sol#L28C8

safe合约签名采用EIP 1271标准，在isValidSignature实现了2种验证方式。

首先判断_signature是否有值，无值走第一种方式，反之第二种方式。

第一种是需要先调用`signMessage`函数，传入要签名的消息进行链上发交易实现合约签名。

https://github.com/safe-global/safe-smart-account/blob/v1.3.0/contracts/examples/libraries/SignMessage.sol#L20

第二种是沿用上个章节的签名逻辑

```solidity
/**
  * Implementation of ISignatureValidator (see `interfaces/ISignatureValidator.sol`)
  * @dev Should return whether the signature provided is valid for the provided data.
  * @param _data Arbitrary length data signed on the behalf of address(msg.sender)
  * @param _signature Signature byte array associated with _data
  * @return a bool upon valid or invalid signature with corresponding _data
  */
function isValidSignature(bytes calldata _data, bytes calldata _signature) public view override returns (bytes4) {
    // Caller should be a Safe
    GnosisSafe safe = GnosisSafe(payable(msg.sender));
    bytes32 messageHash = getMessageHashForSafe(safe, _data);
    if (_signature.length == 0) {
        require(safe.signedMessages(messageHash) != 0, "Hash not approved");
    } else {
        // 沿用上个章节的签名逻辑
        safe.checkSignatures(messageHash, _data, _signature);
    }
    return EIP1271_MAGIC_VALUE;
}
```

## 参考链接

https://docs.safe.global/safe-core-protocol/signatures

https://github.com/safe-global/safe-smart-account/blob/v1.3.0/contracts/GnosisSafe.sol#L35-L43
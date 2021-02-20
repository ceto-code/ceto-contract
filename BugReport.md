# CETO Bug Report

Based on our analysis the state of the contract was corrupted in the transaction id [`83f97831ede76755f31afec81c5a52ab62434cd3bc75bb3e6c4894447f98b842`](https://tronscan.org/#/transaction/83f97831ede76755f31afec81c5a52ab62434cd3bc75bb3e6c4894447f98b842) due to an underflow error when the autoreinvest bot `TSQe2GMoX4b8oDDMDJPSZeF57NZvz8VTpc` called the `invokeAutoReinvest` function for the account `TGLe1dg2DGn9qUxxXATx5htdJrAqudKuTj`

The error was on the line [#1064](https://github.com/ceto-code/ceto-contract/blob/main/Hourglass.sol#L1064). We were checking if the sum of the dividends and the referral balance was greater than the rewardPerInvocation and the minimumDividendValue amount, this led to the case in which the dividends in themselves were lesser than the reward which led to a underflow error in the function dividendsOf called on line [#799](https://github.com/ceto-code/ceto-contract/blob/main/Hourglass.sol#L799) resulting in a huge dividend value.

### Whats the fix?
The fix is to only use the divdendsOf value and not the sum of the dividendsOf and the referral balance to pay put the auto reinvestment reward.  
So changing line [#1064](https://github.com/ceto-code/ceto-contract/blob/main/Hourglass.sol#L1064) from 
```solidity
uint256 _dividends = dividendsOf(_customerAddress) + referralBalance_[_customerAddress];
```
to 
```solidity
uint256 _dividends = dividendsOf(_customerAddress);
```
fixes the bug

__Note__: This bug only seeped in cause we didn't consider referral incomes in our test cases. We are writing all the test cases again including referral incomes now.

### Where did the funds go?
Due to the corrupted state of the contract it was possible for anyone to drain the funds using the function invokeAutoReinvest which was seen as a cause of concern by the a community member(`TSQe2GMoX4b8oDDMDJPSZeF57NZvz8VTpc`) who drained the funds and is currently holding them as an escrow while we prepare a patched up contract with everyones stake the same as before the buggy transaction. After the new contract is deployed the community member will transfer the funds direclty to it. We will be releasing the contract in the community for public scrutiny a day prior to its deployment. 

__Note__: After the above community member withdrew 1.1M TRX from the contract the remaining the 55930 TRX were withdrawn by our core team(`TBQaYFAjL6ZzQW199oG7Du8GcWtZmK5yPH`) following the same method. These funds will also be directly transfered to the new contract once deployed.

We are preparing a more indepth report along with the patched up contract source code, both of which will be released in the next 24hrs.

## Detailed Analysis

The state of the contract before the transaction [`83f97831ede76755f31afec81c5a52ab62434cd3bc75bb3e6c4894447f98b842`](https://tronscan.org/#/transaction/83f97831ede76755f31afec81c5a52ab62434cd3bc75bb3e6c4894447f98b842) was as follows

```
getAutoReinvestEntry() = (1613825817, 20000000, 43200, 50000000)
dividendsOf('TGLe1dg2DGn9qUxxXATx5htdJrAqudKuTj') = 2495954
referralBalance_['TGLe1dg2DGn9qUxxXATx5htdJrAqudKuTj'] = 53333333
payoutsTo_['TGLe1dg2DGn9qUxxXATx5htdJrAqudKuTj'] = 14913563948781233480056009397
profitPerShare_ = 24809137937556660190
tokenBalanceLedger_['TGLe1dg2DGn9qUxxXATx5htdJrAqudKuTj'] = 602987747
```

This meant that the conditions at both line [#1059](https://github.com/ceto-code/ceto-contract/blob/main/Hourglass.sol#L1059) and line [#1070](https://github.com/ceto-code/ceto-contract/blob/main/Hourglass.sol#L1070) will be satisfied

Then the payoutsTo value will be updated on the line [#1075](https://github.com/ceto-code/ceto-contract/blob/main/Hourglass.sol#L1075) which will make its new value to be
```
14913563948781233480056009397 + 20000000 * magnitude = 15282498830255424512376009397
```
The role of this line is to deduct the reward from the users dividends as it will be paid to the caller of this transaction as a reimbursement for their gas fees.

Then when the execution will reach line #799 inside the *_reinvest* function it'll call the *dividendsOf* function again.
The underflow occurs inside the *dividendsOf* function on line #484
```solidity
(uint256)(
    (int256)(
        profitPerShare_ * tokenBalanceLedger_[_customerAddress]
    ) - payoutsTo_[_customerAddress]
) / magnitude;
```
where each of the values are
```
profitPerShare_ = 24809137937556660190
tokenBalanceLedger_['TGLe1dg2DGn9qUxxXATx5htdJrAqudKuTj'] = 602987747
payoutsTo_['TGLe1dg2DGn9qUxxXATx5htdJrAqudKuTj'] = 15282498830255424512376009397
magnitude = 18446744073709551616  
```
which leads to
```
(uint256)(
    (int256)(
        24809137937556660190 * 602987747
    ) - 15282498830255424512376009397
) / 18446744073709551616;
```
```
(uint256)(
    (int256)(
        14959606189979517212812691930
    ) - 15282498830255424512376009397
) / 18446744073709551616;
```
```
(uint256)(
    14959606189979517212812691930 - 15282498830255424512376009397
) / 18446744073709551616;
```
```
(uint256)(
    14959606189979517212812691930 - 15282498830255424512376009397
) / 18446744073709551616;
```
```
(uint256)(-322892640275907299563317467) / 18446744073709551616;
```
```
((2^256 - 1) -322892640275907299563317467) / 18446744073709551616;
```
```
(115792089237316195423570985008687907853269984665640564039457584007913129639936 -322892640275907299563317467) / 18446744073709551616;
```
```
(115792089237316195423570985008687907853269984665640241146817308100613566322469) / 18446744073709551616;
```
```
6277101735386680763835789423207666416102355444464017008850
```

then on line #807 we add the referral balance to the above value
```
_dividends = 6277101735386680763835789423207666416102355444464017008850 + 53333333
```
```
_dividends = 6277101735386680763835789423207666416102355444464070342183
```

which is same as the value that is logged in the events for the transaction as seen in the blob below

```json
{
  "methodName": "invokeAutoReinvest",
  "inputTypes": [
    "address"
  ],
  "args": [
    "TGLe1dg2DGn9qUxxXATx5htdJrAqudKuTj"
  ],
  "owner_address": "TSQe2GMoX4b8oDDMDJPSZeF57NZvz8VTpc",
  "contract_address": "TLqB1kuXuKeKzeGkvrZjpLA6Kz6pN2LHj5",
  "block_number": 27731702,
  "block_timestamp": 1613580654000,
  "call_value": null,
  "tx_id": "83f97831ede76755f31afec81c5a52ab62434cd3bc75bb3e6c4894447f98b842",
  "events": [
    {
      "event_name": "onReinvestment",
      "result": {
        "customerAddress": "0x45de5dfb0e13d6933afed37870be6eaf87b4cdee",
        "tokensMinted": "10629573426857742617765951435542434",
        "tronReinvested": "6277101735386680763835789423207666416102355444464070342183"
      }
    },
    {
      "event_name": "onTokenPurchase",
      "result": {
        "customerAddress": "0x45de5dfb0e13d6933afed37870be6eaf87b4cdee",
        "tokensMinted": "10629573426857742617765951435542434",
        "referredBy": "0x0000000000000000000000000000000000000000",
        "incomingTron": "6277101735386680763835789423207666416102355444464070342183"
      }
    }
  ]
}
```

This very huge value of dividends led to huge amount of tokens being minted and very large dividend earnings for all the token holders. This also led to very high token prices. These very high token prices allowed one to set a very high autoReinvestment reward for the a account and then run the invokeAutoReinvestment function using another account claiming the rewards.


# CETO Bug Report

Based on our analysis the state of the contract was corrupted in the transaction id [`83f97831ede76755f31afec81c5a52ab62434cd3bc75bb3e6c4894447f98b842`](https://tronscan.org/#/transaction/83f97831ede76755f31afec81c5a52ab62434cd3bc75bb3e6c4894447f98b842) due to an underflow error when the autoreinvest bot `TSQe2GMoX4b8oDDMDJPSZeF57NZvz8VTpc` called the `invokeAutoReinvest` function for the account `TGLe1dg2DGn9qUxxXATx5htdJrAqudKuTj`

The error was on the line [#1064](https://github.com/ceto-code/ceto-contract/blob/main/Hourglass.sol#L1064). We were checking if the sum of the dividends and the referral balance was greater than the rewardPerInvocation and the minimumDividendValue amount, this led to the case in which the dividends in themselves were lesser than the reward which led to a underflow error in the function dividendsOf called on line [#799](https://github.com/ceto-code/ceto-contract/blob/main/Hourglass.sol#L799) resulting in a huge dividend value.

### Fix
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

__Note__: This bug only seeped in cause we didn't consider referral incomes in our test cases. We are writing the all the test cases again including that now.

### Where did the funds go
Due to the corrupted state of the contract it was possible for anyone to drain the funds using the function invokeAutoReinvest which was seen as a cause of concern by the a community member(`TSQe2GMoX4b8oDDMDJPSZeF57NZvz8VTpc`) who drained the funds and is currently holding them as an escrow while we prepare a patched up contract with everyones stake the same as before the buggy transaction. After the new contract is deployed the community member will transfer the funds direclty to it. We will be releasing the contract in the community for public scrutiny a day prior to its deployment. 

__Note__: After the above community member withdrew 1.1M TRX from the contract the remaining the 55930 TRX were withdrawn by our core team(`TBQaYFAjL6ZzQW199oG7Du8GcWtZmK5yPH`) following the same method. These funds will also be directly transfered to the new contract once deployed.

We are preparing a more indepth report along with the patched up contract both of which will be released in the next 24hrs.

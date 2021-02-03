# Crystal Elephant Token

## Whitepaper
https://crystalelephant.net/whitepaper

## Documentation
[Hourglass]: #Hourglass
[Hourglass-onlyBagholders--]: #Hourglass-onlyBagholders--
[Hourglass-onlyStronghands--]: #Hourglass-onlyStronghands--
[Hourglass-onlyAdministrator--]: #Hourglass-onlyAdministrator--
[Hourglass-antiEarlyWhale-uint256-]: #Hourglass-antiEarlyWhale-uint256-
[Hourglass-name-string]: #Hourglass-name-string
[Hourglass-symbol-string]: #Hourglass-symbol-string
[Hourglass-decimals-uint8]: #Hourglass-decimals-uint8
[Hourglass-dividendFee_-uint8]: #Hourglass-dividendFee_-uint8
[Hourglass-tokenPriceInitial_-uint256]: #Hourglass-tokenPriceInitial_-uint256
[Hourglass-tokenPriceIncremental_-uint256]: #Hourglass-tokenPriceIncremental_-uint256
[Hourglass-magnitude-uint256]: #Hourglass-magnitude-uint256
[Hourglass-stakingRequirement-uint256]: #Hourglass-stakingRequirement-uint256
[Hourglass-ambassadors_-mapping-address----bool-]: #Hourglass-ambassadors_-mapping-address----bool-
[Hourglass-ambassadorMaxPurchase_-uint256]: #Hourglass-ambassadorMaxPurchase_-uint256
[Hourglass-ambassadorQuota_-uint256]: #Hourglass-ambassadorQuota_-uint256
[Hourglass-tokenBalanceLedger_-mapping-address----uint256-]: #Hourglass-tokenBalanceLedger_-mapping-address----uint256-
[Hourglass-tokenTimestampedBalanceLedger_-mapping-address----struct-Hourglass-TimestampedBalance---]: #Hourglass-tokenTimestampedBalanceLedger_-mapping-address----struct-Hourglass-TimestampedBalance---
[Hourglass-tokenTimestampedBalanceCursor-mapping-address----struct-Hourglass-Cursor-]: #Hourglass-tokenTimestampedBalanceCursor-mapping-address----struct-Hourglass-Cursor-
[Hourglass-referralMapping-mapping-address----bytes32-]: #Hourglass-referralMapping-mapping-address----bytes32-
[Hourglass-referralReverseMapping-mapping-bytes32----address-]: #Hourglass-referralReverseMapping-mapping-bytes32----address-
[Hourglass-referralBalance_-mapping-address----uint256-]: #Hourglass-referralBalance_-mapping-address----uint256-
[Hourglass-referralIncome_-mapping-address----uint256-]: #Hourglass-referralIncome_-mapping-address----uint256-
[Hourglass-payoutsTo_-mapping-address----int256-]: #Hourglass-payoutsTo_-mapping-address----int256-
[Hourglass-ambassadorAccumulatedQuota_-mapping-address----uint256-]: #Hourglass-ambassadorAccumulatedQuota_-mapping-address----uint256-
[Hourglass-tokenSupply_-uint256]: #Hourglass-tokenSupply_-uint256
[Hourglass-profitPerShare_-uint256]: #Hourglass-profitPerShare_-uint256
[Hourglass-administrators-mapping-address----bool-]: #Hourglass-administrators-mapping-address----bool-
[Hourglass-onlyAmbassadors-bool]: #Hourglass-onlyAmbassadors-bool
[Hourglass-autoReinvestment-mapping-address----struct-Hourglass-AutoReinvestEntry-]: #Hourglass-autoReinvestment-mapping-address----struct-Hourglass-AutoReinvestEntry-
[Hourglass-fallback--]: #Hourglass-fallback--
[Hourglass-buy-address-]: #Hourglass-buy-address-
[Hourglass-reinvest-bool-uint24-uint256-uint256-]: #Hourglass-reinvest-bool-uint24-uint256-uint256-
[Hourglass-exit--]: #Hourglass-exit--
[Hourglass-withdraw--]: #Hourglass-withdraw--
[Hourglass-_updateLedgerForTransfer-uint256-address-]: #Hourglass-_updateLedgerForTransfer-uint256-address-
[Hourglass-calculateAveragePenalty-uint256-address-]: #Hourglass-calculateAveragePenalty-uint256-address-
[Hourglass-executeAveragePenalty-uint256-address-]: #Hourglass-executeAveragePenalty-uint256-address-
[Hourglass-_calculatePenalty-uint256-]: #Hourglass-_calculatePenalty-uint256-
[Hourglass-sell-uint256-]: #Hourglass-sell-uint256-
[Hourglass-disableInitialStage--]: #Hourglass-disableInitialStage--
[Hourglass-setAdministrator-address-bool-]: #Hourglass-setAdministrator-address-bool-
[Hourglass-setStakingRequirement-uint256-]: #Hourglass-setStakingRequirement-uint256-
[Hourglass-setReferrals-address-bytes32-]: #Hourglass-setReferrals-address-bytes32-
[Hourglass-getReferralAddressForName-bytes32-]: #Hourglass-getReferralAddressForName-bytes32-
[Hourglass-getReferralNameForAddress-address-]: #Hourglass-getReferralNameForAddress-address-
[Hourglass-getReferralBalance--]: #Hourglass-getReferralBalance--
[Hourglass-getCursor--]: #Hourglass-getCursor--
[Hourglass-getTimestampedBalanceLedger-uint256-]: #Hourglass-getTimestampedBalanceLedger-uint256-
[Hourglass-totalTronBalance--]: #Hourglass-totalTronBalance--
[Hourglass-totalSupply--]: #Hourglass-totalSupply--
[Hourglass-myTokens--]: #Hourglass-myTokens--
[Hourglass-myDividends-bool-]: #Hourglass-myDividends-bool-
[Hourglass-balanceOf-address-]: #Hourglass-balanceOf-address-
[Hourglass-dividendsOf-address-]: #Hourglass-dividendsOf-address-
[Hourglass-sellPrice--]: #Hourglass-sellPrice--
[Hourglass-buyPrice--]: #Hourglass-buyPrice--
[Hourglass-calculateTokensReceived-uint256-]: #Hourglass-calculateTokensReceived-uint256-
[Hourglass-calculateTokensReinvested--]: #Hourglass-calculateTokensReinvested--
[Hourglass-calculateTronReceived-uint256-]: #Hourglass-calculateTronReceived-uint256-
[Hourglass-calculateTronTransferred-uint256-]: #Hourglass-calculateTronTransferred-uint256-
[Hourglass-purchaseTokens-address-uint256-address-]: #Hourglass-purchaseTokens-address-uint256-address-
[Hourglass-_withdraw-address-]: #Hourglass-_withdraw-address-
[Hourglass-tronToTokens_-uint256-]: #Hourglass-tronToTokens_-uint256-
[Hourglass-tokensToTron_-uint256-]: #Hourglass-tokensToTron_-uint256-
[Hourglass-sqrt-uint256-]: #Hourglass-sqrt-uint256-
[Hourglass-fullMul-uint256-uint256-]: #Hourglass-fullMul-uint256-uint256-
[Hourglass-mulDiv-uint256-uint256-uint256-]: #Hourglass-mulDiv-uint256-uint256-uint256-
[Hourglass-setupAutoReinvest-uint24-uint256-address-uint256-]: #Hourglass-setupAutoReinvest-uint24-uint256-address-uint256-
[Hourglass-invokeAutoReinvest-address-]: #Hourglass-invokeAutoReinvest-address-
[Hourglass-getAutoReinvestEntry--]: #Hourglass-getAutoReinvestEntry--
[Hourglass-getAutoReinvestEntryOf-address-]: #Hourglass-getAutoReinvestEntryOf-address-
[Hourglass-stopAutoReinvest--]: #Hourglass-stopAutoReinvest--
[Hourglass-allowance-address-address-]: #Hourglass-allowance-address-address-
[Hourglass-approve-address-uint256-]: #Hourglass-approve-address-uint256-
[Hourglass-transferFrom-address-address-uint256-]: #Hourglass-transferFrom-address-address-uint256-
[Hourglass-transfer-address-uint256-]: #Hourglass-transfer-address-uint256-
[Hourglass-_transfer-address-address-uint256-]: #Hourglass-_transfer-address-address-uint256-
[Hourglass-increaseAllowance-address-uint256-]: #Hourglass-increaseAllowance-address-uint256-
[Hourglass-decreaseAllowance-address-uint256-]: #Hourglass-decreaseAllowance-address-uint256-
[Hourglass-_approve-address-address-uint256-]: #Hourglass-_approve-address-address-uint256-
[Hourglass-onTokenPurchase-address-uint256-uint256-address-]: #Hourglass-onTokenPurchase-address-uint256-uint256-address-
[Hourglass-onTokenSell-address-uint256-uint256-]: #Hourglass-onTokenSell-address-uint256-uint256-
[Hourglass-onReinvestment-address-uint256-uint256-]: #Hourglass-onReinvestment-address-uint256-uint256-
[Hourglass-onWithdraw-address-uint256-]: #Hourglass-onWithdraw-address-uint256-
[Hourglass-Transfer-address-address-uint256-]: #Hourglass-Transfer-address-address-uint256-
[Hourglass-Approval-address-address-uint256-]: #Hourglass-Approval-address-address-uint256-
[Hourglass-onAutoReinvestmentEntry-address-uint256-uint256-uint24-uint256-]: #Hourglass-onAutoReinvestmentEntry-address-uint256-uint256-uint24-uint256-
[Hourglass-onAutoReinvestmentStop-address-]: #Hourglass-onAutoReinvestmentStop-address-
[SafeMath]: #SafeMath
[SafeMath-mul-uint256-uint256-]: #SafeMath-mul-uint256-uint256-
[SafeMath-div-uint256-uint256-]: #SafeMath-div-uint256-uint256-
[SafeMath-sub-uint256-uint256-]: #SafeMath-sub-uint256-uint256-
[SafeMath-add-uint256-uint256-]: #SafeMath-add-uint256-uint256-
## <span id="Hourglass"></span> `Hourglass`





- [`onlyBagholders()`][Hourglass-onlyBagholders--]
- [`onlyStronghands()`][Hourglass-onlyStronghands--]
- [`onlyAdministrator()`][Hourglass-onlyAdministrator--]
- [`antiEarlyWhale(uint256 _amountOfTron)`][Hourglass-antiEarlyWhale-uint256-]
- [`fallback()`][Hourglass-fallback--]
- [`buy(address _referredBy)`][Hourglass-buy-address-]
- [`reinvest(bool isAutoReinvestChecked, uint24 period, uint256 rewardPerInvocation, uint256 minimumDividendValue)`][Hourglass-reinvest-bool-uint24-uint256-uint256-]
- [`exit()`][Hourglass-exit--]
- [`withdraw()`][Hourglass-withdraw--]
- [`_updateLedgerForTransfer(uint256 _amountOfTokens, address _customerAddress)`][Hourglass-_updateLedgerForTransfer-uint256-address-]
- [`calculateAveragePenalty(uint256 _amountOfTokens, address _customerAddress)`][Hourglass-calculateAveragePenalty-uint256-address-]
- [`executeAveragePenalty(uint256 _amountOfTokens, address _customerAddress)`][Hourglass-executeAveragePenalty-uint256-address-]
- [`_calculatePenalty(uint256 timestamp)`][Hourglass-_calculatePenalty-uint256-]
- [`sell(uint256 _amountOfTokens)`][Hourglass-sell-uint256-]
- [`disableInitialStage()`][Hourglass-disableInitialStage--]
- [`setAdministrator(address _identifier, bool _status)`][Hourglass-setAdministrator-address-bool-]
- [`setStakingRequirement(uint256 _amountOfTokens)`][Hourglass-setStakingRequirement-uint256-]
- [`setReferrals(address ref_address, bytes32 ref_name)`][Hourglass-setReferrals-address-bytes32-]
- [`getReferralAddressForName(bytes32 ref_name)`][Hourglass-getReferralAddressForName-bytes32-]
- [`getReferralNameForAddress(address ref_address)`][Hourglass-getReferralNameForAddress-address-]
- [`getReferralBalance()`][Hourglass-getReferralBalance--]
- [`getCursor()`][Hourglass-getCursor--]
- [`getTimestampedBalanceLedger(uint256 counter)`][Hourglass-getTimestampedBalanceLedger-uint256-]
- [`totalTronBalance()`][Hourglass-totalTronBalance--]
- [`totalSupply()`][Hourglass-totalSupply--]
- [`myTokens()`][Hourglass-myTokens--]
- [`myDividends(bool _includeReferralBonus)`][Hourglass-myDividends-bool-]
- [`balanceOf(address _customerAddress)`][Hourglass-balanceOf-address-]
- [`dividendsOf(address _customerAddress)`][Hourglass-dividendsOf-address-]
- [`sellPrice()`][Hourglass-sellPrice--]
- [`buyPrice()`][Hourglass-buyPrice--]
- [`calculateTokensReceived(uint256 _tronToSpend)`][Hourglass-calculateTokensReceived-uint256-]
- [`calculateTokensReinvested()`][Hourglass-calculateTokensReinvested--]
- [`calculateTronReceived(uint256 _tokensToSell)`][Hourglass-calculateTronReceived-uint256-]
- [`calculateTronTransferred(uint256 _amountOfTokens)`][Hourglass-calculateTronTransferred-uint256-]
- [`purchaseTokens(address _customerAddress, uint256 _incomingTron, address _referredBy)`][Hourglass-purchaseTokens-address-uint256-address-]
- [`_withdraw(address _customerAddress)`][Hourglass-_withdraw-address-]
- [`tronToTokens_(uint256 _tron)`][Hourglass-tronToTokens_-uint256-]
- [`tokensToTron_(uint256 _tokens)`][Hourglass-tokensToTron_-uint256-]
- [`sqrt(uint256 x)`][Hourglass-sqrt-uint256-]
- [`fullMul(uint256 x, uint256 y)`][Hourglass-fullMul-uint256-uint256-]
- [`mulDiv(uint256 x, uint256 y, uint256 z)`][Hourglass-mulDiv-uint256-uint256-uint256-]
- [`setupAutoReinvest(uint24 period, uint256 rewardPerInvocation, address customerAddress, uint256 minimumDividendValue)`][Hourglass-setupAutoReinvest-uint24-uint256-address-uint256-]
- [`invokeAutoReinvest(address _customerAddress)`][Hourglass-invokeAutoReinvest-address-]
- [`getAutoReinvestEntry()`][Hourglass-getAutoReinvestEntry--]
- [`getAutoReinvestEntryOf(address _customerAddress)`][Hourglass-getAutoReinvestEntryOf-address-]
- [`stopAutoReinvest()`][Hourglass-stopAutoReinvest--]
- [`allowance(address owner, address spender)`][Hourglass-allowance-address-address-]
- [`approve(address spender, uint256 value)`][Hourglass-approve-address-uint256-]
- [`transferFrom(address sender, address recipient, uint256 amount)`][Hourglass-transferFrom-address-address-uint256-]
- [`transfer(address _toAddress, uint256 _amountOfTokens)`][Hourglass-transfer-address-uint256-]
- [`_transfer(address _customerAddress, address _toAddress, uint256 _amountOfTokens)`][Hourglass-_transfer-address-address-uint256-]
- [`increaseAllowance(address spender, uint256 addedValue)`][Hourglass-increaseAllowance-address-uint256-]
- [`decreaseAllowance(address spender, uint256 subtractedValue)`][Hourglass-decreaseAllowance-address-uint256-]
- [`_approve(address owner, address spender, uint256 value)`][Hourglass-_approve-address-address-uint256-]
- [`onTokenPurchase(address customerAddress, uint256 incomingTron, uint256 tokensMinted, address referredBy)`][Hourglass-onTokenPurchase-address-uint256-uint256-address-]
- [`onTokenSell(address customerAddress, uint256 tokensBurned, uint256 tronEarned)`][Hourglass-onTokenSell-address-uint256-uint256-]
- [`onReinvestment(address customerAddress, uint256 tronReinvested, uint256 tokensMinted)`][Hourglass-onReinvestment-address-uint256-uint256-]
- [`onWithdraw(address customerAddress, uint256 tronWithdrawn)`][Hourglass-onWithdraw-address-uint256-]
- [`Transfer(address from, address to, uint256 tokens)`][Hourglass-Transfer-address-address-uint256-]
- [`Approval(address owner, address spender, uint256 value)`][Hourglass-Approval-address-address-uint256-]
- [`onAutoReinvestmentEntry(address customerAddress, uint256 nextExecutionTime, uint256 rewardPerInvocation, uint24 period, uint256 minimumDividendValue)`][Hourglass-onAutoReinvestmentEntry-address-uint256-uint256-uint24-uint256-]
- [`onAutoReinvestmentStop(address customerAddress)`][Hourglass-onAutoReinvestmentStop-address-]

### <span id="Hourglass-onlyBagholders--"></span> `onlyBagholders()`





### <span id="Hourglass-onlyStronghands--"></span> `onlyStronghands()`





### <span id="Hourglass-onlyAdministrator--"></span> `onlyAdministrator()`





### <span id="Hourglass-antiEarlyWhale-uint256-"></span> `antiEarlyWhale(uint256 _amountOfTron)`





### <span id="Hourglass-fallback--"></span> `fallback()` (external)

Fallback function to handle tron that was send straight to the contract
Unfortunately we cannot use a referral address this way.



### <span id="Hourglass-buy-address-"></span> `buy(address _referredBy)` (public)

Converts all incoming tron to tokens for the caller, and passes down the referral addy (if any)



### <span id="Hourglass-reinvest-bool-uint24-uint256-uint256-"></span> `reinvest(bool isAutoReinvestChecked, uint24 period, uint256 rewardPerInvocation, uint256 minimumDividendValue)` (public)

Converts all of caller's dividends to tokens.



### <span id="Hourglass-exit--"></span> `exit()` (public)

Alias of sell() and withdraw().



### <span id="Hourglass-withdraw--"></span> `withdraw()` (public)

Withdraws all of the callers earnings.



### <span id="Hourglass-_updateLedgerForTransfer-uint256-address-"></span> `_updateLedgerForTransfer(uint256 _amountOfTokens, address _customerAddress)` (internal)

Update ledger after transferring x tokens



### <span id="Hourglass-calculateAveragePenalty-uint256-address-"></span> `calculateAveragePenalty(uint256 _amountOfTokens, address _customerAddress) → uint256` (public)

Calculate the withholding penalty for selling x tokens



### <span id="Hourglass-executeAveragePenalty-uint256-address-"></span> `executeAveragePenalty(uint256 _amountOfTokens, address _customerAddress) → uint256` (public)

Calculate the withholding penalty for selling x tokens and edit the timestamped ledger



### <span id="Hourglass-_calculatePenalty-uint256-"></span> `_calculatePenalty(uint256 timestamp) → uint256` (public)

Calculate the early exit penalty for selling after x days



### <span id="Hourglass-sell-uint256-"></span> `sell(uint256 _amountOfTokens)` (public)

Liquifies tokens to tron.



### <span id="Hourglass-disableInitialStage--"></span> `disableInitialStage()` (public)

In case the amassador quota is not met, the administrator can manually disable the ambassador phase.



### <span id="Hourglass-setAdministrator-address-bool-"></span> `setAdministrator(address _identifier, bool _status)` (public)





### <span id="Hourglass-setStakingRequirement-uint256-"></span> `setStakingRequirement(uint256 _amountOfTokens)` (public)

Precautionary measures in case we need to adjust the masternode rate.



### <span id="Hourglass-setReferrals-address-bytes32-"></span> `setReferrals(address ref_address, bytes32 ref_name) → bool` (public)





### <span id="Hourglass-getReferralAddressForName-bytes32-"></span> `getReferralAddressForName(bytes32 ref_name) → address` (public)





### <span id="Hourglass-getReferralNameForAddress-address-"></span> `getReferralNameForAddress(address ref_address) → bytes32` (public)





### <span id="Hourglass-getReferralBalance--"></span> `getReferralBalance() → uint256, uint256` (public)





### <span id="Hourglass-getCursor--"></span> `getCursor() → uint256, uint256` (public)





### <span id="Hourglass-getTimestampedBalanceLedger-uint256-"></span> `getTimestampedBalanceLedger(uint256 counter) → uint256, uint256, uint256` (public)





### <span id="Hourglass-totalTronBalance--"></span> `totalTronBalance() → uint256` (public)

Method to view the current Tron stored in the contract
Example: totalTronBalance()



### <span id="Hourglass-totalSupply--"></span> `totalSupply() → uint256` (public)

Retrieve the total token supply.



### <span id="Hourglass-myTokens--"></span> `myTokens() → uint256` (public)

Retrieve the tokens owned by the caller.



### <span id="Hourglass-myDividends-bool-"></span> `myDividends(bool _includeReferralBonus) → uint256` (public)

Retrieve the dividends owned by the caller.
If `_includeReferralBonus` is true, the referral bonus will be included in the calculations.
The reason for this, is that in the frontend, we will want to get the total divs (global + ref)
But in the internal calculations, we want them separate.



### <span id="Hourglass-balanceOf-address-"></span> `balanceOf(address _customerAddress) → uint256` (public)

Retrieve the token balance of any single address.



### <span id="Hourglass-dividendsOf-address-"></span> `dividendsOf(address _customerAddress) → uint256` (public)

Retrieve the dividend balance of any single address.



### <span id="Hourglass-sellPrice--"></span> `sellPrice() → uint256` (public)

Return the tron received on selling 1 individual token.
We are not deducting the penalty over here as it's a general sell price
the user can use the `calculateTronReceived` to get the sell price specific to them



### <span id="Hourglass-buyPrice--"></span> `buyPrice() → uint256` (public)

Return the tron required for buying 1 individual token.



### <span id="Hourglass-calculateTokensReceived-uint256-"></span> `calculateTokensReceived(uint256 _tronToSpend) → uint256` (public)





### <span id="Hourglass-calculateTokensReinvested--"></span> `calculateTokensReinvested() → uint256` (public)





### <span id="Hourglass-calculateTronReceived-uint256-"></span> `calculateTronReceived(uint256 _tokensToSell) → uint256` (public)

Function for the frontend to dynamically retrieve the price scaling of sell orders.



### <span id="Hourglass-calculateTronTransferred-uint256-"></span> `calculateTronTransferred(uint256 _amountOfTokens) → uint256` (public)





### <span id="Hourglass-purchaseTokens-address-uint256-address-"></span> `purchaseTokens(address _customerAddress, uint256 _incomingTron, address _referredBy) → uint256` (internal)





### <span id="Hourglass-_withdraw-address-"></span> `_withdraw(address _customerAddress)` (internal)





### <span id="Hourglass-tronToTokens_-uint256-"></span> `tronToTokens_(uint256 _tron) → uint256` (public)

Calculate Token price based on an amount of incoming tron
Some conversions occurred to prevent decimal errors or underflows / overflows in solidity code.



### <span id="Hourglass-tokensToTron_-uint256-"></span> `tokensToTron_(uint256 _tokens) → uint256` (public)

Calculate token sell value.
Some conversions occurred to prevent decimal errors or underflows / overflows in solidity code.



### <span id="Hourglass-sqrt-uint256-"></span> `sqrt(uint256 x) → uint256 y` (internal)





### <span id="Hourglass-fullMul-uint256-uint256-"></span> `fullMul(uint256 x, uint256 y) → uint256 l, uint256 h` (public)



calculates x*y and outputs a emulated 512bit number as l being the lower 256bit half and h the upper 256bit half.

### <span id="Hourglass-mulDiv-uint256-uint256-uint256-"></span> `mulDiv(uint256 x, uint256 y, uint256 z) → uint256` (public)



calculates x*y/z taking care of phantom overflows.

### <span id="Hourglass-setupAutoReinvest-uint24-uint256-address-uint256-"></span> `setupAutoReinvest(uint24 period, uint256 rewardPerInvocation, address customerAddress, uint256 minimumDividendValue)` (internal)





### <span id="Hourglass-invokeAutoReinvest-address-"></span> `invokeAutoReinvest(address _customerAddress) → uint256` (external)





### <span id="Hourglass-getAutoReinvestEntry--"></span> `getAutoReinvestEntry() → uint256, uint256, uint24, uint256` (public)





### <span id="Hourglass-getAutoReinvestEntryOf-address-"></span> `getAutoReinvestEntryOf(address _customerAddress) → uint256, uint256, uint24, uint256` (public)





### <span id="Hourglass-stopAutoReinvest--"></span> `stopAutoReinvest()` (external)





### <span id="Hourglass-allowance-address-address-"></span> `allowance(address owner, address spender) → uint256` (public)





### <span id="Hourglass-approve-address-uint256-"></span> `approve(address spender, uint256 value) → bool` (public)





### <span id="Hourglass-transferFrom-address-address-uint256-"></span> `transferFrom(address sender, address recipient, uint256 amount) → bool` (public)





### <span id="Hourglass-transfer-address-uint256-"></span> `transfer(address _toAddress, uint256 _amountOfTokens) → bool` (public)





### <span id="Hourglass-_transfer-address-address-uint256-"></span> `_transfer(address _customerAddress, address _toAddress, uint256 _amountOfTokens)` (internal)



Moves tokens `amount` from `sender` to `recipient` after liquifying 10% of the tokens `amount` as dividens.

This is internal function is equivalent to {transfer}, and can be used to
e.g. implement automatic token fees, slashing mechanisms, etc.

Emits a {Transfer} event.

Requirements:

- `_customerAddress` cannot be the zero address.
- `_toAddress` cannot be the zero address.
- `_customerAddress` must have a balance of at least `_amountOfTokens`.

### <span id="Hourglass-increaseAllowance-address-uint256-"></span> `increaseAllowance(address spender, uint256 addedValue) → bool` (public)



Atomically increases the allowance granted to `spender` by the caller.

This is an alternative to {approve} that can be used as a mitigation for
problems described in {IERC20-approve}.

Emits an {Approval} event indicating the updated allowance.

Requirements:

- `spender` cannot be the zero address.

### <span id="Hourglass-decreaseAllowance-address-uint256-"></span> `decreaseAllowance(address spender, uint256 subtractedValue) → bool` (public)



Atomically decreases the allowance granted to `spender` by the caller.

This is an alternative to {approve} that can be used as a mitigation for
problems described in {IERC20-approve}.

Emits an {Approval} event indicating the updated allowance.

Requirements:

- `spender` cannot be the zero address.
- `spender` must have allowance for the caller of at least
`subtractedValue`.

### <span id="Hourglass-_approve-address-address-uint256-"></span> `_approve(address owner, address spender, uint256 value)` (internal)



Sets `amount` as the allowance of `spender` over the `owner`s tokens.

This is internal function is equivalent to `approve`, and can be used to
e.g. set automatic allowances for certain subsystems, etc.

Emits an {Approval} event.

Requirements:

- `owner` cannot be the zero address.
- `spender` cannot be the zero address.

### <span id="Hourglass-onTokenPurchase-address-uint256-uint256-address-"></span> `onTokenPurchase(address customerAddress, uint256 incomingTron, uint256 tokensMinted, address referredBy)`





### <span id="Hourglass-onTokenSell-address-uint256-uint256-"></span> `onTokenSell(address customerAddress, uint256 tokensBurned, uint256 tronEarned)`





### <span id="Hourglass-onReinvestment-address-uint256-uint256-"></span> `onReinvestment(address customerAddress, uint256 tronReinvested, uint256 tokensMinted)`





### <span id="Hourglass-onWithdraw-address-uint256-"></span> `onWithdraw(address customerAddress, uint256 tronWithdrawn)`





### <span id="Hourglass-Transfer-address-address-uint256-"></span> `Transfer(address from, address to, uint256 tokens)`





### <span id="Hourglass-Approval-address-address-uint256-"></span> `Approval(address owner, address spender, uint256 value)`





### <span id="Hourglass-onAutoReinvestmentEntry-address-uint256-uint256-uint24-uint256-"></span> `onAutoReinvestmentEntry(address customerAddress, uint256 nextExecutionTime, uint256 rewardPerInvocation, uint24 period, uint256 minimumDividendValue)`





### <span id="Hourglass-onAutoReinvestmentStop-address-"></span> `onAutoReinvestmentStop(address customerAddress)`







## <span id="SafeMath"></span> `SafeMath`



Math operations with safety checks that throw on error

- [`mul(uint256 a, uint256 b)`][SafeMath-mul-uint256-uint256-]
- [`div(uint256 a, uint256 b)`][SafeMath-div-uint256-uint256-]
- [`sub(uint256 a, uint256 b)`][SafeMath-sub-uint256-uint256-]
- [`add(uint256 a, uint256 b)`][SafeMath-add-uint256-uint256-]

### <span id="SafeMath-mul-uint256-uint256-"></span> `mul(uint256 a, uint256 b) → uint256` (internal)



Multiplies two numbers, throws on overflow.

### <span id="SafeMath-div-uint256-uint256-"></span> `div(uint256 a, uint256 b) → uint256` (internal)



Integer division of two numbers, truncating the quotient.

### <span id="SafeMath-sub-uint256-uint256-"></span> `sub(uint256 a, uint256 b) → uint256` (internal)



Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).

### <span id="SafeMath-add-uint256-uint256-"></span> `add(uint256 a, uint256 b) → uint256` (internal)



Adds two numbers, throws on overflow.


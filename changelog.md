# Change Log

The following record logs changes to Trade Control, first released on **2019.09.24**. Checked items are included in the latest master commit.

[creation script](src/tcNode/scripts/tc_create_node.sql)

## 3.24

### 3.24.2

[sql](src/tcNode/scripts/tc_upgrade_3_24_2.sql)

- [x] trigger new current balance when OpeningBalance updated 
- [x] include opening balance in the current balance in new accounts
- [x] cast EntryNumber to int on cash account listing
- [x] include ActivityCode in [Invoice.vwSalesInvoiceSpool](src/tcNodeDb/Invoice/Views/vwSalesInvoiceSpool.sql)
- [x] exclude vat entries from [Cash.vwStatement](src/tcNodeDb/Cash/Views/vwStatement.sql) for un-registered businesses
- [x] forward invoices with multiple lines not totaling in [Cash.proc_FlowCashCodeValues](src/tcNodeDb/Cash/Stored%20Procedures/proc_FlowCashCodeValues.sql)

### 3.24.3

[sql](src/tcNode/scripts/tc_upgrade_3_24_3.sql)

- [x] [Task.proc_Configure](src/tcNodeDb/Task/Stored%20Procedures/proc_Configure.sql) inserting empty contacts into Org.tbContact

### 3.24.4

[sql](src/tcNode/scripts/tc_upgrade_3_24_4.sql)

- [x] remove obsolete field Cash.tbCode.OpeningBalance
- [x] invoiced vat not showing on [Cash.vwStatement](src/tcNodeDb/Cash/Views/vwStatement.sql) when no payments have been made 
- [x] move _TradeControl.Node.Config.exe_ error log to _Documents\Trade Control_ folder.
- [x] code signing Sectigo RSA tcNodeConfigSetup 

### 3.24.5

[sql](src/tcNode/scripts/tc_upgrade_3_24_5.sql)

- [x] remove obsolete field IndustrySector from Org.tbOrg
- [x] early vat payment handling on [Cash.vwStatement](src/tcNodeDb/Cash/Views/vwStatement.sql)
- [x] [App.proc_BasicSetup](src/tcNodeDb/App/Stored%20Procedures/proc_BasicSetup.sql) year periods creation fix for < StartMonth
- [x] set historical year periods to closed instead of archived
- [x] error reporting in setup app terminating executing process on log write failure

### 3.24.6

- [x] remove obsolete IndustrySector code from the Services demo [App.proc_DemoServices](src/tcNodeDb/App/Stored%20Procedures/proc_DemoServices.sql)
- [x] extract the [TCNodeConfig](src/tcNode/TCNodeConfig.cs) class into a separate library for use in the [Network project](https://github.com/tradecontrol/tc-network).

### 3.25.1

[sql](src/tcNode/scripts/tc_upgrade_3_25_1.sql)

A script to facilitate event processing by the [Trade Control Network](https://github.com/tradecontrol/tc-network)

- [x] transmission status enumerated type for networking Orgs and triggering contract deployment
- [x] [Task.tbChangeLog](src/tcNodeDb/Task/Tables/tbChangeLog.sql) table maintained by the [Task.tbTask](src/tcNodeDb/Task/Tables/tbTask.sql) insert, update and delete triggers 
- [x] [Invoice.tbChangeLog](src/tcNodeDb/Invoice/Tables/tbChangeLog.sql) table maintained by the [Invoice.tbInvoice](src/tcNodeDb/Invoice/Tables/tbInvoice.sql) insert, update and delete triggers
- [x] Cleardown procedures for the Service Event Log and the new Change Logs. 
- [x] remove obsolete function _Cash.fnFlowCashCodeValues()_


### 3.26.1

[sql](src/tcNode/scripts/tc_upgrade_3_26_1.sql)

- [x] ```FLOAT``` is a useful but imprecise type in Sql Server. Moving forward we are going to use ```DECIMAL``` for storing quantities, which is also the underlying type for ```MONEY```

### 3.27.1

Release 3.27.1 supports the first full release of the [Trade Control Network](https://github.com/tradecontrol/tc-network).  

[sql](src/tcNode/scripts/tc_upgrade_3_27_1.sql)

- [x] [unit of charge](src/tcNodeDb/App/Tables/tbUoC.sql)
- [x] [activity code mirrors](src/tcNodeDb/Activity/Tables/tbMirror.sql)
- [x] [task allocations](src/tcNodeDb/Task/Tables/tbAllocation.sql) and [SvD algorithm](src/tcNodeDb/Task/Views/vwAllocationSvD.sql) 
- [x] [cash code mirrors](src/tcNodeDb/Cash/Tables/tbMirror.sql)
- [x] [invoice mirrors](src/tcNodeDb/Invoice/Tables/tbMirror.sql) 
- [x] intialisation integration
- [x] network interface to sql db class [tcNodeNetwork.cs](src/tcNode/TCNodeNetwork.cs).

### 3.28.1

[sql](src/tcNode/scripts/tc_upgrade_3_28_1.sql)

- [x] replace type ```MONEY``` with ```DECIMAL(18,5)``` to support bitcoin decimals (1000*BTC)
- [x] re-create views to assign ```DECIMAL(18,5)``` type to outputs
- [x] move payment tables, functions and procedures from Org to Cash schema
- [x] add rounding decimals to tax codes 
- [x] procedure [Cash.proc_PaymentPostReconcile](src/tcNodeDb/Cash/Stored%20Procedures/proc_PaymentPostReconcile.sql) to ensure wallet -> cash account -> invoice synchronisation

### 3.28.2

Implements the data logic of the [Trade Control Bitcoin Wallet](https://github.com/tradecontrol/tc-bitcoin).  

[sql](src/tcNode/scripts/tc_upgrade_3_28_2.sql)

- [x] [coin type](src/tcNodeDb/Cash/Tables/tbCoinType.sql) - Main, TestNet, Fiat
- [x] [miner identity](src/tcNodeDb/App/Tables/tbOptions.sql) - cash and account code
- [x] [key hierarchy](src/tcNodeDb/Org/Tables/tbAccountKey.sql) - extended keys
- [x] [change keys](src/tcNodeDb/Cash/Tables/tbChange.sql)
- [x] [company namespace](src/tcNodeDb/Org/Views/vwNamespace.sql)
- [x] [invoice mirror](src/tcNodeDb/Invoice/Tables/tbMirrorEvent.sql) - payment address send event
- [x] [bitcoin transactions](src/tcNodeDb/Cash/Tables/tbTx.sql)
- [x] procedures to process transaction outputs  
- [x] wallet interface to sql cb class [tcNodeCash.cs](src/tcNode/TCNodeCash.cs). 

### 3.28.3

[sql](src/tcNode/scripts/tc_upgrade_3_28_3.sql)

- [x] node initialisation for crypto wallet
- [x] unit of charge changes to demo data 
- [x] remove the UOC from the installer for upgrades before 3.27.1
 
### 3.28.4

[sql](src/tcNode/scripts/tc_upgrade_3_28_4.sql)

- [x] increase the decimal places of the UnitCharge to 7 in [Tasks](src/tcNodeDb/Task/Tables/tbTask.sql)
- [x] [App.proc_BasicSetup](src/tcNodeDb/App/Stored%20Procedures/proc_BasicSetup.sql) creating a miner account for fiat currencies resulting in Services Demo failure
- [x] [App.proc_DemoServices](src/tcNodeDb/App/Stored%20Procedures/proc_DemoServices.sql) cleardown - exclude miner 

### 3.28.5

[sql](src/tcNode/scripts/tc_upgrade_3_28_5.sql)

- [x] fix for [client app](https://github.com/tradecontrol/tc-office) converting calculated decimal fields to short text. Reconnect required.


### 3.29.1

Implements the data logic of the Trade Control [Balance Sheet](https://github.com/tradecontrol/tc-office#demos)

[sql](src/tcNode/scripts/tc_upgrade_3_29_1.sql)

- [x] [cash account type](src/tcNodeDb/Org/Tables/tbAccountType.sql) - Cash, Dummy, Asset
- [x] add account type and [liquidity](src/tcNodeDb/Org/Tables/tbAccount.sql) to the cash accounts
- [x] exclude asset accounts from all views, functions and procedures related to trading
- [x] global [coin type](src/tcNodeDb/Cash/Tables/tbCoinType.sql) in [options](src/tcNodeDb/App/Tables/tbOptions.sql)
- [x] prohibit asset payment entries from generating invoices in [Cash.proc_PaymentPost](src/tcNodeDb/Cash/Stored%20Procedures/proc_PaymentPost.sql)
- [x] add asset statements to [period end closedown](src/tcNodeDb/App/Stored%20Procedures/proc_PeriodClose.sql)
- [x] [asset type](src/tcNodeDb/Cash/Tables/tbAssetType.sql) - Debtors, Creditors, Bank, Cash, Cash Accounts, Capital
- [x] [Cash.fnFlowBankBalances](src/tcNodeDb/Cash/Functions/fnFlowBankBalances.sql) not projecting the balance over periods where there are no transactions
- [x] [balance sheet periods](src/tcNodeDb/Cash/Views/vwBalanceSheetPeriods.sql), [organisation statement](src/tcNodeDb/Org/Views/vwAssetStatement.sql), [debtors and creditors](src/tcNodeDb/Cash/Views/vwBalanceSheetOrgs.sql), [bank/wallet accounts](src/tcNodeDb/Cash/Views/vwBalanceSheetAccounts.sql), [asset accounts](src/tcNodeDb/Cash/Views/vwBalanceSheetAssets.sql)  
- [x] [the balance sheet](src/tcNodeDb/Cash/Views/vwBalanceSheet.sql) 

### 3.29.2

[sql](src/tcNode/scripts/tc_upgrade_3_29_2.sql)

- [x] node initialisation, setup and demos to incorporate balance sheet assets 

### 3.29.3

[sql](src/tcNode/scripts/tc_upgrade_3_29_3.sql)

- [x] fix for neutral cash mode signing error on P&L

### 3.29.4

[sql](src/tcNode/scripts/tc_upgrade_3_29_4.sql)

- [x] set all UnitCharge fields to ```decimal(18, 7)```
- [x] assert UnitCharge in related views

### 3.30.1

[Balance Sheet](https://github.com/tradecontrol/tc-office#demos) consolidation.

[sql](src/tcNode/scripts/tc_upgrade_3_30_1.sql)

- [x] fix [Cash Statement](src/tcNodeDb/Cash/Views/vwAccountStatement.sql) - opening balance manual override not included on asset type cash accounts
- [x] fix [Debtors and Creditors](src/tcNodeDb/Org/Views/vwAssetBalances.sql) - replace account polarity with transaction polarity
- [x] fix [Organisation Statements](src/tcNodeDb/Org/Views/vwStatement.sql) - ```UNION ALL``` to include all transctions
- [x] derive the [Asset Statement](src/tcNodeDb/Org/Views/vwAssetStatement.sql) from the Organisation Statement and add financial periods
- [x] separate out [organisation balances](src/tcNodeDb/Cash/Views/vwBalanceSheetOrgs.sql) from the balance sheet for audit reports
- [x] views for balance sheet auditing
- [x] [include corporation tax](src/tcNodeDb/Cash/Views/vwBalanceSheetTax.sql) from the [Tax Statement](src/tcNodeDb/Cash/Views/vwTaxCorpStatement.sql)
- [x] offset the inclusion of debtor/creditor tax by [adding the closing balances](src/tcNodeDb/Cash/Views/vwBalanceSheetVat.sql) of the [VAT Statement](src/tcNodeDb/Cash/Views/vwTaxVatStatement.sql)

### 3.30.2

Paid tax and invoice status simplification.

[sql](src/tcNode/scripts/tc_upgrade_3_30_2.sql)

- [x] remove TaxPaidIn and TaxPaidOut from [Cash.tbPayment](src/tcNodeDb/Cash/Tables/tbPayment.sql)
- [x] replace Cash.proc_PaymentPostPaidIn/Out with [Invoice.vwStatusLive](src/tcNodeDb/Invoice/Views/vwStatusLive.sql)
- [x] remove PaidTaxValue and PaidValue from [Invoice.tbItem](src/tcNodeDb/Invoice/Tables/tbItem.sql) and [Invoice.tbTask](src/tcNodeDb/Invoice/Tables/tbTask.sql) 
- [x] optimise rebuild procedures [System Rebuild](src/tcNodeDb/App/Stored%20Procedures/proc_SystemRebuild.sql) and [Organisation Rebuild](src/tcNodeDb/Org/Stored%20Procedures/proc_Rebuild.sql)

### 3.30.3

[sql](src/tcNode/scripts/tc_upgrade_3_30_3.sql)

- [x] fix [Corporation Tax period totals](src/tcNodeDb/Cash/Views/vwTaxCorpTotalsByPeriod.sql) - include asset type net profits
- [x] [zeroise corporation tax](src/tcNodeDb/Cash/Views/vwBalanceSheetTax.sql) due in loss making periods
- [x] fix [Cash.proc_PaymentPostReconcile](src/tcNodeDb/Cash/Stored%20Procedures/proc_PaymentPostReconcile.sql) - obsolete invoice detail Paid Value inclusion
- [x] fix [Invoice.proc_Pay](src/tcNodeDb/Invoice/Stored%20Procedures/proc_Pay.sql) - use header paid value
- [x] fix [App.proc_BasicSetup](src/tcNodeDb/App/Stored%20Procedures/proc_BasicSetup.sql) - assign HMREV account to Cash.tbTaxType 
- [x] fix [Cash.vwBalanceSheetVat](src/tcNodeDb/Cash/Views/vwBalanceSheetVat.sql) - select the correct balance for same day payments
 
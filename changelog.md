# Change Log

The following record logs changes to Trade Control, first released on **2019.09.24**. Checked items are included in the latest master commit.

[creation script](src/tcNode/scripts/tc_create_node.sql)

## 3.24

### 3.24.2

[sql](src/tcNode/scripts/tc_upgrade_3_24_2.sql)

- [x] trigger new current balance when OpeningBalance updated 
- [x] include opening balance in the current balance in new accounts
- [x] cast EntryNumber to int on cash account listing
- [x] include ActivityCode in _Invoice.vwSalesInvoiceSpool__
- [x] exclude vat entries from _Cash.vwStatement_ for un-registered businesses
- [x] forward invoices with multiple lines not totaling in _Cash.proc_FlowCashCodeValues__

### 3.24.3

[sql](src/tcNode/scripts/tc_upgrade_3_24_3.sql)

- [x] _Task.proc_Configure_ inserting empty contacts into Org.tbContact

### 3.24.4

[sql](src/tcNode/scripts/tc_upgrade_3_24_4.sql)

- [x] remove obsolete field Cash.tbCode.OpeningBalance
- [x] invoiced vat not showing on _Cash.vwStatement_ when no payments have been made 
- [x] move _TradeControl.Node.Config.exe_ error log to _Documents\Trade Control_ folder.
- [x] code signing Sectigo RSA tcNodeConfigSetup 

### 3.24.5

[sql](src/tcNode/scripts/tc_upgrade_3_24_5.sql)

- [x] remove obsolete field IndustrySector from Org.tbOrg
- [x] early vat payment handling on _Cash.vwStatement_
- [x] _App.proc_BasicSetup_ year periods creation fix for < StartMonth
- [x] set historical year periods to closed instead of archived
- [x] error reporting in setup app terminating executing process on log write failure

### 3.24.6

- [x] remove obsolete IndustrySector code from the Services demo _App.proc_DemoServices_
- [x] extract the _TCNodeConfig_ class into a separate library for use in the [Network project](https://github.com/tradecontrol/tc-network).

### 3.25.1

[sql](src/tcNode/scripts/tc_upgrade_3_25_1.sql)

A script to facilitate event processing by the [Trade Control Network](https://github.com/tradecontrol/tc-network)

- [x] transmission status enumerated type for networking Orgs and triggering contract deployment
- [x] _Task.tbChangeLog_ table maintained by the _Task.tbTask_ insert, update and delete triggers 
- [x] _Invoice.tbChangeLog_ table maintained by the _Invoice.tbInvoice_ insert, update and delete triggers
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
- [x] procedure _Cash.proc_PaymentPostReconcile_ to ensure wallet -> cash account -> invoice synchronisation

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
- [x] _App.proc_BasicSetup_ creating a miner account for fiat currencies resulting in Services Demo failure
- [x] _App.proc_DemoServices_ cleardown - exclude miner 

### 3.28.5

[sql](src/tcNode/scripts/tc_upgrade_3_28_5.sql)

- [x] fix for [client app](https://github.com/tradecontrol/tc-office) converting calculated decimal fields to short text. Reconnect required.



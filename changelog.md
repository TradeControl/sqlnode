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

- [x] A transmission status enumerated type for networking Orgs and triggering contract deployment
- [x] _Task.tbChangeLog_ table maintained by the _Task.tbTask_ insert, update and delete triggers 
- [x] _Invoice.tbChangeLog_ table maintained by the _Invoice.tbInvoice_ insert, update and delete triggers
- [x] Cleardown procedures for the Service Event Log and the new Change Logs. 
- [x] remove obsolete function _Cash.fnFlowCashCodeValues()_

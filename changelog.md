# Change Log

The following record logs changes to Trade Control, first released on **2019.09.24**. Checked items are included in the latest master commit.

## 3.24

### 3.24.2

- [x] trigger new current balance when OpeningBalance updated 
- [x] include opening balance in the current balance in new accounts
- [x] cast EntryNumber to int on cash account listing
- [x] include ActivityCode in Invoice.vwSalesInvoiceSpool
- [x] exclude vat entries from Cash.vwStatement for un-registered businesses
- [x] forward invoices with multiple lines not totaling in Cash.proc_FlowCashCodeValues

### 3.24.3

- [x] Task.proc_Configure inserting empty contacts into Org.tbContact

### 3.24.4

- [x] remove obsolete field Cash.tbCode.OpeningBalance
- [x] invoiced vat not showing on _Cash.vwStatement_ when no payments have been made 
- [x] move _TradeControl.Node.Config.exe_ error log to _Documents\Trade Control_ folder.
- [x] code signing Sectigo RSA tcNodeConfigSetup 

### 3.24.5

- [x] remove obsolete field IndustrySector from Org.tbOrg
- [x] early vat payment handling on _Cash.vwStatement_
- [x] _App.proc_BasicSetup_ year periods creation fix for < StartMonth
- [x] set historical year periods to closed instead of archived
- [x] error reporting in setup app terminating executing process on log write failure

### 3.24.6

- [x] remove obsolete IndustrySector code from the Services demo _App.proc_DemoServices_
- [x] extract the _TCNodeConfig_ class into a separate library for use in the [TC-Network project](https://github.com/tradecontrol/tc-network).


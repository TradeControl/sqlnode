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

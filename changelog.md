# Change Log

Changes to 3.33.1, released February 2021.

### 3.34.1

Completion of the [costing system](https://tradecontrol.github.io/tutorials/manufacturing#job-costing)

- [x] [Task.tbCostSet](src/tcNodeDb/Task/Tables/tbCostSet.sql) - active set of user quotes for costing
- [x] [Task.Task_tbTask_TriggerUpdate](src/tcNodeDb/Task/Tables/tbTask.sql) - remove tasks from cost set when set to ordered 
- [x] [Task.vwQuotes](src/tcNodeDb/Task/Views/vwQuotes.sql) - quotes available for selection
- [x] [Task.vwCostSet](src/tcNodeDb/Task/Views/vwCostSet.sql) - current user's set of quotes 
- [x] [Task.proc_CostSetAdd](src/tcNodeDb/Task/Stored%20Procedures/proc_CostSetAdd.sql) - include task in the set
- [x] [Cash.vwStatementBase](src/tcNodeDb/Cash/Views/vwStatementBase.sql) - split out the live company statement from the balance projection
- [x] [Cash.vwStatement](src/tcNodeDb/Cash/Views/vwStatement.sql) - derive the company statement from the base dataset
- [x] [Cash.vwStatementWhatIf](src/tcNodeDb/Cash/Views/vwStatementWhatIf.sql) - integrate the quotes, vat and company tax into the company statement 

### 3.34.2

- [x] [Task.proc_Pay](src/tcNodeDb/Task/Stored%20Procedures/proc_Pay.sql) - fix auto-invoice date not matching payment on date

### 3.34.3

Authorisation and authentication support for the [Asp.Net Core interface](https://github.com/tradecontrol/tradecontrol.web).

- [x] Standard Asp.Net Core schema design. Unfortunately it uses the default dbo schema instead of AspNet.TableName.

### 3.34.4 

Integrates setup templates into the [Node Configuration](https://tradecontrol.github.io/tutorials/installing-sqlnode#basic-setup) program. There are only two at this stage, but more can be added.

- [x] [App.tbTemplate](src/tcNodeDb/App/Tables/tbTemplate.sql) - a list of configuration templates and the associated stored procedure name.
- [x] [App.proc_TemplateCompanyGeneral](src/tcNodeDb/App/Stored%20Procedures/proc_TemplateCompanyGeneral.sql) - a new template that supports vat and capital accounts
- [x] [App.proc_TemplateTutorials](src/tcNodeDb/App/Stored%20Procedures/proc_TemplateTutorials.sql) - the original configuration template used by [the tutorials](https://tradecontrol.github.io/tutorials/overview)
- [x] [App.proc_BasicSetup](src/tcNodeDb/App/Stored%20Procedures/proc_BasicSetup.sql) - @TemplateName param to execute user selected configuration.

### 3.34.5

- [x] [Cash.vwBalanceSheetAccounts](src/tcNodeDb/Cash/Views/vwBalanceSheetAccounts.sql) - fix negative m/e balances zeroised

### 3.34.6

Full script for the [Asp.Net Core interface](https://github.com/tradecontrol/tradecontrol.web). It has no impact on the 365 implementation since it uses the same algorithms.


 
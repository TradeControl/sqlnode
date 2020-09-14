## TRADE CONTROL - Coding Practice

### History

The first release of Trade Control (TC) was designed in Sql Server 2005 and released on 19th March 2008. However, due to the development partner's IT infrastructure, the database was designed to function at Compatibility Level (CL) 2000. The initial Open Source version is released with CL 2016 (130). 

The one constant from the beginning is the schema design. The only difference really is the introduction of separate schema, rather than the default dbo, which was preferred at the time. That is because schema design is universal, and un-related to T-SQL where most of the changes, at least for developers, has occurred between the two CLs. 

Not wishing to re-write the application from scratch, particularly where it works fine, has resulted in a combination of legacy and up-to-date coding styles in the TC schema and business logic. It is easy to spot though, because both styles are completely different.  

Sql Server 2000 did not have many of the features provided today.  It was finally written in C++ and introduced functions (UDFs), but it was not until 2005 that it was fully liberated from SyBase. Then, principle changes for developers were the formal introduction of error handling techniques, windows functions and common table expressions (CTE) with recursion.  

### CTEs

Versions 1 and 2 of TC were CL 2000 compatible. They employed a combination of nested views, cursors and stored procedures to model the business logic. A lot of this has been written out in Version 3. Today, the preferred method is to combine T-Sql Windows Functions with CTEs and their recursive form. The only disadvantage is that the Query Designer in Management Studio does not support it; except on the outer query level, rearranging the entire CTE with its deranged formatting methodology.

CTEs require that the previous statement be terminated by a semicolon, but not for other kinds of statement. Version 3 code tends to use semicolons for that reason, so its presence is a good indication as to what CL the code was written under. However, because the T-Sql syntax checker does not enforce this requirement, it is not a totally reliable indicator.

The view *Cash.vwTaxCorpStatement* is a good example of how all these things come together. It returns a transaction level statement of a business's corporation tax obligations. In other words, each time a Company Statement is refreshed, the dataset is recalculated from all associated Cash Codes and their individual transactions.


``` sql
CREATE OR ALTER VIEW Cash.vwTaxCorpStatement
AS
	WITH tax_dates AS
	(
		SELECT PayOn, PayFrom, PayTo FROM Cash.fnTaxTypeDueDates(0)
	), period_totals AS
	(
		SELECT (SELECT PayOn FROM tax_dates WHERE totals.StartOn >= PayFrom AND totals.StartOn < PayTo) AS StartOn, CorporationTax
		FROM Cash.vwTaxCorpTotalsByPeriod totals
	), tax_entries AS
	(
		SELECT StartOn, SUM(CorporationTax) AS TaxDue, 0 AS TaxPaid
		FROM period_totals
		WHERE NOT StartOn IS NULL
		GROUP BY StartOn
		
		UNION

		SELECT Org.tbPayment.PaidOn AS StartOn, 0 As TaxDue, ( Org.tbPayment.PaidOutValue * -1) + Org.tbPayment.PaidInValue AS TaxPaid
		FROM Org.tbPayment 
			JOIN Cash.tbTaxType tt ON Org.tbPayment.CashCode = tt.CashCode
		WHERE (tt.TaxTypeCode = 0)

	), tax_statement AS
	(
		SELECT StartOn, TaxDue, TaxPaid,
			SUM(TaxDue + TaxPaid) OVER (ORDER BY StartOn, TaxDue ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Balance
		FROM tax_entries
	)
	SELECT StartOn, TaxDue, TaxPaid, Balance FROM tax_statement 
	WHERE StartOn >= (SELECT MIN(StartOn) FROM App.tbYearPeriod p JOIN App.tbYear y ON p.YearNumber = y.YearNumber  WHERE y.CashStatusCode < 3);
``` 

The Cash Codes associated with corporation tax are configured by the user. View *Cash.vwTaxCorpTotalsByPeriod* retrieves them from the recursive CTE view:

``` sql
CREATE OR ALTER VIEW App.vwCorpTaxCashCodes
AS
	WITH category_relations AS
	(
		SELECT Cash.tbCategoryTotal.ParentCode, Cash.tbCategoryTotal.ChildCode, Cash.tbCategory.CategoryTypeCode, Cash.tbCode.CashCode
		FROM  Cash.tbCategoryTotal 
			INNER JOIN Cash.tbCategory ON Cash.tbCategoryTotal.ChildCode = Cash.tbCategory.CategoryCode 
			LEFT OUTER JOIN Cash.tbCode ON Cash.tbCategory.CategoryCode = Cash.tbCode.CategoryCode
	), cashcode_candidates AS
	(
		SELECT     ChildCode, CashCode
		FROM category_relations
		WHERE     ( CategoryTypeCode = 1) AND ( ParentCode = (SELECT NetProfitCode FROM App.tbOptions))

		UNION ALL

		SELECT     category_relations.ChildCode, category_relations.CashCode
		FROM  category_relations JOIN cashcode_candidates ON category_relations.ParentCode = cashcode_candidates.ChildCode
	), cashcode_selected AS
	(
		SELECT CashCode FROM cashcode_candidates
		UNION
		SELECT CashCode FROM category_relations WHERE ParentCode = (SELECT NetProfitCode FROM App.tbOptions)
	)
	SELECT CashCode FROM cashcode_selected WHERE NOT CashCode IS NULL;
```


### Recursion

TC is a recursive application: Activities, Tasks and Cash Categories are its key components and they are all recursive. Organisations, in the pre-release versions of TC, were also expressed recursively, but this confused the users and was therefore replaced with the current simplified form. In CL 2000, recursion had to be expressed through a combination of self-calling procedures and cursors. Legacy procedures that use this technique can be obtained from the following code:

``` sql
WITH cms AS
(	
	SELECT 
		CONCAT(SCHEMA_NAME(o2.schema_id), '.', OBJECT_NAME(d.referenced_id)) AS referenced_object, 
		CONCAT(SCHEMA_NAME(o1.schema_id), '.', OBJECT_NAME(d.referencing_id)) AS referencing_object, o1.type AS referencing_type
	FROM sys.sql_expression_dependencies d
			JOIN sys.objects o1 ON d.referencing_id = o1.object_id
			JOIN sys.objects o2 ON d.referenced_id = o2.object_id		
	WHERE referenced_entity_name <> 'inserted' AND NOT referencing_id IS NULL 
)
SELECT DISTINCT referenced_object
FROM cms
WHERE referenced_object = referencing_object;
```
By way of example, *Task.proc_Delete*, with error handling removed, is written like this:

``` sql
CREATE OR ALTER PROCEDURE Task.proc_Delete (@TaskCode nvarchar(20))
AS
	DECLARE @ChildTaskCode nvarchar(20)

	IF @@NESTLEVEL = 1
		BEGIN TRANSACTION

	DELETE FROM Task.tbFlow
	WHERE     (ChildTaskCode = @TaskCode)

	DECLARE curFlow cursor local for
		SELECT     ChildTaskCode
		FROM         Task.tbFlow
		WHERE     (ParentTaskCode = @TaskCode)
	
	OPEN curFlow		
	FETCH NEXT FROM curFlow INTO @ChildTaskCode
	WHILE @@FETCH_STATUS = 0
		BEGIN
		EXEC Task.proc_Delete @ChildTaskCode
		FETCH NEXT FROM curFlow INTO @ChildTaskCode		
		END
	
	CLOSE curFlow
	DEALLOCATE curFlow
	
	DELETE FROM Task.tbTask
	WHERE (TaskCode = @TaskCode)
	
	IF @@NESTLEVEL = 1
		COMMIT TRANSACTION

```

It is identical to the CL 2000 version and is retained because there is enforced integrity checking on the work flow. To code this procedure using a CTE recursion equivalent would require something like the following code, where **UNION ALL** is the recursive operator:
``` sql
DECLARE @TaskCode nvarchar(20) = 'IM_10011';

	BEGIN TRANSACTION;

	DECLARE @Tasks TABLE (ParentTaskCode nvarchar(20), ChildTaskCode nvarchar(20));

	WITH task_flow AS
	(
		SELECT child.ParentTaskCode, child.ChildTaskCode
		FROM Task.tbFlow child 
		WHERE child.ParentTaskCode = @TaskCode
			UNION
		SELECT child.ParentTaskCode, child.ChildTaskCode
		FROM Task.tbFlow child 
		WHERE child.ChildTaskCode = @TaskCode

		UNION ALL

		SELECT child.ParentTaskCode, child.ChildTaskCode
		FROM Task.tbFlow child 
			JOIN task_flow parent ON child.ParentTaskCode = parent.ChildTaskCode
	)
	INSERT INTO @Tasks (ParentTaskCode, ChildTaskCode)
	SELECT  ParentTaskCode, ChildTaskCode
	FROM task_flow;

	DELETE tb
	FROM Task.tbFlow tb
		JOIN @Tasks flow ON tb.ParentTaskCode = flow.ParentTaskCode 
				AND tb.ChildTaskCode = flow.ChildTaskCode;

	WITH tasks AS
	(
		SELECT @TaskCode AS TaskCode
		UNION
		SELECT DISTINCT ChildTaskCode AS TaskCode FROM @Tasks
	)
	DELETE tb
	FROM Task.tbTask tb 
		JOIN tasks ON tb.TaskCode = tasks.TaskCode;
	
	COMMIT TRANSACTION;


```

### Identity Codes

All codes in TC are alpha-numeric, consisting of a unique User Id and an incremented number from **App.tbRegister**. Other than the user menus, there are no Identity seeds in the schema. This allows each user to operate inside an isolated environment. In theory, all users could take their own snapshot of the database, and for an indefinite period, go offline, process orders, enter expenses, payments and so forth. Their versions of the database could then be seamlessly synchronised; and because TC is a real-time system, the various Company and Tax Statements would be instantly revised. Similarly, two separate regional databases could encapsulate the functionality of a single node.

### Enumerated Types

To fulfil its purpose, the schema essentially models changes in state. Therefore, about a quarter of all the tables in the database serve as enumerated types and are not really a part of the schema design. An enumerated type table is used to translate a number into text that can be understood by the user. These tables will usually have the word Type or Status in them and take the format below.

SyncTypeCode | SyncType
-- | --
0 | SYNC
1 | ASYNC
2 | CALL-OFF

It is possible to write code that is more legible by joining the type tables to the enumeration and using the text (e.g SyncType = 'ASYNC'), but that approach is not used for reasons of efficiency and implementation.  The view *Cash.vwTaxCorpStatement* in the [section above](#ctes) contains an example (``WHERE (tt.TaxTypeCode = 0)``).  There may be a description [commented in](#Comments), but often not.

### Naming Convention

Object Type | Prefix
-- | --
Table | [schema].tb
View | [schema].vw
Procedure | [schema].proc_
Function | [schema].fn

Column names take the form *ColumnName* with no spaces. Boolean values can be prefixed with *Is*, such as IsOn. The table names of enumerated types use the *Code* suffix.

### Error Handling

Version 3 has a straight forward set of procedures to trap and log errors. These are inspired by [Sommarskog's tutorials](http://sommarskog.se/) on the subject.

Errors are written to the Event Log table, whith **EventTypeCode** set to ERROR.

``` sql
CREATE TABLE App.tbEventLog (
	LogCode nvarchar(20) NOT NULL,
	LoggedOn datetime NOT NULL CONSTRAINT DF_App_tbLog_LoggedOn  DEFAULT getdate(),
	EventTypeCode smallint NOT NULL  CONSTRAINT DF_App_tbLog_EventTypeCode  DEFAULT (2),
	EventMessage nvarchar(max) NULL,
	InsertedBy nvarchar(50) NOT NULL CONSTRAINT DF_App_tbLog_InsertedBy  DEFAULT suser_sname(),
	RowVer timestamp NOT NULL,
 CONSTRAINT PK_App_tbEventLog_LogCode PRIMARY KEY CLUSTERED 
(
	LogCode ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]


```

A general procedure is defined for adding any kind of event to the log file (of EventType Information, Warning or Error), by assigning a unique [Log Code](#Identity-Codes) from the register specified in **App.tbOptions**.

``` sql
CREATE OR ALTER PROCEDURE App.proc_EventLog (@EventMessage NVARCHAR(MAX), @EventTypeCode SMALLINT = 0, @LogCode NVARCHAR(20) = NULL OUTPUT)
AS
	SET XACT_ABORT, NOCOUNT ON;

	BEGIN TRY

		DECLARE 
			@UserId nvarchar(10)
			, @LogNumber INT
			, @RegisterName nvarchar(50) = (SELECT RegisterName FROM App.tbOptions);
	
		SET @UserId = (SELECT TOP 1 Usr.tbUser.UserId FROM Usr.vwCredentials c INNER JOIN
								Usr.tbUser ON c.UserId = Usr.tbUser.UserId);

		BEGIN TRANSACTION;
		
		WHILE (1 = 1)
			BEGIN
			SET @LogNumber = FORMAT((SELECT TOP 1 r.NextNumber
						FROM App.tbRegister r
						WHERE r.RegisterName = @RegisterName), '00000');
				
			UPDATE App.tbRegister
			SET NextNumber += 1
			WHERE RegisterName = @RegisterName;

			SET @LogCode = CONCAT(@UserId, @LogNumber);

			IF NOT EXISTS (SELECT * FROM App.tbEventLog WHERE LogCode = @LogCode)
				BREAK;
			END

		INSERT INTO App.tbEventLog (LogCode, EventTypeCode, EventMessage)
		VALUES (@LogCode, @EventTypeCode, @EventMessage);

		COMMIT TRANSACTION;

		RETURN;
					
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 
			ROLLBACK TRANSACTION;
		THROW;
	END CATCH
```

The code that traps the error rolls back any pending transactions, calls _App.proc_EventLog_ and then bubbles the error message:

``` sql
CREATE OR ALTER PROCEDURE App.proc_ErrorLog 
AS
DECLARE 
	@ErrorMessage NVARCHAR(MAX)
	, @ErrorSeverity TINYINT
	, @ErrorState TINYINT
	, @MessagePrefix nvarchar(4) = '*** ';
	
	IF @@TRANCOUNT > 0 
		ROLLBACK TRANSACTION;

	SET @ErrorSeverity = ERROR_SEVERITY();
	SET @ErrorState = ERROR_STATE();
	SET @ErrorMessage = ERROR_MESSAGE();

	IF @ErrorMessage NOT LIKE CONCAT(@MessagePrefix, '%')
		BEGIN
		SET @ErrorMessage = CONCAT(@MessagePrefix, ERROR_NUMBER(), ': ', QUOTENAME(ERROR_PROCEDURE()) + '.' + FORMAT(ERROR_LINE(), '0'),
			' Severity ', @ErrorSeverity, ', State ', @ErrorState, ' => ' + LEFT(ERROR_MESSAGE(), 1500));		

		EXEC App.proc_EventLog @ErrorMessage;
		END

	RAISERROR ('%s', @ErrorSeverity, @ErrorState, @ErrorMessage);
```

This method provides a standard template for error trapping throughout:

``` sql
CREATE OR ALTER PROCEDURE App.proc_Name
AS
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        declare @i int;
        --Code
    END TRY
    BEGIN CATCH
        EXEC App.proc_ErrorLog;
    END CATCH
```

For triggers, the **XACT_ABORT** setting is not required.

### Change Log

Tables that are not [Enumerated Types](#enumerated-types) have four additional columns that record when and who inserted or updated the record. The insert columns are set by the fields default.

``` sql
[InsertedBy] [nvarchar](50) NOT NULL CONSTRAINT DF_SchemaName_TableName_InsertedBy DEFAULT SUSER_SNAME(),
[InsertedOn] [datetime] NOT NULL CONSTRAINT DF_SchemaName_TableName_InsertedOn DEFAULT GETDATE(),
[UpdatedBy] [nvarchar](50) NOT NULL  CONSTRAINT DF_SchemaName_TableName_UpdatedBy DEFAULT SUSER_SNAME(),
[UpdatedOn] [datetime] NOT NULL CONSTRAINT DF_SchemaName_TableName_UpdatedOn DEFAULT GETDATE(),

``` 

Updates are set inside the table triggers:

``` sql
CREATE OR ALTER TRIGGER Activity.Activity_tbActivity_TriggerUpdate
   ON  Activity.tbActivity
   AFTER UPDATE, INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY	
		IF EXISTS (SELECT * FROM inserted i WHERE App.fnParsePrimaryKey(ActivityCode) = 0)
			BEGIN
			DECLARE @Msg NVARCHAR(MAX);
			SELECT @Msg = Message FROM App.tbText WHERE TextId = 2004;
			RAISERROR (@Msg, 10, 1)
			ROLLBACK
			END
		ELSE
			BEGIN
			UPDATE Activity.tbActivity
			SET UpdatedBy = SUSER_SNAME(), UpdatedOn = CURRENT_TIMESTAMP
			FROM Activity.tbActivity INNER JOIN inserted AS i ON tbActivity.ActivityCode = i.ActivityCode;
			END
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH
END
```

### Azure

As shown in the **tbEventLog** creation statement above, all tables that are not Type Tables, have a field called ``RowVer timestamp NOT NULL`` added to their definition. This gives Azure Sql the version of the row when it is returned following an update, preventing it from being rejected. None Azure versions of Sql Server do not need this field, but it is harmless.

### Comments

Trade Control has been developed by a single author who does not like comments cluttering up the code.  Currently, comments are only used as reminders and requests for change. Coding, however, does strive to be self-documenting.

## Licence

The Trade Control Code licence is issued by Trade Control Ltd under a [GNU General Public Licence v3.0](https://www.gnu.org/licenses/gpl-3.0.en.html) 

Trade Control Documentation by Trade Control Ltd is licenced under a [Creative Commons Attribution-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-sa/4.0/) 

![Creative Commons](https://i.creativecommons.org/l/by-sa/4.0/88x31.png) 
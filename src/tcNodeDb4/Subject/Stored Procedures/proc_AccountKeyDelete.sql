﻿CREATE   PROCEDURE Subject.proc_AccountKeyDelete(@CashAccountCode nvarchar(10), @KeyName nvarchar(50))
AS
	SET NOCOUNT, XACT_ABORT OFF;

	BEGIN TRY	

		WITH root_level AS
		(
			SELECT CashAccountCode, CAST(NULL as hierarchyid) Ancestor, HDPath, HDPath.GetLevel() Lv
			FROM Subject.tbAccountKey 
			WHERE CashAccountCode = @CashAccountCode AND KeyName = @KeyName
		), candidates AS
		(
			SELECT ns.CashAccountCode, ns.HDPath.GetAncestor(1) Ancestor, ns.HDPath, ns.HDPath.GetLevel() Lv
			FROM Subject.tbAccountKey ns 
				JOIN root_level ON ns.CashAccountCode = root_level.CashAccountCode
			WHERE ns.HDPath.GetLevel() > root_level.Lv
		), selected AS
		(
			SELECT CashAccountCode, Ancestor, HDPath FROM root_level
		
			UNION ALL

			SELECT candidates.CashAccountCode, candidates.Ancestor, candidates.HDPath
			FROM candidates
				JOIN selected ON selected.HDPath = candidates.Ancestor
		)
		DELETE Subject.tbAccountKey
		FROM selected
			JOIN Subject.tbAccountKey ON Subject.tbAccountKey.CashAccountCode = selected.CashAccountCode AND Subject.tbAccountKey.HDPath = selected.HDPath;

	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH

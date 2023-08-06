﻿CREATE   PROCEDURE Subject.proc_WalletInitialise
AS
	SET NOCOUNT, XACT_ABORT OFF;

	BEGIN TRY
		WITH wallets AS
		(
			SELECT wallet.CashAccountCode
			FROM Subject.vwWallets AS wallet 
				LEFT OUTER JOIN Subject.tbAccountKey AS nspace ON wallet.CashAccountCode = nspace.CashAccountCode
			WHERE        (nspace.CashAccountCode IS NULL)
		), hdrootName AS
		(
			SELECT AccountName KeyName
			FROM Subject.tbSubject Subjects
				JOIN App.tbOptions opts ON opts.AccountCode = Subjects.AccountCode
		)
		INSERT INTO Subject.tbAccountKey (CashAccountCode, HDPath, KeyName)
		SELECT CashAccountCode, '/' HDPath, (SELECT KeyName FROM hdrootName) KeyName
		FROM wallets;
	END TRY
	BEGIN CATCH
		EXEC App.proc_ErrorLog;
	END CATCH

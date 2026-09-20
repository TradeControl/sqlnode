/*
    DP5 synthetic statutory-context provisioning.
    This wrapper is restricted to the fixed Tax Hub sandbox catalogue. The
    population itself belongs to the normal synthetic-dataset implementation.
*/
SET NOCOUNT, XACT_ABORT ON;

IF DB_NAME() NOT IN
(
    N'tcNodeDb4-COMIPFVT1-COMIN26', N'tcNodeDb4-COSIPFVT1-COSTD26',
    N'tcNodeDb4-STMIPFVT1-STMIN26', N'tcNodeDb4-STSIPFVT1-STSTD26'
)
    THROW 51070, 'DP5 provisioning is restricted to the named Tax Hub sandboxes.', 1;

BEGIN TRAN PhaseDP5Provision;
BEGIN TRY
    EXEC App.proc_DatasetSyntheticMIS_StatutoryProfile
        @AsOfDate = CONVERT(date, '20250406');

    COMMIT TRAN PhaseDP5Provision;
    PRINT 'DP5 synthetic statutory context provisioned.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRAN PhaseDP5Provision;
    THROW;
END CATCH;

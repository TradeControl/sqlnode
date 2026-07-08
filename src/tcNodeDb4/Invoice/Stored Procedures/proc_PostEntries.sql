CREATE PROCEDURE Invoice.proc_PostEntries
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    DECLARE @UserId nvarchar(10);

    SELECT @UserId = UserId
    FROM Usr.vwCredentials;

    EXEC Invoice.proc_PostEntriesByUserId @UserId;
END

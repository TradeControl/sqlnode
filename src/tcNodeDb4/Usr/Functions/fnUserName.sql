CREATE FUNCTION Usr.fnUserName()
RETURNS nvarchar(50)
AS
BEGIN
	DECLARE @UserName nvarchar(50) =
		(SELECT TOP (1) UserName FROM Usr.vwCredentials);

	-- Bootstrap and controlled commissioning can run before an application user exists.
	-- Once credentials resolve, descriptive audit fields use the application UserName.
	RETURN COALESCE(@UserName, LEFT(SUSER_SNAME(), 50));
END

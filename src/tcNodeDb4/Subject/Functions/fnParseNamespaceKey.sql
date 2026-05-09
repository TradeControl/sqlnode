CREATE FUNCTION [Subject].[fnParseNamespaceKey]
(
    @NamespaceKey NVARCHAR(50)
)
RETURNS BIT
AS
BEGIN
    DECLARE @ParseOk BIT = 0;
    DECLARE @Value NVARCHAR(50) = ISNULL(@NamespaceKey, N'');
    DECLARE @Trimmed NVARCHAR(50) = LTRIM(RTRIM(@Value));

    SET @ParseOk = CASE
        WHEN LEN(@Trimmed) = 0 THEN 0
        WHEN LEN(@Trimmed) <> LEN(@Value) THEN 0
        WHEN CHARINDEX(N'.', @Trimmed) > 0 THEN 0
        WHEN LEFT(@Trimmed, 1) LIKE N'[0-9]' THEN 0
        WHEN LEFT(@Trimmed, 1) NOT LIKE N'[A-Za-z_]' THEN 0
        WHEN @Trimmed LIKE N'%[^0-9A-Za-z_]%' THEN 0
        ELSE 1
    END;

    RETURN @ParseOk;
END
GO

CREATE PROCEDURE [Cash].[proc_CategoryVersionIdNext]
    @VersionId NVARCHAR(10) OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    DECLARE @SequenceValue BIGINT = NEXT VALUE FOR [Cash].[seqCategoryVersion];

    SET @VersionId = CONCAT
    (
        N'CV',
        RIGHT(REPLICATE(N'0', 8) + CONVERT(NVARCHAR(8), @SequenceValue), 8)
    );

    IF EXISTS
    (
        SELECT 1
        FROM [Cash].[tbCategoryVersion]
        WHERE [VersionId] = @VersionId
    )
        THROW 51060, 'The allocated Category Tree version identifier already exists.', 1;
END;

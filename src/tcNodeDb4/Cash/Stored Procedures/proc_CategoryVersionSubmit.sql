CREATE PROCEDURE [Cash].[proc_CategoryVersionSubmit]
(
    @VersionId NVARCHAR(10),
    @ChangeNote NVARCHAR(MAX)
)
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    THROW 51188, 'Category Tree submission is completed only by a sealed statutory workflow.', 1;
END;

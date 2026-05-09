CREATE PROCEDURE Subject.proc_AddParentPreview
(
    @ParentSubjectCode nvarchar(50),
    @ChildSubjectCode nvarchar(50)
)
AS
SET NOCOUNT, XACT_ABORT ON;

BEGIN TRY
    DECLARE
        @ActionCode smallint = 0,
        @CanProceed bit = 0,
        @Message nvarchar(4000) = N'Add parent is blocked.';

    IF NULLIF(LTRIM(RTRIM(@ParentSubjectCode)), N'') IS NULL
       OR NULLIF(LTRIM(RTRIM(@ChildSubjectCode)), N'') IS NULL
    BEGIN
        SET @Message = N'ParentSubjectCode and ChildSubjectCode are required.';
        SELECT
            @ActionCode AS ActionCode,
            @CanProceed AS CanProceed,
            @Message AS Message,
            @ParentSubjectCode AS ParentSubjectCode,
            @ChildSubjectCode AS ChildSubjectCode;
        RETURN;
    END

    IF @ParentSubjectCode = @ChildSubjectCode
    BEGIN
        SET @Message = N'A Subject cannot be added under itself.';
        SELECT
            @ActionCode AS ActionCode,
            @CanProceed AS CanProceed,
            @Message AS Message,
            @ParentSubjectCode AS ParentSubjectCode,
            @ChildSubjectCode AS ChildSubjectCode;
        RETURN;
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM Subject.tbSubject
        WHERE SubjectCode = @ParentSubjectCode
    )
    BEGIN
        SET @Message = N'The target parent Subject was not found.';
        SELECT
            @ActionCode AS ActionCode,
            @CanProceed AS CanProceed,
            @Message AS Message,
            @ParentSubjectCode AS ParentSubjectCode,
            @ChildSubjectCode AS ChildSubjectCode;
        RETURN;
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM Subject.tbSubject
        WHERE SubjectCode = @ChildSubjectCode
    )
    BEGIN
        SET @Message = N'The child Subject was not found.';
        SELECT
            @ActionCode AS ActionCode,
            @CanProceed AS CanProceed,
            @Message AS Message,
            @ParentSubjectCode AS ParentSubjectCode,
            @ChildSubjectCode AS ChildSubjectCode;
        RETURN;
    END

    IF EXISTS
    (
        SELECT 1
        FROM Subject.tbNamespace
        WHERE ParentSubjectCode = @ParentSubjectCode
          AND ChildSubjectCode = @ChildSubjectCode
    )
    BEGIN
        SET @Message = N'The Subject is already related to the selected parent.';
        SELECT
            @ActionCode AS ActionCode,
            @CanProceed AS CanProceed,
            @Message AS Message,
            @ParentSubjectCode AS ParentSubjectCode,
            @ChildSubjectCode AS ChildSubjectCode;
        RETURN;
    END

    DECLARE @Descendants TABLE
    (
        SubjectCode nvarchar(50) NOT NULL PRIMARY KEY
    );

    ;WITH Descendants AS
    (
        SELECT @ChildSubjectCode AS SubjectCode

        UNION ALL

        SELECT n.ChildSubjectCode
        FROM Subject.tbNamespace AS n
        INNER JOIN Descendants AS d
            ON n.ParentSubjectCode = d.SubjectCode
    )
    INSERT INTO @Descendants (SubjectCode)
    SELECT SubjectCode
    FROM Descendants
    GROUP BY SubjectCode
    OPTION (MAXRECURSION 32767);

    IF EXISTS
    (
        SELECT 1
        FROM @Descendants
        WHERE SubjectCode = @ParentSubjectCode
    )
    BEGIN
        SET @Message = N'The add would create a namespace cycle.';
        SELECT
            @ActionCode AS ActionCode,
            @CanProceed AS CanProceed,
            @Message AS Message,
            @ParentSubjectCode AS ParentSubjectCode,
            @ChildSubjectCode AS ChildSubjectCode;
        RETURN;
    END

    SET @ActionCode = 4;
    SET @CanProceed = 1;
    SET @Message = N'This will add the Subject to the selected namespace.';

    SELECT
        @ActionCode AS ActionCode,
        @CanProceed AS CanProceed,
        @Message AS Message,
        @ParentSubjectCode AS ParentSubjectCode,
        @ChildSubjectCode AS ChildSubjectCode;
END TRY
BEGIN CATCH
    DECLARE @ErrorMessage nvarchar(4000) = ERROR_MESSAGE();
    EXEC App.proc_ErrorLog;

    SELECT
        CAST(0 AS smallint) AS ActionCode,
        CAST(0 AS bit) AS CanProceed,
        @ErrorMessage AS Message,
        @ParentSubjectCode AS ParentSubjectCode,
        @ChildSubjectCode AS ChildSubjectCode;
END CATCH
GO

CREATE PROCEDURE Subject.proc_Reparent
(
    @OldParentSubjectCode nvarchar(50),
    @ChildSubjectCode nvarchar(50),
    @NewParentSubjectCode nvarchar(50)
)
AS
SET NOCOUNT, XACT_ABORT ON;

BEGIN TRY
    DECLARE
        @ActionCode smallint = 0,
        @CanProceed bit = 0,
        @Message nvarchar(4000) = N'Reparent is blocked.',
        @RemovedWasDefault bit = 0,
        @NewOrdinal int = 0,
        @NewIsDefault bit = 0;

    IF NULLIF(LTRIM(RTRIM(@OldParentSubjectCode)), N'') IS NULL
       OR NULLIF(LTRIM(RTRIM(@ChildSubjectCode)), N'') IS NULL
       OR NULLIF(LTRIM(RTRIM(@NewParentSubjectCode)), N'') IS NULL
    BEGIN
        SET @Message = N'OldParentSubjectCode, ChildSubjectCode, and NewParentSubjectCode are required.';
        SELECT
            @ActionCode AS ActionCode,
            @CanProceed AS CanProceed,
            @Message AS Message,
            @OldParentSubjectCode AS OldParentSubjectCode,
            @NewParentSubjectCode AS NewParentSubjectCode,
            @ChildSubjectCode AS ChildSubjectCode;
        RETURN;
    END

    IF @OldParentSubjectCode = @NewParentSubjectCode
    BEGIN
        SET @Message = N'The new parent is the same as the current parent.';
        SELECT
            @ActionCode AS ActionCode,
            @CanProceed AS CanProceed,
            @Message AS Message,
            @OldParentSubjectCode AS OldParentSubjectCode,
            @NewParentSubjectCode AS NewParentSubjectCode,
            @ChildSubjectCode AS ChildSubjectCode;
        RETURN;
    END

    IF @ChildSubjectCode = @NewParentSubjectCode
    BEGIN
        SET @Message = N'A Subject cannot be moved under itself.';
        SELECT
            @ActionCode AS ActionCode,
            @CanProceed AS CanProceed,
            @Message AS Message,
            @OldParentSubjectCode AS OldParentSubjectCode,
            @NewParentSubjectCode AS NewParentSubjectCode,
            @ChildSubjectCode AS ChildSubjectCode;
        RETURN;
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM Subject.tbNamespace
        WHERE ParentSubjectCode = @OldParentSubjectCode
          AND ChildSubjectCode = @ChildSubjectCode
    )
    BEGIN
        SET @Message = N'The current namespace relationship was not found.';
        SELECT
            @ActionCode AS ActionCode,
            @CanProceed AS CanProceed,
            @Message AS Message,
            @OldParentSubjectCode AS OldParentSubjectCode,
            @NewParentSubjectCode AS NewParentSubjectCode,
            @ChildSubjectCode AS ChildSubjectCode;
        RETURN;
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM Subject.tbSubject
        WHERE SubjectCode = @NewParentSubjectCode
    )
    BEGIN
        SET @Message = N'The target parent Subject was not found.';
        SELECT
            @ActionCode AS ActionCode,
            @CanProceed AS CanProceed,
            @Message AS Message,
            @OldParentSubjectCode AS OldParentSubjectCode,
            @NewParentSubjectCode AS NewParentSubjectCode,
            @ChildSubjectCode AS ChildSubjectCode;
        RETURN;
    END

    IF EXISTS
    (
        SELECT 1
        FROM Subject.tbNamespace
        WHERE ParentSubjectCode = @NewParentSubjectCode
          AND ChildSubjectCode = @ChildSubjectCode
    )
    BEGIN
        SET @Message = N'The Subject is already related to the target parent.';
        SELECT
            @ActionCode AS ActionCode,
            @CanProceed AS CanProceed,
            @Message AS Message,
            @OldParentSubjectCode AS OldParentSubjectCode,
            @NewParentSubjectCode AS NewParentSubjectCode,
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
        WHERE SubjectCode = @NewParentSubjectCode
    )
    BEGIN
        SET @Message = N'The move would create a namespace cycle.';
        SELECT
            @ActionCode AS ActionCode,
            @CanProceed AS CanProceed,
            @Message AS Message,
            @OldParentSubjectCode AS OldParentSubjectCode,
            @NewParentSubjectCode AS NewParentSubjectCode,
            @ChildSubjectCode AS ChildSubjectCode;
        RETURN;
    END

    BEGIN TRANSACTION;

    SELECT @RemovedWasDefault = IsDefault
    FROM Subject.tbNamespace
    WHERE ParentSubjectCode = @OldParentSubjectCode
      AND ChildSubjectCode = @ChildSubjectCode;

    DELETE
    FROM Subject.tbNamespace
    WHERE ParentSubjectCode = @OldParentSubjectCode
      AND ChildSubjectCode = @ChildSubjectCode;

    IF @RemovedWasDefault <> 0
    BEGIN
        ;WITH Replacement AS
        (
            SELECT TOP (1)
                ParentSubjectCode,
                ChildSubjectCode
            FROM Subject.tbNamespace
            WHERE ParentSubjectCode = @OldParentSubjectCode
            ORDER BY Ordinal, ChildSubjectCode
        )
        UPDATE n
        SET IsDefault = 1
        FROM Subject.tbNamespace AS n
        INNER JOIN Replacement AS r
            ON r.ParentSubjectCode = n.ParentSubjectCode
           AND r.ChildSubjectCode = n.ChildSubjectCode;
    END

    SELECT @NewOrdinal = ISNULL(MAX(Ordinal), 0) + 1
    FROM Subject.tbNamespace
    WHERE ParentSubjectCode = @NewParentSubjectCode;

    SET @NewIsDefault = CASE
        WHEN EXISTS
        (
            SELECT 1
            FROM Subject.tbNamespace
            WHERE ParentSubjectCode = @NewParentSubjectCode
        ) THEN 0
        ELSE 1
    END;

    INSERT INTO Subject.tbNamespace
    (
        ParentSubjectCode,
        ChildSubjectCode,
        Ordinal,
        IsDefault
    )
    VALUES
    (
        @NewParentSubjectCode,
        @ChildSubjectCode,
        @NewOrdinal,
        @NewIsDefault
    );

    COMMIT TRANSACTION;

    SET @ActionCode = 3;
    SET @CanProceed = 1;
    SET @Message = N'Namespace relationship moved.';

    SELECT
        @ActionCode AS ActionCode,
        @CanProceed AS CanProceed,
        @Message AS Message,
        @OldParentSubjectCode AS OldParentSubjectCode,
        @NewParentSubjectCode AS NewParentSubjectCode,
        @ChildSubjectCode AS ChildSubjectCode;
END TRY
BEGIN CATCH
    DECLARE @ErrorMessage nvarchar(4000) = ERROR_MESSAGE();
    EXEC App.proc_ErrorLog;

    SELECT
        CAST(0 AS smallint) AS ActionCode,
        CAST(0 AS bit) AS CanProceed,
        @ErrorMessage AS Message,
        @OldParentSubjectCode AS OldParentSubjectCode,
        @NewParentSubjectCode AS NewParentSubjectCode,
        @ChildSubjectCode AS ChildSubjectCode;
END CATCH
GO

CREATE PROCEDURE Subject.proc_RemoveNamespace
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
        @Message nvarchar(4000) = N'Namespace removal is blocked.',
        @HasOtherParents bit = 0,
        @AffectedSubjectCount int = 0,
        @InvoiceCount int = 0,
        @PaymentCount int = 0,
        @ProjectCount int = 0,
        @RemovedWasDefault bit = 0;

    IF NULLIF(LTRIM(RTRIM(@ParentSubjectCode)), N'') IS NULL
       OR NULLIF(LTRIM(RTRIM(@ChildSubjectCode)), N'') IS NULL
    BEGIN
        SET @Message = N'ParentSubjectCode and ChildSubjectCode are required.';
        SELECT
            @ActionCode AS ActionCode,
            @CanProceed AS CanProceed,
            @Message AS Message,
            @HasOtherParents AS HasOtherParents,
            @AffectedSubjectCount AS AffectedSubjectCount,
            @InvoiceCount AS InvoiceCount,
            @PaymentCount AS PaymentCount,
            @ProjectCount AS ProjectCount;
        RETURN;
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM Subject.tbNamespace
        WHERE ParentSubjectCode = @ParentSubjectCode
          AND ChildSubjectCode = @ChildSubjectCode
    )
    BEGIN
        SET @Message = N'The selected namespace relationship was not found.';
        SELECT
            @ActionCode AS ActionCode,
            @CanProceed AS CanProceed,
            @Message AS Message,
            @HasOtherParents AS HasOtherParents,
            @AffectedSubjectCount AS AffectedSubjectCount,
            @InvoiceCount AS InvoiceCount,
            @PaymentCount AS PaymentCount,
            @ProjectCount AS ProjectCount;
        RETURN;
    END

    IF EXISTS
    (
        SELECT 1
        FROM Subject.tbNamespace
        WHERE ChildSubjectCode = @ChildSubjectCode
          AND ParentSubjectCode <> @ParentSubjectCode
    )
    BEGIN
        SET @ActionCode = 1;
        SET @CanProceed = 1;
        SET @HasOtherParents = 1;
        SET @AffectedSubjectCount = 1;
    END
    ELSE
    BEGIN
        DECLARE @DetachedClosure TABLE
        (
            SubjectCode nvarchar(50) NOT NULL PRIMARY KEY
        );

        ;WITH Subtree AS
        (
            SELECT @ChildSubjectCode AS SubjectCode

            UNION ALL

            SELECT n.ChildSubjectCode
            FROM Subject.tbNamespace AS n
            INNER JOIN Subtree AS s
                ON n.ParentSubjectCode = s.SubjectCode
        )
        INSERT INTO @DetachedClosure (SubjectCode)
        SELECT SubjectCode
        FROM Subtree
        GROUP BY SubjectCode
        OPTION (MAXRECURSION 32767);

        SELECT @AffectedSubjectCount = COUNT(*)
        FROM @DetachedClosure;

        IF EXISTS
        (
            SELECT 1
            FROM Subject.tbNamespace AS n
            INNER JOIN @DetachedClosure AS c
                ON c.SubjectCode = n.ChildSubjectCode
            WHERE NOT EXISTS
            (
                SELECT 1
                FROM @DetachedClosure AS p
                WHERE p.SubjectCode = n.ParentSubjectCode
            )
              AND NOT
              (
                  n.ParentSubjectCode = @ParentSubjectCode
                  AND n.ChildSubjectCode = @ChildSubjectCode
              )
        )
        BEGIN
            SET @Message = N'The detached closure still has namespace links outside the selected branch and cannot be deleted by this operation.';

            SELECT
                @ActionCode AS ActionCode,
                @CanProceed AS CanProceed,
                @Message AS Message,
                @HasOtherParents AS HasOtherParents,
                @AffectedSubjectCount AS AffectedSubjectCount,
                @InvoiceCount AS InvoiceCount,
                @PaymentCount AS PaymentCount,
                @ProjectCount AS ProjectCount;
            RETURN;
        END

        SELECT @InvoiceCount = COUNT(*)
        FROM Invoice.tbInvoice AS i
        INNER JOIN @DetachedClosure AS c
            ON c.SubjectCode = i.SubjectCode;

        SELECT @PaymentCount = COUNT(*)
        FROM Cash.tbPayment AS p
        INNER JOIN @DetachedClosure AS c
            ON c.SubjectCode = p.SubjectCode;

        SELECT @ProjectCount = COUNT(*)
        FROM Project.tbProject AS p
        INNER JOIN @DetachedClosure AS c
            ON c.SubjectCode = p.SubjectCode;

        IF (@InvoiceCount + @PaymentCount + @ProjectCount) > 0
        BEGIN
            SET @Message = CONCAT(
                N'The detached closure contains transactions and cannot be deleted. ',
                N'Invoices: ', @InvoiceCount, N', ',
                N'Payments: ', @PaymentCount, N', ',
                N'Projects: ', @ProjectCount, N'.');

            SELECT
                @ActionCode AS ActionCode,
                @CanProceed AS CanProceed,
                @Message AS Message,
                @HasOtherParents AS HasOtherParents,
                @AffectedSubjectCount AS AffectedSubjectCount,
                @InvoiceCount AS InvoiceCount,
                @PaymentCount AS PaymentCount,
                @ProjectCount AS ProjectCount;
            RETURN;
        END

        SET @ActionCode = 2;
        SET @CanProceed = 1;

        BEGIN TRANSACTION;

        DELETE s
        FROM Subject.tbSubject AS s
        INNER JOIN @DetachedClosure AS c
            ON c.SubjectCode = s.SubjectCode;

        COMMIT TRANSACTION;

        SET @Message = CASE
            WHEN @AffectedSubjectCount = 1
                THEN N'The detached Subject was deleted.'
            ELSE CONCAT(N'The detached closure of ', @AffectedSubjectCount, N' Subjects was deleted.')
        END;

        SELECT
            @ActionCode AS ActionCode,
            @CanProceed AS CanProceed,
            @Message AS Message,
            @HasOtherParents AS HasOtherParents,
            @AffectedSubjectCount AS AffectedSubjectCount,
            @InvoiceCount AS InvoiceCount,
            @PaymentCount AS PaymentCount,
            @ProjectCount AS ProjectCount;
        RETURN;
    END

    IF @ActionCode = 1
    BEGIN
        SELECT @RemovedWasDefault = IsDefault
        FROM Subject.tbNamespace
        WHERE ParentSubjectCode = @ParentSubjectCode
          AND ChildSubjectCode = @ChildSubjectCode;

        BEGIN TRANSACTION;

        DELETE
        FROM Subject.tbNamespace
        WHERE ParentSubjectCode = @ParentSubjectCode
          AND ChildSubjectCode = @ChildSubjectCode;

        IF @RemovedWasDefault <> 0
        BEGIN
            ;WITH Replacement AS
            (
                SELECT TOP (1)
                    ParentSubjectCode,
                    ChildSubjectCode
                FROM Subject.tbNamespace
                WHERE ParentSubjectCode = @ParentSubjectCode
                ORDER BY Ordinal, ChildSubjectCode
            )
            UPDATE n
            SET IsDefault = 1
            FROM Subject.tbNamespace AS n
            INNER JOIN Replacement AS r
                ON r.ParentSubjectCode = n.ParentSubjectCode
               AND r.ChildSubjectCode = n.ChildSubjectCode;
        END

        COMMIT TRANSACTION;

        SET @Message = N'Namespace relationship removed.';

        SELECT
            @ActionCode AS ActionCode,
            @CanProceed AS CanProceed,
            @Message AS Message,
            @HasOtherParents AS HasOtherParents,
            @AffectedSubjectCount AS AffectedSubjectCount,
            @InvoiceCount AS InvoiceCount,
            @PaymentCount AS PaymentCount,
            @ProjectCount AS ProjectCount;
        RETURN;
    END

    SELECT
        @ActionCode AS ActionCode,
        @CanProceed AS CanProceed,
        @Message AS Message,
        @HasOtherParents AS HasOtherParents,
        @AffectedSubjectCount AS AffectedSubjectCount,
        @InvoiceCount AS InvoiceCount,
        @PaymentCount AS PaymentCount,
        @ProjectCount AS ProjectCount;
END TRY
BEGIN CATCH
    DECLARE @ErrorMessage nvarchar(4000) = ERROR_MESSAGE();
    EXEC App.proc_ErrorLog;

    SELECT
        CAST(0 AS smallint) AS ActionCode,
        CAST(0 AS bit) AS CanProceed,
        @ErrorMessage AS Message,
        CAST(0 AS bit) AS HasOtherParents,
        CAST(0 AS int) AS AffectedSubjectCount,
        CAST(0 AS int) AS InvoiceCount,
        CAST(0 AS int) AS PaymentCount,
        CAST(0 AS int) AS ProjectCount;
END CATCH
GO

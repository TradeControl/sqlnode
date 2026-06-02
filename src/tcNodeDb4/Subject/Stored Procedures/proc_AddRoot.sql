CREATE PROCEDURE Subject.proc_AddRoot
	(
	@SubjectName nvarchar(100),
    @SubjectTypeCode smallint,
    @SubjectCode nvarchar(50) OUTPUT
	)
AS
SET NOCOUNT, XACT_ABORT ON;

BEGIN TRY

	IF NULLIF(LTRIM(RTRIM(@SubjectName)), N'') IS NULL
		RAISERROR ('SubjectName is required.', 16, 1);

	IF EXISTS
	(
		SELECT 1
		FROM Subject.tbSubject AS s
		LEFT OUTER JOIN Subject.tbNamespace AS n
			ON s.SubjectCode = n.ChildSubjectCode
		WHERE n.ChildSubjectCode IS NULL
			AND s.SubjectName = @SubjectName
	)
	BEGIN
		SELECT TOP (1) @SubjectCode = s.SubjectCode
		FROM Subject.tbSubject AS s
		LEFT OUTER JOIN Subject.tbNamespace AS n
			ON s.SubjectCode = n.ChildSubjectCode
		WHERE n.ChildSubjectCode IS NULL
			AND s.SubjectName = @SubjectName
		ORDER BY s.SubjectCode;

		RETURN;
	END

	DECLARE
		@CheckSql nvarchar(max),
        @SubjectClassCode smallint;

    SELECT @SubjectClassCode = SubjectClassCode
    FROM Subject.tbType
    WHERE SubjectTypeCode = @SubjectTypeCode;

    IF @SubjectClassCode IS NULL
		RAISERROR ('SubjectTypeCode was not found.', 16, 1);

	SET @CheckSql = N'SELECT @cnt = COUNT(*) FROM Subject.tbSubject WHERE SubjectCode = @Code;';

	EXEC App.proc_DefaultCodeGenerator
		@Description = @SubjectName,
		@CheckSql = @CheckSql,
        @UseWholeWords = 1,
		@Code = @SubjectCode OUTPUT;

	IF LEN(ISNULL(@SubjectCode, N'')) = 0
		RAISERROR ('Unable to generate a SubjectCode.', 16, 1);

	BEGIN TRANSACTION;

	INSERT INTO Subject.tbSubject
	(
		SubjectCode,
		SubjectName,
		SubjectTypeCode
	)
	VALUES
	(
		@SubjectCode,
		@SubjectName,
		@SubjectTypeCode
	);

    IF @SubjectClassCode = 0
    BEGIN
        INSERT INTO Subject.tbVirtual (SubjectCode)
        VALUES (@SubjectCode);
    END
    ELSE IF @SubjectClassCode = 1
    BEGIN
        INSERT INTO Subject.tbReal (SubjectCode)
        VALUES (@SubjectCode);
    END
    ELSE IF @SubjectClassCode = 2
    BEGIN
        INSERT INTO Subject.tbStructural (SubjectCode)
        VALUES (@SubjectCode);
    END
    ELSE
    BEGIN
		RAISERROR ('Unsupported SubjectClassCode.', 16, 1);
    END

	COMMIT TRANSACTION;

END TRY
BEGIN CATCH
	EXEC App.proc_ErrorLog;
END CATCH
GO

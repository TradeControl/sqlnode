CREATE FUNCTION [App].[fnIdentifierMask]
(
    @Identifier NVARCHAR(255),
    @VisibleSuffixLength SMALLINT
)
RETURNS NVARCHAR(255)
AS
BEGIN
    IF @Identifier IS NULL RETURN NULL;

    DECLARE @Length INT = LEN(@Identifier);
    DECLARE @SuffixLength INT =
        CASE
            WHEN @VisibleSuffixLength < 0 THEN 0
            WHEN @VisibleSuffixLength > @Length THEN @Length
            ELSE @VisibleSuffixLength
        END;

    RETURN REPLICATE(N'*', @Length - @SuffixLength)
        + RIGHT(@Identifier, @SuffixLength);
END;

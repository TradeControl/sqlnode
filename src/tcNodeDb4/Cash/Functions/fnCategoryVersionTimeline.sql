CREATE FUNCTION Cash.fnCategoryVersionTimeline()
RETURNS TABLE
AS
RETURN
(
    SELECT
        VersionId,
        EffectiveFromOn,
        EffectiveToOn
    FROM Cash.tbCategoryVersion
    WHERE VersionStatusCode IN (1, 2, 3)
      AND EffectiveFromOn IS NOT NULL
);

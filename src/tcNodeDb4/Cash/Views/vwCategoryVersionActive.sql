CREATE VIEW [Cash].[vwCategoryVersionActive]
AS
SELECT
    version.VersionId,
    version.VersionStatusCode,
    version.Description,
    version.Notes,
    version.PredecessorVersionId,
    version.BaseContentSha256,
    version.CanonicalProfile,
    version.CanonicalSha256,
    version.CanonicalByteLength,
    version.ContentChangedOn,
    version.EffectiveFromOn,
    version.EffectiveToOn,
    version.CreatedOn,
    version.CreatedByUserId,
    version.RowVer
FROM App.tbOptions AS options
JOIN Cash.tbCategoryVersion AS version
  ON version.VersionId = options.CategoryVersionId;

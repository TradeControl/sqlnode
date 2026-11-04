CREATE FUNCTION Cash.fnCategoryVersionResolve
(
    @CategoryVersionId nvarchar(10)
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        active.VersionId AS ActiveVersionId,
        active.Description AS ActiveDescription,
        active.VersionStatusCode AS ActiveStatusCode,
        active_status.VersionStatus AS ActiveStatus,
        active.EffectiveFromOn AS ActiveEffectiveFromOn,
        active.EffectiveToOn AS ActiveEffectiveToOn,
        active.ContentChangedOn AS ActiveContentChangedOn,
        CONVERT(varchar(64), active.CanonicalSha256, 2) AS ActiveCanonicalSha256,
        active.CanonicalByteLength AS ActiveCanonicalByteLength,
        selected.VersionId AS SelectedVersionId,
        selected.Description AS SelectedDescription,
        selected.VersionStatusCode AS SelectedStatusCode,
        selected_status.VersionStatus AS SelectedStatus,
        selected.EffectiveFromOn AS SelectedEffectiveFromOn,
        selected.EffectiveToOn AS SelectedEffectiveToOn,
        selected.ContentChangedOn AS SelectedContentChangedOn,
        CONVERT(varchar(64), selected.CanonicalSha256, 2) AS SelectedCanonicalSha256,
        selected.CanonicalByteLength AS SelectedCanonicalByteLength
    FROM App.tbOptions AS options
    JOIN Cash.tbCategoryVersion AS active
      ON active.VersionId = options.CategoryVersionId
    JOIN Cash.tbCategoryVersionStatus AS active_status
      ON active_status.VersionStatusCode = active.VersionStatusCode
    LEFT JOIN Cash.tbCategoryVersion AS selected
      ON selected.VersionId = COALESCE(NULLIF(@CategoryVersionId, N''), options.CategoryVersionId)
    LEFT JOIN Cash.tbCategoryVersionStatus AS selected_status
      ON selected_status.VersionStatusCode = selected.VersionStatusCode
);

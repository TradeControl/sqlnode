CREATE VIEW [Subject].[vwStatutoryIdentity]
AS
    SELECT *
    FROM Subject.fnStatutoryIdentity(CONVERT(date, getdate()));

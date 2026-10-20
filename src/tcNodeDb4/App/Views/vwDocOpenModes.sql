

CREATE   VIEW App.vwDocOpenModes
AS
SELECT TOP 100 PERCENT OpenMode, OpenModeDescription
FROM            App.tbDocOpenMode
WHERE        (OpenMode > 1)
ORDER BY OpenMode;

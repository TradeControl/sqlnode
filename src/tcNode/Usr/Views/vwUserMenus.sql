
CREATE   VIEW Usr.vwUserMenus
AS
SELECT Usr.tbMenuUser.MenuId
FROM Usr.vwCredentials INNER JOIN Usr.tbMenuUser ON Usr.vwCredentials.UserId = Usr.tbMenuUser.UserId;

CREATE TABLE Task.tbCostSet
(
	TaskCode nvarchar(20) NOT NULL,
	UserId nvarchar(10) NOT NULL,
	InsertedBy nvarchar(50) NOT NULL CONSTRAINT Task_tbCostSet_InsertedBy DEFAULT (SUSER_SNAME()),
	InsertedOn datetime NOT NULL CONSTRAINT Task_tbCostSet_InsertedOn DEFAULT (GETDATE()),
	RowVer timestamp NOT NULL
	CONSTRAINT PK_Task_tbCostSet PRIMARY KEY CLUSTERED (TaskCode, UserId)
);
go
CREATE UNIQUE NONCLUSTERED INDEX IX_Task_tbCostSet_UserId ON Task.tbCostSet (UserId ASC, TaskCode ASC);
go
ALTER TABLE Task.tbCostSet ADD
	CONSTRAINT FK_Task_tbCostSet_Task_tbTask FOREIGN KEY (TaskCode) REFERENCES Task.tbTask (TaskCode) ON DELETE CASCADE;
go
ALTER TABLE Task.tbCostSet ADD
	CONSTRAINT FK_Task_tbCostSet_Usr_tbUser FOREIGN KEY (UserId) REFERENCES Usr.tbUser (UserId) ON DELETE CASCADE;
go
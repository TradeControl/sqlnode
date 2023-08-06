CREATE VIEW Project.vwActiveData
AS
	SELECT        ProjectCode, UserId, AccountCode, ContactName, ObjectCode, ProjectTitle, ProjectStatusCode, ActionById, ActionOn, ActionedOn, PaymentOn, SecondReference, ProjectNotes, TaxCode, Quantity, UnitCharge, TotalCharge, 
							 AddressCodeFrom, AddressCodeTo, Printed, Spooled, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn, Period, BucketId, ProjectStatus, CashCode, CashDescription, OwnerName, ActionName, AccountName, 
							 SubjectStatus, SubjectType, CashPolarityCode
	FROM            Project.vwProjects
	WHERE        (ProjectStatusCode = 1);

CREATE VIEW Org.vwSales
AS
SELECT        AccountCode, TaskCode, UserId, ContactName, ActivityCode, TaskTitle, TaskStatusCode, ActionById, ActionOn, ActionedOn, PaymentOn, SecondReference, TaskNotes, TaxCode, Quantity, UnitCharge, TotalCharge, 
                         AddressCodeFrom, AddressCodeTo, Printed, Spooled, InsertedBy, InsertedOn, UpdatedBy, UpdatedOn, Period, BucketId, TaskStatus, CashCode, CashDescription, OwnerName, ActionName, AccountName, 
                         OrganisationStatus, OrganisationType, CashModeCode
FROM            Task.vwTasks
WHERE        (CashModeCode = 1) AND (CashCode IS NOT NULL);


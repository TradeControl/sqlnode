CREATE TABLE [Org].[tbPaymentStatus] (
    [PaymentStatusCode] SMALLINT      NOT NULL,
    [PaymentStatus]     NVARCHAR (20) NOT NULL,
    CONSTRAINT [PK_Org_tbPaymentStatus] PRIMARY KEY CLUSTERED ([PaymentStatusCode] ASC) WITH (FILLFACTOR = 90)
);


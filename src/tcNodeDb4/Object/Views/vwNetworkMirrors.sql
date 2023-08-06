CREATE   VIEW Object.vwNetworkMirrors
AS
	SELECT AccountCode, ObjectCode, AllocationCode, TransmitStatusCode FROM Object.tbMirror WHERE TransmitStatusCode BETWEEN 1 AND 2;

using System;
using System.Collections.Generic;
using System.Linq;
using System.Data;

using System.Text;
using System.Threading.Tasks;

namespace TradeControl.Node
{
    public class TCNodeNetwork : dbNodeNetworkDataContext
    {
        public TCNodeNetwork(string connection) : base(connection) { }

        #region network
        public string NetworkName
        {
            get
            {
                try
                {
                    var owner = (from org in tbOrgs
                                 from opt in tbOptions
                                 where org.AccountCode == opt.AccountCode
                                 select org.AccountName).First().ToString();
                    return owner;
                }
                catch (Exception err)
                {
                    string logCode = string.Empty;
                    proc_EventLog(err.Message, (short)EventType.Error, ref logCode);
                    return string.Empty;
                }
            }
        }

        public string UnitOfAccount
        {
            get
            {
                try
                {
                    var uoc = (from opt in tbOptions
                               select opt.UnitOfCharge != null ? opt.UnitOfCharge : string.Empty).First().ToString();
                    return uoc;
                }
                catch (Exception err)
                {
                    string logCode = string.Empty;
                    proc_EventLog(err.Message, (short)EventType.Error, ref logCode);
                    return string.Empty;
                }
            }
        }

        public Task<bool> AddNetworkProvider(string networkProvider, string publicKey, string privateKey, string consortiumAddress)
        {
            return Task.Run(() =>
            {
                try
                {
                    var provider = (from tb in tbEths where tb.NetworkProvider == networkProvider select tb).Select(tb => tb).FirstOrDefault();

                    if (provider == null)
                    {
                        tbEths.InsertOnSubmit(new tbEth { NetworkProvider = networkProvider, PublicKey = publicKey, PrivateKey = privateKey, ConsortiumAddress = consortiumAddress });
                        SubmitChanges();
                    }
                    else if (publicKey != provider.PublicKey || privateKey != provider.PrivateKey || (consortiumAddress != provider.ConsortiumAddress))
                    {
                        provider.PublicKey = publicKey.Length > 0 ? publicKey : provider.PublicKey;
                        provider.PrivateKey = privateKey.Length > 0 ? privateKey : provider.PrivateKey;
                        provider.ConsortiumAddress = consortiumAddress.Length > 0 ? consortiumAddress : provider.ConsortiumAddress;
                        SubmitChanges();
                    }
                    return true;
                }
                catch (Exception err)
                {
                    string logCode = string.Empty;
                    proc_EventLog(err.Message, (short)EventType.Error, ref logCode);
                    return false;
                }
            });
        }
        #endregion

        #region membership
        public Dictionary<string, string> Members
        {
            get
            {
                try
                {
                    Dictionary<string, string> members = new Dictionary<string, string>();

                    var orgs = (from tb in tbOrgs
                                where tb.TransmitStatusCode == (short)TransmitStatus.Deploy
                                orderby tb.AccountName
                                select new { tb.AccountCode, tb.AccountName });

                    foreach (var member in orgs)
                        members.Add(member.AccountCode, member.AccountName);
                    return members;
                }
                catch (Exception err)
                {
                    string logCode = string.Empty;
                    proc_EventLog(err.Message, (short)EventType.Error, ref logCode);
                    return new Dictionary<string, string>();
                }
            }
        }

        public Dictionary<string, string> Candidates
        {
            get
            {
                try
                {
                    Dictionary<string, string> candidates = new Dictionary<string, string>();

                    var orgs = (from tb in tbOrgs
                                where tb.TransmitStatusCode == (short)TransmitStatus.Disconnected
                                    && tb.AccountCode != (tbOptions.Select(o => o.AccountCode).First().ToString())
                                orderby tb.AccountName
                                select new { tb.AccountCode, tb.AccountName });

                    foreach (var candidate in orgs)
                        candidates.Add(candidate.AccountCode, candidate.AccountName);
                    return candidates;
                }
                catch (Exception err)
                {
                    string logCode = string.Empty;
                    proc_EventLog(err.Message, (short)EventType.Error, ref logCode);
                    return new Dictionary<string, string>();
                }
            }
        }

        public Task<bool> AddMember(string accountCode)
        {
            return Task.Run(() =>
            {
                try
                {
                    var org = (from tb in tbOrgs where tb.AccountCode == accountCode select tb).First();
                    org.TransmitStatusCode = (short)TransmitStatus.Deploy;
                    SubmitChanges();
                    return true;
                }
                catch (Exception err)
                {
                    string logCode = string.Empty;
                    proc_EventLog(err.Message, (short)EventType.Error, ref logCode);
                    return false;
                }
            });
        }
        #endregion

        #region activities
        public Task<bool> AllocationTransmitted(string accountCode, string allocationCode)
        {
            return Task.Run(() =>
            {
                try
                {
                    int result = proc_ActivityUpdated(accountCode, allocationCode);
                    return result == 0;
                }
                catch (Exception err)
                {
                    string logCode = string.Empty;
                    proc_EventLog(err.Message, (short)EventType.Error, ref logCode);
                    return false;
                }
            });
        }

        public Task<bool> MirrorAllocation(string activityCode, string accountCode, string allocationCode)
        {
            return Task.Run(() =>
            {
                try
                {
                    int result = proc_MirrorActivity(activityCode, accountCode, allocationCode);
                    return result == 0;
                }
                catch (Exception err)
                {
                    string logCode = string.Empty;
                    proc_EventLog(err.Message, (short)EventType.Error, ref logCode);
                    return false;
                }
            });

        }
        #endregion

        #region tasks
        public Task<bool> TaskTransmitted(string taskCode)
        {
            return Task.Run(() =>
            {
                try
                {
                    int result = proc_TaskUpdated(taskCode);
                    return result == 0;
                }
                catch (Exception err)
                {
                    string logCode = string.Empty;
                    proc_EventLog(err.Message, (short)EventType.Error, ref logCode);
                    return false;
                }
            });
        }


        public Task<bool> TaskAllocation(tbAllocation taskAllocation)
        {
            return Task.Run(() =>
            {

                try
                {
                    if (tbAllocations.Where(rec => rec.ContractAddress == taskAllocation.ContractAddress).Select(s => s).SingleOrDefault() == null)
                        TaskAllocationInsert(taskAllocation);
                    else
                        TaskAllocationUpdate(taskAllocation);

                    SubmitChanges();

                    return true;
                }
                catch (Exception err)
                {
                    string logCode = string.Empty;
                    proc_EventLog(err.Message, (short)EventType.Error, ref logCode);
                    return false;
                }
            });
        }

        private void TaskAllocationInsert(tbAllocation taskAllocation)
        {
            tbAllocations.InsertOnSubmit(taskAllocation);
        }

        private void TaskAllocationUpdate(tbAllocation newAllocation)
        {
            tbAllocation existingAllocation = tbAllocations.Where(m => m.ContractAddress == newAllocation.ContractAddress).Single();

            existingAllocation.TaskStatusCode = newAllocation.TaskStatusCode;
            existingAllocation.UnitCharge = newAllocation.UnitCharge;
            existingAllocation.TaxRate = newAllocation.TaxRate;
            existingAllocation.ActionOn = newAllocation.ActionOn;
            existingAllocation.QuantityOrdered = newAllocation.QuantityOrdered;

        }
        #endregion

        #region cash codes
        public Task<bool> CashCodeTransmitted(string accountCode, string chargeCode)
        {
            return Task.Run(() =>
            {
                try
                {
                    int result = proc_CashCodeUpdated(accountCode, chargeCode);
                    return result == 0;
                }
                catch (Exception err)
                {
                    string logCode = string.Empty;
                    proc_EventLog(err.Message, (short)EventType.Error, ref logCode);
                    return false;
                }
            });
        }

        public Task<bool> MirrorCashCode(string cashCode, string accountCode, string chargeCode)
        {
            return Task.Run(() =>
            {
                try
                {
                    int result = proc_MirrorCashCode(cashCode, accountCode, chargeCode);
                    return result == 0;
                }
                catch (Exception err)
                {
                    string logCode = string.Empty;
                    proc_EventLog(err.Message, (short)EventType.Error, ref logCode);
                    return false;
                }
            });

        }
        #endregion

        #region invoices
        public InvoiceType GetInvoiceType(CashMode invoicePolarity, CashMode paymentPolarity)
        {
            switch (invoicePolarity)
            {
                case CashMode.Expense:
                    return paymentPolarity == CashMode.Expense ? InvoiceType.PurchaseInvoice : InvoiceType.DebitNote;
                case CashMode.Income:
                    return paymentPolarity == CashMode.Income ? InvoiceType.SalesInvoice : InvoiceType.CreditNote;
                default:
                    return InvoiceType.SalesInvoice;
            }
        }

        public Task<bool> InvoiceTransmitted(string invoiceNumber)
        {
            return Task.Run(() =>
            {
                try
                {
                    int result = proc_InvoiceUpdated(invoiceNumber);
                    return result == 0;
                }
                catch (Exception err)
                {
                    string logCode = string.Empty;
                    proc_EventLog(err.Message, (short)EventType.Error, ref logCode);
                    return false;
                }
            });
        }

        public Task<bool> InvoiceMirror (tbInvoiceMirror invoiceMirror)
        {
            return Task.Run(() =>
            {
                try
                {
                     if (tbInvoiceMirrors.Where(rec => rec.ContractAddress == invoiceMirror.ContractAddress).Select(s => s).SingleOrDefault() == null)
                        InvoiceMirrorInsert(invoiceMirror);
                    else
                        InvoiceMirrorUpdate(invoiceMirror);
                        
                    return true;
                }
                catch (Exception err)
                {
                    string logCode = string.Empty;
                    proc_EventLog(err.Message, (short)EventType.Error, ref logCode);
                    return false;
                }
            });
        }

        private void InvoiceMirrorInsert(tbInvoiceMirror invoiceMirror)
        {
            tbInvoiceMirrors.InsertOnSubmit(invoiceMirror);
        }

        private void InvoiceMirrorUpdate(tbInvoiceMirror newMirror)
        {
            tbInvoiceMirror existingMirror = tbInvoiceMirrors.Where(m => m.ContractAddress == newMirror.ContractAddress).Single();

            existingMirror.DueOn = newMirror.DueOn;
            existingMirror.InvoiceStatusCode = newMirror.InvoiceStatusCode;
            existingMirror.PaidValue = newMirror.PaidValue;
            existingMirror.PaidTaxValue = newMirror.PaidTaxValue;
            SubmitChanges();
        }

        public Task<bool> InvoiceMirrorTask (tbMirrorTask mirrorTask)
        {
            return Task.Run(() =>
            {
                try
                {
                    tbMirrorTasks.InsertOnSubmit(mirrorTask);
                    return true;
                }
                catch (Exception err)
                {
                    string logCode = string.Empty;
                    proc_EventLog(err.Message, (short)EventType.Error, ref logCode);
                    return false;
                }
            });
        }

        public Task<bool> InvoiceMirrorItem(tbMirrorItem mirrorItem)
        {
            return Task.Run(() =>
            {
                try
                {
                    tbMirrorItems.InsertOnSubmit(mirrorItem);
                    return true;
                }
                catch (Exception err)
                {
                    string logCode = string.Empty;
                    proc_EventLog(err.Message, (short)EventType.Error, ref logCode);
                    return false;
                }
            });
        }


        public Task<bool> InvoiceMirrorReference(string contractAddress, string invoiceNumber)
        {
            return Task.Run(() =>
            {
                try
                {
                    if (!tbMirrorReferences.Where(r => r.ContractAddress == contractAddress && r.InvoiceNumber == invoiceNumber).Any())
                    {
                        tbMirrorReference mirrorReference = new tbMirrorReference
                        {
                            ContractAddress = contractAddress,
                            InvoiceNumber = invoiceNumber
                        };

                        tbMirrorReferences.InsertOnSubmit(mirrorReference);
                    }

                    return true;

                }
                catch (Exception err)
                {
                    string logCode = string.Empty;
                    proc_EventLog(err.Message, (short)EventType.Error, ref logCode);
                    return false;
                }
            });
        }


        #endregion
    }
}

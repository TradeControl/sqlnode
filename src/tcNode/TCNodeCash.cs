using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TradeControl.Node
{
    public class TCNodeCash : dbNodeCashDataContext
    {
        public TCNodeCash(string connection) : base(connection)
        {
            proc_WalletInitialise();
        }


        public string RootName
        {
            get
            {
                TCNodeNetwork tcNodeNetwork = new TCNodeNetwork(Connection.ConnectionString);
                return tcNodeNetwork.NetworkName.Replace(' ', '_');
            }
        }

        public List<string> CashAccountCodes
        {
            get
            {
                return (from tb in this.vwWallets orderby tb.CashAccountCode select tb.CashAccountCode).ToList<string>();
            }
        }

        public string CashAccountTrade
        {
            get
            {
                var v = vwInvoicedReceipts;

                return (from tb in this.vwWallets where tb.CashCode != null select tb.CashAccountCode).FirstOrDefault();
            }
        }

        public CoinType GetCoinType(string cashAccountCode)
        {
            var coinType = vwWallets.Where(w => w.CashAccountCode == cashAccountCode).Select(acc => acc.CoinTypeCode).First();
            return (CoinType)coinType;
        }

        public bool AddReceiptKey(string cashAccountCode, string paymentAddress, string hdPath, int addressIndex, string notes)
        {
            return AddReceiptKey(cashAccountCode, paymentAddress, hdPath, addressIndex, null, notes);
        }

        public bool AddReceiptKey(string cashAccountCode, string paymentAddress, string keyName, int addressIndex, string notes, string invoiceNumber)
        {
            try
            {
                int rc = proc_ChangeNew(cashAccountCode, keyName, (short?)CoinChangeType.Receipt, paymentAddress, addressIndex, invoiceNumber, notes);
                return rc == 0;
            }
            catch (Exception err)
            {
                string logCode = string.Empty;
                proc_EventLog(err.Message, (short)EventType.Error, ref logCode);
                return false;
            }
        }

        public bool DeleteChangeKey(string paymentAddress)
        {
            try
            {
                int rc = proc_ChangeDelete(paymentAddress);
                return rc == 0;
            }
            catch (Exception err)
            {
                string logCode = string.Empty;
                proc_EventLog(err.Message, (short)EventType.Error, ref logCode);
                return false;
            }
        }

        public bool ChangeKeyNote(string paymentAddress, string note)
        {
            try
            {
                int rc = proc_ChangeNote(paymentAddress, note);
                return rc == 0;
            }
            catch (Exception err)
            {
                string logCode = string.Empty;
                proc_EventLog(err.Message, (short)EventType.Error, ref logCode);
                return false;
            }
        }

        public bool TxPayIn(string cashAccountCode, string paymentAddress, string txId, string accountCode, string cashCode, DateTime paidOn, string paymentReference)
        {
            try
            {
                string paymentCode = string.Empty;
                proc_TxPayIn(cashAccountCode, paymentAddress, txId, accountCode, cashCode, paidOn, paymentReference, ref paymentCode);
                return paymentCode.Length > 0;
            }
            catch (Exception err)
            {
                string logCode = string.Empty;
                proc_EventLog(err.Message, (short)EventType.Error, ref logCode);
                return false;
            }
        }

        public Task<double> NamespaceBalance (string cashAccountCode, string keyName)
        {
            return Task.Run(() =>
            {
                try
                {
                    double balance = (double)fnNamespaceBalance(cashAccountCode, keyName);
                    return balance;
                }
                catch (Exception err)
                {
                    string logCode = string.Empty;
                    proc_EventLog(err.Message, (short)EventType.Error, ref logCode);
                    return 0;
                }
            });
        }

        public Task<double> KeyNameBalance(string cashAccountCode, string keyName)
        {
            return Task.Run(() =>
            {
                try
                {
                    double balance = (double)fnKeyNameBalance(cashAccountCode, keyName);
                    return balance;
                }
                catch (Exception err)
                {
                    string logCode = string.Empty;
                    proc_EventLog(err.Message, (short)EventType.Error, ref logCode);
                    return 0;
                }
            });
        }

        public Task<double> AccountBalance(string accountCode)
        {
            return Task.Run(() =>
            {
                try
                {
                    decimal? balance = 0;
                    proc_BalanceToPay(accountCode, ref balance);
                    return (double)balance * -1;
                }
                catch (Exception err)
                {
                    string logCode = string.Empty;
                    proc_EventLog(err.Message, (short)EventType.Error, ref logCode);
                    return 0;
                }
            });
        }
    }
}
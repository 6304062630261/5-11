import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class TransactionList extends StatelessWidget {
  final Map<String, List<Map<String, dynamic>>> transactions;

  TransactionList({required this.transactions});

  @override
  Widget build(BuildContext context) {
    double totalIncome = 0;
    double totalExpense = 0;
    final localizations = AppLocalizations.of(context)!;
    // คำนวณยอดรวมของธุรกรรมทั้งหมด (สำหรับยอดรวมรายเดือนหรือรายปี)
    transactions.forEach((date, transactionList) {
      for (var item in transactionList) {
        if (item['type_expense'] == 0) {
          totalIncome += item['amount_transaction'];
        } else if (item['type_expense'] == 1) {
          totalExpense += item['amount_transaction'];
        }
      }
    });

    double balance = totalIncome - totalExpense; // ยอดคงเหลือ

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: ListView.builder(
              itemCount: transactions.length + 3,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Row(
                    children: [
                      Expanded(
                        child: _buildTotalCard(
                          title: localizations.totalIncome,
                          amount: totalIncome,
                          color: Colors.green[100]!,
                          textColor: Colors.green[800]!,
                          icon: Icons.arrow_upward,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _buildTotalCard(
                          title: localizations.totalExpense,
                          amount: totalExpense,
                          color: Colors.red[100]!,
                          textColor: Colors.red[800]!,
                          icon: Icons.arrow_downward,
                        ),
                      ),
                    ],
                  );
                } else if (index == 1) {
                  return _buildBalanceCard(
                    title: localizations.balance,
                    amount: balance,
                    color: Colors.blue[100]!,
                    textColor: Colors.blue[800]!,
                    icon: Icons.account_balance_wallet,
                  );
                } else if (index >= 2 && index - 2 < transactions.length) {
                  final entry = transactions.entries.elementAt(index - 2); // ลดดัชนีลง 2 สำหรับ Total Income และ Balance
                  final date = entry.key;
                  final transactionList = entry.value;
                  return _buildTransactionCard(date, transactionList);
                } else {
                  return SizedBox.shrink(); // หากไม่มีข้อมูลให้คืนค่าเป็นช่องว่าง
                }
              },

            ),
          ),
        ),
      ],
    );
  }

  String formatAmount(double amount) {
    if (amount >= 1e9) {
      // ถ้าเกินพันล้าน
      return (amount / 1e9).toStringAsFixed(2) + 'B';
    } else if (amount >= 1e6) {
      // ถ้าเกินล้าน
      return (amount / 1e6).toStringAsFixed(2) + 'M';
    } else {

      return NumberFormat('#,##0.00').format(amount);
    }
  }

  Widget _buildTotalCard({
    required String title,
    required double amount,
    required Color color,
    required Color textColor,
    required IconData icon,
  }) {
    String formattedAmount = formatAmount(amount); // ใช้ฟังก์ชัน formatAmount

    return Card(
      elevation: 4,
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 40, color: textColor),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 16, color: textColor, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '$formattedAmount',
              style: TextStyle(fontSize: 16, color: textColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  }

  String formatAmount(double amount) {
    if (amount >= 1e9) {
      // ถ้าเกินพันล้าน
      return (amount / 1e9).toStringAsFixed(2) + 'B';
    } else if (amount >= 1e6) {
      // ถ้าเกินล้าน
      return (amount / 1e6).toStringAsFixed(2) + 'M';
    } else {
      // ถ้ายอดเงินน้อยกว่า 1 ล้าน
      return NumberFormat('#,##0.00').format(amount);
    }
  }



  Widget _buildBalanceCard({
    required String title,
    required double amount,
    required Color color,
    required Color textColor,
    required IconData icon,
  }) {
    String formattedAmount = formatAmount(amount); // ใช้ฟังก์ชัน formatAmount สำหรับ Balance

    return Card(
      elevation: 5,
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Row(
          children: [
            Icon(icon, size: 50, color: textColor),
            SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 20, color: textColor, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  '$formattedAmount', // แสดงจำนวนเงินตาม formatAmount
                  style: TextStyle(fontSize: 20, color: textColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(String date, List<Map<String, dynamic>> transactionList) {
    return Card(
      margin: EdgeInsets.only(bottom: 10),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12.0),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                DateFormat('d MMM yyyy').format(DateTime.parse(date)),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 8.0),
            Column(
              children: [
                ...transactionList.where((item) => item['type_expense'] == 0).map((item) {
                  return _buildTransactionItem(item);
                }).toList(),
                ...transactionList.where((item) => item['type_expense'] == 1).map((item) {
                  return _buildTransactionItem(item);
                }).toList(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> item) {
    DateTime transactionDate = DateTime.parse(item['date_user']);
    String formattedDate = DateFormat('d MMM yyyy').format(transactionDate);

    String imagePath;
    if (item['type_expense'] == 0) {
      imagePath = 'assets/money.png'; // Income
    } else if (item['type_expense'] == 1) {
      imagePath = 'assets/receipt.png'; // Expense
    } else {
      imagePath = 'assets/other.png'; // Other types
    }

    Color amountColor = item['type_expense'] == 0 ? Colors.green : Colors.red;
    String formattedAmount = NumberFormat('#,##0.00').format(item['amount_transaction']);

    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      leading: Image.asset(
        imagePath,
        width: 50,
        height: 50,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.error, size: 50, color: Colors.red);
        },
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['type_expense'] == 1 ? 'Expense' : 'Income',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          Text(
            '${formattedAmount}',
            style: TextStyle(color: amountColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }


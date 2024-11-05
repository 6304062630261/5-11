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
    transactions.values.forEach((transactionList) {
      for (var item in transactionList) {
        if (item['type_transaction'] == 'IC') {
          totalIncome += item['amount_transaction'];
        } else {
          totalExpense += item['amount_transaction'];
        }
      }
    });

    final sortTransactions = transactions.entries.toList();
    sortTransactions.sort((a, b) => DateTime.parse(b.key).compareTo(DateTime.parse(a.key)));

    return Padding(

      padding: const EdgeInsets.symmetric(horizontal: 20.0),

      child: ListView.builder(
        itemCount: sortTransactions.length + 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildTotalCard(
              title: localizations.totalIncome,
              amount: totalIncome,
              color: Colors.green.shade300,
            );
          } else if (index == 1) {
            return _buildTotalCard(
              title: localizations.totalExpense,
              amount: totalExpense,
              color: Colors.red.shade300,
            );
          } else {
            final entry = sortTransactions[index - 2];
            final date = entry.key;
            final transactionList = entry.value;

            return _buildTransactionCard(context, date, transactionList);
          }
        },
      ),
    );
  }

  Widget _buildTotalCard({required String title, required double amount, required Color color}) {
    String formattedAmount = NumberFormat('#,##0.00').format(amount);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), Colors.blue.shade100], // ไล่สีเริ่มต้นและปลาย
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(8), // ขอบมน
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              '$formattedAmount',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, String date, List<Map<String, dynamic>> transactionList) {
    final localizations = AppLocalizations.of(context)!;
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
                DateFormat('d MMM yyyy', localizations.localeName).format(DateTime.parse(date)),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 8.0),
            Column(
              children: transactionList.map((item) {
                return _buildTransactionItem(item);
              }).toList(),
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
    switch (item['type_transaction']) {
      case 'IC':
        imagePath = 'assets/money.png';
        break;
      case 'Electricity bill':
        imagePath = 'assets/electricity_bill.png';
        break;
      case 'Internet cost':
        imagePath = 'assets/internet.png';
        break;
      case 'Food':
        imagePath = 'assets/food.png';
        break;
      case 'Travel expenses':
        imagePath = 'assets/travel_expenses.png';
        break;
      case 'Water bill':
        imagePath = 'assets/water_bill.png';
        break;
      case 'House cost':
        imagePath = 'assets/house.png';
        break;
      case 'Car fare':
        imagePath = 'assets/car.png';
        break;
      case 'Gasoline cost':
        imagePath = 'assets/gasoline_cost.png';
        break;
      case 'Medical expenses':
        imagePath = 'assets/medical.png';
        break;
      case 'Beauty expenses':
        imagePath = 'assets/beauty.png';
        break;
      default:
        imagePath = 'assets/other.png';
    }

    Color amountColor = item['type_transaction'] == 'IC' ? Colors.green : Colors.red;
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
                Text('${item['type_transaction'] == 'IC' ? 'Income' : item['type_transaction']}', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    if (item['memo_transaction'] != null && item['memo_transaction'].isNotEmpty)
                      Icon(Icons.favorite, color: Colors.red, size: 16),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${item['memo_transaction'] ?? 'No memo'}',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          Text(
            '${formattedAmount}', // ใช้ formattedAmount
            style: TextStyle(color: amountColor, fontWeight: FontWeight.bold),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

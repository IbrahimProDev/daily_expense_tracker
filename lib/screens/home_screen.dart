import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../services/local_db_service.dart';
import 'add_expense_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocalDbService _dbService = LocalDbService();
  List<ExpenseModel> _expenses = [];
  double _total = 0;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final data = await _dbService.getAllExpenses();
    double sum = 0;
    for (var e in data) sum += e.amount;
    setState(() {
      _expenses = data;
      _total = sum;
    });
  }

  Future<void> _deleteExpense(int id) async {
    await _dbService.deleteExpense(id);
    _loadExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 219, 205, 16),
      ),
      body: Column(
        children: [
          // 🔹 Total Expense Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 184, 238, 244),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 231, 12, 96),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text('Total Expense', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text(
                  '৳ ${_total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // 🔹 Expense List
          Expanded(
            child: _expenses.isEmpty
                ? const Center(
                    child: Text(
                      'No expenses yet',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _expenses.length,
                    itemBuilder: (context, index) {
                      final e = _expenses[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: Text(
                              e.category[0],
                              style: const TextStyle(
                                color: Color.fromARGB(255, 231, 12, 96),
                              ),
                            ),
                          ),
                          title: Text(e.title),
                          subtitle: Text('${e.category} • ${e.date}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${e.amount}'),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteExpense(e.id!),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      // ➕ Add Expense Button
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
          );
          _loadExpenses();
        },
        backgroundColor: const Color.fromARGB(255, 167, 217, 105),
        child: const Icon(Icons.add),
      ),
    );
  }
}

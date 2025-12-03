import 'package:flutter/material.dart';
import '../models/bank_rule.dart';
import '../services/rules_manager.dart';

class NotifRulesTab extends StatefulWidget {
  const NotifRulesTab({super.key});

  @override
  State<NotifRulesTab> createState() => _NotifRulesTabState();
}

class _NotifRulesTabState extends State<NotifRulesTab> {
  List<BankRule> rules = [];
  bool isLoading = true;
  bool isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadRules();
  }

  Future<void> _loadRules() async {
    final loadedRules = await RulesManager.loadRules();
    setState(() {
      rules = loadedRules;
      isLoading = false;
    });
  }

  Future<void> _refreshRulesFromServer() async {
    setState(() {
      isRefreshing = true;
    });

    final serverRules = await RulesManager.loadRemoteRules();
    if (serverRules != null && serverRules.isNotEmpty) {
      await RulesManager.saveRules(serverRules);
      setState(() {
        rules = serverRules;
        isRefreshing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rules updated: ${serverRules.length} items')),
        );
      }
    } else {
      setState(() {
        isRefreshing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load rules from server')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _refreshRulesFromServer,
      child: Column(
        children: [
          if (isRefreshing)
            const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Rules: ${rules.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: isRefreshing ? null : _refreshRulesFromServer,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Sync Server'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: rules.length,
              itemBuilder: (context, index) {
                final rule = rules[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bank: ${rule.bankName} - ${rule.accountNumber}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Packagename: ${rule.packageName}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          'Judul: ${rule.title}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          'Detail: ${rule.detail}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          'Metode: ${rule.extractMethod}',
                          style: const TextStyle(fontSize: 12),
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
    );
  }
}

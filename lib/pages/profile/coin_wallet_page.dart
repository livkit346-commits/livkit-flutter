import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../services/auth_service.dart';

class CoinWalletPage extends StatefulWidget {
  const CoinWalletPage({super.key});

  @override
  State<CoinWalletPage> createState() => _CoinWalletPageState();
}

class _CoinWalletPageState extends State<CoinWalletPage> {
  final AuthService _authService = AuthService();
  String? _accessToken;
  bool _isLoading = true;
  List<dynamic> _packages = [];
  int _balance = 0; // In a full prod app this would be fetched from a user/wallet endpoint

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    _accessToken = await _authService.getAccessToken();
    if (_accessToken != null) {
      await _fetchPackages();
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchPackages() async {
    try {
      final response = await http.get(
        Uri.parse("https://livkit.onrender.com/api/payments/coins/"),
        headers: {"Authorization": "Bearer $_accessToken"},
      );
      if (response.statusCode == 200) {
        setState(() {
          _packages = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _buyPackage(int packageId) async {
    if (_accessToken == null) return;
    showDialog(context: context, builder: (_) => const Center(child: CircularProgressIndicator()));
    
    try {
      final response = await http.post(
        Uri.parse("https://livkit.onrender.com/api/payments/coins/buy/"),
        headers: {
          "Authorization": "Bearer $_accessToken",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"package_id": packageId}),
      );
      
      Navigator.pop(context); // close loader
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _balance = data['new_balance'] ?? _balance;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Purchase successful!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to purchase package.")),
        );
      }
    } catch (e) {
      Navigator.pop(context); // close loader
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Coin Wallet", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey.shade900,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFFFF0050), Color(0xFFFF2E63)]),
            ),
            child: Column(
              children: [
                const Text("Current Balance", style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.amber, size: 36),
                    const SizedBox(width: 8),
                    Text("$_balance", style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
              : _packages.isEmpty 
                  ? const Center(child: Text("No coin packages available.", style: TextStyle(color: Colors.white)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _packages.length,
                      itemBuilder: (context, index) {
                        final pkg = _packages[index];
                        return Card(
                          color: Colors.grey.shade900,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: const Icon(Icons.monetization_on, color: Colors.amber, size: 32),
                            title: Text("${pkg['coin_amount']} Coins", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            subtitle: Text("Buy for \$${pkg['usd_price']}", style: const TextStyle(color: Colors.white70)),
                            trailing: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF0050)),
                              onPressed: () => _buyPackage(pkg['id']),
                              child: const Text("Buy", style: TextStyle(color: Colors.white)),
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

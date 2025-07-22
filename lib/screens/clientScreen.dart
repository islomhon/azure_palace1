import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  List<dynamic> clients = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchClients();
  }

  Future<void> fetchClients() async {
    try {
      final response = await http
          .get(Uri.parse('https://dash.vips.uz/api/88/10221/95412'))
          .timeout(const Duration(seconds: 10)); // 10 soniyagacha kutadi

      if (response.statusCode == 200) {
        setState(() {
          clients = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        print("Xatolik: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Boshqa xatolik: $e");
    }
  }

  void openAddClientDialog() {
    String fullName = '';
    String email = '';
    String phone = '';
    String address = '';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Yangi mijoz qo‘shish"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'To‘liq ism'),
                onChanged: (val) => fullName = val,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Email'),
                onChanged: (val) => email = val,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Telefon'),
                onChanged: (val) => phone = val,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Manzil'),
                onChanged: (val) => address = val,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Bekor"),
          ),
          ElevatedButton(
            onPressed: () {
              addClient(fullName, email, phone, address);
              Navigator.pop(ctx);
            },
            child: const Text("Qo‘shish"),
          ),
        ],
      ),
    );
  }

  Future<void> addClient(
    String ism,
    String email,
    String telefon,
    String manzil,
  ) async {
    final now = DateTime.now();
    final yaratilgan_sana =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final response = await http.post(
      Uri.parse('https://dash.vips.uz/api-in/88/10221/95412'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'apipassword': '1sl0mh0n',
        "ism": ism,
        "email": email,
        "telefon": telefon,
        "manzil": manzil,
        "yaratilgan_sana": yaratilgan_sana,
      },
    );

    print("📤 Yuborilayotgan mijoz: $ism, $email, $telefon");
    print("📥 Javob: ${response.statusCode} — ${response.body}");

    if (response.statusCode == 200) {
      fetchClients();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Xatolik: ${response.statusCode}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mijozlar"),
        actions: [
          IconButton(
            onPressed: openAddClientDialog,
            icon: const Icon(Icons.person_add),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: clients.length,
              itemBuilder: (context, index) {
                final client = clients[index];
                return Card(
                  color: Colors.white10,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.person, color: Colors.white),
                    title: Text(
                      client['ism'] ?? '',
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "📧 ${client['email'] ?? ''}",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Text(
                          "📞 ${client['telefon'] ?? ''}",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Text(
                          "📍 ${client['manzil'] ?? ''}",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

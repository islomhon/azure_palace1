import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<dynamic> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final response = await http.get(
      Uri.parse('https://dash.vips.uz/api/88/10221/95411'),
    );

    if (response.statusCode == 200) {
      setState(() {
        orders = jsonDecode(response.body);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      print("Xatolik: ${response.statusCode}");
    }
  }

  String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Buyurtmalar")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
          ? const Center(child: Text("Hech qanday buyurtma yo‘q"))
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  color: Colors.white10,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.calendar_today,
                      color: Colors.white,
                    ),
                    title: Text(
                      "Mijoz ID: ${order['mujoz_id']} — Xona ID: ${order['xona_id']}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "🕒 ${formatDate(order['kirish_sana'])} → ${formatDate(order['chiqish_sana'])}",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Text(
                          "💰 \$${order['umumiy_narx'] ?? '0'}",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Text(
                          "📌 Holati: ${order['status'] ?? 'Noma’lum'}",
                          style: TextStyle(
                            color: order['status'] == 'Active'
                                ? Colors.green
                                : Colors.redAccent,
                          ),
                        ),
                        Text(
                          "🗓 Yaratilgan: ${formatDate(order['yaratilgan_sana'])}",
                          style: const TextStyle(color: Colors.white54),
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

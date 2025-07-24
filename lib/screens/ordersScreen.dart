import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AddOrderDialog extends StatefulWidget {
  @override
  State<AddOrderDialog> createState() => _AddOrderDialogState();
}

class _AddOrderDialogState extends State<AddOrderDialog> {
  List<dynamic> clients = [];
  List<dynamic> rooms = [];

  String? selectedClientId;
  String? selectedRoomId;

  DateTime? checkInDate;
  DateTime? checkOutDate;
  TextEditingController priceController = TextEditingController();
  bool isActive = true;
  DateTime createdDate = DateTime.now();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    final clientRes = await http.get(
      Uri.parse('https://dash.vips.uz/api/88/10221/95412'),
    );
    final roomRes = await http.get(
      Uri.parse('https://dash.vips.uz/api/88/10221/95413'),
    );

    if (clientRes.statusCode == 200 && roomRes.statusCode == 200) {
      setState(() {
        clients = jsonDecode(clientRes.body);
        rooms = jsonDecode(roomRes.body);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      print('Xatolik: mijoz yoki xona maʼlumotlari olinmadi');
    }
  }

  Future<void> submitOrder() async {
    final response = await http.post(
      Uri.parse('https://dash.vips.uz/api-in/88/10221/95411'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        "apipassword": "1sl0mh0n",
        "mijoz_id": selectedClientId!,
        "xona_id": selectedRoomId!,
        "kirish_sana": DateFormat('yyyy-MM-dd').format(checkInDate!),
        "chiqish_sana": DateFormat('yyyy-MM-dd').format(checkOutDate!),
        "umumiy_narx": priceController.text,
        "status": isActive ? "Active" : "Inactive",
        "yaratilgan_sana": DateFormat('yyyy-MM-dd').format(createdDate),
      },
    );

    if (response.statusCode == 200) {
      Navigator.pop(context, true); // ✅ natijani qaytar
    } else {
      print("Xatolik: ${response.statusCode} - ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    print("🧪 selectedClientId: $selectedClientId");
    print("🧪 client IDs: ${clients.map((c) => c['id'].toString()).toList()}");
    print(jsonEncode(clients));
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      title: const Text(
        "Yangi buyurtma",
        style: TextStyle(color: Colors.white),
      ),
      content: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value:
                        (selectedClientId != null &&
                            clients.any(
                              (c) =>
                                  c['mijoz_id'].toString() == selectedClientId,
                            ))
                        ? selectedClientId
                        : null,
                    items: clients.map((client) {
                      final id = client['mijoz_id'].toString();
                      final name = client['ism'] ?? 'Nomaʼlum';
                      return DropdownMenuItem<String>(
                        value: id,
                        child: Text(
                          name,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => selectedClientId = val),
                    decoration: const InputDecoration(labelText: 'Mijoz'),
                  ),

                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value:
                        (selectedRoomId != null &&
                            rooms.any(
                              (r) => r['xona_id'].toString() == selectedRoomId,
                            ))
                        ? selectedRoomId
                        : null,
                    items: rooms
                        .map<DropdownMenuItem<String>>((room) {
                          return DropdownMenuItem<String>(
                            value: room['xona_id'].toString(),
                            child: Text(
                              room['xona_raqami'].toString(),
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        })
                        .toSet()
                        .toList(), // <-- bu yerda ham .toSet() dublikatlarni yo‘q qiladi
                    onChanged: (val) => setState(() => selectedRoomId = val),
                    decoration: const InputDecoration(labelText: 'Xona'),
                  ),

                  const SizedBox(height: 10),
                  ListTile(
                    title: Text(
                      "Kirish sana: ${checkInDate == null ? '' : DateFormat('yyyy-MM-dd').format(checkInDate!)}",
                    ),
                    trailing: const Icon(Icons.calendar_month),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2023),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) setState(() => checkInDate = date);
                    },
                  ),
                  ListTile(
                    title: Text(
                      "Chiqish sana: ${checkOutDate == null ? '' : DateFormat('yyyy-MM-dd').format(checkOutDate!)}",
                    ),
                    trailing: const Icon(Icons.calendar_month),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(
                          const Duration(days: 1),
                        ),
                        firstDate: DateTime(2023),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) setState(() => checkOutDate = date);
                    },
                  ),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: "Umumiy narx"),
                    keyboardType: TextInputType.number,
                  ),
                  SwitchListTile(
                    title: const Text("Status: Active"),
                    value: isActive,
                    onChanged: (val) => setState(() => isActive = val),
                  ),
                  ListTile(
                    title: Text(
                      "Yaratilgan sana: ${DateFormat('yyyy-MM-dd').format(createdDate)}",
                    ),
                    trailing: const Icon(Icons.edit_calendar),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: createdDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) setState(() => createdDate = date);
                    },
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed:
                        (selectedClientId != null &&
                            selectedRoomId != null &&
                            checkInDate != null &&
                            checkOutDate != null &&
                            priceController.text.isNotEmpty)
                        ? submitOrder
                        : null,
                    child: const Text("Saqlash"),
                  ),
                ],
              ),
            ),
    );
  }
}

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
      appBar: AppBar(
        title: const Text("Buyurtmalar"),
        actions: [
          IconButton(
            onPressed: () async {
              final added = await showDialog(
                context: context,
                builder: (context) => AddOrderDialog(),
              );

              if (added == true) {
                fetchOrders();
              }
            },

            icon: Icon(Icons.add),
          ),
        ],
      ),
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
                      "Mijoz ism: ${order['mijoz_idism']}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Xona raqami: ${order['xona_idxona_raqami']}',
                          style: const TextStyle(color: Colors.white70),
                        ),
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

void displayAddOrderDialog(BuildContext context) {
  showDialog(context: context, builder: (context) => AddOrderDialog());
}

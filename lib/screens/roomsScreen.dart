import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  List<dynamic> rooms = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRooms();
  }

  Future<void> fetchRooms() async {
    final response = await http.get(
      Uri.parse('https://dash.vips.uz/api/88/10221/95413'),
    );  

    if (response.statusCode == 200) {
      setState(() {
        rooms = jsonDecode(response.body);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      print("Xatolik: ${response.statusCode}");
    }
  }

  void openAddRoomDialog() {
    String number = '';
    String type = '';
    String price = '';
    String status = '';

    void selectStatusDialog(StateSetter localSetState) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Statusni tanlang"),
          actions: [
            TextButton(
              onPressed: () {
                localSetState(() => status = "Bo'sh");
                Navigator.pop(ctx);
              },
              child: const Text("Bo'sh"),
            ),
            TextButton(
              onPressed: () {
                localSetState(() => status = "Band");
                Navigator.pop(ctx);
              },
              child: const Text("Band"),
            ),
          ],
        ),
      );
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Yangi xona qo‘shish"),
        content: StatefulBuilder(
          builder: (context, localSetState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Xona raqami'),
                onChanged: (val) => number = val,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Xona turi'),
                onChanged: (val) => type = val,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Narxi'),
                keyboardType: TextInputType.number,
                onChanged: (val) => price = val,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => selectStatusDialog(localSetState),
                child: Text(
                  status.isEmpty ? "Statusni tanlang" : "Status: $status",
                ),
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
              if (status.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Iltimos, status tanlang!")),
                );
                return;
              }
              addRoom(number, type, price, status);
              Navigator.pop(ctx);
            },
            child: const Text("Qo‘shish"),
          ),
        ],
      ),
    );
  }

  Future<void> addRoom(
    String number,
    String type,
    String price,
    String status,
  ) async {
    final now = DateTime.now();
    final createdAt =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final response = await http.post(
      Uri.parse('https://dash.vips.uz/api-in/88/10221/95413'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        "apipassword": '1sl0mh0n',
        "xona_raqami": number,
        "xona_turi": type,
        "narx": price,
        "status": status,
        "yaratilgan_sana": createdAt,
      },
    );

    print(
      "📤 Yuborilgan: xona_raqami=$number, xona_turi=$type, narx=$price, status=$status, yaratilgan_sana=$createdAt",
    );
    print("📥 API javobi: ${response.statusCode} — ${response.body}");

    if (response.statusCode == 200) {
      fetchRooms(); // ro'yxatni yangilaymiz
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
        title: const Text("Xonalar"),
        actions: [
          IconButton(onPressed: openAddRoomDialog, icon: const Icon(Icons.add)),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final room = rooms[index];
                return Card(
                  color: Colors.white10,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.bed, color: Colors.white),
                    title: Text(
                      "Xona #${room['xona_raqami']}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      "${room['xona_turi']} - \$${room['narx']}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: Text(
                      room['status'],
                      style: TextStyle(
                        color: room['status'] == "Bo'sh"
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const WifiSuiteApp());

class WifiSuiteApp extends StatelessWidget {
  const WifiSuiteApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wi-Fi Suite',
      theme: ThemeData.dark(useMaterial3: true),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<dynamic> interfaces = [];
  List<dynamic> accessPoints = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);
    try {
      // 1. جلب بيانات الشبكة من Go Engine (المنفذ 8081)
      final goResponse = await http.get(Uri.parse('http://127.0.0.1:8081/interfaces'));
      if (goResponse.statusCode == 200) {
        interfaces = jsonDecode(goResponse.body);
      }

      // 2. جلب نقاط الوصول من Spring Boot (المنفذ 8083)
      final javaResponse = await http.get(Uri.parse('http://127.0.0.1:8083/api/ap'));
      if (javaResponse.statusCode == 200) {
        accessPoints = jsonDecode(javaResponse.body);
      }
    } catch (e) {
      debugPrint("Error fetching data: $e");
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wi-Fi Suite Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchData)
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Network Interfaces (Go Engine)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                ...interfaces.map((i) => ListTile(
                  leading: Icon(i['up'] ? Icons.wifi : Icons.wifi_off, color: i['up'] ? Colors.green : Colors.red),
                  title: Text(i['name']),
                  subtitle: Text('IPs: ${i['addrs'].join(", ")}'),
                )),
                const Divider(height: 32, color: Colors.grey),
                const Text('Access Points (Spring Boot API)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
                ...accessPoints.map((ap) => ListTile(
                  leading: const Icon(Icons.router, color: Colors.orange),
                  title: Text(ap['ssid']),
                  subtitle: Text('BSSID: ${ap['bssid']} | RSSI: ${ap['rssi']} dBm'),
                )),
              ],
            ),
    );
  }
}

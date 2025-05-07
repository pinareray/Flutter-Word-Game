import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/firestore_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final FirestoreService firestoreService;
  final user = FirebaseAuth.instance.currentUser!;
  int _dailyLimit = 10;
  bool _isLoading = true;

  String? userName;
  String? email;
  DateTime? createdAt;

  @override
  void initState() {
    super.initState();
    firestoreService = FirestoreService(uid: user.uid);
    _loadSettingsAndProfile();
  }

  Future<void> _loadSettingsAndProfile() async {
    try {
      final settings = await firestoreService.getUserSettings();
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      final data = doc.data();
      setState(() {
        _dailyLimit = settings['dailyLimit'] ?? 10;
        userName = data?['userName'] ?? 'Bilinmiyor';
        email = data?['email'] ?? 'Yok';
        final timestamp = data?['createdAt'];
        createdAt =
            timestamp != null ? (timestamp as Timestamp).toDate() : null;
        _isLoading = false;
      });
    } catch (e) {
      print("❌ HATA (profil yükleme): $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ayarlar yüklenirken hata oluştu.")),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateLimit(int newLimit) async {
    setState(() => _isLoading = true);
    await firestoreService.updateUserSettings(dailyLimit: newLimit);
    setState(() {
      _dailyLimit = newLimit;
      _isLoading = false;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Günlük limit güncellendi")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ayarlar")),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(20),
                child: ListView(
                  children: [
                    const Text(
                      "👤 Profil Bilgileri",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text("Kullanıcı adı: $userName"),
                    Text("E-posta: $email"),
                    Text(
                      "Hesap oluşturma: ${createdAt != null ? "${createdAt!.day}.${createdAt!.month}.${createdAt!.year}" : 'Bilinmiyor'}",
                    ),
                    const Divider(height: 40),
                    const Text(
                      "🔁 Günlük Tekrar Limiti",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: _dailyLimit,
                      items:
                          [5, 10, 15, 20, 30]
                              .map(
                                (limit) => DropdownMenuItem(
                                  value: limit,
                                  child: Text("$limit kelime"),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          _updateLimit(value);
                        }
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Limit Seç",
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}

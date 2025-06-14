// lib/screens/home/views/penggunaan/target_pengguna.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:emonic/screens/home/views/database/database_helper.dart';
import 'package:emonic/screens/home/views/penggunaan/history_target_screen.dart';
import 'package:emonic/screens/home/views/penggunaan/berhasil_input_screen.dart';

class TargetPenggunaanScreen extends StatefulWidget {
  const TargetPenggunaanScreen({Key? key}) : super(key: key);

  @override
  State<TargetPenggunaanScreen> createState() => _TargetPenggunaanScreenState();
}

class _TargetPenggunaanScreenState extends State<TargetPenggunaanScreen> {
  String? selectedGolongan;
  String? selectedParameter;
  DateTime? startDate;
  DateTime? endDate;
  final targetController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Daftar opsi untuk dropdown
  List<String> golonganOptions = [
    "R-1/TR Daya 900 VA",
    "R-1/TR Daya 1.300 VA",
    "R-2/TR Daya 3.500 VA",
    "R-3/TR Daya 6.600 VA",
    "B-2/TR Daya 200 kVA",
    "P-1/TR Untuk Penerangan Jalan Umum"
  ];

  List<String> parameterOptions = [
    "Daya Listrik (kWh)",
    "Biaya (Rp)",
  ];

  // Fungsi untuk menampilkan date picker
  Future<void> pickDate({required bool isStart}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? DateTime.now() : (startDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  // Fungsi untuk menyimpan data ke SQLite
  void _saveToSQLite() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (selectedGolongan != null &&
          selectedParameter != null &&
          startDate != null &&
          endDate != null &&
          targetController.text.isNotEmpty) {

        // Dapatkan userId saat ini dari Firebase Authentication
        final userId = FirebaseAuth.instance.currentUser?.uid;

        if (userId == null) {
          // Tampilkan pesan error jika pengguna belum login
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Anda harus login untuk menyimpan target.")),
          );
          return; // Hentikan proses penyimpanan
        }

        try {
          Map<String, dynamic> targetData = {
            'userId': userId, // <--- Tambahkan userId di sini
            'golongan': selectedGolongan,
            'parameter': selectedParameter,
            'startDate': startDate!.toIso8601String(),
            'endDate': endDate!.toIso8601String(),
            'target': targetController.text,
            'createdAt': DateTime.now().toIso8601String(),
          };

          await _databaseHelper.insertTarget(targetData);

          // Navigasi ke BerhasilInputScreen setelah berhasil menyimpan
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BerhasilInputScreen()),
          );

        } catch (e) {
          // Handle error dengan lebih baik, misalnya tampilkan dialog error
          print("Terjadi error saat menyimpan data: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Terjadi kesalahan: $e")),
          );
        }
      }
    } else {
      print("Form tidak valid"); // Ini untuk debugging
    }
  }

  // Fungsi untuk memeriksa apakah semua field telah terisi
  bool _isFormFilled() {
    return selectedGolongan != null &&
        selectedParameter != null &&
        startDate != null &&
        endDate != null &&
        targetController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text("Target Penggunaan"),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Riwayat Target',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const HistoryTargetScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.lightBlueAccent, Colors.blue],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          const Text(
                            "⚡ TARGET ⚡",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                              shadows: [
                                Shadow(blurRadius: 5, color: Colors.black26)
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const Text(
                            "PENGGUNAAN",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              shadows: [
                                Shadow(blurRadius: 5, color: Colors.black26)
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 30),
                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "Golongan Rumah Tangga",
                                  style: TextStyle(color: Colors.white70),
                                ),
                                const SizedBox(height: 8),
                                _buildRoundedDropdown(
                                  label: "Golongan Rumah Tangga",
                                  value: selectedGolongan,
                                  items: golonganOptions,
                                  onChanged: (value) =>
                                      setState(() => selectedGolongan = value),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "Parameter Target",
                                  style: TextStyle(color: Colors.white70),
                                ),
                                const SizedBox(height: 8),
                                _buildRoundedDropdown(
                                  label: "Parameter Target",
                                  value: selectedParameter,
                                  items: parameterOptions,
                                  onChanged: (value) =>
                                      setState(() => selectedParameter = value),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "Waktu Mulai",
                                  style: TextStyle(color: Colors.white70),
                                ),
                                const SizedBox(height: 8),
                                _buildRoundedDateField(
                                  label: "Waktu Mulai",
                                  selectedDate: startDate,
                                  onTap: () => pickDate(isStart: true),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "Waktu Akhir",
                                  style: TextStyle(color: Colors.white70),
                                ),
                                const SizedBox(height: 8),
                                _buildRoundedDateField(
                                  label: "Waktu Akhir",
                                  selectedDate: endDate,
                                  onTap: () => pickDate(isStart: false),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "Nilai Target",
                                  style: TextStyle(color: Colors.white70),
                                ),
                                const SizedBox(height: 8),
                                _buildRoundedTextField(
                                    label: "Nilai Target",
                                    controller: targetController),
                                const SizedBox(height: 30),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isFormFilled()
                                        ? _saveToSQLite
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16, horizontal: 50),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      backgroundColor: _isFormFilled()
                                          ? const Color.fromARGB(
                                              255, 250, 204, 2)
                                          : Colors.lightBlue[100],
                                      foregroundColor: _isFormFilled()
                                          ? Colors.blue
                                          : Colors.white,
                                      textStyle:
                                          const TextStyle(fontSize: 18),
                                    ),
                                    child: Text(
                                      "Simpan",
                                      style: TextStyle(
                                        color: _isFormFilled()
                                            ? const Color.fromARGB(
                                                255, 255, 255, 255)
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Widget untuk membuat dropdown dengan tampilan yang diinginkan
  Widget _buildRoundedDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item, style: const TextStyle(color: Colors.black)),
          );
        }).toList(),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[700]),
          border: InputBorder.none,
        ),
        style: const TextStyle(color: Colors.black),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label harus dipilih';
          }
          return null;
        },
        icon: Icon(Icons.arrow_drop_down, color: Colors.grey[700]),
        isExpanded: true,
      ),
    );
  }

  // Widget untuk membuat input field tanggal dengan tampilan yang diinginkan
  Widget _buildRoundedDateField({
    required String label,
    required DateTime? selectedDate,
    required VoidCallback onTap,
  }) {
    return TextFormField(
      readOnly: true,
      onTap: onTap,
      controller: TextEditingController(
        text: selectedDate != null
            ? "${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}"
            : "",
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[700]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        suffixIcon: Icon(Icons.calendar_today, color: Colors.grey[700]),
      ),
      validator: (value) {
        if (selectedDate == null) {
          return '$label harus dipilih';
        }
        return null;
      },
      style: const TextStyle(color: Colors.black),
    );
  }

  // Widget untuk membuat input field teks dengan tampilan yang diinginkan
  Widget _buildRoundedTextField({
    required String label,
    required TextEditingController controller,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[700]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label tidak boleh kosong';
        }
        return null;
      },
      style: const TextStyle(color: Colors.black),
    );
  }
}
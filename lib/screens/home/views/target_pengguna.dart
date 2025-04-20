import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final _formKey = GlobalKey<FormState>();  // GlobalKey untuk form

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

  // Fungsi untuk memilih tanggal
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

  // Fungsi untuk menyimpan data ke Firestore
  void _saveToFirestore() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Validasi berhasil
      if (selectedGolongan != null &&
          selectedParameter != null &&
          startDate != null &&
          endDate != null &&
          targetController.text.isNotEmpty) {
        try {
          // Simpan data ke Firestore
          await FirebaseFirestore.instance.collection('targets').add({
            'golongan': selectedGolongan,
            'parameter': selectedParameter,
            'startDate': Timestamp.fromDate(startDate!),
            'endDate': Timestamp.fromDate(endDate!),
            'target': targetController.text,
            'createdAt': Timestamp.now(),
          });

          print("Data berhasil disimpan");
          // Kosongkan form setelah data disimpan
          targetController.clear();
          setState(() {
            selectedGolongan = null;
            selectedParameter = null;
            startDate = null;
            endDate = null;
          });
        } catch (e) {
          print("Terjadi error saat menyimpan data: $e");
        }
      }
    } else {
      // Jika form tidak valid
      print("Form tidak valid");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("⚡ Target Penggunaan")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(  // Tambahkan Form untuk validasi
          key: _formKey,  // Kunci form untuk validasi
          child: Column(
            children: [
              // Dropdown untuk Golongan Rumah Tangga
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: "Golongan Rumah Tangga"),
                value: selectedGolongan,
                onChanged: (value) => setState(() => selectedGolongan = value),
                validator: (value) {
                  if (value == null) {
                    return 'Golongan harus dipilih';
                  }
                  return null;
                },
                items: golonganOptions
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
              ),
              SizedBox(height: 12),
              // Dropdown untuk Parameter Target
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: "Parameter Target"),
                value: selectedParameter,
                onChanged: (value) => setState(() => selectedParameter = value),
                validator: (value) {
                  if (value == null) {
                    return 'Parameter harus dipilih';
                  }
                  return null;
                },
                items: parameterOptions
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
              ),
              SizedBox(height: 12),
              // Tanggal Mulai
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Waktu Mulai",
                ),
                onTap: () => pickDate(isStart: true),
                controller: TextEditingController(
                    text: startDate != null
                        ? "${startDate!.day}/${startDate!.month}/${startDate!.year}"
                        : ""),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tanggal mulai harus dipilih';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              // Tanggal Akhir
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Waktu Akhir",
                ),
                onTap: () => pickDate(isStart: false),
                controller: TextEditingController(
                    text: endDate != null
                        ? "${endDate!.day}/${endDate!.month}/${endDate!.year}"
                        : ""),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tanggal akhir harus dipilih';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              // Nilai Target
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Nilai Target",
                ),
                controller: targetController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nilai target tidak boleh kosong';
                  }
                  return null;  // Validasi berhasil jika tidak ada error
                },
              ),
              SizedBox(height: 20),
              // Tombol Simpan
              ElevatedButton(
                onPressed: _saveToFirestore,  // Panggil simpan ke Firestore
                child: Text("Simpan"),
              ),
              SizedBox(height: 20),
              // Menampilkan Data dari Firestore
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('targets').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text("Tidak ada data target"));
                    }

                    var data = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        var target = data[index];
                        return ListTile(
                          title: Text("Golongan: ${target['golongan']}"),
                          subtitle: Text("Parameter: ${target['parameter']}"),
                          trailing: Text("Target: ${target['target']}"),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

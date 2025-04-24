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
  final _formKey = GlobalKey<FormState>();
  DocumentSnapshot? editingTarget;

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

  void _saveToFirestore() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (selectedGolongan != null &&
          selectedParameter != null &&
          startDate != null &&
          endDate != null &&
          targetController.text.isNotEmpty) {
        try {
          if (editingTarget != null) {
            await FirebaseFirestore.instance
                .collection('targets')
                .doc(editingTarget!.id)
                .update({
              'golongan': selectedGolongan,
              'parameter': selectedParameter,
              'startDate': Timestamp.fromDate(startDate!),
              'endDate': Timestamp.fromDate(endDate!),
              'target': targetController.text,
              'updatedAt': Timestamp.now(),
            });
          } else {
            await FirebaseFirestore.instance.collection('targets').add({
              'golongan': selectedGolongan,
              'parameter': selectedParameter,
              'startDate': Timestamp.fromDate(startDate!),
              'endDate': Timestamp.fromDate(endDate!),
              'target': targetController.text,
              'createdAt': Timestamp.now(),
            });
          }

          print("Data berhasil disimpan");

          setState(() {
            editingTarget = null;
            selectedGolongan = null;
            selectedParameter = null;
            startDate = null;
            endDate = null;
            targetController.clear();
          });
        } catch (e) {
          print("Terjadi error saat menyimpan data: $e");
        }
      }
    } else {
      print("Form tidak valid");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.lightBlueAccent, Colors.blue],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "⚡ TARGET ⚡",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                      shadows: [Shadow(blurRadius: 5, color: Colors.black26)],
                    ),
                  ),
                  const Text(
                    "PENGGUNAAN",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      shadows: [Shadow(blurRadius: 5, color: Colors.black26)],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildRoundedDropdown(
                          label: "Golongan Rumah Tangga",
                          value: selectedGolongan,
                          items: golonganOptions,
                          onChanged: (value) => setState(() => selectedGolongan = value),
                        ),
                        const SizedBox(height: 12),
                        _buildRoundedDropdown(
                          label: "Parameter Target",
                          value: selectedParameter,
                          items: parameterOptions,
                          onChanged: (value) => setState(() => selectedParameter = value),
                        ),
                        const SizedBox(height: 12),
                        _buildRoundedDateField("Waktu Mulai", startDate, () => pickDate(isStart: true)),
                        const SizedBox(height: 12),
                        _buildRoundedDateField("Waktu Akhir", endDate, () => pickDate(isStart: false)),
                        const SizedBox(height: 12),
                        _buildRoundedTextField("Nilai Target", targetController),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _saveToFirestore,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            backgroundColor: Colors.lightBlue.shade100,
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                          child: const Text("Simpan"),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Divider(color: Colors.white),
                  const SizedBox(height: 12),
                  const Text(
                    "Histori Target",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('targets')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Text("Belum ada target", style: TextStyle(color: Colors.white));
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final doc = snapshot.data!.docs[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final start = (data['startDate'] as Timestamp).toDate();
                          final end = (data['endDate'] as Timestamp).toDate();

                          return Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              title: Text("${data['golongan']} - ${data['parameter']}"),
                              subtitle: Text(
                                  "Target: ${data['target']} \n${start.day}/${start.month}/${start.year} - ${end.day}/${end.month}/${end.year}"),
                              isThreeLine: true,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {
                                      setState(() {
                                        editingTarget = doc;
                                        selectedGolongan = data['golongan'];
                                        selectedParameter = data['parameter'];
                                        startDate = start;
                                        endDate = end;
                                        targetController.text = data['target'];
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      await FirebaseFirestore.instance
                                          .collection('targets')
                                          .doc(doc.id)
                                          .delete();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoundedDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      value: value,
      onChanged: onChanged,
      validator: (val) => val == null ? '$label harus dipilih' : null,
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
    );
  }

  Widget _buildRoundedDateField(String label, DateTime? date, VoidCallback onTap) {
    return TextFormField(
      readOnly: true,
      onTap: onTap,
      controller: TextEditingController(
          text: date != null ? "${date.day}/${date.month}/${date.year}" : ""),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (val) => val == null || val.isEmpty ? '$label harus dipilih' : null,
    );
  }

  Widget _buildRoundedTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (val) => val == null || val.isEmpty ? '$label tidak boleh kosong' : null,
    );
  }
}

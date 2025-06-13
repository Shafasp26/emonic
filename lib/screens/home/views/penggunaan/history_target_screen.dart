import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HistoryTargetScreen extends StatefulWidget {
  const HistoryTargetScreen({super.key});

  @override
  State<HistoryTargetScreen> createState() => _HistoryTargetScreenState();
}

class _HistoryTargetScreenState extends State<HistoryTargetScreen> {
  String formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Future<void> _showEditDialog(
      BuildContext context, DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;

    final TextEditingController targetController =
        TextEditingController(text: data['target']);
    DateTime? startDate = data['startDate']?.toDate();
    DateTime? endDate = data['endDate']?.toDate();

    String selectedGolongan = data['golongan'];
    String selectedParameter = data['parameter'];

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) => AlertDialog(
            title: const Text("Edit Target"),
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            content: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 400.0,
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          labelText: "Golongan",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        value: selectedGolongan,
                        onChanged: (String? newValue) {
                          setStateDialog(() {
                            selectedGolongan = newValue!;
                          });
                        },
                        items: [
                          "R-1/TR Daya 900 VA",
                          "R-1/TR Daya 1.300 VA",
                          "R-2/TR Daya 3.500 VA",
                          "R-3/TR Daya 6.600 VA",
                          "B-2/TR Daya 200 kVA",
                          "P-1/TR Untuk Penerangan Jalan"
                        ].map((golongan) {
                          return DropdownMenuItem<String>(
                            value: golongan,
                            child: Text(golongan),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 400.0,
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          labelText: "Parameter",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        value: selectedParameter,
                        onChanged: (String? newValue) {
                          setStateDialog(() {
                            selectedParameter = newValue!;
                          });
                        },
                        items: [
                          "Daya Listrik (kWh)",
                          "Biaya (Rp)",
                        ].map((parameter) {
                          return DropdownMenuItem<String>(
                            value: parameter,
                            child: Text(parameter),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: targetController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Nilai Target",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      title: Text(
                        "Waktu Mulai: ${startDate != null ? formatDate(Timestamp.fromDate(startDate!)) : ''}",
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: startDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setStateDialog(() => startDate = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      title: Text(
                        "Waktu Akhir: ${endDate != null ? formatDate(Timestamp.fromDate(endDate!)) : ''}",
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: endDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setStateDialog(() => endDate = picked);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Batal"),
              ),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('targets')
                      .doc(doc.id)
                      .update({
                    'golongan': selectedGolongan,
                    'parameter': selectedParameter,
                    'target': targetController.text,
                    'startDate': Timestamp.fromDate(startDate!),
                    'endDate': Timestamp.fromDate(endDate!),
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Target berhasil diperbarui")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: const Text(
                  "Simpan",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteTarget(String docId) async {
    await FirebaseFirestore.instance.collection('targets').doc(docId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Target berhasil dihapus")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Target"),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('targets')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Terjadi kesalahan"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text("Belum ada data target"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.blue[50], // Warna latar belakang Card diubah menjadi biru muda
                child: ListTile(
                  title: Text(data['golongan'] ?? ''),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Parameter: ${data['parameter'] ?? ''}"),
                      Text("Target: ${data['target'] ?? ''}"),
                      Text(
                        "Periode: ${formatDate(data['startDate'])} - ${formatDate(data['endDate'])}",
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        color: Colors.green,
                        onPressed: () {
                          _showEditDialog(context, doc);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        color: Colors.red,
                        onPressed: () {
                          _deleteTarget(doc.id);
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
    );
  }
}
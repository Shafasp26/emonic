import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:emonic/constants/colors.dart';

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
            title: Text(
              "Edit Target",
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: AppColors.white,
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
                          fillColor: AppColors.white,
                          labelText: "Golongan",
                          labelStyle: TextStyle(color: AppColors.textGrey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: AppColors.primaryBlue),
                          ),
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
                          "P-1/TR Untuk Penerangan Jalan Umum"
                        ].map((golongan) {
                          return DropdownMenuItem<String>(
                            value: golongan,
                            child: Text(
                              golongan,
                              style: TextStyle(color: AppColors.black),
                            ),
                          );
                        }).toList(),
                        style: TextStyle(color: AppColors.black),
                        icon: Icon(Icons.arrow_drop_down,
                            color: AppColors.textGrey),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 400.0,
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.white,
                          labelText: "Parameter",
                          labelStyle: TextStyle(color: AppColors.textGrey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: AppColors.primaryBlue),
                          ),
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
                            child: Text(
                              parameter,
                              style: TextStyle(color: AppColors.black),
                            ),
                          );
                        }).toList(),
                        style: TextStyle(color: AppColors.black),
                        icon: Icon(Icons.arrow_drop_down,
                            color: AppColors.textGrey),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: targetController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: AppColors.black),
                      decoration: InputDecoration(
                        labelText: "Nilai Target",
                        labelStyle: TextStyle(color: AppColors.textGrey),
                        filled: true,
                        fillColor: AppColors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primaryBlue),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.grey),
                      ),
                      child: ListTile(
                        title: Text(
                          "Waktu Mulai: ${startDate != null ? formatDate(Timestamp.fromDate(startDate!)) : 'Pilih tanggal'}",
                          style: TextStyle(color: AppColors.black),
                        ),
                        trailing: Icon(Icons.calendar_today,
                            color: AppColors.primaryBlue),
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
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.grey),
                      ),
                      child: ListTile(
                        title: Text(
                          "Waktu Akhir: ${endDate != null ? formatDate(Timestamp.fromDate(endDate!)) : 'Pilih tanggal'}",
                          style: TextStyle(color: AppColors.black),
                        ),
                        trailing: Icon(Icons.calendar_today,
                            color: AppColors.primaryBlue),
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
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textGrey,
                ),
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
                    SnackBar(
                      content: const Text("Target berhasil diperbarui"),
                      backgroundColor: AppColors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Simpan"),
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
      SnackBar(
        content: const Text("Target berhasil dihapus"),
        backgroundColor: AppColors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Riwayat Target",
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('targets')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Terjadi kesalahan",
                style: TextStyle(color: AppColors.red),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryBlue,
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: AppColors.textGrey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Belum ada data target",
                    style: TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                color: AppColors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.chartBlue,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              data['golongan'] ?? '',
                              style: TextStyle(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                color: AppColors.green,
                                onPressed: () {
                                  _showEditDialog(context, doc);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                color: AppColors.red,
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(
                                        "Konfirmasi Hapus",
                                        style: TextStyle(color: AppColors.red),
                                      ),
                                      content: const Text(
                                        "Apakah Anda yakin ingin menghapus target ini?",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text(
                                            "Batal",
                                            style: TextStyle(
                                                color: AppColors.textGrey),
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _deleteTarget(doc.id);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.red,
                                          ),
                                          child: const Text(
                                            "Hapus",
                                            style: TextStyle(
                                                color: AppColors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.track_changes,
                            color: AppColors.primaryBlue,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Parameter: ${data['parameter'] ?? ''}",
                            style: TextStyle(
                              color: AppColors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.flag,
                            color: AppColors.yellow,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Target: ${data['target'] ?? ''}",
                            style: TextStyle(
                              color: AppColors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.date_range,
                            color: AppColors.textGrey,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Periode: ${formatDate(data['startDate'])} - ${formatDate(data['endDate'])}",
                            style: TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 14,
                            ),
                          ),
                        ],
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

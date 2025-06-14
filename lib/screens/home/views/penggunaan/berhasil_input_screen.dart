import 'package:flutter/material.dart';
import 'package:emonic/screens/home/views/penggunaan/history_target_screen.dart';

class BerhasilInputScreen extends StatefulWidget {
  const BerhasilInputScreen({super.key});

  @override
  State<BerhasilInputScreen> createState() => _BerhasilInputScreenState();
}

class _BerhasilInputScreenState extends State<BerhasilInputScreen> {
  @override
  void initState() {
    super.initState();
    // Tunggu beberapa detik sebelum navigasi ke history screen
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        // Navigasi langsung ke history dengan push (bukan replace)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HistoryTargetScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Stack(
              alignment: Alignment.center,
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.green,
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
                Positioned(
                  left: 10,
                  bottom: 10,
                  child: Transform.rotate(
                    angle: -0.2,
                    child: const Icon(
                      Icons.bolt,
                      color: Colors.yellow,
                      size: 30,
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: Transform.rotate(
                    angle: 0.2,
                    child: const Icon(
                      Icons.bolt,
                      color: Colors.yellow,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Berhasil Input Harian",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
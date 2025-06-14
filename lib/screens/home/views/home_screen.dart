import 'package:flutter/material.dart';
import 'package:emonic/screens/home/views/penggunaan/target_pengguna.dart';
import 'package:emonic/screens/home/views/berita.dart';
import 'package:emonic/screens/home/views/settings_screen.dart';
import 'package:emonic/constants/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeContent(),
    const TargetPenggunaanScreen(),
    const Center(child: Text('Statistik')),
    BeritaScreen(),
    const SettingsScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: _currentIndex == 0
          ? AppBar(
              backgroundColor: AppColors.primaryBlue,
              elevation: 0,
              title: Row(
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: 30,
                    width: 30,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'EMONIC',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            )
          : null,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.textGrey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Penggunaan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insert_chart_outlined),
            label: 'Statistik',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.language),
            label: 'Berita',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}

// Create a new widget for the home content
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUsageCard(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildEnergyCard(
                    "Today's energy",
                    '36.2',
                    'kWh',
                    const Color(0xFFFFF9E6),
                    Icons.lightbulb_outline,
                    const Color(0xFFFFCC00),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildEnergyCard(
                    'Yesterday',
                    '42.0',
                    'kWh',
                    const Color(0xFFF5F5F5),
                    Icons.receipt_outlined,
                    Colors.black54,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildRewardCard(),
            const SizedBox(height: 16),
            _buildConsumptionChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textGrey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flash_on, color: AppColors.red),
              const SizedBox(width: 8),
              Text(
                '30.276KWh',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.black,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.orange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '40%',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Electricity Usage',
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: 0.4,
            backgroundColor: AppColors.progressGrey,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.red),
            minHeight: 5,
            borderRadius: BorderRadius.circular(2.5),
          ),
        ],
      ),
    );
  }

  Widget _buildEnergyCard(String title, String value, String unit,
      Color backgroundColor, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: value,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: ' $unit',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRewardCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE5F3FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                'Reward',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Pengurangan konsumsi Energi (/kWh)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDayProgress('Sun', 0.8),
              _buildDayProgress('Mon', 0.6),
              _buildDayProgress('Tues', 0.9),
              _buildDayProgress('Wed', 0.4),
              _buildDayProgress('Thurs', 0.5),
              _buildDayProgress('Fri', 0.7),
              _buildDayProgress('Sat', 0.3),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFDD00),
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '26',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayProgress(String day, double progress) {
    return Column(
      children: [
        Container(
          height: 50,
          width: 5,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Stack(
            children: [
              Positioned(
                bottom: 0,
                child: Container(
                  height: 50 * progress,
                  width: 5,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          day,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildConsumptionChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Electricity Consumption Over Time',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.more_horiz),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              Text(
                '140.65',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              Text(
                ' kWh',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 150,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://via.placeholder.com/400x150/FFFFFF/2196F3?text=Chart',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: const Stack(),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              7,
              (index) => Text(
                '${13 + index}:00',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:prayer_times/prayer_times.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  Map<String, String>? prayerTimes;
  String currentPrayer = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPrayerTimes();
  }

  Future<void> loadPrayerTimes() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Get saved location from settings
      final prefs = await SharedPreferences.getInstance();
      String country = prefs.getString('country') ?? 'مصر';
      String city = prefs.getString('city') ?? 'القاهرة';

      // Map Arabic names to English for the API
      Map<String, String> cityMap = {
        'مصر': 'Cairo',
        'السعودية': 'Riyadh',
        'الإمارات': 'Dubai',
        'الكويت': 'Kuwait',
        'قطر': 'Doha',
        'عمان': 'Muscat',
        'البحرين': 'Manama',
        'الأردن': 'Amman',
        'المغرب': 'Casablanca',
        'الجزائر': 'Algiers',
        'تونس': 'Tunis',
        'ليبيا': 'Tripoli',
        'سوريا': 'Damascus',
        'العراق': 'Baghdad',
        'اليمن': 'Sanaa',
        'السودان': 'Khartoum',
        'فلسطين': 'Gaza',
        'لبنان': 'Beirut',
      };

      // Map Arabic country to English
      Map<String, String> countryMap = {
        'مصر': 'Egypt',
        'السعودية': 'Saudi Arabia',
        'الإمارات': 'UAE',
        'الكويت': 'Kuwait',
        'قطر': 'Qatar',
        'عمان': 'Oman',
        'البحرين': 'Bahrain',
        'الأردن': 'Jordan',
        'المغرب': 'Morocco',
        'الجزائر': 'Algeria',
        'تونس': 'Tunisia',
        'ليبيا': 'Libya',
        'سوريا': 'Syria',
        'العراق': 'Iraq',
        'اليمن': 'Yemen',
        'السودان': 'Sudan',
        'فلسطين': 'Palestine',
        'لبنان': 'Lebanon',
      };

      String cityEnglish = cityMap[city] ?? 'Cairo';
      String countryEnglish = countryMap[country] ?? 'Egypt';

      // Get prayer times
      final prayerTimesObj = PrayerTimes();
      final times = await prayerTimesObj.getTimes(
        city: cityEnglish,
        country: countryEnglish,
        method: PrayerMethod.MWL, // Muslim World League
      );

      setState(() {
        prayerTimes = {
          'الفجر': times.fajr,
          'الشروق': times.sunrise,
          'الظهر': times.dhuhr,
          'العصر': times.asr,
          'المغرب': times.maghrib,
          'العشاء': times.isha,
        };
        currentPrayer = getCurrentPrayer(times);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        prayerTimes = null;
      });
      print('Error loading prayer times: $e');
    }
  }

  String getCurrentPrayer(PrayerTimes times) {
    final now = DateTime.now();
    final timeFormat = 'HH:mm';

    // Convert prayer times to DateTime
    List<Map<String, dynamic>> prayers = [
      {'name': 'الفجر', 'time': times.fajr},
      {'name': 'الشروق', 'time': times.sunrise},
      {'name': 'الظهر', 'time': times.dhuhr},
      {'name': 'العصر', 'time': times.asr},
      {'name': 'المغرب', 'time': times.maghrib},
      {'name': 'العشاء', 'time': times.isha},
    ];

    String current = '';

    // Find current prayer
    for (int i = 0; i < prayers.length; i++) {
      final prayerTime = prayers[i]['time'];
      final parts = prayerTime.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final prayerDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // Check if current time is after this prayer
      if (now.isAfter(prayerDateTime) || now.difference(prayerDateTime).inMinutes < 5) {
        current = prayers[i]['name'];
      }
    }

    // If no prayer found, show next prayer
    if (current.isEmpty) {
      for (var prayer in prayers) {
        final parts = prayer['time'].split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final prayerDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          hour,
          minute,
        );
        if (now.isBefore(prayerDateTime)) {
          current = '🔜 ${prayer['name']} (القادمة)';
          break;
        }
      }
    }

    return current.isEmpty ? 'لا توجد صلاة حالياً' : current;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🕌 مواقيت الصلاة'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadPrayerTimes,
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            )
          : prayerTimes == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 80,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'حدث خطأ في تحميل المواقيت',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: loadPrayerTimes,
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Current prayer
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.green, Colors.greenAccent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'الصلاة الحالية',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              currentPrayer,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'بارك الله فيك ❤️',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'مواقيت اليوم',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Prayer times list
                      ...prayerTimes!.entries.map((entry) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: entry.key == currentPrayer.split(' ')[0]
                                ? Colors.green.withOpacity(0.1)
                                : Colors.white,
                            border: Border.all(
                              color: entry.key == currentPrayer.split(' ')[0]
                                  ? Colors.green
                                  : Colors.grey.shade300,
                              width: entry.key == currentPrayer.split(' ')[0] ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: entry.key == currentPrayer.split(' ')[0]
                                  ? Colors.green
                                  : Colors.grey.shade200,
                              child: Text(
                                entry.key[0],
                                style: TextStyle(
                                  color: entry.key == currentPrayer.split(' ')[0]
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              entry.key,
                              style: TextStyle(
                                fontWeight: entry.key == currentPrayer.split(' ')[0]
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: entry.key == currentPrayer.split(' ')[0]
                                    ? Colors.green
                                    : Colors.black,
                              ),
                            ),
                            trailing: Text(
                              entry.value,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 30),
                      // Prayer counter
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'الصلوات المؤداة اليوم',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Text(
                                        '5',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'من أصل 6 صلوات',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

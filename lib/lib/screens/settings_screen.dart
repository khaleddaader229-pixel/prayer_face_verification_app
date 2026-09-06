import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String selectedCountry = 'مصر';
  String selectedCity = 'القاهرة';
  bool notificationsEnabled = true;
  bool faceVerificationEnabled = true;

  final List<String> countries = [
    'مصر',
    'السعودية',
    'الإمارات',
    'الكويت',
    'قطر',
    'عمان',
    'البحرين',
    'الأردن',
    'المغرب',
    'الجزائر',
    'تونس',
    'ليبيا',
    'سوريا',
    'العراق',
    'اليمن',
    'السودان',
    'فلسطين',
    'لبنان',
  ];

  final Map<String, List<String>> cities = {
    'مصر': ['القاهرة', 'الإسكندرية', 'الجيزة', 'شرم الشيخ'],
    'السعودية': ['مكة', 'المدينة', 'الرياض', 'جدة'],
    'الإمارات': ['دبي', 'أبوظبي', 'الشارقة'],
    'الكويت': ['مدينة الكويت', 'الجهراء'],
    'قطر': ['الدوحة', 'الوكرة'],
    'عمان': ['مسقط', 'صلالة'],
    'البحرين': ['المنامة', 'المحرق'],
    'الأردن': ['عمان', 'الزرقاء'],
    'المغرب': ['الدار البيضاء', 'الرباط'],
    'الجزائر': ['الجزائر العاصمة', 'وهران'],
    'تونس': ['تونس العاصمة', 'صفاقس'],
    'ليبيا': ['طرابلس', 'بنغازي'],
    'سوريا': ['دمشق', 'حلب'],
    'العراق': ['بغداد', 'البصرة'],
    'اليمن': ['صنعاء', 'عدن'],
    'السودان': ['الخرطوم', 'أم درمان'],
    'فلسطين': ['القدس', 'غزة'],
    'لبنان': ['بيروت', 'طرابلس'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚙️ الإعدادات'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🔔 إعدادات التطبيق',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),

            // Country Selection
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🌍 الدولة',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedCountry,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    items: countries.map((country) {
                      return DropdownMenuItem(
                        value: country,
                        child: Text(country),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCountry = value!;
                        selectedCity = cities[selectedCountry]?.first ?? '';
                      });
                    },
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    '🏙️ المدينة',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedCity,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    items: cities[selectedCountry]?.map((city) {
                      return DropdownMenuItem(
                        value: city,
                        child: Text(city),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCity = value!;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Toggle Switches
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('🔊 تنبيه الصلاة'),
                    subtitle: const Text('تشغيل/إيقاف صوت الأذان'),
                    value: notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        notificationsEnabled = value;
                      });
                    },
                    activeColor: Colors.green,
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('📸 التحقق بالوجه'),
                    subtitle: const Text('تشغيل/إيقاف ميزة التعرف على الوجه'),
                    value: faceVerificationEnabled,
                    onChanged: (value) {
                      setState(() {
                        faceVerificationEnabled = value;
                      });
                    },
                    activeColor: Colors.green,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Save settings and go back
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ تم حفظ الإعدادات بنجاح'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('💾 حفظ الإعدادات'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

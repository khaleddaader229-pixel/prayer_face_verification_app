import 'package:prayer_times/prayer_times.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'notification_service.dart';

class PrayerService {
  static Future<void> scheduleAllPrayerNotifications() async {
    try {
      // Get saved location
      final prefs = await SharedPreferences.getInstance();
      String country = prefs.getString('country') ?? 'مصر';
      String city = prefs.getString('city') ?? 'القاهرة';

      // Map Arabic to English
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
        method: PrayerMethod.MWL,
      );

      // Cancel old notifications
      await NotificationService.cancelAllNotifications();

      // Schedule each prayer
      Map<String, String> prayers = {
        'الفجر': times.fajr,
        'الظهر': times.dhuhr,
        'العصر': times.asr,
        'المغرب': times.maghrib,
        'العشاء': times.isha,
      };

      final now = DateTime.now();
      for (var entry in prayers.entries) {
        String prayerName = entry.key;
        String prayerTimeStr = entry.value;

        // Parse time string
        List<String> parts = prayerTimeStr.split(':');
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);

        // Create DateTime for today
        DateTime prayerDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          hour,
          minute,
        );

        // If prayer time is in the past, schedule for tomorrow
        if (prayerDateTime.isBefore(now)) {
          prayerDateTime = prayerDateTime.add(const Duration(days: 1));
        }

        await NotificationService.schedulePrayerNotification(
          prayerName: prayerName,
          prayerTime: prayerTimeStr,
          dateTime: prayerDateTime,
        );

        print('✅ Scheduled $prayerName at $prayerTimeStr');
      }
    } catch (e) {
      print('❌ Error scheduling notifications: $e');
    }
  }

  static Future<Map<String, String>?> getPrayerTimes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String country = prefs.getString('country') ?? 'مصر';
      String city = prefs.getString('city') ?? 'القاهرة';

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

      final prayerTimesObj = PrayerTimes();
      final times = await prayerTimesObj.getTimes(
        city: cityEnglish,
        country: countryEnglish,
        method: PrayerMethod.MWL,
      );

      return {
        'الفجر': times.fajr,
        'الشروق': times.sunrise,
        'الظهر': times.dhuhr,
        'العصر': times.asr,
        'المغرب': times.maghrib,
        'العشاء': times.isha,
      };
    } catch (e) {
      print('❌ Error getting prayer times: $e');
      return null;
    }
  }
}

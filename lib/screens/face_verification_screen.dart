import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FaceVerificationScreen extends StatefulWidget {
  const FaceVerificationScreen({super.key});

  @override
  State<FaceVerificationScreen> createState() =>
      _FaceVerificationScreenState();
}

class _FaceVerificationScreenState extends State<FaceVerificationScreen> {
  bool isProcessing = false;
  bool isFaceVerified = false;
  String message = 'قم بتصوير وجهك لتأكيد الصلاة';
  bool hasRegisteredFace = false;
  int prayersCount = 0;

  @override
  void initState() {
    super.initState();
    checkRegisteredFace();
    loadPrayersCount();
  }

  Future<void> checkRegisteredFace() async {
    final prefs = await SharedPreferences.getInstance();
    final hasFace = prefs.getBool('has_registered_face') ?? false;
    setState(() {
      hasRegisteredFace = hasFace;
      if (!hasFace) {
        message = '📸 يرجى تسجيل وجهك أولاً من الإعدادات';
      }
    });
  }

  Future<void> loadPrayersCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prayersCount = prefs.getInt('prayers_count') ?? 0;
    });
  }

  Future<void> savePrayersCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('prayers_count', count);
    setState(() {
      prayersCount = count;
    });
  }

  Future<void> registerFace() async {
    setState(() {
      isProcessing = true;
      message = 'جاري تسجيل الوجه...';
    });

    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
      );

      if (image == null) {
        setState(() {
          isProcessing = false;
          message = '❌ تم إلغاء التسجيل';
        });
        return;
      }

      final inputImage = InputImage.fromFilePath(image.path);
      final faceDetector = GoogleMlKit.vision.faceDetector();
      final faces = await faceDetector.processImage(inputImage);

      if (faces.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('has_registered_face', true);
        setState(() {
          hasRegisteredFace = true;
          message = '✅ تم تسجيل الوجه بنجاح!';
          isProcessing = false;
        });
      } else {
        setState(() {
          message = '❌ لم يتم التعرف على وجه، حاول مرة أخرى';
          isProcessing = false;
        });
      }
    } catch (e) {
      setState(() {
        message = '❌ حدث خطأ: $e';
        isProcessing = false;
      });
    }
  }

  Future<void> verifyFace() async {
    setState(() {
      isProcessing = true;
      message = 'جاري التحقق من الوجه...';
    });

    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
      );

      if (image == null) {
        setState(() {
          isProcessing = false;
          message = '❌ تم إلغاء التحقق';
        });
        return;
      }

      final inputImage = InputImage.fromFilePath(image.path);
      final faceDetector = GoogleMlKit.vision.faceDetector();
      final faces = await faceDetector.processImage(inputImage);

      if (faces.isNotEmpty) {
        setState(() {
          isFaceVerified = true;
          isProcessing = false;
          message = '✅ بارك الله فيك ❤️';
        });
        int newCount = prayersCount + 1;
        await savePrayersCount(newCount);
        _showSuccessDialog();
      } else {
        setState(() {
          message = '❌ لم يتم التعرف على وجه، حاول مرة أخرى';
          isProcessing = false;
        });
      }
    } catch (e) {
      setState(() {
        message = '❌ حدث خطأ: $e';
        isProcessing = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('✅ تم التحقق بنجاح'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            const Text('بارك الله فيك ❤️',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('عدد الصلوات اليوم: $prayersCount',
                style: const TextStyle(fontSize: 18)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('تم'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📸 التحقق بالوجه'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.face, size: 100, color: Colors.green),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isFaceVerified
                    ? Colors.green.withOpacity(0.1)
                    : Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isFaceVerified ? Colors.green : Colors.blue,
                  width: 2,
                ),
              ),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.mosque, color: Colors.green),
                  const SizedBox(width: 10),
                  Text(
                    'الصلوات المؤداة اليوم: $prayersCount',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            if (!hasRegisteredFace)
              ElevatedButton.icon(
                onPressed: isProcessing ? null : registerFace,
                icon: const Icon(Icons.face_retouching_natural),
                label: const Text('📸 تسجيل الوجه'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            const SizedBox(height: 15),
            if (hasRegisteredFace && !isFaceVerified)
              ElevatedButton.icon(
                onPressed: isProcessing ? null : verifyFace,
                icon: isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.camera_alt),
                label: Text(
                  isProcessing ? 'جاري التحقق...' : '📸 التحقق الآن',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            const SizedBox(height: 15),
            if (isFaceVerified)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.check_circle),
                label: const Text('✅ تم التحقق'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }
}  }

  Future<void> loadPrayersCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prayersCount = prefs.getInt('prayers_count') ?? 0;
    });
  }

  Future<void> savePrayersCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('prayers_count', count);
    setState(() {
      prayersCount = count;
    });
  }

  Future<void> registerFace() async {
    setState(() {
      isProcessing = true;
      message = 'جاري تسجيل الوجه...';
    });

    try {
      // Pick image from camera
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
      );

      if (image == null) {
        setState(() {
          isProcessing = false;
          message = '❌ تم إلغاء التسجيل';
        });
        return;
      }

      // Process face detection
      final inputImage = InputImage.fromFilePath(image.path);
      final faceDetector = GoogleMlKit.vision.faceDetector();
      final faces = await faceDetector.processImage(inputImage);

      if (faces.isNotEmpty) {
        // Save face landmarks
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('has_registered_face', true);
        // In real app, you would save face features here
        setState(() {
          hasRegisteredFace = true;
          message = '✅ تم تسجيل الوجه بنجاح!';
          isProcessing = false;
        });
      } else {
        setState(() {
          message = '❌ لم يتم التعرف على وجه، حاول مرة أخرى';
          isProcessing = false;
        });
      }
    } catch (e) {
      setState(() {
        message = '❌ حدث خطأ: $e';
        isProcessing = false;
      });
    }
  }

  Future<void> verifyFace() async {
    setState(() {
      isProcessing = true;
      message = 'جاري التحقق من الوجه...';
    });

    try {
      // Pick image from camera
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
      );

      if (image == null) {
        setState(() {
          isProcessing = false;
          message = '❌ تم إلغاء التحقق';
        });
        return;
      }

      // Process face detection
      final inputImage = InputImage.fromFilePath(image.path);
      final faceDetector = GoogleMlKit.vision.faceDetector();
      final faces = await faceDetector.processImage(inputImage);

      if (faces.isNotEmpty) {
        // In real app, you would compare face features here
        // For demo, we'll just check if a face is detected
        setState(() {
          isFaceVerified = true;
          isProcessing = false;
          message = '✅ بارك الله فيك ❤️';
        });

        // Update prayer count
        int newCount = prayersCount + 1;
        await savePrayersCount(newCount);

        // Show success dialog
        _showSuccessDialog();
      } else {
        setState(() {
          message = '❌ لم يتم التعرف على وجه، حاول مرة أخرى';
          isProcessing = false;
        });
      }
    } catch (e) {
      setState(() {
        message = '❌ حدث خطأ: $e';
        isProcessing = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('✅ تم التحقق بنجاح'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 80,
            ),
            const SizedBox(height: 20),
            const Text(
              'بارك الله فيك ❤️',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'عدد الصلوات اليوم: $prayersCount',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Close this screen
            },
            child: const Text('تم'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📸 التحقق بالوجه'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            const Icon(
              Icons.face,
              size: 100,
              color: Colors.green,
            ),
            const SizedBox(height: 30),

            // Message
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isFaceVerified
                    ? Colors.green.withOpacity(0.1)
                    : Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isFaceVerified ? Colors.green : Colors.blue,
                  width: 2,
                ),
              ),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 30),

            // Prayer count
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.mosque, color: Colors.green),
                  const SizedBox(width: 10),
                  Text(
                    'الصلوات المؤداة اليوم: $prayersCount',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Buttons
            if (!hasRegisteredFace)
              ElevatedButton.icon(
                onPressed: isProcessing ? null : registerFace,
                icon: const Icon(Icons.face_retouching_natural),
                label: const Text('📸 تسجيل الوجه'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            const SizedBox(height: 15),

            if (hasRegisteredFace && !isFaceVerified)
              ElevatedButton.icon(
                onPressed: isProcessing ? null : verifyFace,
                icon: isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.camera_alt),
                label: Text(
                  isProcessing ? 'جاري التحقق...' : '📸 التحقق الآن',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            const SizedBox(height: 15),

            if (isFaceVerified)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.check_circle),
                label: const Text('✅ تم التحقق'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

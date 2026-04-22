// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:matka_dev/core/storage/auth_storage.dart';
import 'package:matka_dev/presentation/screens/add_utr_screen.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/constants/colors.dart';

Future<Uint8List> generateQrBytes(String data) async {
  final qrPainter = QrPainter(
    data: data,
    version: QrVersions.auto,
    gapless: true,
  );

  final picData = await qrPainter.toImageData(220);
  return picData!.buffer.asUint8List();
}

void showQrPaymentDialog(BuildContext context, double amount) async {
  int secondsLeft = 300;
  Timer? timer;

  final h = MediaQuery.of(context).size.height;
  final w = MediaQuery.of(context).size.width;

  final merchantId = await AuthStorage.getMerchantId();
  final qrBytes = await generateQrBytes(
    "upi://pay?pa=$merchantId"
    "&pn=${Uri.encodeComponent('Matka Dev')}"
    "&am=$amount"
    "&cu=INR",
  );

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setState) {
          timer ??= Timer.periodic(const Duration(seconds: 1), (t) {
            if (secondsLeft <= 0) {
              t.cancel();
              Navigator.pop(context);
            } else {
              setState(() => secondsLeft--);
            }
          });

          final minutes = (secondsLeft ~/ 60).toString().padLeft(2, '0');
          final secs = (secondsLeft % 60).toString().padLeft(2, '0');

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(w * 0.05),
            ),
            titlePadding: EdgeInsets.only(
              top: h * 0.02,
              left: w * 0.04,
              right: w * 0.04,
            ),
            title: Column(
              children: [
                Text(
                  "Scan QR to Add Funds",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: w * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: h * 0.008),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: w * 0.04,
                    vertical: h * 0.006,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Valid for $minutes:$secs",
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.w600,
                      fontSize: w * 0.032,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: h * 0.015),

                /// 🧾 QR Card
                Container(
                  padding: EdgeInsets.all(w * 0.04),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(w * 0.045),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Image.memory(
                    qrBytes,
                    width: w * 0.55,
                    height: w * 0.55,
                  ),
                ),

                SizedBox(height: h * 0.015),

                Text(
                  "Amount: ₹$amount",
                  style: TextStyle(
                    fontSize: w * 0.04,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                SizedBox(height: h * 0.008),

                Text(
                  "Scan using any UPI app",
                  style: TextStyle(
                    fontSize: w * 0.032,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            actionsPadding: EdgeInsets.symmetric(
              horizontal: w * 0.04,
              vertical: h * 0.02,
            ),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        timer?.cancel();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kPrimaryColor,
                        side:
                            const BorderSide(color: kPrimaryColor, width: 1.5),
                        padding: EdgeInsets.symmetric(
                          vertical: h * 0.018,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(w * 0.04),
                        ),
                      ),
                      child: const Text("Cancel"),
                    ),
                  ),
                  SizedBox(width: w * 0.03),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        padding: EdgeInsets.symmetric(
                          vertical: h * 0.018,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(w * 0.04),
                        ),
                      ),
                      onPressed: () {
                        timer?.cancel();
                        Navigator.pop(context);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddUtrScreen(amount: amount),
                          ),
                        );
                      },
                      child: const Text(
                        "I Have Paid",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );
    },
  ).then((_) => timer?.cancel());
}

import 'package:flutter/material.dart';

bool isOpenTimeClosed(String openTime) {
  final now = TimeOfDay.now();
  final parts = openTime.split(":");

  final open = TimeOfDay(
    hour: int.parse(parts[0]),
    minute: int.parse(parts[1]),
  );

  if (now.hour > open.hour) return true;
  if (now.hour == open.hour && now.minute >= open.minute) return true;

  return false;
}

bool isCloseTimeClosed(String closeTime) {
  final now = TimeOfDay.now();
  final parts = closeTime.split(":");

  final close = TimeOfDay(
    hour: int.parse(parts[0]),
    minute: int.parse(parts[1]),
  );

  if (now.hour > close.hour) return true;
  if (now.hour == close.hour && now.minute >= close.minute) return true;

  return false;
}

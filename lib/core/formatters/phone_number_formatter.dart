

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KazakhPhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    
    // If text is empty, return with +7
    if (text.isEmpty) {
      return TextEditingValue(
        text: '+7 ',
        selection: TextSelection.collapsed(offset: 3),
      );
    }
    
    // Remove all non-digit characters except + at the start
    String digitsOnly = text.replaceAll(RegExp(r'[^\d]'), '');
    
    // If it doesn't start with 7, ensure +7 is at the beginning
    if (!digitsOnly.startsWith('7')) {
      // If user typed something that starts with 7, keep it
      if (digitsOnly.isNotEmpty && digitsOnly[0] == '7') {
        // Already starts with 7, keep it
      } else {
        // Prepend 7 if not present
        if (digitsOnly.isEmpty || digitsOnly[0] != '7') {
          digitsOnly = '7$digitsOnly';
        }
      }
    }
    
    // Limit to 11 digits (7 + 10 digits)
    if (digitsOnly.length > 11) {
      digitsOnly = digitsOnly.substring(0, 11);
    }
    
    // Format: +7 XXX XXX XXXX
    String formatted = '+7 ';
    
    if (digitsOnly.length > 1) {
      final numberPart = digitsOnly.substring(1); // Remove the leading 7
      
      if (numberPart.length <= 3) {
        formatted += numberPart;
      } else if (numberPart.length <= 6) {
        formatted += '${numberPart.substring(0, 3)} ${numberPart.substring(3)}';
      } else {
        formatted += '${numberPart.substring(0, 3)} ${numberPart.substring(3, 6)} ${numberPart.substring(6)}';
      }
    }
    
    // Calculate cursor position
    int cursorPosition = formatted.length;
    
    // If user is deleting, adjust cursor position
    if (oldValue.text.length > newValue.text.length) {
      // User is deleting, try to maintain relative position
      final oldDigits = oldValue.text.replaceAll(RegExp(r'[^\d]'), '').length;
      final newDigits = digitsOnly.length;
      
      if (newDigits < oldDigits) {
        // Calculate position based on digit count
        if (newDigits <= 1) {
          cursorPosition = 3; // After +7 
        } else if (newDigits <= 4) {
          cursorPosition = 3 + newDigits; // After +7 and digits
        } else if (newDigits <= 7) {
          cursorPosition = 3 + 3 + 1 + (newDigits - 3); // After first group and space
        } else {
          cursorPosition = 3 + 3 + 1 + 3 + 1 + (newDigits - 6); // After second group and space
        }
      }
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}
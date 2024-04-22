import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todolist/constants/colors.dart';

class FontSettingsProvider extends ChangeNotifier {
  double _paragraph = 15;
  double get paragraph => _paragraph;

  double _heading = 18;
  double get heading => _heading;

  FontWeight _fontWeightHeadings = FontWeight.normal;
  FontWeight get fontWeight => _fontWeightHeadings;

  FontWeight _fontWeightParagraph = FontWeight.normal;
  FontWeight get fontWeightParagraph => _fontWeightParagraph;

  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;

  int _selectedColor = appContainerColor.value;
  int get selectedColor => _selectedColor;

  void setSelectedColor(int newColor) {
    _selectedColor = newColor;
    notifyListeners();
  }

  void headingIncrease() {
    if (_heading < 35) {
      _heading++;
      notifyListeners();
    }
  }

  void headingDecrease() {
    if (_heading > 18) {
      _heading--;
      notifyListeners();
    }
  }

  FontSettingsProvider() {
    loadFontSettings();
  }

  void increaseCounter() {
    if (_paragraph < 30) {
      _paragraph++;
      notifyListeners();
    }
  }

  void decreaseCounter() {
    if (_paragraph > 15) {
      _paragraph--;
      notifyListeners();
    }
  }

  void setFontWeight(FontWeight newWeight) {
    _fontWeightHeadings = newWeight;
    notifyListeners();
  }

  String fontWeightHeadingsToString() {
    // Convert FontWeight to a string for dropdown menu
    if (_fontWeightHeadings == FontWeight.bold) {
      return 'Bold';
    } else if (_fontWeightHeadings == FontWeight.normal) {
      return 'Normal';
    } else if (_fontWeightHeadings == FontWeight.w600) {
      return 'Semibold';
    } else {
      return '';
    }
  }

// Paragraph font settings
  void setParagraphFontWeight(FontWeight newWeight) {
    _fontWeightParagraph = newWeight;
    notifyListeners();
  }

  String fontParagraphWeighttoString() {
    // Convert FontWeight to a string for dropdown menu
    if (_fontWeightParagraph == FontWeight.bold) {
      return 'Bold';
    } else if (_fontWeightParagraph == FontWeight.normal) {
      return 'Normal';
    } else if (_fontWeightParagraph == FontWeight.w600) {
      return 'SemiBold';
    } else {
      return '';
    }
  }

// Save and load font settings
  Future<void> saveFontSettings() async {
    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('fontSettings')
          .doc('settings')
          .set({
        'paragraph': _paragraph,
        'heading': _heading,
        'fontWeightHeadings': _fontWeightHeadings.toString(),
        'fontWeightParagraph': _fontWeightParagraph.toString(),
        'color': _selectedColor,
      });
    } catch (e) {
      print('Error saving font settings: $e');
    }
  }

  Future<void> loadFontSettings() async {
    try {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('fontSettings')
          .doc('settings')
          .get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;

        _paragraph = data['paragraph'] ?? 15;
        _heading = data['heading'] ?? 18;
        _fontWeightHeadings = parseFontWeight(data['fontWeightHeadings']);
        _fontWeightParagraph = parseFontWeight(data['fontWeightParagraph']);
        _selectedColor =
            data['color'] ?? appContainerColor.value; // Load the color value

        notifyListeners();
      }
    } catch (e) {
      print('Error loading font settings: $e');
    }
  }

  FontWeight parseFontWeight(String value) {
    if (value == 'bold') {
      return FontWeight.bold;
    } else if (value == 'normal') {
      return FontWeight.normal;
    } else {
      return FontWeight.normal;
    }
  }
}

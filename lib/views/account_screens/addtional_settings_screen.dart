import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todolist/constants/colors.dart';
import 'package:todolist/providers/fonts_provider.dart';

class AdditionalSettingsScreen extends StatefulWidget {
  AdditionalSettingsScreen({super.key});

  @override
  State<AdditionalSettingsScreen> createState() =>
      _AdditionalSettingsScreenState();
}

class _AdditionalSettingsScreenState extends State<AdditionalSettingsScreen> {
  final List<int> colors = [
    Colors.red.value,
    Colors.blue.value,
    Colors.brown.value,
    Colors.yellow.value,
    Colors.purple.value,
    Colors.green.value,
    appContainerColor.value
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FontSettingsProvider>(context, listen: false);
    int selectedColor = provider.selectedColor;
    return Scaffold(
        appBar: AppBar(
          title: Text('Additional Settings'),
        ),
        body: Container(
          child: Column(
            children: [
              Consumer<FontSettingsProvider>(
                builder: (context, value, child) {
                  // Only this part will rebuild when the value changes
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('Heading Font Size',
                          style: TextStyle(fontSize: value.heading)),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              value.headingDecrease();
                            },
                            icon: Icon(Icons.minimize),
                          ),
                          Text(value.heading.toString()),
                          IconButton(
                            onPressed: () {
                              value.headingIncrease();
                            },
                            icon: Icon(Icons.add),
                          ),
                        ],
                      )
                    ],
                  );
                },
              ),
              Consumer<FontSettingsProvider>(
                builder: (context, value, child) {
                  // Only this part will rebuild when the value changes
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('Paragraph Font Size',
                          style: TextStyle(fontSize: value.paragraph)),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              value.decreaseCounter();
                            },
                            icon: const Icon(Icons.minimize),
                          ),
                          Text(value.paragraph.toString()),
                          IconButton(
                            onPressed: () {
                              value.increaseCounter();
                            },
                            icon: Icon(Icons.add),
                          ),
                        ],
                      )
                    ],
                  );
                },
              ),
              Consumer<FontSettingsProvider>(
                builder: (context, value, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('Heading Font Weight'),
                      DropdownButton<String>(
                        value: value
                            .fontWeightHeadingsToString(), // The currently selected value
                        items: <String>[
                          'Bold',
                          'Normal',
                        ]
                            .map<DropdownMenuItem<String>>(
                              (String value) => DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              ),
                            )
                            .toList(),
                        onChanged: (String? newValue) {
                          if (newValue == 'Bold') {
                            value.setFontWeight(FontWeight.bold);
                          } else if (newValue == 'Normal') {
                            value.setFontWeight(FontWeight.normal);
                          }
                        },
                      ),
                    ],
                  );
                },
              ),
              Consumer<FontSettingsProvider>(
                builder: (context, value, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('Paragraph Font Weight'),
                      DropdownButton<String>(
                        value: value
                            .fontParagraphWeighttoString(), // The currently selected value
                        items: <String>['Bold', 'Normal', 'SemiBold']
                            .map<DropdownMenuItem<String>>(
                              (String value) => DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              ),
                            )
                            .toList(),
                        onChanged: (String? newValue) {
                          if (newValue == 'Bold') {
                            value.setParagraphFontWeight(FontWeight.bold);
                          } else if (newValue == 'Normal') {
                            value.setParagraphFontWeight(FontWeight.normal);
                          } else if (newValue == 'SemiBold') {
                            value.setParagraphFontWeight(FontWeight.w600);
                          }
                        },
                      ),
                    ],
                  );
                },
              ),
              Consumer<FontSettingsProvider>(
                builder: (context, value, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('Primary Color Color:'),
                      DropdownButton<int>(
                        value: selectedColor,
                        items: colors
                            .map<DropdownMenuItem<int>>(
                              (int colorValue) => DropdownMenuItem<int>(
                                value: colorValue,
                                child: Container(
                                  width: 100,
                                  height: 20,
                                  decoration: BoxDecoration(
                                      color: Color(colorValue),
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (int? newValue) {
                          setState(() {
                            selectedColor = newValue!;
                          });
                          value.setSelectedColor(newValue == null
                              ? appContainerColor.value
                              : newValue);
                        },
                      ),
                    ],
                  );
                },
              ),
              ElevatedButton(
                onPressed: () {
                  // Save font settings to the database
                  Provider.of<FontSettingsProvider>(context, listen: false)
                      .saveFontSettings();
                  Navigator.pop(context);
                },
                child: Text('Save'),
              ),
            ],
          ),
        ));
  }
}

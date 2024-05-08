import 'package:flutter/material.dart';

class MoreCheckboxGroupWidget<T> extends StatelessWidget {
  final String title;
  final List<T> values;
  final Map<T, String> labels;
  final List<T> selectedValues;
  final void Function(List<T>) onChanged;

  const MoreCheckboxGroupWidget({
    Key? key,
    required this.title,
    required this.values,
    required this.labels,
    required this.selectedValues,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'KoreanFamily',
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            flex: 5,
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: values
                  .map((value) =>
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: selectedValues.contains(value),
                        onChanged: (checked) {
                          List<T> newValues = List.from(selectedValues);
                          if (checked!) {
                            newValues.add(value);
                          } else {
                            newValues.remove(value);
                          }
                          onChanged(newValues);
                        },
                      ),
                      Text(labels[value]!,
                          style: const TextStyle(fontFamily: 'KoreanFamily')),
                    ],
                  ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
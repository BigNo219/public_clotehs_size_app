import 'package:flutter/material.dart';

class RadioGroupWidget<T> extends StatelessWidget {
  final String title;
  final List<T> values;
  final Map<T, String> labels;
  final T? selectedValue;
  final void Function(T?) onChanged;

  const RadioGroupWidget({
    Key? key,
    required this.title,
    required this.values,
    required this.labels,
    required this.selectedValue,
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
                  .map((value) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Radio<T>(
                    value: value,
                    groupValue: selectedValue,
                    onChanged: onChanged,
                  ),
                  Text(labels[value]!),
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
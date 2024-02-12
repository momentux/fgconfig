import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

Widget buildTitle(String title) {
  return Padding(
    padding: EdgeInsets.only(bottom: 22.0), // Adjust the value as needed
    child: Text(
      title,
      style: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

Widget buildRow(List<Widget> children) {
  return Row(
    children: children
        .expand((child) => [SizedBox(width: 16.0), Expanded(child: child)])
        .toList(),
  );
}

Widget buildDropdownFormField(String? value, List<String> items,
    ValueChanged<String?> onChanged, String labelText) {
  return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          fontSize: 20.0, // Set the size as per your requirement
        ),
        border: OutlineInputBorder(),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
  );
}

Widget buildUploadButton(Future<void> Function(String filePath) onPressed) {
  return ElevatedButton(
    onPressed: () async {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        String filePath = result.files.single.path!;
        print('Selected file: $filePath');
        await onPressed(filePath);
      } else {
        print('File picking canceled.');
      }
    },
    child: Text('Upload File'),
  );
}

Widget buildTextFormField(TextEditingController controller,
    ValueChanged<String> onChanged, String labelText) {
  return TextFormField(
    controller: controller,
    keyboardType: TextInputType.number,
    onChanged: onChanged,
    decoration: InputDecoration(
      labelText: labelText,
      border: OutlineInputBorder(),
    ),
  );
}

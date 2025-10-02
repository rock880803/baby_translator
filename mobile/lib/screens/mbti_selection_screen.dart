import 'package:flutter/material.dart';
import '../models/mbti_type.dart';

class MBTISelectionScreen extends StatelessWidget {
  const MBTISelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('選擇 MBTI 人格類型'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: MBTIType.values.length,
        itemBuilder: (context, index) {
          final type = MBTIType.values[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(type.name.substring(0, 2)),
              ),
              title: Text(
                type.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(type.description),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pop(context, type),
            ),
          );
        },
      ),
    );
  }
}

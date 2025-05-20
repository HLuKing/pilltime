import 'package:flutter/material.dart';

class AddPillScreen extends StatelessWidget {
  const AddPillScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed:() {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          '약 추가하기',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: const Center(
        child: Text('여기에 본문이 들어감'),
      ),
    );
  }
}
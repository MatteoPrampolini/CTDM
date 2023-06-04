import 'package:flutter/material.dart';

class CustomCharacters extends StatefulWidget {
  final String packPath;
  const CustomCharacters(this.packPath, {super.key});

  @override
  State<CustomCharacters> createState() => _CustomCharactersState();
}

class _CustomCharactersState extends State<CustomCharacters> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Custom characters",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.amber,
          iconTheme: IconThemeData(color: Colors.red.shade700),
        ),
        body: const Text("TODO"));
  }
}

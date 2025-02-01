import 'package:flutter/material.dart';

class EditableTextWidget extends StatefulWidget {
  const EditableTextWidget({
    super.key,
    required this.initname,
    required this.changename,
  });
  final String initname;
  final void Function(String) changename;
  @override
  _EditableTextWidgetState createState() => _EditableTextWidgetState();
}

class _EditableTextWidgetState extends State<EditableTextWidget> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initname);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isEditing = true;
        });
      },
      child: _isEditing
          ? TextField(
              controller: _controller,
              autofocus: true,
              onSubmitted: (value) {
                setState(() {
                  _isEditing = false;
                });
              },
              onEditingComplete: () {
                setState(() {
                  _isEditing = false;
                });
                widget.changename(_controller.text);
              },
            )
          : Text(
              _controller.text,
              style: TextStyle(fontSize: 16.0, color: Colors.black),
            ),
    );
  }
}

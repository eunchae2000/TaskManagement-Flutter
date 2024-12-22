import 'package:flutter/material.dart';

class MemberPicker extends StatefulWidget {
  @override
  _MemberPickerState createState() => _MemberPickerState();
}

class _MemberPickerState extends State<MemberPicker> {
  List<String> members = ['Alice', 'Bob', 'Charlie', 'Eve', 'Daisy'];
  List<String> selectedMembers = [];

  void _addMember(String member) {
    if (!selectedMembers.contains(member)) {
      setState(() {
        selectedMembers.add(member);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return ListView.builder(
              itemCount: members.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(members[index]),
                  trailing: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      _addMember(members[index]);
                      Navigator.pop(context);
                    },
                  ),
                );
              },
            );
          },
        );
      },
      child: AbsorbPointer(
        child: TextField(
          decoration: InputDecoration(
            labelText: 'Select Members',
            hintText: 'Tap to select members',
            suffixIcon: Icon(Icons.search),
          ),
        ),
      ),
    );
  }
}

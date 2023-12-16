import 'package:flutter/material.dart';

class DrawerList extends StatefulWidget {
  final String title;
  final IconData icon;
  final int index;

  const DrawerList({
    Key? key,
    required this.title,
    required this.icon, required this.index,
  }) : super(key: key);

  @override
  State<DrawerList> createState() => _DrawerListState();
}

class _DrawerListState extends State<DrawerList> {
  final List<Color> colors = [
    Colors.black,
    Colors.blue,
    // Add more colors as needed
  ];
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        widget.title,
        style: TextStyle(color: colors[widget.index]),
      ),
      leading:
          Icon(widget.icon,
            color: colors[widget.index],

          ),
    );
  }
}

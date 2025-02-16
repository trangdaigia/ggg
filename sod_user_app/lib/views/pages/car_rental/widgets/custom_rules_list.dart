import 'package:flutter/material.dart';

class CustomRulesList extends StatefulWidget {
  final List<String> itemsShort;
  final List<String> itemsFull;

  const CustomRulesList({
    super.key,
    required this.itemsShort,
    required this.itemsFull,
  });
  @override
  _CustomRulesListState createState() => _CustomRulesListState();
}

class _CustomRulesListState extends State<CustomRulesList> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final _displayItems = _showAll ? widget.itemsFull : widget.itemsShort;

    return Column(
      children: <Widget>[
        ListView.builder(
          controller: ScrollController(),
          shrinkWrap: true,
          itemCount: _displayItems.length,
          itemBuilder: (context, index) {
            return Text(_displayItems[index]);
          },
        ),
        TextButton(
          child: Text(_showAll ? 'Thu nhỏ' : 'Xem tất cả'),
          onPressed: () {
            setState(() {
              _showAll = !_showAll;
            });
          },
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class AutoCompleteComponent extends StatefulWidget {
  final List<Map<String, dynamic>> options;
  final ValueSetter<Map<String, dynamic>> onSelect;
  final ValueSetter<String> onChange;
  final String label;
  final Widget icon;
  final String value;
  AutoCompleteComponent({Key key, this.options, this.onSelect, this.onChange, this.label, this.icon, this.value})
      : super(key: key);

  @override
  _AutoCompleteComponentState createState() => _AutoCompleteComponentState();
}

class _AutoCompleteComponentState extends State<AutoCompleteComponent> {
  String oldValue = "";

  @override
  Widget build(BuildContext context) {
    return Autocomplete<Map<String, dynamic>>(
      fieldViewBuilder: (BuildContext context,
          TextEditingController fieldTextEditingController,
          FocusNode fieldFocusNode,
          VoidCallback onFieldSubmitted) {
        return TextField(
          controller: fieldTextEditingController,
          focusNode: fieldFocusNode,
          decoration: InputDecoration(
            hintText : widget.label,
            filled: true,
            fillColor: Colors.white,
            border: new OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: const BorderRadius.all(
                const Radius.circular(10.0),
              ),
            ),
            suffixIcon: widget.icon
          )
        );
      },
      displayStringForOption: (Map<String, dynamic> option) {
        return option['label'];
      },
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text != oldValue) {
          widget.onChange(textEditingValue.text);
          setState(() {
            oldValue = textEditingValue.text;
          });
        }
        if (textEditingValue.text == '') {
          return const Iterable<Map<String, dynamic>>.empty();
        }
        return widget.options.where((option) {
          return option['label']
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (Map<String, dynamic> selection) {
        widget.onSelect(selection);
      },
    );
  }
}

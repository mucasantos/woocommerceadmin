import 'package:flutter/material.dart';

class SingleSelect extends StatefulWidget {
  final String labelText;
  final TextStyle labelTextStyle;
  final TextStyle modalHeadingTextStyle;
  final TextStyle modalListTextStyle;
  final double modalHeight;
  final dynamic selectedKey;
  final List<Map<String, dynamic>> options;
  final String keyString;
  final String valueString;
  final Function(Map<String, dynamic>) onChange;

  SingleSelect({
    @required this.labelText,
    this.labelTextStyle,
    this.modalHeadingTextStyle,
    this.modalListTextStyle,
    this.modalHeight,
    @required this.selectedKey,
    @required this.options,
    @required this.keyString,
    @required this.valueString,
    @required this.onChange,
  });

  @override
  _SingleSelectState createState() => _SingleSelectState();
}

class _SingleSelectState extends State<SingleSelect> {
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    for (int i = 0; i < widget.options.length; i++) {
      if (widget.options[i][widget.keyString] == widget.selectedKey) {
        _textController.text = widget.options[i]["name"];
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: AbsorbPointer(
        child: TextFormField(
          controller: _textController,
          style: widget.labelTextStyle,
          keyboardType: TextInputType.datetime,
          decoration: InputDecoration(
            labelText: widget.labelText,
            suffixIcon: Icon(Icons.arrow_drop_down),
          ),
        ),
      ),
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return SingleSelectModal(
              modalHeadingText: widget.labelText,
              modalHeadingTextStyle: widget.modalHeadingTextStyle,
              modalListTextStyle: widget.modalListTextStyle,
              modalHeight: widget.modalHeight,
              selectedKey: widget.selectedKey,
              options: widget.options,
              keyString: widget.keyString,
              valueString: widget.valueString,
              onChange: (Map<String, dynamic> value) {
                _textController.text = value[widget.valueString];
                widget.onChange(value);
              },
            );
          },
        );
      },
    );
  }
}

class SingleSelectModal extends StatefulWidget {
  final String modalHeadingText;
  final TextStyle modalHeadingTextStyle;
  final TextStyle modalListTextStyle;
  final double modalHeight;
  final dynamic selectedKey;
  final List<Map<String, dynamic>> options;
  final String keyString;
  final String valueString;
  final Function(Map<String, dynamic>) onChange;

  SingleSelectModal({
    @required this.modalHeadingText,
    this.modalHeadingTextStyle,
    this.modalListTextStyle,
    this.modalHeight,
    @required this.selectedKey,
    @required this.options,
    @required this.keyString,
    @required this.valueString,
    @required this.onChange,
  });

  @override
  _SingleSelectModalState createState() => _SingleSelectModalState();
}

class _SingleSelectModalState extends State<SingleSelectModal> {
  int _selectedIndex = 0;

  @override
  void initState() {
    for (int i = 0; i < widget.options.length; i++) {
      if (widget.selectedKey == widget.options[i][widget.keyString]) {
        _selectedIndex = i;
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: (widget.modalHeight is double && widget.modalHeight > 0)
          ? widget.modalHeight
          : 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              widget.modalHeadingText,
              style: widget.modalHeadingTextStyle,
            ),
          ),
          Divider(
            height: 0,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.options.length,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: <Widget>[
                    RadioListTile(
                      title: Text(
                        widget.options[index][widget.valueString],
                        style: widget.modalListTextStyle,
                      ),
                      value: index,
                      groupValue: _selectedIndex,
                      onChanged: (int newSelectedIndex) {
                        setState(() {
                          _selectedIndex = newSelectedIndex;
                        });
                        widget.onChange(widget.options[newSelectedIndex]);
                        Navigator.pop(context);
                      },
                    ),
                    Divider(
                      height: 0,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class SingleSelect extends StatelessWidget {
  final String labelText;
  final TextStyle labelTextStyle;
  final TextStyle modalHeadingTextStyle;
  final TextStyle modalListTextStyle;
  final double modalHeight;
  final dynamic selectedValue;
  final List<SingleSelectMenu> options;
  final Function(dynamic) onChange;

  SingleSelect({
    @required this.labelText,
    this.labelTextStyle,
    this.modalHeadingTextStyle,
    this.modalListTextStyle,
    this.modalHeight,
    @required this.selectedValue,
    @required this.options,
    @required this.onChange,
  });

  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    for (int i = 0; i < options.length; i++) {
      if (options[i].value == selectedValue) {
        _textController.text = options[i].name;
      }
    }

    return GestureDetector(
      child: AbsorbPointer(
        child: TextFormField(
          controller: _textController,
          style: labelTextStyle,
          keyboardType: TextInputType.datetime,
          decoration: InputDecoration(
            labelText: labelText,
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
              modalHeadingText: labelText,
              modalHeadingTextStyle: modalHeadingTextStyle,
              modalListTextStyle: modalListTextStyle,
              modalHeight: modalHeight,
              selectedValue: selectedValue,
              options: options,
              onChange: (SingleSelectMenu singleSelectMenu) {
                _textController.text = singleSelectMenu.name;
                onChange(singleSelectMenu.value);
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
  final dynamic selectedValue;
  final List<SingleSelectMenu> options;
  final Function(SingleSelectMenu) onChange;

  SingleSelectModal({
    @required this.modalHeadingText,
    this.modalHeadingTextStyle,
    this.modalListTextStyle,
    this.modalHeight,
    @required this.selectedValue,
    @required this.options,
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
      if (widget.selectedValue == widget.options[i].value) {
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
                        widget.options[index].name,
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

class SingleSelectMenu {
  final dynamic value;
  final String name;

  SingleSelectMenu({
    @required this.value,
    @required this.name,
  })  : assert(value != null),
        assert(name != null);
}

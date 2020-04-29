import 'package:flutter/material.dart';

class MultiSelect extends StatelessWidget {
  final String labelText;
  final TextStyle labelTextStyle;
  final TextStyle modalHeadingTextStyle;
  final TextStyle modalListTextStyle;
  final double modalHeight;
  final bool isLoading;
  final List selectedValuesList;
  final List<MultiSelectMenu> options;
  final void Function(List) onChange;

  MultiSelect({
    @required this.labelText,
    this.labelTextStyle,
    this.modalHeadingTextStyle,
    this.modalListTextStyle,
    this.modalHeight,
    this.isLoading = false,
    @required this.selectedValuesList,
    @required this.options,
    @required this.onChange,
  });

  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _textController.text = _getSelectedValuesString(selectedValuesList);

    return GestureDetector(
      child: AbsorbPointer(
        child: TextFormField(
          controller: _textController,
          style: labelTextStyle,
          keyboardType: TextInputType.datetime,
          decoration: InputDecoration(
            labelText: labelText,
            suffixIcon: isLoading
                ? Container(
                    height: 10,
                    width: 10,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Icon(
                    Icons.arrow_drop_down,
                  ),
          ),
        ),
      ),
      onTap: isLoading
          ? null
          : () {
              FocusScope.of(context).requestFocus(FocusNode());
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return MultiSelectModal(
                    modalHeadingText: labelText,
                    modalHeadingTextStyle: modalHeadingTextStyle,
                    modalListTextStyle: modalListTextStyle,
                    modalHeight: modalHeight,
                    selectedValuesList: selectedValuesList,
                    options: options,
                    onChange: (List<MultiSelectMenu> multiSelectMenuList) {
                      _textController.text =
                          _getSelectedValuesString(selectedValuesList);
                      onChange(multiSelectMenuList
                          .map((multiSelectMenu) => multiSelectMenu.value)
                          .toList());
                    },
                  );
                },
              );
            },
    );
  }

  String _getSelectedValuesString(List selectedValuesList) {
    String selectedValuesString = "";
    for (int i = 0; i < selectedValuesList.length; i++) {
      if (i == selectedValuesList.length - 1) {
        for (int j = 0; j < options.length; j++) {
          if (options[j].value == selectedValuesList[i]) {
            selectedValuesString += "${options[j].name}";
          }
        }
      } else {
        for (int j = 0; j < options.length; j++) {
          if (options[j].value == selectedValuesList[i]) {
            selectedValuesString += "${options[j].name}, ";
          }
        }
      }
    }
    return selectedValuesString;
  }
}

class MultiSelectModal extends StatefulWidget {
  final String modalHeadingText;
  final TextStyle modalHeadingTextStyle;
  final TextStyle modalListTextStyle;
  final double modalHeight;
  final List selectedValuesList;
  final List<MultiSelectMenu> options;
  final Function(List<MultiSelectMenu>) onChange;

  MultiSelectModal({
    @required this.modalHeadingText,
    this.modalHeadingTextStyle,
    this.modalListTextStyle,
    this.modalHeight,
    @required this.selectedValuesList,
    @required this.options,
    @required this.onChange,
  });

  @override
  _MultiSelectModalState createState() => _MultiSelectModalState();
}

class _MultiSelectModalState extends State<MultiSelectModal> {
  List _selectedValuesList = [];

  @override
  void initState() {
    _selectedValuesList = widget.selectedValuesList;
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
                    CheckboxListTile(
                      title: Text(
                        widget.options[index].name,
                        style: widget.modalListTextStyle,
                      ),
                      value: widget.selectedValuesList
                          .contains(widget.options[index].value),
                      onChanged: (bool value) {
                        if (value) {
                          _selectedValuesList.add(widget.options[index].value);
                        } else {
                          _selectedValuesList
                              .remove(widget.options[index].value);
                        }
                        setState(() {});
                        widget.onChange(widget.options
                            .where((item) =>
                                _selectedValuesList.contains(item.value))
                            .toList());
                        // setState(() {
                        //   _selectedIndex = newSelectedIndex;
                        // });
                        // widget.onChange(widget.options[newSelectedIndex]);
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

class MultiSelectMenu {
  final dynamic value;
  final String name;

  MultiSelectMenu({
    @required this.value,
    @required this.name,
  })  : assert(value != null),
        assert(name != null);
}

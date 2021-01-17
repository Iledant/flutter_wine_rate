import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'bloc/pick_critics.dart';
import 'bloc/pick_wines.dart';
import 'constant.dart';
import 'models/critic.dart';
import 'models/rate.dart';
import 'models/wine.dart';

class RateEditDialog extends StatefulWidget {
  final DialogMode _mode;
  final Rate _rate;

  RateEditDialog(this._mode, this._rate, {Key key}) : super(key: key);

  @override
  _RateEditDialogState createState() => _RateEditDialogState();
}

class _RateEditDialogState extends State<RateEditDialog> {
  final _rateController = TextEditingController();
  final _yearController = TextEditingController();
  final _publishedController = TextEditingController();
  final _criticController = TextEditingController();
  final _wineController = TextEditingController();
  final _rateRegExp = RegExp(r"^100|[89]\d(\.\d)?$");
  final _yearRegExp = RegExp(r"^19\d\d|20\d\d$");
  final _dateRegExp = RegExp(r"^\d{2}\/\d{4}$");
  final _dateFormatter = DateFormat("MM/yyyy");
  bool _disabled;
  Critic _critic;
  Wine _wine;

  void initState() {
    super.initState();
    final Rate rate = widget._rate;
    _rateController.text = rate.rate.toString();
    _yearController.text = rate.year.toString();
    _critic = rate.critic != null
        ? Critic(id: rate.criticId, name: rate.critic)
        : null;
    _publishedController.text = _dateFormatter.format(rate.published);
    _wine = rate.wine != null
        ? Wine(
            id: rate.wineId,
            name: rate.wine,
            locationId: rate.locationId,
            location: rate.location,
            domainId: rate.domainId,
            domain: rate.domain,
            regionId: rate.regionId,
            region: rate.region,
            comment: rate.comment,
            classification: rate.classification,
          )
        : null;
    _handleDisabled();
  }

  void dispose() {
    _rateController.dispose();
    _yearController.dispose();
    _criticController.dispose();
    _wineController.dispose();
    _publishedController.dispose();
    super.dispose();
  }

  void _handleDisabled() {
    _disabled = !_rateRegExp.hasMatch(_rateController.text) ||
        !_yearRegExp.hasMatch(_yearController.text) ||
        !_dateRegExp.hasMatch(_publishedController.text) ||
        _wine == null ||
        _critic == null;
  }

  Widget popupMenu<T>(
      List<T> lines, void Function(T) setState, String Function(T) getText) {
    return Card(
      child: Column(
        children: lines
            .map(
              (r) => InkWell(
                onTap: () => setState(r),
                child: Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.all(4.0),
                  child: Text(getText(r)),
                ),
              ),
            )
            .toList(),
      ),
      elevation: 2.0,
    );
  }

  DateTime _getPublished() {
    final strings = _publishedController.text.split("/");
    if (strings.length != 2) return null;
    final month = int.parse(strings[0]);
    final year = int.parse(strings[1]);
    return DateTime(year, month);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget._mode == DialogMode.Edit
          ? "Modifier La note"
          : 'Nouvelle note'),
      scrollable: true,
      content: Column(
        children: [
          Form(
            child: TextFormField(
              autofocus: true,
              controller: _yearController,
              onChanged: (value) => setState(() => _handleDisabled()),
              autovalidateMode: AutovalidateMode.always,
              validator: (String value) =>
                  !_yearRegExp.hasMatch(value) ? 'Millésime requis' : null,
              decoration: InputDecoration(labelText: "Millésime"),
            ),
          ),
          SizedBox(height: 16.0),
          Form(
            child: TextFormField(
              controller: _rateController,
              onChanged: (value) => setState(() => _handleDisabled()),
              autovalidateMode: AutovalidateMode.always,
              validator: (String value) =>
                  !_rateRegExp.hasMatch(value) ? 'Note requise' : null,
              decoration: InputDecoration(labelText: "Note"),
            ),
          ),
          SizedBox(height: 16.0),
          Form(
            child: TextFormField(
              controller: _publishedController,
              onChanged: (value) => setState(() => _handleDisabled()),
              autovalidateMode: AutovalidateMode.always,
              validator: (String value) => !_dateRegExp.hasMatch(value)
                  ? 'Date de notation (p.e. 05/2020) requise'
                  : null,
              decoration: InputDecoration(labelText: "Date de notation"),
            ),
          ),
          SizedBox(height: 16.0),
          Text(
            _critic == null ? 'Critique requis' : "Critique",
            style: TextStyle(
                color: _critic != null
                    ? Theme.of(context).textTheme.caption.color
                    : Theme.of(context).errorColor,
                fontSize: Theme.of(context).textTheme.caption.fontSize),
          ),
          Text(
            _critic?.name ?? '-',
            style:
                TextStyle(color: _critic != null ? Colors.black : Colors.red),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 8.0),
            child: Container(
              padding: EdgeInsets.all(8.0),
              color: Colors.deepPurple[50],
              child: Column(children: [
                TextField(
                  controller: _criticController,
                  onChanged: (value) =>
                      BlocProvider.of<PickCriticsBloc>(context)
                          .add(PickCriticsLoaded(value)),
                  decoration: InputDecoration(
                    isDense: true,
                    icon: Icon(Icons.filter_alt_outlined, size: 16.0),
                  ),
                ),
                BlocBuilder<PickCriticsBloc, PickCriticsState>(
                    builder: (context, state) {
                  if (state is PickCriticsLoadFailure ||
                      state is PickCriticsLoadInProgress ||
                      state is PickCriticsEmpty) return SizedBox.shrink();
                  final critics = (state as PickCriticsLoadSuccess).critics;
                  return popupMenu(
                      critics,
                      (critic) => setState(() {
                            _critic = critic;
                            _criticController.text = '';
                            BlocProvider.of<PickCriticsBloc>(context)
                                .add(PickCriticsClear());
                            _handleDisabled();
                          }),
                      (critic) => critic.name);
                }),
              ]),
            ),
          ),
          SizedBox(height: 16.0),
          Text(
            _wine == null ? "Vin requis" : "Vin",
            style: TextStyle(
                color: _wine != null
                    ? Theme.of(context).textTheme.caption.color
                    : Theme.of(context).errorColor,
                fontSize: Theme.of(context).textTheme.caption.fontSize),
          ),
          Text(
            (_wine != null ? _wine.name : '-'),
            style: TextStyle(color: _wine != null ? Colors.black : Colors.red),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 8.0),
            child: Container(
              padding: EdgeInsets.all(8.0),
              color: Colors.deepPurple[50],
              child: Column(children: [
                TextField(
                  controller: _wineController,
                  onChanged: (value) => BlocProvider.of<PickWinesBloc>(context)
                      .add(PickWinesLoaded(value)),
                  decoration: InputDecoration(
                    isDense: true,
                    icon: Icon(Icons.filter_alt_outlined, size: 16.0),
                  ),
                ),
                BlocBuilder<PickWinesBloc, PickWinesState>(
                  builder: (context, state) {
                    if (state is PickWinesLoadFailure ||
                        state is PickWinesLoadInProgress ||
                        state is PickWinesEmpty) return SizedBox.shrink();

                    final wines = (state as PickWinesLoadSuccess).wines;
                    return popupMenu(
                        wines,
                        (wine) => setState(() {
                              _wine = wine;
                              _wineController.text = '';
                              BlocProvider.of<PickWinesBloc>(context)
                                  .add(PickWinesClear());
                              _handleDisabled();
                            }),
                        (wine) => '${wine.name} [${wine.domain}]');
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text('Annuler'),
          onPressed: () => Navigator.of(context).pop(null),
        ),
        TextButton(
          child: Text(widget._mode == DialogMode.Edit ? 'Modifier' : 'Créer'),
          onPressed: _disabled
              ? null
              : () => Navigator.of(context).pop(Rate(
                    id: widget._rate.id,
                    criticId: _critic.id,
                    critic: _critic.name,
                    wineId: _wine.id,
                    wine: _wine.name,
                    comment: _wine.comment,
                    classification: _wine.classification,
                    locationId: _wine.locationId,
                    location: _wine.location,
                    domainId: _wine.domainId,
                    domain: _wine.domain,
                    regionId: _wine.regionId,
                    region: _wine.region,
                    published: _getPublished(),
                    year: int.parse(_yearController.text),
                    rate: double.parse(_rateController.text),
                  )),
        ),
      ],
    );
  }
}

Future<Rate> showEditRateDialog(
    BuildContext context, Rate rate, DialogMode mode) {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RateEditDialog(mode, rate));
}

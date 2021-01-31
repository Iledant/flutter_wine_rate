import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_wine_rate/providers/critic_provider.dart';
import 'package:flutter_wine_rate/screen_widget.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'constants.dart';
import 'models/critic.dart';
import 'models/equatable_with_name.dart';
import 'models/rate.dart';
import 'models/wine.dart';
import 'providers/wine_provider.dart';

final _rateRegExp = RegExp(r"^100|[89]\d(\.\d)?$");
final _yearRegExp = RegExp(r"^19\d\d|20\d\d$");
final _dateRegExp = RegExp(r"^\d{2}\/\d{4}$");
final _dateFormatter = DateFormat("MM/yyyy");

class RateEditDialog extends StatefulHookWidget {
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

  DateTime _getPublished() {
    final strings = _publishedController.text.split("/");
    if (strings.length != 2) return null;
    final month = int.parse(strings[0]);
    final year = int.parse(strings[1]);
    return DateTime(year, month);
  }

  @override
  Widget build(BuildContext context) {
    final criticsProvider = useProvider(pickCriticsProvider);
    final critics = useProvider(pickCriticsProvider.state);
    final winesProvider = useProvider(pickWinesProvider);
    final wines = useProvider(pickWinesProvider.state);
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
          const SizedBox(height: 16.0),
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
          const SizedBox(height: 16.0),
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
          const SizedBox(height: 16.0),
          critics.when(
            data: (suggestions) => ItemPicker<Critic>(
              item: _critic,
              suggestions: suggestions,
              fetchItems: (value) => criticsProvider.fetch(value),
              onChanged: (EquatableWithName r) => setState(() {
                _critic = r;
                criticsProvider.clear();
              }),
              itemHintMessage: "Critique",
              nullItemMessage: "Critique requis",
            ),
            loading: () => ProgressWidget(),
            error: (error, _) => ScreenErrorWidget(error: error),
          ),
          SizedBox(height: 16.0),
          wines.when(
            data: (suggestions) => ItemPicker<Wine>(
              item: _wine,
              suggestions: suggestions,
              fetchItems: (value) => winesProvider.fetch(value),
              onChanged: (EquatableWithName r) => setState(() {
                _wine = r;
                winesProvider.clear();
              }),
              itemHintMessage: "Vin",
              nullItemMessage: "Vin requis",
            ),
            loading: () => ProgressWidget(),
            error: (error, _) => ScreenErrorWidget(error: error),
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

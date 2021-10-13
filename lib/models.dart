import 'imports.dart';

enum RequestState { none, error, loading, success }

class Status {
  final String code;
  final String message;
  final dynamic data;

  Status({required this.code, required this.message, this.data});
}

class FutureData extends ChangeNotifier {
  List<SoilData> _data = [];
  RequestState _state = RequestState.none;
  late Status _message;

  void update({
    required RequestState state,
    required Status message,
    required List<SoilData> data,
  }) {
    _data = data;
    _state = state;
    _message = message;

    notifyListeners();
  }

  List<SoilData> get data => _data;
  set data(List<SoilData> _value) {
    _data = _value;
    notifyListeners();
  }

  RequestState get state => _state;
  set state(RequestState _value) {
    _state = _value;
    notifyListeners();
  }

  Status get message => _message;
  set message(Status _value) {
    _message = _value;
    notifyListeners();
  }
}

class SoilData {
  final int soilMoisture;
  final double soilPH;
  final double soilTemperature;
  final int atmosphericTemperature;
  final int atmosphericHumidity;
  final DateTime datetime;
  final int id;

  SoilData({
    required this.soilMoisture,
    required this.soilPH,
    required this.soilTemperature,
    required this.atmosphericTemperature,
    required this.atmosphericHumidity,
    required this.datetime,
    required this.id,
  });

  static SoilData fromMap(Map _map) {
    return SoilData(
      id: _map['entry_id'],
      datetime: DateTime.parse(_map["created_at"]),
      soilMoisture: double.parse(_map['field1']).toInt(),
      soilPH: double.parse(_map['field3']),
      soilTemperature: double.parse(
        double.parse(_map['field5']).toStringAsFixed(1),
      ),
      atmosphericTemperature: double.parse(_map['field2']).toInt(),
      atmosphericHumidity: double.parse(_map['field4']).toInt(),
    );
  }
}

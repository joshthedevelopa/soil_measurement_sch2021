import 'imports.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  FutureData data = FutureData();

  @override
  void initState() {
    super.initState();

    data.state = RequestState.loading;
    getData();
  }

  void getData() async {
    Status results = await ApiServices.getMeasurements();

    if (results.code == "OK") {
      data.update(
        data: results.data,
        message: results,
        state: RequestState.success,
      );
    } else {
      data.state = RequestState.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(k_size * 2.5).copyWith(
                    top: k_size * 3.0,
                    bottom: k_size,
                  ),
                  child: Text(
                    "Precision Farming",
                    style: TextStyle(
                      color: k_secondaryColor,
                      fontSize: k_fontSize * 1.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                Expanded(child: SizedBox()),
                AnimatedBuilder(
                  animation: data,
                  builder: (context, child) =>
                      data.state == RequestState.success ? child! : SizedBox(),
                  child: _refreshButton(),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(k_size),
                child: LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: AnimatedBuilder(
                          animation: data,
                          builder: (context, _) {
                            if (data.state == RequestState.none ||
                                data.state == RequestState.loading) {
                              return Center(
                                child: SizedBox(
                                  height: 60.0,
                                  width: 60.0,
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            } else if (data.state == RequestState.error) {
                              return Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Try Again",
                                      style: TextStyle(
                                        color: k_greyColor,
                                        fontSize: k_fontSize * 2,
                                      ),
                                    ),
                                    _refreshButton()
                                  ],
                                ),
                              );
                            }
                            return _displayTiles();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Column _displayTiles() {
    return Column(
      children: [
        Expanded(
          child: DashboardTile(
            value: data.data.last.soilMoisture,
            unit: "%",
            isSubscript: true,
            description: "Soil Moisture Content",
            page: DetailedView(
              type: "Soil Moisture Content",
              data: data.data.reversed.toList(),
            ),
          ),
        ),
        Expanded(
          child: DashboardTile(
            value: data.data.last.soilPH,
            description: "Soil pH",
            unit: "",
            page: DetailedView(
              type: "Soil pH",
              data: data.data.reversed.toList(),
            ),
          ),
        ),
        Expanded(
          child: DashboardTile(
            value: data.data.last.soilTemperature,
            unit: "o",
            isSubscript: false,
            description: "Soil Temperature (Celsius)",
            page: DetailedView(
              type: "Soil Temperature",
              data: data.data.reversed.toList(),
            ),
          ),
        ),
        Expanded(
          child: DashboardTile(
            value: data.data.last.atmosphericTemperature,
            unit: "o",
            isSubscript: false,
            description: "Atmospheric Temperature (Celsius)",
            page: DetailedView(
              type: "Atmospheric Temperature",
              data: data.data.reversed.toList(),
            ),
          ),
        ),
        Expanded(
          child: DashboardTile(
            value: data.data.last.atmosphericHumidity,
            unit: "%",
            isSubscript: true,
            description: "Atmospheric Humidity",
            page: DetailedView(
              type: "Atmospheric Humidity",
              data: data.data.reversed.toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _refreshButton() {
    return IconButton(
      onPressed: () {
        data.state = RequestState.loading;
        getData();
      },
      color: k_primaryColor,
      icon: Icon(
        Icons.refresh,
      ),
    );
  }
}

class DetailedView extends StatefulWidget {
  final List<SoilData> data;
  final String type;

  DetailedView({required this.data, required this.type});

  @override
  _DetailedViewState createState() => _DetailedViewState();
}

class _DetailedViewState extends State<DetailedView> {
  List<FlSpot> flSpots = [];
  late double _yInterval, _yMin, _yMax;
  late String _unit;

  @override
  void initState() {
    super.initState();

    List<double> _yValues = [];
    int count = 0;

    widget.data.take(10).forEach((element) {
      late dynamic _x, _y;

      if (widget.type == "Soil Moisture Content") {
        _y = element.soilMoisture;
        _unit = "%";
      } else if (widget.type == "Soil pH") {
        _y = element.soilPH;
        _unit = "";
      } else if (widget.type == "Atmospheric Temperature") {
        _y = element.atmosphericTemperature;
        _unit = "celsius";
      } else if (widget.type == "Soil Temperature") {
        _y = element.soilTemperature;
        _unit = "celsius";
      } else if (widget.type == "Atmospheric Humidity") {
        _y = element.atmosphericHumidity;
        _unit = "%";
      } else {
        _y = 0.0;
        _unit = "";
      }

      _x = count.toDouble();

      flSpots.add(
        widget.type == "Soil pH"
            ? FlSpot(_x, _y)
            : FlSpot(_x.toDouble(), _y.toDouble()),
      );

      _yValues.add(widget.type == "Soil pH" ? _y : _y.toDouble());
      count++;
    });
    _yValues.sort();
    _yMin = _yValues.first;
    _yMax = _yValues.last;

    if (_yMax == _yMin) {
      _yMin = _yMin.floorToDouble();
      _yMax = _yMax.ceilToDouble();

      if (_yMax == _yMin) {
        _yMax += 1;
        _yMin -= 1;
      }
    }
    _yInterval = (_yMax - _yMin) / 6;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: k_size * 1.5),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(k_size * 2.5).copyWith(
                        top: k_size * 2.0,
                        bottom: k_size,
                      ),
                      child: Text(
                        "${widget.type} Graph",
                        style: TextStyle(
                          color: k_secondaryColor,
                          fontSize: k_fontSize * 1.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: k_size * .5),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: k_whiteColor,
                        width: 1.0,
                      ),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      color: k_primaryColor,
                      icon: Icon(
                        Icons.close,
                      ),
                    ),
                  ),
                  SizedBox(width: k_size * 1.5),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Card(
                    margin: EdgeInsets.symmetric(vertical: k_size * .5),
                    child: Container(
                      margin: EdgeInsets.all(k_size * 1.8),
                      width: double.infinity,
                      height: 280,
                      child: LineChart(
                        LineChartData(
                          lineTouchData: LineTouchData(enabled: true),
                          borderData: FlBorderData(
                            border: Border(
                              left: BorderSide(
                                color: k_greyColor.withOpacity(0.6),
                                width: 1.5,
                              ),
                              bottom: BorderSide(
                                color: k_greyColor.withOpacity(0.6),
                                width: 1.5,
                              ),
                            ),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              isCurved: true,
                              belowBarData: BarAreaData(
                                show: true,
                                colors: [
                                  k_primaryColor.withOpacity(0.3),
                                  k_primaryColor.withOpacity(0.05),
                                ],
                                gradientFrom: Offset(.5, 0),
                                gradientTo: Offset(.5, 1),
                              ),
                              colors: [
                                k_primaryColor.withOpacity(0.6),
                              ],
                              spots: flSpots,
                            ),
                          ],
                          clipData: FlClipData.none(),
                          minY: _yMin - _yInterval,
                          maxY: _yMax + _yInterval,
                          gridData: _gridData(),
                          titlesData: _titlesData(),
                          axisTitleData: FlAxisTitleData(
                            show: true,
                            bottomTitle: AxisTitle(
                              showTitle: true,
                              titleText: "Time",
                              textAlign: TextAlign.right,
                            ),
                            leftTitle: AxisTitle(
                              showTitle: true,
                              titleText: "${widget.type} ($_unit)",
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: k_size * 1.5,
                        horizontal: k_size * 2.5,
                      ),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: k_size * 2.0,
                              ),
                              child: Text(
                                "All Data",
                                style: TextStyle(
                                  color: k_secondaryColor,
                                  fontSize: k_fontSize * 1.2,
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: k_size,
                                horizontal: k_size * 2.0,
                              ),
                              child: Material(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    k_radius * 3,
                                  ),
                                ),
                                color: k_primaryColor,
                                child: SizedBox(
                                  width: 30,
                                  height: 2,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: widget.data.length,
                              itemBuilder: _listTile,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _listTile(context, index) {
    SoilData _soilData = widget.data.toList()[index];
    Text _preffix;

    if (widget.type == "Soil Moisture Content") {
      _preffix = Text(
        "%",
        textScaleFactor: 1.0,
        style: TextStyle(
          height: 1.6,
        ),
      );
    } else if (widget.type == "Soil pH") {
      _preffix = Text("");
    } else if (widget.type == "Atmospheric Temperature" ||
        widget.type == "Soil Temperature") {
      _preffix = Text(
        "o",
        textScaleFactor: 0.6,
        style: TextStyle(
          height: 0.2,
        ),
      );
    } else {
      _preffix = Text(
        "%",
        textScaleFactor: 1.0,
        style: TextStyle(
          height: 1.6,
        ),
      );
    }

    return Card(
      child: ListTile(
        title: Row(
          children: [
            Text(
              _selectedTitle(_soilData),
            ),
            _preffix,
          ],
        ),
        subtitle: Text(
          _displayDate(_soilData),
        ),
      ),
    );
  }

  String _selectedTitle(SoilData _soilData) {
    String _title = "";

    if (widget.type == "Soil Moisture Content") {
      _title = "${_soilData.soilMoisture}";
    } else if (widget.type == "Soil pH") {
      _title = "${_soilData.soilPH}";
    } else if (widget.type == "Soil Temperature") {
      _title = "${_soilData.soilTemperature}";
    } else if (widget.type == "Atmospheric Temperature") {
      _title = "${_soilData.atmosphericTemperature}";
    } else {
      _title = "${_soilData.atmosphericHumidity}";
    }

    return _title;
  }

  String _displayDate(SoilData _soilData) {
    DateTime _datetime = _soilData.datetime;
    String _hour = "", _minute = "", _timeSuffix = "", _day = "";
    List<String> _months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];

    int _tmpHour = _datetime.hour % 12;

    if (_datetime.hour < 10) {
      _hour =  _datetime.hour == 0 ? '${12}' : '0${_datetime.hour}';
      _timeSuffix = "AM";
    } else {
      _hour =
          _tmpHour < 10 ? "${_tmpHour == 0 ? 12 : '0$_tmpHour'}" : "$_tmpHour";

      if (_datetime.hour < 12) {
        _timeSuffix = "AM";
      } else {
        _timeSuffix = "PM";
      }
    }

    if (_datetime.minute < 10) {
      _minute = "0${_datetime.minute}";
    } else {
      _minute = "${_datetime.minute}";
    }

    if (_datetime.day < 10) {
      _day = "0${_datetime.day}";
    } else {
      _day = "${_datetime.day}";
    }

    return "Date: $_day ${_months[_datetime.month - 1]}, ${_datetime.year} || Time: $_hour:$_minute $_timeSuffix";
  }

  FlTitlesData _titlesData() {
    return FlTitlesData(
      leftTitles: SideTitles(
        showTitles: true,
        interval: double.parse(
          _yInterval.toStringAsFixed(2),
        ),
        reservedSize: k_fontSize * 2.5,
        getTextStyles: (context, _) {
          return TextStyle(
            fontSize: k_fontSize * .8,
            color: k_primaryColor,
          );
        },
        getTitles: (value) {
          return value.toStringAsFixed(2);
        },
      ),
      bottomTitles: SideTitles(
        showTitles: true,
        reservedSize: k_fontSize * 2,
        rotateAngle: 60,
        getTextStyles: (context, _) {
          return TextStyle(
            fontSize: k_fontSize * .8,
            color: k_primaryColor,
          );
        },
        getTitles: (value) {
          DateTime _date = widget.data[value.toInt()].datetime;

          late String _hour;
          if (_date.hour < 10) {
            _hour = "0${_date.hour}";
          } else {
            _hour = "${_date.hour}";
          }

          late String _minutes;
          if (_date.minute < 10) {
            _minutes = "0${_date.minute}";
          } else {
            _minutes = "${_date.minute}";
          }

          return "$_hour:$_minutes";
        },
      ),
    );
  }

  FlGridData _gridData() {
    return FlGridData(
      horizontalInterval: double.parse(
        _yInterval.toStringAsFixed(2),
      ),
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: k_greyColor.withOpacity(0.2),
          strokeWidth: 0.5,
        );
      },
    );
  }
}

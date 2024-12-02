import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

void main() {
  runApp(AmpCalculatorApp());
}

class AmpCalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ampere Load ادي بيحمل الاشتراك',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blueAccent,
        scaffoldBackgroundColor: Colors.black,
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.white), // Updated line
        ),
      ),

      home: AmpCalculatorPage(),
    );
  }
}

class AmpCalculatorPage extends StatefulWidget {
  @override
  _AmpCalculatorPageState createState() => _AmpCalculatorPageState();
}

class _AmpCalculatorPageState extends State<AmpCalculatorPage> {
  final TextEditingController _totalAmpController = TextEditingController();
  final TextEditingController _wattController = TextEditingController();
  final TextEditingController _voltageController = TextEditingController();
  double? _totalAmperage;
  double _usedAmperage = 0.0;
  List<String> _deviceList = [];
  String? _resultMessage;

  void _addDevice() {
    final double? watts = double.tryParse(_wattController.text);
    final double? volts = double.tryParse(_voltageController.text);

    if (watts != null && volts != null && volts > 0) {
      final amperage = watts / volts;

      setState(() {
        _usedAmperage += amperage;
        _deviceList.add(
            "Device: ${amperage.toStringAsFixed(2)} A (W: $watts, V: $volts)");

        if (_totalAmperage != null && _usedAmperage > _totalAmperage!) {
          _resultMessage = "⚠️ Overloaded! تك ";
        } else {
          _resultMessage = "✅ Device added.";
        }
      });

      _wattController.clear();
      _voltageController.clear();
    } else {
      setState(() {
        _resultMessage = "enter valid wattage and voltage.";
      });
    }
  }

  void _setTotalAmperage() {
    final double? amps = double.tryParse(_totalAmpController.text);

    if (amps != null && amps > 0) {
      setState(() {
        _totalAmperage = amps;
        _usedAmperage = 0.0;
        _deviceList.clear();
        _resultMessage = "amperage set to ${amps.toStringAsFixed(2)} A.";
      });
      _totalAmpController.clear();
    } else {
      setState(() {
        _resultMessage = " enter a valid  amperage.";
      });
    }
  }

  Widget _buildCircularProgress() {
    double progress = (_totalAmperage != null && _totalAmperage! > 0)
        ? (_usedAmperage / _totalAmperage!).clamp(0.0, 1.0)
        : 0.0;

    return CircularPercentIndicator(
      radius: 120.0,
      lineWidth: 10.0,
      percent: progress,
      center: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "${(_usedAmperage / (_totalAmperage ?? 1.0) * 100).toStringAsFixed(1)}%",
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: progress >= 1.0 ? Colors.red : Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            progress >= 1.0 ? "⚠️ Overloaded ! تك" : "Safe Load",
            style: TextStyle(
              color: progress >= 1.0 ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
      progressColor: progress >= 1.0 ? Colors.red : Colors.blue,
      backgroundColor: Colors.grey[800]!,
      circularStrokeCap: CircularStrokeCap.round,
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Card(
      color: Colors.grey[900],
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue[200],
              ),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(" ⚡ ⚡ ادي الاشتراك؟",
        ),
        backgroundColor: Colors.blue[800],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildCard(
              title: "Set Total Amperage",
              child: Column(
                children: [
                  TextField(
                    controller: _totalAmpController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Enter Total Amperage (A)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _setTotalAmperage,
                    child: Text('Set'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildCircularProgress(),
            const SizedBox(height: 16),
            _buildCard(
              title: "Add Device",
              child: Column(
                children: [
                  TextField(
                    controller: _wattController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Enter Wattage (W)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _voltageController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Enter Voltage (V)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _addDevice,
                    child: Text('Add'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildCard(
              title: "Device List",
              child: _deviceList.isEmpty
                  ? Text("No devices yet.")
                  : ListView.builder(
                shrinkWrap: true,
                itemCount: _deviceList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_deviceList[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

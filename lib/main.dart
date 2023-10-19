import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDirectory = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);
  await Hive.openBox('imcBox');
  runApp(MyApp());
}

class IMC {
  double peso;
  double altura;

  IMC(this.peso, this.altura);

  double calcularIMC() {
    return peso / (altura * altura);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController pesoController = TextEditingController();
  late Box imcBox;
  String imcStatus = '';

  @override
  void initState() {
    super.initState();
    imcBox = Hive.box('imcBox');
  }

  void _navigateToConfiguracoesScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConfiguracoesScreen(),
      ),
    );
  }

  void calcularIMC() {
    double peso = double.parse(pesoController.text);
    double altura = double.parse(imcBox.get('altura', defaultValue: 0.0).toString());
    IMC imc = IMC(peso, altura);
    double imcValue = imc.calcularIMC();
    setState(() {
      imcBox.put('imc', imcValue);

      if (imcValue < 16) {
        imcStatus = "Magreza grave";
      } else if (imcValue >= 16 && imcValue < 17) {
        imcStatus = "Magreza moderada";
      } else if (imcValue >= 17 && imcValue < 18.5) {
        imcStatus = "Magreza leve";
      } else if (imcValue >= 18.5 && imcValue < 25) {
        imcStatus = "Saudável";
      } else if (imcValue >= 25 && imcValue < 30) {
        imcStatus = "Sobrepeso";
      } else if (imcValue >= 30 && imcValue < 35) {
        imcStatus = "Obesidade Grau I";
      } else if (imcValue >= 35 && imcValue < 40) {
        imcStatus = "Obesidade Grau II (severa)";
      } else {
        imcStatus = "Obesidade Grau III (mórbida)";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculadora de IMC'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              _navigateToConfiguracoesScreen(context);
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: pesoController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Peso (kg)'),
            ),
          ),
          ElevatedButton(
            onPressed: calcularIMC,
            child: Text('Calcular IMC'),
          ),
          ValueListenableBuilder(
            valueListenable: imcBox.listenable(),
            builder: (context, Box box, widget) {
              double imc = box.get('imc', defaultValue: 0.0);
              return Column(
                children: [
                  Text('IMC: ${imc.toStringAsFixed(2)}'),
                  Text('Status: $imcStatus'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class ConfiguracoesScreen extends StatefulWidget {
  @override
  _ConfiguracoesScreenState createState() => _ConfiguracoesScreenState();
}

class _ConfiguracoesScreenState extends State<ConfiguracoesScreen> {
  TextEditingController alturaController = TextEditingController();
  late Box imcBox;

  @override
  void initState() {
    super.initState();
    imcBox = Hive.box('imcBox');
    alturaController.text = imcBox.get('altura', defaultValue: 0.0).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configurações'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: alturaController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Altura (m)'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                double altura = double.parse(alturaController.text);
                imcBox.put('altura', altura);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Altura atualizada com sucesso!'),
                  ),
                );
              },
              child: Text('Salvar Altura'),
            ),
          ],
        ),
      ),
    );
  }
}

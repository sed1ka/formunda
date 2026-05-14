import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:formunda/formunda.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Formunda Example',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      home: const FormundaExamplePage(),
    );
  }
}

class FormundaExamplePage extends StatefulWidget {
  const FormundaExamplePage({super.key});

  @override
  State<FormundaExamplePage> createState() => _FormundaExamplePageState();
}

class _FormundaExamplePageState extends State<FormundaExamplePage> {
  final FormundaController _controller = FormundaController();
  late Future<Map<String, dynamic>> _loadFormFuture;

  @override
  void initState() {
    super.initState();
    // Inisialisasi future sekali saja untuk menghindari reload saat build dipanggil ulang
    _loadFormFuture = _loadFormAsset();

    // Melisten perubahan spesifik secara otomatis via stream
    _controller.fieldStream.listen((key) {
      debugPrint('Real-time update: Field $key changed to -> ${_controller.getValue(key)}');
    });

    // Dummy data awal untuk Table (Camunda 7 table dataSource binding)
    _controller.setValue('Field_1a3cndi', [
      {'id': '1', 'name': 'John Doe', 'date': '2024-01-01'},
      {'id': '2', 'name': 'Jane Smith', 'date': '2024-02-15'},
      {'id': '3', 'name': 'Alice Johnson', 'date': '2024-03-10'},
    ], batchUpdate: true);
  }

  /// Membaca file JSON dari assets
  Future<Map<String, dynamic>> _loadFormAsset() async {
    final String response = await rootBundle.loadString('assets/example_camunda7.json');
    return json.decode(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camunda 7 Form Parser'),
        actions: [
          IconButton(
            icon: const Icon(Icons.near_me_outlined),
            onPressed: () => _controller.scrollToField('Field_0attzlv'),
            tooltip: 'Scroll to Text Field',
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadFormFuture,
        builder: (context, snapshot) {
          // 1. State Loading Aset
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. State Error
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading assets: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red)),
            );
          }

          final rawData = snapshot.data ?? {};

          // 3. Render FormundaWidget
          return FormundaWidget(
            data: rawData,
            controller: _controller,
            renderMode: const ListViewMode(
              padding: EdgeInsets.all(16),
            ),
            // Indikator saat proses background isolate (parsing JSON -> Nodes)
            onLoadingBuilder: (context) => const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Isolate is parsing form structure...',
                      style: TextStyle(fontStyle: FontStyle.italic)),
                ],
              ),
            ),
            customWidgetBuilder: (context, node, controller) {
              // Override widget tertentu jika diperlukan
              if (node.id == 'Field_1rfb6ug') {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.auto_awesome),
                      SizedBox(width: 12),
                      Text('Custom Image Placeholder'),
                    ],
                  ),
                );
              }
              return null; // Fallback ke default factory
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final values = _controller.values;
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Current Form State'),
              content: SingleChildScrollView(
                child: Text(const JsonEncoder.withIndent('  ').convert(values)),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
        label: const Text('Get Values'),
        icon: const Icon(Icons.data_object),
      ),
    );
  }
}
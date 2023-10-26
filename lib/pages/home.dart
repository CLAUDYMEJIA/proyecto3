import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class Test {
  final String id;
  final String nombre;
  final String edad;
  final String telefono;

  Test({
    required this.id,
    required this.nombre,
    required this.edad,
    required this.telefono,
  });
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp().then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Proyecto 3',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
        ),
      ),
      home: const MyHomePage(title: 'Proyecto 3'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final CollectionReference testCollection =
      FirebaseFirestore.instance.collection("tbtest");

  final TextEditingController idController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController edadController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();

  Future<void> addTest() async {
    String id = idController.text.trim();
    String nombre = nombreController.text.trim();
    String edad = edadController.text.trim();
    String telefono = telefonoController.text.trim();

    if (id.isNotEmpty &&
        nombre.isNotEmpty &&
        edad.isNotEmpty &&
        telefono.isNotEmpty) {
      await testCollection.doc(id).set({
        'nombre': nombre,
        'edad': edad,
        'telefono': telefono,
      });

      idController.clear();
      nombreController.clear();
      edadController.clear();
      telefonoController.clear();

      _showSnackbar('Datos Agregados Correctamente del Cliente');
    } else {
      _showSnackbar('Por favor, completa todos los campos');
    }
  }

  Future<List<Test>> getTests() async {
    QuerySnapshot tests = await testCollection.get();
    List<Test> listaTests = [];
    if (tests.docs.length != 0) {
      for (var doc in tests.docs) {
        final data = doc.data() as Map<String, dynamic>;
        listaTests.add(Test(
          id: doc.id,
          nombre: data['nombre'] ?? '',
          edad: data['edad'] ?? '',
          telefono: data['telefono'] ?? '',
        ));
      }
    }
    return listaTests;
  }

  Future<void> reloadTests() async {
    setState(() {});
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 1),
      ),
    );
  }
    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.title),
      ),
      body: ScrollbarTheme(
        data: ScrollbarThemeData(
          thumbColor: MaterialStateProperty.all(Colors.red),
        ),
        child: Scrollbar(
          thumbVisibility: false,
          thickness: 8.0,
          radius: Radius.circular(8.0),
          child: CustomScrollView(
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildRoundedTextField(
                        controller: idController,
                        labelText: 'ID',
                        icon: Icons.numbers,
                      ),
                      SizedBox(height: 8.0),
                      _buildRoundedTextField(
                        controller: nombreController,
                        labelText: 'Nombre',
                        icon: Icons.person_2,
                      ),
                      SizedBox(height: 8.0),
                      _buildRoundedTextField(
                        controller: edadController,
                        labelText: 'Edad',
                        icon: Icons.date_range_sharp,
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 8.0),
                      _buildRoundedTextField(
                        controller: telefonoController,
                        labelText: 'Teléfono',
                        icon: Icons.phone_locked,
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              addTest();
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.red,
                              padding: EdgeInsets.symmetric(horizontal: 20),
                            ),
                            child: Text('Agregar'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              reloadTests();
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.green,
                              padding: EdgeInsets.symmetric(horizontal: 20),
                            ),
                            child: Text('Actualizar'),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.0),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: FutureBuilder<List<Test>>(
                  future: getTests(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error al cargar los datos'),
                      );
                    } else {
                      List<Test>? tests = snapshot.data;
                      return DataTable(
                        columns: [
                          DataColumn(label: Text('ID')),
                          DataColumn(label: Text('Nombre')),
                          DataColumn(label: Text('Edad')),
                          DataColumn(label: Text('Teléfono')),
                        ],
                        rows: tests!.map((test) {
                          return DataRow(cells: [
                            DataCell(Text(test.id)),
                            DataCell(Text(test.nombre)),
                            DataCell(Text(test.edad)),
                            DataCell(Text(test.telefono)),
                          ]);
                        }).toList(),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

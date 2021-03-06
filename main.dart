import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(MyAppHome());
}

class MyAppHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hospitais',
      home: _Lista(),
    );
  }
}

class _Lista extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<_Lista> {
  final List<Hospital> _hospitais = [
    new Hospital('Hospital Amaral Carvalho', 'Rua Doná Silvéria, 150', 'Oncologia', 18),
    new Hospital('Hospital Incor', 'Rua Dr.  Enéas Carvalho de Aguiar, 44', 'Cardiologia', 12),
    new Hospital('Hospital do Rim', 'Rua Borges Lagoa, 960', 'Nefrologia', 8),
    new Hospital('Hospital HCor', 'Rua Des. Eliseu Guilherme, 147', 'Neurologia', 7)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Lista dinâmica'),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () async {
                await Navigator.of(context).push(
                    new MaterialPageRoute(builder: (context) => Cadastro()));
                setState(() {});
              },
            )
          ],
        ),
        body: Container(
          child: FutureBuilder(
              future: DataBase.listar(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                NetworkImage('${snapshot.data[index].foto}'),
                          ),
                          title: Text('${snapshot.data[index].nome}'),
                          subtitle:
                              Text('${snapshot.data[index].especialidade}'),
                          trailing: Icon(Icons.keyboard_arrow_right)),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (contex) =>
                                        Endereco(hospital: _hospitais[index])));
                          };
                    });
              }),
        ));
  }
}


class Endereco extends StatelessWidget{
  final Hospital hospital;
   
  Endereco({Key key, @required this.hospital});
    
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Endereco do Hospital')
      ),
      body: Container(
        color: Colors.grey,
        child: new Column(
          children: [
            new Container(
              margin: new EdgeInsets.all(10.0),
              child: Center(
                child: Image.network(
                  hospital.foto,
                )
              ),
            ),
            new Container(
              padding: new EdgeInsets.all(10.0),
              child: Center(
                child: Text(
                  hospital.nome,
//                   style: TextStyle(color: Colors.white, fontSize: 25),
                )
              ),
            ),
            new Container(
              padding: new EdgeInsets.all(10.0),
              child: Center(
                child: Text(
                  hospital.endereco,
                )
              ),
            ),
          ]
        ),
      )
    );
  }
}


class Cadastro extends StatelessWidget {
  final TextEditingController _controladorNome = TextEditingController();
  final TextEditingController _controladorEndereco = TextEditingController();
  final TextEditingController _controladorEspecialidade =
      TextEditingController();
  final TextEditingController _controladorNumeroLeitos =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Novo Hospital"),
        ),
        body: new Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.white,
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextField(
                controller: _controladorNome,
                decoration: InputDecoration(labelText: 'Nome'),
              ),
              TextField(
                controller: _controladorEndereco,
                decoration: InputDecoration(labelText: 'Endereço'),
              ),
              TextField(
                controller: _controladorEspecialidade,
                decoration: InputDecoration(labelText: 'Especialidade'),
              ),
              TextField(
                controller: _controladorNumeroLeitos,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Quantidade de Leitos'),
              ),
              RaisedButton(
                child: Text('Cadastrar'),
                onPressed: () {
                  final String nome = _controladorNome.text;
                  final String endereco = _controladorEndereco.text;
                  final String especialidade = _controladorEspecialidade.text;
                  final int numeroLeitos =
                      int.tryParse(_controladorNumeroLeitos.text);

                  final Hospital hospitalNovo =
                      Hospital(nome, endereco, especialidade, numeroLeitos);
                  print(hospitalNovo);
                  //Hospitais.hospitais.add(hospitalNovo);
                  DataBase.salva(hospitalNovo);
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
        ));
  }
}

class Hospital {
  final String nome;
  final String endereco;
  final String foto = 'http://abre.ai/bmg7';
  final String especialidade;
  final int numeroLeitos;

  Hospital(this.nome, this.endereco, this.especialidade, this.numeroLeitos);

  @override
  String toString() {
    return 'Hospital{nome: $nome, endereco: $endereco, especialidade: $especialidade, leitos: $numeroLeitos}';
  }
}

// Singleton
class Hospitais {
  static final Hospitais _singleton = new Hospitais._internal();
  static final List<Hospital> _hospitais = [
    new Hospital('Hospital Albert Einsten', 'Jardim Leonor, 627', 'Clínica Médica, Cirurgica e Pediatrica', 60),
    new Hospital(
        'Sírio Libanês', 'Dona Adma Jafet, 91', 'Pediatria', 20)
  ];

  factory Hospitais() {
    return _singleton;
  }

  static List<Hospital> get hospitais => _hospitais;
  Hospitais._internal();
}

/* Classe database */
class DataBase {
  static final DataBase _singleton = new DataBase._internal();

  factory DataBase() {
    return _singleton;
  }

  static _recuperandoBancoDados() async {
    final caminhoBancoDados = await getDatabasesPath();
    final localBancoDados = join(caminhoBancoDados, "hospitais.db");
    var bd = await openDatabase(localBancoDados, version: 1,
        onCreate: (db, dbVersaoRecente) {
      String sql =
          "CREATE TABLE HOSPITAIS (id INTEGER PRIMARY KEY AUTOINCREMENT, nome VARCHAR, endereco VARCHAR, foto VARCHAR, especialidade VARCHAR, numeroleitos INTEGER)";

      db.execute(sql);
    });
    return bd;
  }

  static salva(Hospital hospital) async {
    Database bd = await _recuperandoBancoDados();
    Map<String, dynamic> dadosHospital = {
      "nome": hospital.nome,
      "endereco": hospital.endereco,
      "foto": hospital.foto,
      "especialidade": hospital.especialidade,
      "numeroleitos": hospital.numeroLeitos
    };

    int id = await bd.insert("HOSPITAIS", dadosHospital);
    print("Salvo:  $id");
  }

  static Future listar() async {
    Database bd = await _recuperandoBancoDados();
    List listaHospitais = await bd.rawQuery("SELECT * FROM HOSPITAIS");
    var _hospitais = new List();
    for (var item in listaHospitais) {
      Hospital hospital = new Hospital(item['nome'], item['endereco'],
          item['especialidade'], item['numeroLeitos']);
      _hospitais.add(hospital);
    }
    return _hospitais;
  }

  DataBase._internal();
}

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Extraordinario',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  TextEditingController usuario = TextEditingController();
  TextEditingController contrasenia = TextEditingController();
  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Stack(
        children: <Widget>[
           Container(
            height: size.height  * 0.2,
            width: double.infinity
          ),
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SafeArea(
                  child: Container(
                    height: 200.0,
                  ),
                ),
                Container(
                  width: size.width * 0.85,
                  padding: EdgeInsets.symmetric(vertical: 50.0),
                  margin: EdgeInsets.symmetric(vertical: 30.0),
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: TextField(
                          controller: usuario,
                          decoration: InputDecoration(
                            icon: Icon(Icons.account_circle, color: Colors.green,),
                            labelText: 'Usuario',
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30.0,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: TextField(
                          controller: contrasenia,
                          obscureText: true,
                          decoration: InputDecoration(
                            icon: Icon(Icons.account_circle, color: Colors.green,),
                            labelText: 'contraseña',
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30.0,
                      ),
                      RaisedButton(
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 70.0),
                          child: Text('Inicio'),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0)
                        ),
                        color: Colors.green,
                        textColor: Colors.white,
                        
                        onPressed: (){
                          if(usuario.text=='admin' && contrasenia.text=='admin'){
                            Navigator.pop(context);
                              final ruta = MaterialPageRoute(
                                builder: (context) => (EntradaPage())
                              );
                              Navigator.push(context, ruta);
                          }else{
                            AlertDialog(
                              title: Text('Algo Salio mal'),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text('Ok'),
                                  onPressed: (){
                                    Navigator.of(context).pop();
                                  },
                                )
                              ],
                            );
                          }
                        },
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class EntradaPage extends StatefulWidget {

  @override
  _EntradaPageState createState() => _EntradaPageState();
}

class _EntradaPageState extends State<EntradaPage> {
 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registros Encontrados'),
      ),
    body: FutureBuilder(
      future: getTodosAPI(),
      builder: (context, snapshot){
        if(snapshot.data == null){
          print('lugar1');
          return Center(
            child: CircularProgressIndicator(),
          );
        }else{
          print('lugar2');
          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (context,indice){
              return ListTile(
                leading: Icon(Icons.assignment_ind),
                title: Text('Fecha: '+snapshot.data[indice].fecha),
                subtitle: Text('Registrados :'+snapshot.data[indice].total),
                trailing: Icon(Icons.info_outline),
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => PorFecha(aspirante: snapshot.data[indice],)));
                },
              );
            },
          );
        }
      },
    ),
    );
  }
}

class PorFecha extends StatelessWidget{
  final AspirantesCompletos aspirante;
  
  const PorFecha({Key key, this.aspirante}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registros Encontrados P'),
      ),
    body: FutureBuilder(
      future: getPorFechaAPI(aspirante.fecha),
      builder: (context, snapshot){
        if(snapshot.data == null){
          print('lugar1');
          return Center(
            child: CircularProgressIndicator(),
          );
        }else{
          print('lugar2');
          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (context,indice){
              return ListTile(
                leading: Icon(Icons.assignment_ind),
                title: Text('Nombre: '+snapshot.data[indice].nombre+' '+snapshot.data[indice].apellido),
                subtitle: Text('Desea Estudiar en la UPIIZ :'+snapshot.data[indice].upiiz),
                trailing: Icon(Icons.info_outline),
                onTap: (){
                },
              );
            },
          );
        }
      },
    ),
    );
  }
}



Future<List<AspirantesPorFecha>> getPorFechaAPI(String fecha) async{ 
 
  //Listado a retornar   
  List<AspirantesPorFecha> listadoFechas=[]; 
 
  //Url de la solicitud   
  var url="http://sistemas.upiiz.ipn.mx/isc/sira/api/actionReadAspiranteTotalFechaApp.php?accion=read&fecha="+fecha; 

 
  //Realizar la solicitud   
  var respuestaAPI = await http.get(url); 
 
  //Revisar el estado de la solicitud   
  if(respuestaAPI.statusCode==200){     
    var misAspirantesAPI = json.decode(respuestaAPI.body);    
     //En un ciclo, a�adir todos los libros     
     //El ciclo del campo libros = Recorrer el Arreglo    
    if (misAspirantesAPI["estado"]==1){
      for(var e in misAspirantesAPI["listado"] )       
     listadoFechas.add(AspirantesPorFecha(         
       nombre: e["nombre"].toString(),         
       apellido: e["apelllido"].toString(),         
       upiiz: e["upiiz"].toString(),      
      ));
    }
     }   return listadoFechas; } 

Future<List<AspirantesCompletos>> getTodosAPI() async{ 
 
  //Listado a retornar   
  List<AspirantesCompletos> listadoCompleto=[]; 
 
  //Url de la solicitud   
  var url="http://sistemas.upiiz.ipn.mx/isc/sira/api/actionReadAspiranteTotalApp.php?accion=read"; 

 
  //Realizar la solicitud   
  var respuestaAPI = await http.get(url); 
 
  //Revisar el estado de la solicitud   
  if(respuestaAPI.statusCode==200){ 
          print('lugar3');
    var misAspirantesAPI = json.decode(respuestaAPI.body);    
     //En un ciclo, a�adir todos los libros     
     //El ciclo del campo libros = Recorrer el Arreglo    
    if (misAspirantesAPI["estado"]==1){
      for(var e in misAspirantesAPI["listado"] )       
     listadoCompleto.add(AspirantesCompletos(         
       fecha: e["Fecha"].toString(),         
       total: e["Total"].toString(),    
      ));
    }
     }   return listadoCompleto; } 
 
class AspirantesPorFecha{
     final String nombre;
     final String apellido;
     final String upiiz; 
 
  AspirantesPorFecha({this.nombre,this.apellido,this.upiiz}); 
}
class AspirantesCompletos{
     final String fecha;
     final String total;
 
  AspirantesCompletos({this.fecha,this.total}); 
}
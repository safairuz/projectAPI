import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

void main() => runApp(MyApp());

String url = "https://calm-plum-jaguar-tutu.cyclic.app/todos";

class Todo {
  final int userId;
  final int id;
  final String title;
  final bool completed;

  Todo({
    required this.userId,
    required this.id,
    required this.title,
    required this.completed,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      userId: json['userId'] ?? 0,
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      completed: json['completed'] ?? false,
    );
  }
}

Future<List<Todo>> fetchTodos() async {
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    List<dynamic> body = json.decode(response.body);
    List<Todo> todos = body.map((dynamic item) => Todo.fromJson(item)).toList();
    return todos;
  } else {
    throw Exception('Failed to load todos');
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Future<List<Todo>> todos = fetchTodos();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
      ),
      body: Center(
        child: FutureBuilder<List<Todo>>(
          future: todos,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            } else if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    elevation: 4, // Berikan shadow dengan elevasi 4
                    margin: EdgeInsets.all(8), // Berikan margin pada card
                    child: ListTile(
                      title: Text(snapshot.data![index].title),
                      subtitle: Text(snapshot.data![index].completed
                          ? 'Completed'
                          : 'Incomplete'),
                    ),
                  );
                },
              );
            }
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}

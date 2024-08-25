import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: InfiniteScrollPage(),
    );
  }
}

class InfiniteScrollPage extends StatefulWidget {
  @override
  _InfiniteScrollPageState createState() => _InfiniteScrollPageState();
}

class _InfiniteScrollPageState extends State<InfiniteScrollPage> {
  final ScrollController _scrollController = ScrollController();
  List<dynamic> _todos = [];
  int _page = 1;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchTodos();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _fetchTodos();
      }
    });
  }

  Future<void> _fetchTodos() async {
    if (_isLoading || !_hasMore) return;
    setState(() {
      _isLoading = true;
    });

    final response = await http.get(Uri.parse(
        'https://jsonplaceholder.typicode.com/todos?_limit=10&_page=$_page'));

    if (response.statusCode == 200) {
      List newTodos = json.decode(response.body);
      setState(() {
        _page++;
        _todos.addAll(newTodos);
        _isLoading = false;
        if (newTodos.length < 10) {
          _hasMore = false;
        }
      });
    } else {
      setState(() {
        _isLoading = false;
        _hasMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Infinite Scroller'),
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: _todos.length + 1,
        itemBuilder: (context, index) {
          if (index < _todos.length) {
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                title: Text(_todos[index]['title']),
                leading: CircleAvatar(
                  child: Text(_todos[index]['id'].toString()),
                ),
              ),
            );
          } else {
            return _hasMore
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: Text('No more data')),
                  );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

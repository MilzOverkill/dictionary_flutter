import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text("Search for word "),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset( /// image
                "assets/dic.png",
                fit: BoxFit.cover,
                height: MediaQuery.of(context).size.height / 3.5,
              ),
              SizedBox(height: 50),
              TextField(
                controller: _controller,
                decoration:InputDecoration(
                  hintText: "Enter a Word",
                  border: OutlineInputBorder(),
                ) ,
              ),

              SizedBox(height: 50),


              
            ],
          ),
        ),
      ),
    );
  }
}

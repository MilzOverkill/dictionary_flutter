import 'dart:convert'; // Imports the Dart library for encoding and decoding JSON data.

import 'package:flutter/material.dart'; // Imports the Flutter material design package for UI components.
import 'package:http/http.dart' as http; // Imports the http package to perform HTTP requests, with an alias 'http'.

void main() { // The entry point of the Flutter application.
  runApp(MyApp()); // Runs the MyApp widget, which is the root of the application.
}

class MyApp extends StatelessWidget { // Defines a stateless widget called MyApp.
  @override
  Widget build(BuildContext context) { // The build method describes how to display the widget.
    return MaterialApp( // Returns a MaterialApp widget.
      title: 'Dictionary App', // Sets the title of the application.
      theme: ThemeData( // Defines the theme of the application.
        primarySwatch: Colors.blue, // Sets the primary color to blue.
      ),
      home: HomeScreen(), // Sets the home screen of the application to be the HomeScreen widget.
    );
  }
}

class HomeScreen extends StatelessWidget { // Defines a stateless widget called HomeScreen.
  final TextEditingController _controller = TextEditingController(); // Creates a TextEditingController to control the input field.

  @override
  Widget build(BuildContext context) { // The build method describes how to display the widget.
    return Scaffold( // Returns a Scaffold widget, which provides a structure for the visual interface.
      appBar: AppBar( // Adds an AppBar to the Scaffold.
        title: Text('Dictionary App'), // Sets the title of the AppBar.
      ),
      body: Padding( // Adds padding around the body content.
        padding: const EdgeInsets.all(16.0), // Sets padding of 16 pixels on all sides.
        child: Column( // Arranges the child widgets in a vertical column.
          children: [ // The list of child widgets.
            TextField( // Adds a TextField widget for user input.
              controller: _controller, // Connects the TextField to the TextEditingController.
              decoration: InputDecoration( // Adds decoration to the TextField.
                labelText: 'Enter a word', // Sets the label text.
                border: OutlineInputBorder(), // Adds an outline border around the TextField.
              ),
            ),
            SizedBox(height: 16), // Adds a SizedBox with a height of 16 pixels for spacing.
            ElevatedButton( // Adds an elevated button.
              onPressed: () { // Defines the action when the button is pressed.
                if (_controller.text.isNotEmpty) { // Checks if the TextField is not empty.
                  Navigator.push( // Navigates to a new screen.
                    context, // The context of the current screen.
                    MaterialPageRoute( // Creates a route to a new screen.
                      builder: (context) => ResultScreen(word: _controller.text), // Defines the destination as ResultScreen, passing the entered word.
                    ),
                  );
                }
              },
              child: Text('Search'), // Sets the text on the button.
            ),
          ],
        ),
      ),
    );
  }
}

class ResultScreen extends StatefulWidget { // Defines a stateful widget called ResultScreen.
  final String word; // The word to search for, passed as a parameter.

  const ResultScreen({Key? key, required this.word}) : super(key: key); // The constructor, initializing the word.

  @override
  State<ResultScreen> createState() => _ResultScreenState(); // Creates the mutable state for the ResultScreen.
}

class _ResultScreenState extends State<ResultScreen> { // Defines the state class for ResultScreen.
  Future<Map<String, dynamic>>? _futureWordData; // A future variable to hold the fetched word data.

  @override
  void initState() { // The initState method is called when this state is created.
    super.initState(); // Calls the parent class's initState method.
    _futureWordData = _fetchWordData(widget.word); // Fetches the word data when the state initializes.
  }

  Future<Map<String, dynamic>> _fetchWordData(String word) async { // A method to fetch word data from the API.
    final response = await http.get(Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$word')); // Performs a GET request to the API.

    if (response.statusCode == 200) { // Checks if the request was successful.
      return jsonDecode(response.body)[0]; // Decodes the JSON response and returns the first entry.
    } else {
      throw Exception("Failed to load word data"); // Throws an exception if the request failed.
    }
  }

  @override
  Widget build(BuildContext context) { // The build method describes how to display the widget.
    return Scaffold( // Returns a Scaffold widget.
      appBar: AppBar( // Adds an AppBar to the Scaffold.
        title: Text(widget.word), // Sets the title of the AppBar to the searched word.
      ),
      body: FutureBuilder<Map<String, dynamic>>( // Uses a FutureBuilder to handle asynchronous data fetching.
        future: _futureWordData, // The future to wait for.
        builder: (context, snapshot) { // The builder function to build the widget based on the snapshot state.
          if (snapshot.connectionState == ConnectionState.waiting) { // Checks if the future is still loading.
            return Center(child: CircularProgressIndicator()); // Shows a loading indicator.
          } else if (snapshot.hasError) { // Checks if the future completed with an error.
            return Center(
              child: Text("Nothing Found"), // Shows an error message.
            );
          } else { // If the future completed successfully.
            final wordData = snapshot.data!; // Gets the word data from the snapshot.
            final List meanings = wordData['meanings'] ?? []; // Gets the meanings from the word data.
            return ListView.builder( // Builds a scrollable list.
              itemCount: meanings.length, // The number of items in the list.
              itemBuilder: (context, index) { // The builder function to build each item.
                final meaning = meanings[index]; // Gets the meaning at the current index.
                final String partsOfSpeech = meaning['partOfSpeech'] ?? ''; // Gets the part of speech.
                final List definitions = meaning['definitions'] ?? []; // Gets the definitions.
                final List synonyms = meaning['synonyms'] ?? []; // Gets the synonyms.
                final List antonyms = meaning['antonyms'] ?? []; // Gets the antonyms.
                return Padding( // Adds padding around each item.
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10), // Sets vertical and horizontal padding.
                  child: Card( // Adds a Card widget for styling.
                    color: Colors.white, // Sets the card color.
                    child: Padding( // Adds padding inside the card.
                      padding: EdgeInsets.all(8), // Sets padding on all sides.
                      child: Column( // Arranges the child widgets in a vertical column.
                        crossAxisAlignment: CrossAxisAlignment.start, // Aligns children to the start.
                        children: [
                          Text( // Adds a Text widget for the part of speech.
                            partsOfSpeech,
                            style: TextStyle(
                              fontWeight: FontWeight.bold, // Makes the text bold.
                            ),
                          ),
                          if (definitions.isNotEmpty) // Checks if there are definitions.
                            ...definitions.map((definition) { // Maps each definition to a widget.
                              return Column( // Arranges the definition widgets in a vertical column.
                                crossAxisAlignment: CrossAxisAlignment.start, // Aligns children to the start.
                                children: [
                                  Text(
                                    definition['definition'] ?? '', // Shows the definition text.
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic, // Makes the text italic.
                                    ),
                                  ),
                                  if (definition['example'] != null) // Checks if there is an example.
                                    Text(
                                      "Example: ${definition['example']}", // Shows the example text.
                                      style: TextStyle(color: Colors.grey), // Styles the example text.
                                    ),
                                ],
                              );
                            }).toList(),
                          if (synonyms.isNotEmpty) // Checks if there are synonyms.
                            Text(
                              "Synonyms: ${synonyms.join(", ")}", // Shows the synonyms.
                              style: TextStyle(color: Colors.indigo), // Styles the synonyms text.
                            ),
                          if (antonyms.isNotEmpty) // Checks if there are antonyms.
                            Text(
                              "Antonyms: ${antonyms.join(", ")}", // Shows the antonyms.
                              style: TextStyle(color: Colors.blue), // Styles the antonyms text.
                            ),
                          SizedBox(height: 10), // Adds spacing after each card.
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: '',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 29, 18, 114),
            primary: Colors.indigo,
          ),
          textTheme: const TextTheme(
            displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            titleMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            bodyMedium: TextStyle(fontSize: 18),
          ),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var history = <WordPair>[]; // Menyimpan history
  var favorites = <WordPair>[]; // Menyimpan favorit

  void getNext() {
    current = WordPair.random();
    history.add(current); // Menambahkan kata yang baru dihasilkan ke history
    notifyListeners();
  }

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      case 2:
        page = HistoryPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        elevation: 0,
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            selectedIndex = index;
          });
        },
        selectedIndex: selectedIndex,
        destinations: [
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.favorite),
            icon: Icon(Icons.favorite_outline),
            label: "Favorites",
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.history),
            icon: Icon(Icons.history_rounded),
            label: "History",
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: page,
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  const GeneratorPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          const SizedBox(height: 20),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon, color: Colors.white),
                label: const Text(
                  'Like',
                  style: TextStyle(color: Colors.white),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 162, 0, 33),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: const Text('Next Word'),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  side: BorderSide(color: Colors.indigo),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Text(
          pair.asLowerCase,
          style: style,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Container(
      color: Colors.blueGrey.shade50,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Menambahkan tombol "Delete All" di bagian atas dengan styling
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'History Word',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
              ),
              TextButton(
                onPressed: () {
                  // Menghapus seluruh history
                  appState.history.clear();
                  appState.notifyListeners();
                },
                child: Text(
                  'Delete All',
                  style: TextStyle(color: Colors.white),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (appState.history.isEmpty)
            Center(
              child: Text(
                'Tidak ada Kata.',
                style: TextStyle(color: Colors.indigo.shade500),
              ),
            ),
          ...appState.history.map(
            (word) => Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(
                  word.asLowerCase,
                  style: TextStyle(color: Colors.indigo.shade800),
                ),
                leading: Icon(
                  Icons.history,
                  color: const Color.fromARGB(255, 12, 10, 6),
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Word ${word.asLowerCase}!"),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Container(
      color: Colors.blueGrey.shade50,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Hi, Safira You Have ${appState.favorites.length} Favorite Words',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
          ),
          const SizedBox(height: 16),
          ...appState.favorites.map(
            (word) => Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(
                  word.asLowerCase,
                  style: TextStyle(color: Colors.indigo.shade800),
                ),
                leading: Icon(
                  Icons.favorite,
                  color: const Color.fromARGB(255, 237, 5, 83),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete_forever_rounded, color: Colors.red),
                  onPressed: () {
                    appState.favorites.remove(word); // Hapus item favorit
                    appState
                        .notifyListeners(); // Perbarui tampilan setelah menghapus
                  },
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("It's ${word.asLowerCase}!"),
                    ),
                  );
                },
                onLongPress: () {
                  appState.favorites.remove(word);
                  appState
                      .notifyListeners(); // Perbarui tampilan setelah menghapus
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text("${word.asLowerCase} removed from favorites."),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

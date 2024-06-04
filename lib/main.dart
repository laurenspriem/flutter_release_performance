import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int clusteringTime = 0;

  void cluster() async {
    setState(() {
      clusteringTime = -1;
    });
    clusteringTime = await compute(clusteringTimeInSeconds, 5000);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'LinearClustering for 10K embeddings in ${kDebugMode ? 'debug' : 'release'} mode:',
            ),
            Text(
              key: ValueKey(clusteringTime),
              clusteringTime == -1
                  ? 'running clustering'
                  : '$clusteringTime seconds with Vectors',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: cluster,
        tooltip: 'Cluster',
        child: const Icon(Icons.analytics_outlined),
      ),
    );
  }
}

Future<int> clusteringTimeInSeconds(int embeddingAmount) async {
  // Create 10K fake embeddings
  final embeddings = List.generate(embeddingAmount, (_) => _createRandomEmbedding());

  final startTime = DateTime.now();
  for (int i = 1; i < embeddings.length; i++) {
    if ((i + 1) % 250 == 0) {
      debugPrint("Processed ${i + 1} embeddings");
    }
    final embedding1 = embeddings[i];
    for (int j = i - 1; j >= 0; j--) {
      double distance = 0;
      final embedding2 = embeddings[j];
      for (int i = 0; i < 192; i++) {
        distance += embedding1[i] * embedding2[i];
      }
      distance = 1 - distance;
    }
  }
  final listClusteringTime = DateTime.now().difference(startTime).inSeconds;

  return listClusteringTime;
}

List<double> _createRandomEmbedding([int length = 192]) {
  final random = Random();
  final embedding = List<double>.generate(length, (_) => random.nextDouble());
  return _normalize(embedding);
}

List<double> _normalize(List<double> embedding) {
  final norm = _calculateNorm(embedding);
  return embedding.map((value) => value / norm).toList();
}

double _calculateNorm(List<double> embedding) {
  return sqrt(embedding.fold(0, (sum, value) => sum + value * value));
}

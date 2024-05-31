import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ml_linalg/linalg.dart';

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
  int clusteringTimeVector = 0;

  void cluster() async {
    setState(() {
      clusteringTimeVector = -1;
    });
    final timesInSeconds = await compute(clusteringTimeInSeconds, 10000);
    clusteringTimeVector = timesInSeconds;
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
              key: ValueKey(clusteringTimeVector),
              clusteringTimeVector == -1
                  ? 'running clustering'
                  : '$clusteringTimeVector seconds with Vectors',
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
  final List<Vector> vectorEmbeddings =
      embeddings.map((embedding) => Vector.fromList(embedding)).toList();

  final startTime = DateTime.now();
  for (int i = 1; i < embeddings.length; i++) {
    if ((i + 1) % 250 == 0) {
      debugPrint("Processed ${i + 1} embeddings");
    }
    final vectorEmbedding1 = vectorEmbeddings[i];
    double closestDistance = double.infinity;
    for (int j = i - 1; j >= 0; j--) {
      final double distance = 1 - vectorEmbedding1.dot(vectorEmbeddings[j]);
      if (distance < closestDistance) {
        closestDistance = distance;
      }
    }
  }
  final endTime = DateTime.now();
  final vectorClusteringTime = endTime.difference(startTime).inSeconds;

  return vectorClusteringTime;
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

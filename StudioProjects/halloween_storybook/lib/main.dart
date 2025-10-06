// lib/main.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(const MyApp());

class GameItem {
  String asset;
  bool isTrap;
  bool isTarget;
  double left, top, size;
  GameItem({
    required this.asset,
    this.isTrap = false,
    this.isTarget = false,
    this.left = 0,
    this.top = 0,
    this.size = 64,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spooky Storybook',
      theme: ThemeData.dark(),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Spooky Storybook')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Start Game'),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GamePage()),
          ),
        ),
      ),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});
  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final Random _rand = Random();
  final List<GameItem> _items = [];
  Timer? _timer;
  late AudioPlayer _bgPlayer;
  late AudioPlayer _sfxPlayer;
  bool _found = false;

  @override
  void initState() {
    super.initState();
    _bgPlayer = AudioPlayer();
    _sfxPlayer = AudioPlayer();
    // configure items (assets should be in assets/images/)
    _items.addAll([
      GameItem(asset: 'assets/images/ghost.png'),
      GameItem(asset: 'assets/images/pumpkin.png'),
      GameItem(asset: 'assets/images/bat.png'),
      GameItem(asset: 'assets/images/ghost.png', isTrap: true),
      GameItem(asset: 'assets/images/pumpkin.png', isTrap: true),
      GameItem(asset: 'assets/images/target_item.png', isTarget: true),
    ]);
    // start background audio (loop)
    _startBgMusic();
    // start random movement after first frame to get sizes
    WidgetsBinding.instance.addPostFrameCallback((_) => _startMovement(context));
  }

  Future<void> _startBgMusic() async {
    try {
      await _bgPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgPlayer.play(AssetSource('audio/bg.mp3'));
    } catch (e) {
      // ignore for now
    }
  }

  void _startMovement(BuildContext context) {
    // initialize random positions inside the available area
    final size = MediaQuery.of(context).size;
    for (var it in _items) {
      it.size = (size.width / 6).clamp(48, 100);
      it.left = _rand.nextDouble() * (size.width - it.size - 16);
      it.top = _rand.nextDouble() * (size.height - it.size - 120);
    }
    setState(() {});
    // every 1.5s, randomize positions for movement
    _timer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
      final s = MediaQuery.of(context).size;
      setState(() {
        for (var it in _items) {
          final maxLeft = (s.width - it.size - 16).clamp(0, s.width);
          final maxTop = (s.height - it.size - 120).clamp(0, s.height);
          it.left = _rand.nextDouble() * maxLeft;
          it.top = _rand.nextDouble() * maxTop;
        }
      });
    });
    // precache images
    for (var it in _items) {
      precacheImage(AssetImage(it.asset), context);
    }
  }

  Future<void> _playSfx(String file) async {
    try {
      await _sfxPlayer.play(AssetSource(file));
    } catch (e) {}
  }

  void _onTapItem(GameItem item) {
    if (_found) return;
    if (item.isTrap) {
      _playSfx('audio/jumpscare.mp3');
      // tiny visual flash
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.black,
          content: const Text('AHH! Trap!', style: TextStyle(color: Colors.white)),
        ),
      );
      Future.delayed(const Duration(milliseconds: 700), () => Navigator.pop(context));
      return;
    }
    if (item.isTarget) {
      _found = true;
      _playSfx('audio/success.mp3');
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('You Found It!'),
          content: const Text('Congrats — you found the secret item!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // go back home for now
              },
              child: const Text('OK'),
            )
          ],
        ),
      );
      return;
    }
    // neutral item — small twinkle sfx optional
    _playSfx('audio/empty.mp3');
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bgPlayer.dispose();
    _sfxPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find the right item')),
      body: LayoutBuilder(builder: (context, constraints) {
        return Stack(
          children: [
            // background - simple gradient; replace with CustomPainter for more spook
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Colors.black87, Colors.indigo]),
              ),
            ),
            ..._items.map((item) {
              return AnimatedPositioned(
                duration: const Duration(milliseconds: 800),
                left: item.left,
                top: item.top,
                child: GestureDetector(
                  onTap: () => _onTapItem(item),
                  child: SizedBox(
                    width: item.size,
                    height: item.size,
                    child: Image.asset(item.asset, fit: BoxFit.contain),
                  ),
                ),
              );
            }).toList(),
            // overlay HUD
            Positioned(
              left: 12,
              top: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(8)),
                child: const Text('Tap objects — avoid traps!', style: TextStyle(fontSize: 16)),
              ),
            )
          ],
        );
      }),
    );
  }
}

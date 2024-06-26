import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Mobile Scale App',
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) => const MyHomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Image.asset(
              'assets/loadingpage.png',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Image.asset(
              'assets/logo.png',
              width: 130,
              height: 130,
            ),
          ),
          //Positioned(
          //  left: 0,
          //  right: 0,
          //  bottom: 20.0,
          //  child: Text(
           //   'Made in Indonesia',
           //   textAlign: TextAlign.center,
           //   style: TextStyle(
           //     color: Colors.grey,
           //     fontSize: 8.0,
           //  ),
           // ),
         // ),
        ],
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  late WebSocketChannel channel;
  double weight = 0.0;
  String status = "Connecting...";
  bool isTaring = false;
  bool isLoading = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    connectWebSocket();

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    );

    if (weight > 0) {
      _controller.repeat();
    }
  }

  void connectWebSocket() {
    channel = WebSocketChannel.connect(
      Uri.parse('ws://192.168.199.116:81'),
    );

    channel.stream.listen((data) {
      if (kDebugMode) {
        print('Data received: $data');
      }
      setState(() {
        weight = double.tryParse(data) ?? 0.0;
        status = "Connected";
        if (weight > 0) {
          _controller.repeat();
        } else {
          _controller.stop();
        }
      });
    }, onError: (error) {
      if (kDebugMode) {
        print('WebSocket error: $error');
      }
      setState(() {
        status = "Connection Error";
      });
      reconnectWebSocket();
    }, onDone: () {
      if (kDebugMode) {
        print('WebSocket closed');
      }
      setState(() {
        status = "Disconnected";
      });
      reconnectWebSocket();
    });
  }

  void reconnectWebSocket() {
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        status = "Reconnecting...";
      });
      connectWebSocket();
    });
  }

  void tareWeight() {
    setState(() {
      isTaring = true;
      isLoading = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tare dilakukan.'),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
        weight = 0.0;
        _controller.stop();
      });
    });
  }

  void addWeight() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Berat bertambah 0.1.'),
      ),
    );
  }

  void resetWeight() {
    setState(() {
      isTaring = false;
      weight = 0.0;
      _controller.stop();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Berat timbangan direset.'),
      ),
    );
  }

  void showWeightDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: _controller,
              curve: Curves.elasticOut,
            ),
            child: AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              title: Text(
                'Weight Result',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.orangeAccent[800]),
              ),
              content: Text(
                'The current result is ${weight.toStringAsFixed(1)} Grams.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.orange[800]),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK', style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          ),
        );
      },
    );

    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: <Widget>[
          Positioned(
          top: 100,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              child: Image.asset(
                'assets/logonama.png',
                width: 100,
                height: 100,
              ),
            ),
          ),
        ),
        Positioned.fill(
        bottom: MediaQuery.of(context).size.height / 2 - 50,
    child: Container(
    decoration: BoxDecoration(
    borderRadius: const BorderRadius.only(
    bottomLeft: Radius.circular(50.0),
    bottomRight: Radius.circular(50.0),
    ),
    gradient: const LinearGradient(
    colors: [
    Colors.orangeAccent,
    Colors.deepOrangeAccent,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    ),
    boxShadow: [
    BoxShadow(
    color: Colors.grey.withOpacity(0.5),
    spreadRadius: 5,
    blurRadius: 7,
    offset: const Offset(0, 3),
    ),
    ],
    ),
    child: Center(
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Text(
    weight == 0 ? 'Weigh Here' : 'Weight In',
    textAlign: TextAlign.center,
    style: TextStyle(
    color: Colors.white,
    fontSize: 17.0,
    fontWeight: FontWeight.bold,
    shadows: [
    BoxShadow(
    color: Colors.black.withOpacity(0.3),
    blurRadius: 2,
    offset: const Offset(0, 3),
    ),
    ],
    ),
    ),
    const SizedBox(height: 20),
    Container(
    width: 200.0,
    height: 200.0,
    decoration: const BoxDecoration(
    shape: BoxShape.circle,
    ),
    child: ClipOval(
    child: CustomPaint(
    painter: RadialPulsePainter(_animation),
    child: Center(
    child: Stack(
    alignment: Alignment.center,
    children: [
    if (isLoading)
    const CircularProgressIndicator(
    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
    ),
    GestureDetector(
    onTap: () {
    if (!isTaring) {
    addWeight();
    }
    },
    onLongPress: tareWeight,
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Text(
    weight.toStringAsFixed(1),
    textAlign: TextAlign.center,
    style: TextStyle(
    color: Colors.white,
    fontSize: 50.0,
    fontWeight: FontWeight.bold,
    shadows: [
    BoxShadow(
    color: Colors.black.withOpacity(0.3),
    blurRadius: 3,
    offset: const Offset(0, 3),
    ),
    ],
    ),
    ),
    const Text(
    'Grams',
    style: TextStyle(
    color: Colors.white,
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    ),
    ),
    ],
    ),
    ),
    ],
    ),
    ),
    ),
    ),
    ),
    const SizedBox(height: 20),
    const Text(
    'Status Connection:',
    style: TextStyle(
    color: Colors.white,
    fontSize: 14.0,
      fontWeight: FontWeight.bold,
    ),
    ),
      const SizedBox(height: 5),
      Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 17.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
    ),
    ),
    ),
        ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 40.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: resetWeight,
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(Colors.orangeAccent),
                      elevation: WidgetStateProperty.all<double>(5.0),
                      padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                        const EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
                      ),
                    ),
                    child: const Text(
                      'RESET',
                      style: TextStyle(color: Colors.white, fontSize: 20.0),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: tareWeight,
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(Colors.orangeAccent),
                      elevation: WidgetStateProperty.all<double>(5.0),
                      padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                        const EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
                      ),
                    ),
                    child: const Text(
                      'TARE',
                      style: TextStyle(color: Colors.white, fontSize: 20.0),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: showWeightDialog,
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(Colors.orangeAccent),
                      elevation: WidgetStateProperty.all<double>(5.0),
                      padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                        const EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
                      ),
                    ),
                    child: const Text(
                      'HASIL',
                      style: TextStyle(color: Colors.white, fontSize: 20.0),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }
}

class RadialPulsePainter extends CustomPainter {
  final Animation<double> animation;

  RadialPulsePainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final outerRadius = size.width / 2;
    final innerRadius = size.width / 4;
    final gradient = RadialGradient(
      colors: [
        Colors.white.withOpacity(0.0),
        Colors.white.withOpacity(0.5),
        Colors.white.withOpacity(0.0),
      ],
      stops: const [0.0, 0.7, 0.0],
      center: Alignment.center,
      radius: 1.5,
    );
    final rect = Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: outerRadius);
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = outerRadius - innerRadius
      ..strokeJoin = StrokeJoin.round;

    final progress = animation.value;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      outerRadius,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      innerRadius + (outerRadius - innerRadius) * progress,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

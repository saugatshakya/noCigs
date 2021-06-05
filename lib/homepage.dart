import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:no_cigs/components/fbutton.dart';
import 'package:no_cigs/components/particles.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation _animation;
  int icolor = 0;
  final List<Color> colors = [
    Color(0xffffc100),
    Color(0xffff9a00),
    Color(0xffff7400),
    Color(0xffff4d00),
    Color(0xffff0000)
  ];
  final List<Color> bgcolors = [
    Color(0xffff0000),
    Color(0xffff4d00),
    Color(0xffff7400),
    Color(0xffff9a00),
    Color(0xffffc100),
  ];
  final GlobalKey _boxkey = GlobalKey();
  dynamic counterText = {"count": 0, "color": Color(0xffffc100)};
  Rect boxSize = Rect.zero;
  List<Particle> particles = [];
  final double fps = 1 / 24;
  Timer timer;
  final double gravity = 9.81, dragCof = 0.47, airDensity = 1.1644;

  @override
  void dispose() {
    timer.cancel();
    _animationController.removeListener(_animationListener);
    _animationController.dispose();
    super.dispose();
  }

  boxCollision(Particle pt) {
    if (pt.position.x > boxSize.width - pt.radius) {
      pt.position.x = boxSize.width - pt.radius;
      pt.velocity.x *= pt.jumpFactor;
    }
    if (pt.position.x < pt.radius) {
      pt.position.x = pt.radius;
      pt.velocity.x *= pt.jumpFactor;
    }
    if (pt.position.y > boxSize.height - pt.radius) {
      pt.position.y = boxSize.height - pt.radius;
      pt.velocity.y *= pt.jumpFactor;
    }
  }

  updateCounter(int val) {
    if (particles.length > 200) {
      particles.removeRange(0, 75);
    }
    _animationController.forward();
    _animationController.addListener(_animationListener);
    icolor = Random().nextInt(colors.length);
    Color color = colors[icolor];
    String previousCount = "${counterText['count']}";
    Color prevColor = counterText['color'];
    counterText['count'] = counterText['count'] + val;
    counterText['color'] = color;
    //int count = Random().nextInt(25).clamp(7, 25);
    int count = counterText['count'];
    for (int x = 0; x < count; x++) {
      double randomX = Random().nextDouble() * 4.0;
      if (x % 2 == 0) {
        randomX = -randomX;
      }
      double randomY = Random().nextDouble() * -7.0;
      Particle p = Particle();
      p.position = PVector(boxSize.center.dx, boxSize.center.dy);
      p.velocity = PVector(randomX, randomY);
      p.radius = (Random().nextDouble() * 10).clamp(2.0, 10.0);
      p.color = prevColor;
      p.jumpFactor = Random().nextDouble() * -1;
      particles.add(p);
    }
    List<String> numbers = previousCount.split("");
    for (int x = 0; x < numbers.length; x++) {
      double randomX = Random().nextDouble();
      if (x % 2 == 0) {
        randomX = -randomX;
      }
      double randomY = Random().nextDouble() * -7.0;
      Particle p = Particle();
      p.type = ParticleType.TEXT;
      p.text = numbers[x];
      p.radius = 25;
      p.color = color;
      p.position = PVector(boxSize.center.dx, boxSize.center.dy);
      p.velocity = PVector(randomX * 4.0, randomY);
      particles.add(p);
    }
  }

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 100));
    _animation = Tween(begin: 1.0, end: 2.0).animate(_animationController);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Size size = _boxkey.currentContext.size;
      boxSize = Rect.fromLTRB(0, 0, size.width, size.height);
    });
    timer = Timer.periodic(
        Duration(milliseconds: (fps * 1000).floor()), frameBuilder);
    super.initState();
  }

  _animationListener() {
    if (_animationController.isCompleted) {
      _animationController.reverse();
    }
  }

  frameBuilder(dynamic timer) {
    particles.forEach((pt) {
      double dragForceX =
          0.5 * airDensity * pow(pt.velocity.x, 2) * dragCof * pt.area;
      double dragForceY =
          0.5 * airDensity * pow(pt.velocity.y, 2) * dragCof * pt.area;
      dragForceX = dragForceX.isInfinite ? 0.0 : dragForceX;
      dragForceY = dragForceY.isInfinite ? 0.0 : dragForceY;
      double accX = dragForceX / pt.mass;
      double accY = dragForceY / pt.mass + gravity;
      pt.velocity.x += accX * fps;
      pt.velocity.y += accY * fps;
      pt.position.x += pt.velocity.x * fps * 100;
      pt.position.y += pt.velocity.y * fps * 100;

      boxCollision(pt);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: counterText['color'],
        title: Text("Counter"),
      ),
      body: Container(
        color: Colors.black,
        key: _boxkey,
        child: Stack(children: [
          Center(
            child: Text(
              "${counterText['count']}",
              textScaleFactor: _animation.value * 2,
              style: TextStyle(color: counterText['color'], fontSize: 60),
            ),
          ),
          ...particles.map((pt) {
            if (pt.type == ParticleType.TEXT) {
              return Positioned(
                top: pt.position.y,
                left: pt.position.x,
                child: Container(
                  child: Text(
                    "${pt.text}",
                    style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: counterText['color']),
                  ),
                ),
              );
            } else {
              return Positioned(
                  top: pt.position.y,
                  left: pt.position.x,
                  child: Container(
                    width: pt.radius * 2,
                    height: pt.radius * 2,
                    decoration:
                        BoxDecoration(shape: BoxShape.circle, color: pt.color),
                  ));
            }
          }).toList(),
          Positioned(
              bottom: 20,
              right: 20,
              child: fbutton(
                function: () => updateCounter(1),
                icon: Icons.add,
                color: counterText['color'],
              )),
          Positioned(
              bottom: 20,
              left: 20,
              child: fbutton(
                function:
                    counterText['count'] == 0 ? () {} : () => updateCounter(-1),
                icon: Icons.remove,
                color: counterText['color'],
              ))
        ]),
      ),
    );
  }
}



import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

var FIRE_PALETTE = [
  Color.fromARGB(0xFF, 0x07, 0x07, 0x07),
  Color.fromARGB(0xFF, 0x1F, 0x07, 0x07),
  Color.fromARGB(0xFF, 0x2F, 0x0F, 0x07),
  Color.fromARGB(0xFF, 0x47, 0x0F, 0x07),
  Color.fromARGB(0xFF, 0x57, 0x17, 0x07),
  Color.fromARGB(0xFF, 0x67, 0x1F, 0x07),
  Color.fromARGB(0xFF, 0x77, 0x1F, 0x07),
  Color.fromARGB(0xFF, 0x8F, 0x27, 0x07),
  Color.fromARGB(0xFF, 0x9F, 0x2F, 0x07),
  Color.fromARGB(0xFF, 0xAF, 0x3F, 0x07),
  Color.fromARGB(0xFF, 0xBF, 0x47, 0x07),
  Color.fromARGB(0xFF, 0xC7, 0x47, 0x07),
  Color.fromARGB(0xFF, 0xDF, 0x4F, 0x07),
  Color.fromARGB(0xFF, 0xDF, 0x57, 0x07),
  Color.fromARGB(0xFF, 0xDF, 0x57, 0x07),
  Color.fromARGB(0xFF, 0xD7, 0x5F, 0x07),
  Color.fromARGB(0xFF, 0xD7, 0x5F, 0x07),
  Color.fromARGB(0xFF, 0xD7, 0x67, 0x0F),
  Color.fromARGB(0xFF, 0xCF, 0x6F, 0x0F),
  Color.fromARGB(0xFF, 0xCF, 0x77, 0x0F),
  Color.fromARGB(0xFF, 0xCF, 0x7F, 0x0F),
  Color.fromARGB(0xFF, 0xCF, 0x87, 0x17),
  Color.fromARGB(0xFF, 0xC7, 0x87, 0x17),
  Color.fromARGB(0xFF, 0xC7, 0x8F, 0x17),
  Color.fromARGB(0xFF, 0xC7, 0x97, 0x1F),
  Color.fromARGB(0xFF, 0xBF, 0x9F, 0x1F),
  Color.fromARGB(0xFF, 0xBF, 0x9F, 0x1F),
  Color.fromARGB(0xFF, 0xBF, 0xA7, 0x27),
  Color.fromARGB(0xFF, 0xBF, 0xA7, 0x27),
  Color.fromARGB(0xFF, 0xBF, 0xAF, 0x2F),
  Color.fromARGB(0xFF, 0xB7, 0xAF, 0x2F),
  Color.fromARGB(0xFF, 0xB7, 0xB7, 0x2F),
  Color.fromARGB(0xFF, 0xB7, 0xB7, 0x37),
  Color.fromARGB(0xFF, 0xCF, 0xCF, 0x6F),
  Color.fromARGB(0xFF, 0xDF, 0xDF, 0x9F),
  Color.fromARGB(0xFF, 0xEF, 0xEF, 0xC7),
  Color.fromARGB(0xFF, 0xFF, 0xFF, 0xFF),
];

const int COLUMNS = 150;
const int ROWS = 100;
const int FIRE_STATE_SIZE = COLUMNS * ROWS;

final _random = new Random();


class DoomFire extends StatefulWidget {
  @override
  _DoomFireState createState() => _DoomFireState();
}

class _DoomFireState extends State<DoomFire> {
  List<int> _fireState;
  Offset _tapPos;
  Timer _timer;

  @override
  void initState() {
    super.initState();

    createFireState();
    insertFireSource();

    // defines a timer
    _timer = Timer.periodic(Duration(milliseconds: 30), (Timer t) {
      setState(() {
        _fireState = getUpdatedFireState(_tapPos);
        _tapPos = null;
      });
    });
  }

  createFireState() {
    _fireState = List.filled(
        FIRE_STATE_SIZE,
        0
    );
  }

  List<int> getUpdatedFireState(Offset tapPos) {
    for (var row = 0; row < ROWS - 1; row++) {
      for (var col = 0; col < COLUMNS; col++) {
        var currentPixelIndex = col + COLUMNS * row;
        var belowPixelIndex = col + COLUMNS * (row + 1);

        var intensity = _fireState[belowPixelIndex];
        var decay = _random.nextInt(2);


        var d = 1;
        if (tapPos != null) {
          d = tapPos.direction > 1 ? 1 : -1;
        }
        var newIntensityC = intensity - decay + (tapPos != null ? (d*tapPos.dy/100).toInt() : 0);
        var newIntensity =  newIntensityC < 0 ? 0 : newIntensityC > 36 ? 36 : newIntensityC;

        if(currentPixelIndex - decay > 0 && currentPixelIndex < FIRE_STATE_SIZE) {
          _fireState[currentPixelIndex - decay] = newIntensity;
        } else {
          _fireState[currentPixelIndex] = newIntensity;
        }
      }
    }
    return _fireState;
  }

  insertFireSource() {
    for (var col = 0; col < COLUMNS; col++) {
      _fireState[col + COLUMNS * (ROWS - 1)] = FIRE_PALETTE.length - 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
          painter: DoomFirePainter(
            _fireState,
          ),
          child: GestureDetector(
              onPanUpdate: (details) {
                            RenderBox box = context.findRenderObject();
                            _tapPos = box.globalToLocal(details.globalPosition);
                        },
              child: Container(
                width: double.infinity,
                height: double.infinity,
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 0,
                    sigmaY: 0,
                  ),
                  child: Container(
                    color: Colors.black.withOpacity(0),
                  ),
                ),
              )
          )
    );
  }

}

class DoomFirePainter extends CustomPainter {
  List<int> fireData;

  DoomFirePainter(List<int> fireData) {
    this.fireData = fireData;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint p = Paint();
    var pixelSize = Size(
      size.width / COLUMNS,
      size.height / ROWS,
    );

    for (var row = 0; row < ROWS; row++) {
      for (var col = 0; col < COLUMNS; col++) {
        p.color = FIRE_PALETTE[this.fireData[col + COLUMNS * row]];
        canvas.drawRect(
            Rect.fromPoints(
              Offset(
                  col * pixelSize.width - 1,
                  row * pixelSize.height - 1,
              ),
              Offset(
                  (col + 1) * pixelSize.width + 1,
                  (row + 1) * pixelSize.height + 1,
              ),
            ),
            p
        );
//        canvas.drawCircle(
//            Offset(
//              col * pixelSize.width + pixelSize.width / 2,
//              row * pixelSize.height + pixelSize.height / 2,
//            ),
//            pixelSize.width,
//            p
//        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

}

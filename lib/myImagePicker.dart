import 'dart:io';

import 'package:matakuw/Result.dart';
import 'package:matakuw/myResultsPage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class MyImagePicker extends StatefulWidget {
  static final style = TextStyle(
    fontSize: 20,
    fontFamily: "Poppins",
    fontWeight: FontWeight.w400,
  );

  @override
  _MyImagePickerState createState() => _MyImagePickerState();
}

class _MyImagePickerState extends State<MyImagePicker> {
  File imageURI;
  String result;
  String path;
  var confidence;
  var label;
  var message;
  bool isResult = false;

  var percentageConfidence;

  Future getImageFromCamera() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(
      () {
        imageURI = image;
        path = image.path;
      },
    );
  }

  Future getImageFromGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(
      () {
        imageURI = image;
        path = image.path;
      },
    );
  }

  Future classifyImage() async {
    await Tflite.loadModel(
        model: "assets/model_unquant.tflite", labels: "assets/labels.txt");
    var output = await Tflite.runModelOnImage(path: path);
    var data = getResult(output);

    setState(
      () {
        result = data.toString();
        print(result);
        confidence = (data[0].confidence * 100).round().toString();
        label = data[0].label.toString();
      },
    );

    setState(() {
      result = data.toString();
      print(result);
      confidence = (data[0].confidence * 100).toStringAsFixed(2);
      label = data[0].label.toString();
      double confidenceInt = double.parse(confidence);
      if (confidenceInt > 70 && label == 'cataracts') {
        message = "Kamu perlu segera menemui Dokter Spesialis Mata!";
      } else if (confidenceInt <= 70 &&
          confidenceInt > 50 &&
          label == 'cataracts') {
        message = "Kamu harus mulai mencari perhatian medis!";
      } else {
        message = "Kamu relatif baik!";
      }
    });
    isResult = true;
  }

  List<Result> getResult(List<dynamic> output) {
    List<Result> data = List();

    output.forEach((element) {
      Result item = Result(
          confidence: element['confidence'],
          label: element['label'],
          message: element['message'],
          index: element['index']);
      data.add(item);
    });
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Matakuw"),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            imageURI == null
                ? Text('Tak ada gambar dipilih')
                : Image.file(imageURI,
                    width: 300, height: 200, fit: BoxFit.cover),
            Container(
              margin: EdgeInsets.fromLTRB(0, 30, 0, 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0)),
                ),
                onPressed: () => getImageFromCamera(),
                child: Text(
                  "Ambil gambar dari kamera",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0)),
                ),
                onPressed: () => getImageFromGallery(),
                child: Text('Pilih gambar dari Galeri',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 30, 0, 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0)),
                ),
                child: Text(
                  'Jalankan Pendeteksi',
                  style: TextStyle(color: Colors.white),
                  // selectionColor: Colors.white,
                ),
                onPressed: () async {
                  classifyImage();
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return MyResultsPage(
                          confidence: confidence,
                          label: label,
                          message: message,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            isResult
                ? Container(
                    margin: EdgeInsets.fromLTRB(0, 30, 0, 20),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                      ),
                      child: Text(
                        'Memproses',
                        style: TextStyle(color: Colors.white),
                        // selectionColor: Colors.white,
                      ),
                      onPressed: () async {
                        classifyImage();
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) {
                            return MyResultsPage(
                              confidence: confidence,
                              label: label,
                              message: message,
                            );
                          }),
                        );
                      },
                    ),
                  )
                : Text(
                    "Untuk Memproses Pendeteksian Silakan Klik",
                    style: GoogleFonts.raleway(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.deepPurpleAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),
            // confidence == null ? Text('Confidence') : Text(confidence + " %"),
            // label == null ? Text('Label') : Text(label),
            // message == null ? Text('Message') : Text(message)
          ],
        ),
      ),
    );
  }
}

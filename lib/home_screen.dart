import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool istap = false;
  bool isBodytap = false;
  bool isButtonActive = false;
  bool submit = false;
  bool _isLoading = true;

  late Uint8List _imageData = Uint8List(0);
  late TextEditingController descp = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    descp.addListener(() {
      isButtonActive = !descp.text.isEmpty;

      setState(() {
        this.isButtonActive = isButtonActive;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    descp.dispose();
  }

  void _convertTextToImage() async {
    setState(() {
      _isLoading = true;
      submit = true;
      isBodytap = true;
    });

    const baseUrl = 'https://api.stability.ai';
    final url = Uri.parse(
        '$baseUrl/v1alpha/generation/stable-diffusion-512-v2-0/text-to-image');

    // Make the HTTP POST request to the Stability Platform API
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer sk-DEho0A6lmon3sJZ7UJMmULNL1Ndfz7RZUzGLZCPtgWC5brjS',
        'Accept': 'image/png',
      },
      body: jsonEncode({
        'cfg_scale': 7,
        'clip_guidance_preset': 'FAST_BLUE',
        'height': 512,
        'width': 512,
        'samples': 1,
        'steps': 50,
        'text_prompts': [
          {
            'text': descp.text,
            'weight': 1,
          }
        ],
      }),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode != 200) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(
                'failed to generate image',
                textAlign: TextAlign.center,
              ),
            );
          });
    } else {
      try {
        _imageData = (response.bodyBytes);
        setState(() {});
      } on Exception catch (e) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                  'failed to generate image',
                  textAlign: TextAlign.center,
                ),
              );
            });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: istap ? 200 : 80,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey, width: 1)),
              child: TextField(
                onTap: () {
                  setState(() {
                    istap = true;
                    isBodytap = false;
                    print(istap);
                  });
                },
                controller: descp,
                readOnly: isBodytap ? true : false,
                maxLines: istap ? 5 : 1,
                autocorrect: true,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'describe your thoughts here...'),
              ),
            ),

            //generate button
            !istap
                ? Container()
                : ElevatedButton(
                    onPressed: isButtonActive ? _convertTextToImage : null,
                    child: Text('generate image'),
                  )
          ],
        ),
      ),
      body: SafeArea(
          child: InkWell(
        onTap: () {
          setState(() {
            istap = false;
            isBodytap = true;
            print(istap);
          });
        },
        highlightColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        child: Center(
          child: submit
              ? Container(
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : Image.memory(_imageData),
                )
              : Text('hello'),
        ),
      )),
    );
  }
}

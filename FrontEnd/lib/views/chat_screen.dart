import 'package:app/custom_widget/message_tile.dart';
import 'package:app/custom_widget/text_input.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:app/views/min_height_view.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:app/api/api.dart';
import 'dart:io';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  var controller = TextEditingController();
  List<List> messages = [];
  final List<dynamic> list = [];
  bool dragging = false;
  bool progress = false;
  var loadedPdf = '';
  bool answered = true;

  void addAnswer(text) async {
    await answer(text).then(
      (value) {
        setState(() {
          messages.insert(0, ['Questify', value]);
          answered = true;
        });
      },
    );
  }

  void handleSubmitted(String text) {
    if (answered) {
      text = text.trim();
      if (text == '') {
        return;
      }
      controller.clear();
      setState(() {
        messages.insert(0, ['You', text]);
        if (loadedPdf == '') {
          messages.insert(0, ['Questify', 'please select a pdf']);
        } else {
          answered = false;
          addAnswer(text);
        }
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxHeight > 116) {
              return Row(
                children: [
                  Container(
                    foregroundDecoration: const BoxDecoration(
                        border:
                            Border(right: BorderSide(color: Colors.white10))),
                    color: const Color.fromARGB(255, 17, 17, 17),
                    width: 240,
                    child: Column(
                      children: [
                        Container(
                          foregroundDecoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(color: Colors.white10))),
                          alignment: Alignment.centerLeft,
                          color: const Color.fromARGB(5, 255, 255, 255),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Pdf Files',
                                style: TextStyle(
                                    color: Color.fromARGB(228, 255, 255, 255),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  FilePickerResult? result =
                                      await FilePicker.platform.pickFiles();

                                  if (result != null) {
                                    PlatformFile file = result.files.first;
                                    for (var efile in list) {
                                      if (efile.path == file.path) {
                                        file = PlatformFile(name: '', size: 0);
                                      }
                                    }
                                    if (file.name
                                            .split('.')
                                            .last
                                            .toLowerCase()
                                            .trim() ==
                                        'pdf') {
                                      setState(() {
                                        list.add(file);
                                      });
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    elevation: 0),
                                child: const Icon(
                                  Icons.note_add_rounded,
                                  color: Colors.white60,
                                  size: 19,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: DropTarget(
                            onDragDone: (detail) {
                              for (var file in detail.files) {
                                var entity =
                                    FileSystemEntity.typeSync(file.path);
                                for (var efile in list) {
                                  if (efile.path == file.path) {
                                    entity = FileSystemEntityType.directory;
                                  }
                                }
                                if (entity == FileSystemEntityType.directory ||
                                    (file.name
                                            .split('.')
                                            .last
                                            .toLowerCase()
                                            .trim() !=
                                        'pdf')) {
                                  detail.files.remove(file);
                                }
                              }
                              setState(() {
                                list.addAll(detail.files);
                              });
                            },
                            onDragEntered: (detail) {
                              setState(() {
                                dragging = true;
                              });
                            },
                            onDragExited: (detail) {
                              setState(() {
                                dragging = false;
                              });
                            },
                            child: Container(
                                width: 240,
                                color: dragging
                                    ? const Color.fromARGB(5, 255, 255, 255)
                                    : Colors.black26,
                                child: list.isEmpty
                                    ? const Center(
                                        child: Text(
                                        "Drop here",
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                16, 255, 255, 255),
                                            fontSize: 24),
                                      ))
                                    : ListView.builder(
                                        itemCount: list.length,
                                        itemBuilder: (context, index) {
                                          return ElevatedButton(
                                            onPressed: () async {
                                              var alert = '';
                                              if (loadedPdf !=
                                                  list[index].name) {
                                                setState(() {
                                                  loadedPdf = '';
                                                  progress = true;
                                                });
                                                await processPdf(
                                                        list[index].path)
                                                    .then((value) {
                                                  if (value == 'error1') {
                                                    alert =
                                                        'The remote computer refused the network connection.';
                                                  } else if (value ==
                                                      'error2') {
                                                    alert =
                                                        'Unable to load pdf.';
                                                  } else if (RegExp(r"^error3")
                                                      .hasMatch(value)) {
                                                    alert = value.split()[1];
                                                  }
                                                  alert != ''
                                                      ? showDialog(
                                                          context: context,
                                                          builder: (ctx) =>
                                                              AlertDialog(
                                                            backgroundColor:
                                                                Colors.white10,
                                                            content: Text(
                                                              alert,
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ),
                                                        )
                                                      : const Placeholder();
                                                }).whenComplete(() {
                                                  setState(() {
                                                    progress = false;
                                                    if (alert == '') {
                                                      loadedPdf =
                                                          list[index].name;
                                                    }
                                                  });
                                                });
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                                shape:
                                                    const ContinuousRectangleBorder(),
                                                fixedSize: const Size(240, 4),
                                                backgroundColor: loadedPdf !=
                                                        list[index].name
                                                    ? const Color.fromARGB(
                                                        5, 255, 255, 255)
                                                    : const Color.fromARGB(
                                                        133, 255, 255, 255)),
                                            child: Tooltip( showDuration: Duration(milliseconds: 10),
                                              message: list[index].path,
                                              child: Container(
                                                width: 240,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  list[index].name,
                                                  style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      wordSpacing: 2,
                                                      color: Color.fromARGB(
                                                          221, 255, 255, 255)),
                                                  textAlign: TextAlign.left,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      )),
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                              border: BorderDirectional(
                                  top: BorderSide(
                                      width: .1, color: Colors.white))),
                          height: height < 150 ? height * 0.4 : 90,
                          child: Column(
                            children: [
                              Expanded(
                                child: ListView(
                                  children: [
                                    progress
                                        ? const SizedBox(
                                            width: 220,
                                            child: LinearProgressIndicator(
                                              backgroundColor: Colors.black,
                                              color: Color(0xFF10a37f),
                                            ),
                                          )
                                        : const SizedBox(),
                                    Container(
                                      decoration: const BoxDecoration(
                                          border: BorderDirectional(
                                              bottom: BorderSide(
                                                  width: .1,
                                                  color: Colors.white))),
                                      padding: const EdgeInsets.only(
                                          left: 10, top: 6, bottom: 6),
                                      child: Text(
                                        'PDF: $loadedPdf',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    Container(
                                      height: 45,
                                      width: 240,
                                      margin: const EdgeInsets.only(
                                          left: 8, right: 8, top: 8),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          fixedSize: const Size(240, 45),
                                          backgroundColor:
                                              const Color(0xFF10a37f),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            messages.clear();
                                          });
                                        },
                                        child: const Text('New chat'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: const Color(0xFF131515),
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            height: 40,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 25, vertical: 8),
                            child: const Row(
                              children: [
                                Text(
                                  'Questify',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Noto',
                                      fontSize: 21),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    ' - pdf based question answering.',
                                    softWrap: true,
                                    overflow: TextOverflow.fade,
                                    maxLines: 1,
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(31, 255, 255, 255),
                                        fontWeight: FontWeight.w100,
                                        fontFamily: 'Noto',
                                        fontSize: 21),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Container(
                              width: width / 1.6,
                              padding: const EdgeInsets.only(bottom: 30),
                              child: messages.isEmpty
                                  ? Center(
                                      child: loadedPdf == ''
                                          ? const Text(
                                              'Select a pdf to begin.',
                                              style: TextStyle(
                                                  fontSize: 35,
                                                  color: Color.fromARGB(
                                                      46, 255, 255, 255)),
                                            )
                                          : const Text(
                                              'Type your question to begin.',
                                              style: TextStyle(
                                                  fontSize: 35,
                                                  color: Color.fromARGB(
                                                      46, 255, 255, 255)),
                                            ))
                                  : ListView.builder(
                                      scrollDirection: Axis.vertical,
                                      reverse: true,
                                      itemCount: messages.length,
                                      itemBuilder: (context, index) {
                                        return ListTile(
                                            title: MessageTile(
                                                message: messages[index][1],
                                                messenger: messages[index][0]));
                                      }),
                            ),
                          ),
                          answered
                              ? const SizedBox()
                              : Container(
                                  height: 50,
                                  width: width / 1.65,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 9),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(colors: [
                                      Colors.transparent,
                                      Color.fromARGB(55, 16, 163, 126),
                                      Colors.transparent
                                    ]),
                                  ),
                                  child: const LinearProgressIndicator(
                                    backgroundColor: Colors.transparent,
                                    minHeight: 50,
                                    color: Color.fromARGB(106, 19, 21, 21),
                                  )),
                          textInput(controller, width, height, handleSubmitted,
                              answered),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return minHeightView(height, width);
            }
          },
        ),
      ),
    );
  }
}

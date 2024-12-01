import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fc_file_picker_util/fc_file_picker_util.dart';
import 'package:saf_stream/saf_stream.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
  final _safStream = SafStream();

  String _output = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_output),
            const SizedBox(height: 10),
            OutlinedButton(
                onPressed: () async {
                  final res = await FcFilePickerUtil.pickFile();
                  if (res == null) {
                    setState(() {
                      _output = 'Cancelled';
                    });
                  } else {
                    _readFiles([res]);
                  }
                },
                child: const Text('Pick File')),
            const SizedBox(height: 10),
            OutlinedButton(
                onPressed: () async {
                  final res = await FcFilePickerUtil.pickMultipleFiles();
                  if (res == null) {
                    setState(() {
                      _output = 'Cancelled';
                    });
                  } else {
                    _readFiles(res);
                  }
                },
                child: const Text('Pick Files')),
            const SizedBox(height: 10),
            OutlinedButton(
                onPressed: () async {
                  try {
                    final res = await FcFilePickerUtil.pickFolder(
                        writePermission: false);
                    setState(() {
                      _output = res?.toString() ?? 'Cancelled';
                    });
                  } catch (err) {
                    setState(() {
                      _output = err.toString();
                    });
                  }
                },
                child: const Text('Pick Folder')),
            const SizedBox(height: 10),
            OutlinedButton(
                onPressed: () async {
                  try {
                    final res = await FcFilePickerUtil.pickSaveFile();
                    setState(() {
                      _output = res?.toString() ?? 'Cancelled';
                    });
                  } catch (err) {
                    setState(() {
                      _output = err.toString();
                    });
                  }
                },
                child: const Text('Pick Save File')),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<void> _readFiles(List<FcFilePickerPath> files) async {
    try {
      String s = '';
      for (final file in files) {
        // Add file path to output.
        s += 'File: $file\n';

        if (Platform.isIOS) {
          await file.accessAppleScopedResource((hasAccess, file) async {
            if (!hasAccess) {
              return;
            }
            final bytes = await File(file.path!).readAsBytes();

            // Handle file content.
            s += 'Bytes: ${_formatBytes(bytes)}\n\n';
          });
        } else if (file.uri != null && Platform.isAndroid) {
          final bytes = await _safStream.readFileBytes(file.uri!);

          // Handle file content.
          s += 'Bytes: ${_formatBytes(bytes)}\n\n';
        } else if (file.path != null) {
          final bytes = await File(file.path!).readAsBytes();

          // Handle file content.
          s += 'Bytes: ${_formatBytes(bytes)}\n\n';
        }
      }

      setState(() {
        _output = s;
      });
    } catch (err) {
      setState(() {
        _output = 'Error: $err';
      });
    }
  }

  String _formatBytes(Uint8List bytes) {
    return '${bytes.length} bytes';
  }
}

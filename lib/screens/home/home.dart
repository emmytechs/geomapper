import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:geo_mapper/models/map_files_model.dart';
import 'package:geo_mapper/screens/map_analyze/map_analyze.dart';
import 'dart:io';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? _shpPath;
  String? _dbfPath;
  bool _dragging = false;

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['shp', 'dbf'],
    );
    if (result != null && result.files.length == 2) {
      String? shp, dbf;
      for (var file in result.files) {
        if (file.extension == 'shp') shp = file.path;
        if (file.extension == 'dbf') dbf = file.path;
      }
      if (shp != null && dbf != null) {
        setState(() {
          _shpPath = shp;
          _dbfPath = dbf;
        });
      } else {
        if (!mounted) return;
        // Show error if both files are not selected
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select both .shp and .dbf files.')),
        );
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select both .shp and .dbf files.')),
      );
    }
  }

  void _handleDrop(List<Uri> uris) {
    if (uris.length == 2) {
      String? shp, dbf;
      for (var uri in uris) {
        if (uri.path.toLowerCase().endsWith('.shp')) shp = uri.toFilePath();
        if (uri.path.toLowerCase().endsWith('.dbf')) dbf = uri.toFilePath();
      }
      if (shp != null && dbf != null) {
        setState(() {
          _shpPath = shp;
          _dbfPath = dbf;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please drop both .shp and .dbf files.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please drop both .shp and .dbf files.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff161616),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 60,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(color: Color(0xffa9a9a9)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.map, color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Text("GeoMapper", style: TextStyle(color: Colors.white)),
                  ],
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xFF42a552),
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    minimumSize: Size(0, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Text("Upload", style: TextStyle(color: Colors.white)),
                ),
                SizedBox(width: 13),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xFFffffff),
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    minimumSize: Size(0, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Text(
                    "Visualize",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                SizedBox(width: 13),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xFFffffff),
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    minimumSize: Size(0, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Text(
                    "Analyze & Export",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: Container(
              height: 450,
              width: 700,
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              margin: EdgeInsets.only(top: 100),
              decoration: BoxDecoration(color: Color(0xffa9a9a9)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Upload Map Files or Input Coordinates",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Upload your geographic map files by dragging them into the area below or by using the file browser.",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  Text(
                    "You must select both a .shp and a .dbf file.",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  SizedBox(height: 50),
                  // Drag and drop area
                  DropTarget(
                    onDragEntered: (details) {
                      setState(() => _dragging = true);
                    },
                    onDragExited: (details) {
                      setState(() => _dragging = false);
                    },
                    onDragDone: (details) {
                      setState(() => _dragging = false);
                      _handleDrop(
                        details.files.map((e) => Uri.file(e.path)).toList(),
                      );
                    },
                    child: GestureDetector(
                      onTap: _pickFiles,
                      child: DottedBorder(
                        color: _dragging ? Colors.green : Color(0xff353535),
                        strokeWidth: 2,
                        dashPattern: [8, 4],
                        borderType: BorderType.RRect,
                        radius: Radius.circular(0),
                        child: Container(
                          width: double.infinity,
                          height: 220,
                          alignment: Alignment.center,
                          color:
                              _dragging ? Colors.lightGreen : Color(0xff161616),
                          child:
                              (_shpPath == null || _dbfPath == null)
                                  ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.insert_drive_file,
                                        color: Colors.white,
                                        size: 36,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        "Drag & drop your .shp and .dbf files here\nor click to select files",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  )
                                  : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.insert_drive_file,
                                        color: Colors.white,
                                        size: 36,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        "Files selected:",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        _shpPath!
                                            .split(Platform.pathSeparator)
                                            .last,
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        _dbfPath!
                                            .split(Platform.pathSeparator)
                                            .last,
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 25),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: _pickFiles,
                        icon: Icon(Icons.insert_drive_file),
                        label: Text(
                          "Browse for files",
                          style: TextStyle(fontWeight: FontWeight.normal),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF42a552),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          if (_shpPath == null ||
                              _dbfPath == null ||
                              _shpPath!.isEmpty ||
                              _dbfPath!.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Please select valid .shp and .dbf files first.',
                                ),
                              ),
                            );
                          } else {
                            // navigate to map analyzing screen
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (context) => MapAnalyze(
                                      model: MapFilesModel(
                                        shpPath: _shpPath,
                                        dbfPath: _dbfPath,
                                      ),
                                    ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF42a552),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                        ),
                        child: const Text(
                          "Submit",
                          style: TextStyle(fontWeight: FontWeight.normal),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

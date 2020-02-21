import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddPage extends StatefulWidget {
  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  String title;
  String description;

  File _image;
  Widget _imageWidget = Container();
  Widget _loading = Container();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add item"),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView(
        padding: EdgeInsets.all(10),
        children: <Widget>[
          SizedBox(
            height: 30.0,
          ),
          _buildTitleField(),
          SizedBox(
            height: 20,
          ),
          _buildDescriptionField(),
          SizedBox(
            height: 20,
          ),
          _buildImgSelectButton(),

          ///
          ///
          SizedBox(
            height: 20,
          ),
          _imageWidget,

          ///
          ///
          SizedBox(
            height: 20,
          ),
          _buildSaveButton(context),

          ///
          ///
          _loading

          ///
        ],
      ),
    );
  }

  TextField _buildTitleField() {
    return TextField(
      controller: _titleController,
      onChanged: (value) {
        setState(() {
          title = value;
        });
      },
      decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: "title",
          prefixIcon: Icon(Icons.title)),
    );
  }

  TextField _buildDescriptionField() {
    return TextField(
      controller: _descriptionController,
      onChanged: (value) {
        setState(() {
          description = value;
        });
      },
      maxLines: 4,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        hintText: "Description",
      ),
    );
  }

  SizedBox _buildImgSelectButton() {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: RaisedButton.icon(
        icon: Icon(Icons.camera),
        label: Text("Add Image"),
        color: Colors.blue,
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) => SimpleDialog(
                  backgroundColor: Colors.white,
                  title: Center(
                    child: Text(
                      'Select image source',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        //source-gallery
                        IconButton(
                          icon: Icon(
                            Icons.image,
                            size: 30,
                            color: Colors.blue,
                          ),
                          onPressed: () async {
                            _image = await ImagePicker.pickImage(
                                source: ImageSource.gallery);
                            if (_image != null) showImage();
                          },
                        ),
                        //source-camera
                        IconButton(
                          icon: Icon(
                            Icons.camera_alt,
                            size: 30,
                            color: Colors.blue,
                          ),
                          onPressed: () async {
                            _image = await ImagePicker.pickImage(
                                source: ImageSource.camera);
                            if (_image != null) showImage();
                          },
                        )
                      ],
                    )
                  ],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  )));
        },
      ),
    );
  }

  SizedBox _buildSaveButton(BuildContext context) {
    return SizedBox(
      height: 50,
      width: 20.0,
      child: RaisedButton.icon(
        icon: Icon(Icons.save),
        label: Text("Save"),
        color: Colors.blue,
        onPressed: () async {
          if (_image != null) {
            setState(() {
              _loading = LinearProgressIndicator();
            });
            saveImage(_image);
          }
        },
      ),
    );
  }

  //show image preview
  showImage() {
    Navigator.pop(context);
    setState(() {
      _imageWidget = SizedBox(
        child: Image.file(
          _image,
          height: 100,
        ),
      );
    });
  }

  //save image to firebase storage
  Future saveImage(File file) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference _ref = storage.ref().child(DateTime.now().toString());
    StorageUploadTask _task = _ref.putFile(file);
    StorageTaskSnapshot _snap = await _task.onComplete;
    String imageUrl = await _snap.ref.getDownloadURL();

    Firestore.instance
        .collection('Items')
        .document(DateTime.now().toString())
        .setData({
      "title": title,
      "description": description,
      "image_url": imageUrl
    });
    setState(() {
      _imageWidget = _loading = Container();
      _titleController.clear();
      _descriptionController.clear();
    });
    _image = null;
  }
}

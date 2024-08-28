import 'package:book/core/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../book/book.dart';

class FirebaseDbManager{
  static FirebaseDbManager? _instance;

  late FirebaseFirestore db;
  late FirebaseStorage storage;
  late Reference storageRef;

  FirebaseDbManager._internal(){
    db = FirebaseFirestore.instance;
    storage = FirebaseStorage.instance;
    storageRef = storage.ref();
  }
  factory FirebaseDbManager() {
    if (_instance == null) {
      _instance = FirebaseDbManager._internal();
    }
    return _instance!;
  }

  static FirebaseDbManager get instance => FirebaseDbManager();

  Future<void> uploadBookImageAndGetUrl(Book book) async{

    final folderRef= storageRef.child(book.title);

    final fileRef = folderRef.child(DateTime.now().toString());

    await fileRef.putFile(book.image!).timeout(Duration(seconds: 3),
        onTimeout: () {
          throw Exception(serverError);
        });
    final url = await fileRef.getDownloadURL().timeout(Duration(seconds: 3),
        onTimeout: () {
          throw Exception(serverError);
        });
    book.imageUrl = url;
  }

  Future<void> uploadBook()async{

  }

}
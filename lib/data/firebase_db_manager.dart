import 'package:book/book/book.dart';
import 'package:book/book/book_chapter/book_chapter.dart';
import 'package:book/book/book_data.dart';
import 'package:book/book/book_page/book_page.dart';
import 'package:book/core/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseDbManager {
  static FirebaseDbManager? _instance;
  late FirebaseFirestore db;
  late FirebaseStorage storage;
  late Reference storageRef;

  FirebaseDbManager._internal() {
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

  Future<void> uploadBookImageAndGetUrl(Book book) async {
    final folderRef = storageRef.child(book.title);

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

  Future<void> uploadBook(Book book) async {
    final bookRef = db.collection('books').doc();
    await bookRef.set(book.toJson()).timeout(Duration(seconds: 3),
        onTimeout: () {
      throw Exception(serverError);
    });
  }

  Future<void> uploadPageImageGetUrl(BookPage page) async {
    final folderRef = storageRef.child('book');

    final fileRef = folderRef.child('${page.pageNumber}/' +
            DateTime.now().toString() +
            page.pageImage!.getFileName() ??
        '');

    await fileRef.putFile(page.pageImage!.image!).timeout(Duration(seconds: 3),
        onTimeout: () {
      throw Exception(serverError);
    });

    final url = await fileRef.getDownloadURL().timeout(Duration(seconds: 3),
        onTimeout: () {
      throw Exception(serverError);
    });

    page.pageImage!.imageUrl = url;
  }

  Future<List<Book>> downloadBooks() async {
    final querySnapshots = await db
        .collection('books')
        .get()
        .timeout(Duration(seconds: 3), onTimeout: () {
      throw Exception(serverError);
    });
    ;
    final List<Book> books = [];
    for (final item in querySnapshots.docs) {
      books.add(Book.fromJson(item.data(), item.id));
    }

    return Future.value(books);
  }

  Future<void> uploadPages(List<BookPage> pages, String bookId) async {
    final booksRef = db.collection("pages").doc(bookId);
    await booksRef
        .set({'items': pages.map((page) => page.toJson()).toList()}).timeout(
            Duration(seconds: 3), onTimeout: () {
      throw Exception(serverError);
    });
  }

  Future<void> uploadChapters(List<BookChapter> chapters, String bookId) async {
    final chaptersRef = db.collection("chapters").doc(bookId);
    await chaptersRef.set({
      'items': chapters.map((chapter) => chapter.toJson()).toList()
    }).timeout(Duration(seconds: 3), onTimeout: () {
      throw Exception(serverError);
    });
  }

  Future<BookData> downloadFromServer(String bookId) async {
    List<BookPage> bookPages = [];
    List<BookChapter> bookChapters = [];

    final booksRef = db.collection("pages").doc(bookId);

    final snapShoot =
        await booksRef.get().timeout(Duration(seconds: 3), onTimeout: () {
      throw Exception(serverError);
    });
    final data = snapShoot.data();
    final List<dynamic> items = data?['items'] ?? [];
    for (final item in items) {
      bookPages.add(BookPage.fromJson(item));
    }

    final chaptersRef = db.collection('chapters').doc(bookId);
    final snapShootChapters =
        await chaptersRef.get().timeout(Duration(seconds: 3), onTimeout: () {
      throw Exception(serverError);
    });
    final dataChapters = snapShootChapters.data();
    final List<dynamic> chaptersItems = dataChapters?['items'] ?? [];
    for (final chapterItem in chaptersItems) {
      bookChapters.add(BookChapter.fromJson(chapterItem));
    }
    BookData bookData =
        BookData(bookPages: bookPages, bookChapters: bookChapters);

    return Future.value(bookData);
  }
}

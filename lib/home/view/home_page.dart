import 'dart:convert';

import 'package:book/app_colors.dart';
import 'package:book/app_routes.dart';
import 'package:book/app_text_styles.dart';
import 'package:book/app_user.dart';
import 'package:book/app_user_singleton.dart';
import 'package:book/book/book.dart';
import 'package:book/core/constants.dart';
import 'package:book/data/firebase_db_manager.dart';
import 'package:book/data/firebase_message_manager.dart';
import 'package:book/home/bloc/home_bloc.dart';
import 'package:book/home/bloc/home_event.dart';
import 'package:book/home/bloc/home_state.dart';
import 'package:book/utils/dialog_utils.dart';
import 'package:book/utils/snackbar_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageSate();
}

class _HomePageSate extends State<HomePage> {
  late final _controller;
  List<Book> books = [];
  late AppUser user;

  @override
  void initState() {
    FirebaseMessageManager.instance.firebaseMessaging.subscribeToTopic(topic);
    FirebaseMessageManager.instance.initializeLocalNotification();
    FirebaseMessageManager.instance.onNotificationClick.stream
        .listen(onNotificationListener);

    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        if (message.notification != null) {
          FirebaseMessageManager.instance.showLocalNotification(message);
        }
      },
    );
    _controller = PageController(viewportFraction: 0.9);
    user = AppUserSingleton.instance.appUser!;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) async {
        if (state is SuccessfulSignOut) {
          Navigator.pushReplacementNamed(context, loginRoute);
        } else if (state is ErrorState) {
          SnackBarUtils.showSnackBar(
              color: AppColors.errorSnackBar,
              content: AppLocalizations.of(context)!.serverError,
              context: context);
        } else if (state is UploadedBookState) {
          books.add(state.book);
        } else if (state is LoadingState) {
          DialogUtils.showLoadingScreen(context);
        } else if (state is LoadedState) {
          Navigator.pop(context);
        } else if (state is GetBooksState) {
          books = state.books;
        }
      },
      builder: (context, HomeState state) {
        return WillPopScope(
          onWillPop: _onBackPressed,
          child: StreamBuilder(
              stream: context.read<HomeBloc>().getBooksStream(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (snapshot.hasData) {
                  context
                      .read<HomeBloc>()
                      .add(GetBooksEvent(querySnapshot: snapshot.data!));
                  return Scaffold(
                    appBar: AppBar(
                      automaticallyImplyLeading: false,
                      actions: [
                        IconButton(
                          onPressed: () {
                            Navigator.maybePop(context);
                          },
                          icon: Icon(Icons.exit_to_app),
                        ),
                      ],
                      title: Text(
                        AppLocalizations.of(context)!.pickBook,
                      ),
                      centerTitle: true,
                    ),
                    body: _buildBody(context),
                    floatingActionButton: Visibility(
                      visible: user.isAdmin == true,
                      child: FloatingActionButton(
                        backgroundColor: AppColors.primaryColor,
                        onPressed: () async {
                          final Book? result =
                              await Navigator.pushNamed<dynamic>(
                            context,
                            addNewBookRoute,
                          );
                          if (result != null) {
                            context.read<HomeBloc>().add(UploadBook(
                                  book: result,
                                  messageTitle: AppLocalizations.of(context)!
                                      .newBookMessageTitle(result.title),
                                  messageBody: AppLocalizations.of(context)!
                                      .newBookMessageBody(result.author),
                                ));
                          }
                        },
                        child: Icon(Icons.add),
                      ),
                    ),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 30),
        SizedBox(
          height: 500,
          child: PageView.builder(
            pageSnapping: true,
            controller: _controller,
            itemCount: books.length,
            itemBuilder: (context, index) => _buildBookItem(
              books.elementAt(index),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookItem(Book book) {
    return Card(
      clipBehavior: Clip.hardEdge,
      margin: EdgeInsets.only(right: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed<dynamic>(context, bookPageRoute,
              arguments: <String, dynamic>{"book": book});
        },
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                image: DecorationImage(
                  image: NetworkImage(book.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.1)
                      ],
                      begin: FractionalOffset.topLeft,
                      end: FractionalOffset.bottomRight),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.all(24),
                      child: Text(
                        book.title,
                        maxLines: titleMaxLines,
                        style: AppTextStyles.title(),
                      ),
                    ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Padding(
                            padding: EdgeInsets.only(
                                right: pageMargin, left: pageMargin),
                            child: Text(
                              AppLocalizations.of(context)!
                                  .authorWithName(book.author),
                              overflow: TextOverflow.ellipsis,
                              maxLines: authorMaxLines,
                              style: AppTextStyles.text1(),
                            ),
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
      ),
    );
  }

  Future<bool> _onBackPressed() async {
    final result = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.singOutDialog),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: Text(AppLocalizations.of(context)!.yes),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: Text(AppLocalizations.of(context)!.no),
          ),
        ],
      ),
    );
    if (result == true) {
      context.read<HomeBloc>().add(SignOut());
    }
    return result;
  }

  void onNotificationListener(String? payload) async {
    if (payload != null) {
      final data = jsonDecode(payload);
      if (data['action'] == messagePageAction) {
        final iD = data['bookId'];

        Book book = await FirebaseDbManager.instance.downloadBook(iD);
        final pageIndex = data['index'];
        if (data['index'] != null) {
          final currentPageIndex = int.parse(pageIndex);
          Navigator.pushNamedAndRemoveUntil(
              context,
              bookPageRoute,
              arguments: <String, dynamic>{
                "book": book,
                "pageIndex": currentPageIndex,
              },
              (route) => route.isFirst);
        } else {
          Navigator.pushNamedAndRemoveUntil(
              context,
              bookPageRoute,
              arguments: <String, dynamic>{
                "book": book,
              },
              (route) => route.isFirst);
        }
      } else if (data['action'] == messageBookAction) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    FirebaseMessageManager.instance.firebaseMessaging
        .unsubscribeFromTopic(topic);
    _controller.dispose();
  }
}

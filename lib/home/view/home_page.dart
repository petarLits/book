import 'package:book/app_colors.dart';
import 'package:book/app_routes.dart';
import 'package:book/app_text_styles.dart';
import 'package:book/app_user_singleton.dart';
import 'package:book/book/book.dart';
import 'package:book/data/firebase_auth_manager.dart';
import 'package:book/home/bloc/home_bloc.dart';
import 'package:book/home/bloc/home_event.dart';
import 'package:book/home/bloc/home_state.dart';
import 'package:book/utils/future_utils.dart';
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
  late Book book1;
  late Book book2;

  @override
  void initState() {
    _controller = PageController(viewportFraction: 0.9);
    super.initState();
    book1 = Book(
        title: 'Prva',
        author: 'Petar',
        imageUrl:
            'https://static0.gamerantimages.com/wordpress/wp-content/uploads/2022/07/Lord-of-the-Rings-One-Ring.jpg',
        docId: 'www');
    book2 = Book(
        title: 'Druga',
        author: 'Petar',
        imageUrl:
            'https://www.art-anima.com/wp-content/uploads/2024/05/golum-m.jpg',
        docId: 'bbb');
    books.add(book1);
    books.add(book2);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) async {
        if (state is SuccessfulSignOut) {
          Navigator.pushReplacementNamed(context, loginRoute);
        } else if (state is ErrorState) {
          final snackBar = SnackBar(
            backgroundColor: AppColors.errorSnackBar,
            content: Text(
              AppLocalizations.of(context)!.serverError,
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else if (state is AddingNewBook) {
          Book newBook = Book(title: '', author: '', imageUrl: '', docId: '');
          final Book? result = await Navigator.pushNamed<dynamic>(context, addNewBookRoute, arguments: newBook);
          if (result != null) {
            books.add(result);
          }
        }
      },
      builder: (context, HomeState state) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: IconButton(
              onPressed: () {
                context.read<HomeBloc>().add(SignOut());
              },
              icon: Icon(Icons.exit_to_app),
            ),
            title: Text(AppLocalizations.of(context)!.welcome),
          ),
          body: _buildBody(context),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              context.read<HomeBloc>().add(AddNewBook());
            },
            child: Icon(Icons.add),
          ),
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
                      maxLines: 2,
                      style: AppTextStyles.title(),
                    ),
                  ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 24),
                        child: Text(
                          '${AppLocalizations.of(context)!.author} ${book.author}',
                          style: AppTextStyles.text1(),
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

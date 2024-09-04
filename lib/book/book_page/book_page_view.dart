import 'package:book/app_colors.dart';
import 'package:book/app_routes.dart';
import 'package:book/book/bloc/book_page_bloc.dart';
import 'package:book/book/bloc/book_page_event.dart';
import 'package:book/book/bloc/book_page_state.dart';
import 'package:book/book/book.dart';
import 'package:book/book/book_page/book_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookPageView extends StatefulWidget {
  BookPageView({required this.book});

  Book book;

  @override
  State<BookPageView> createState() => _BookPageViewState();
}

class _BookPageViewState extends State<BookPageView> {
  int currentPageIndex = 0;
  List<BookPage> pages = [];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookPageBloc, BookPageState>(
        listener: (context, state) {
          if(state is AddBookPageState){
            pages.add(state.page);
          }
        },
        builder: (context, BookPageState state) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.primaryColor,
              centerTitle: true,
              title: pages.isEmpty
                  ? Text(widget.book.title)
                  : Text('Chapter title'),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: AppColors.primaryColor,
              onPressed: () async{
                BookPage newPage =
                    BookPage(text: '', pageNumber: pages.length + 1);
                final BookPage? result =  await Navigator.pushNamed<dynamic>(context, newPageRoute,
                    arguments: newPage);
                if(result != null) {
                  context.read<BookPageBloc>().add(AddBookPage(page: result));
                }

              },
              child: Icon(Icons.add),
            ),
            body: pageBody(context),
          );
        });
  }

  Widget pageBody(BuildContext context) {
    return Container(
      child: pages.isNotEmpty ? Column(
        children: [
          Text(pages[currentPageIndex].text),
          if(pages[currentPageIndex].pageImage != null)
            Image.network(pages[currentPageIndex].pageImage!.imageUrl!)

        ],
      ): Container(),
    );
  }

}

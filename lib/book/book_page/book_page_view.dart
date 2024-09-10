import 'package:book/app_colors.dart';
import 'package:book/app_routes.dart';
import 'package:book/book/bloc/book_page_bloc.dart';
import 'package:book/book/bloc/book_page_event.dart';
import 'package:book/book/bloc/book_page_state.dart';
import 'package:book/book/book.dart';
import 'package:book/book/book_page/book_page.dart';
import 'package:book/book/book_page/book_page_image.dart';
import 'package:book/core/constants.dart';
import 'package:book/enums/image_aspect_ratio.dart';
import 'package:book/utils/dialog_utils.dart';
import 'package:float_column/float_column.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BookPageView extends StatefulWidget {
  BookPageView({required this.book});

  final Book book;

  @override
  State<BookPageView> createState() => _BookPageViewState();
}

class _BookPageViewState extends State<BookPageView> {
  int currentPageIndex = 0;
  late List<BookPage> pages;

  @override
  void initState() {
    context.read<BookPageBloc>().add(InitBookEvent(book: widget.book));
    pages = widget.book.bookData?.bookPages ?? [];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookPageBloc, BookPageState>(
      listener: (context, state) {
        if (state is ErrorState) {
          final snackBar = SnackBar(
              backgroundColor: AppColors.errorSnackBar,
              content: Text(AppLocalizations.of(context)!.serverError));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else if (state is LoadingState) {
          DialogUtils.showLoadingScreen(context);
        } else if (state is LoadedState) {
          Navigator.pop(context);
        } else if (state is InitialState) {
          context.read<BookPageBloc>().add(InitBookEvent(book: widget.book));
        } else if (state is DisplayBookPageState) {
          widget.book.bookData!.bookPages = state.bookData.bookPages;
          pages = widget.book.bookData!.bookPages;
          currentPageIndex = state.pageIndex;
        }
      },
      builder: (context, BookPageState state) {
        if (state is DisplayBookPageState) {
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
              onPressed: () async {
                BookPage newPage =
                    BookPage(text: '', pageNumber: pages.length + 1);
                final BookPage? result = await Navigator.pushNamed<dynamic>(
                  context,
                  newPageRoute,
                  arguments: <String, dynamic>{
                    "newPage": newPage,
                    "bookId": widget.book.docId,
                  },
                );
                if (result != null) {
                  context
                      .read<BookPageBloc>()
                      .add(AddBookPageEvent(page: result));
                }
              },
              child: Icon(Icons.add),
            ),
            body: pageBody(context),
            bottomSheet: pages.isNotEmpty
                ? SafeArea(
                    child: Container(
                      height: kToolbarHeight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            padding: const EdgeInsets.only(left: 16),
                            onPressed: currentPageIndex > 0
                                ? () {
                                    if (currentPageIndex > 0) {
                                      context.read<BookPageBloc>().add(
                                          PreviousPageEvent(
                                              pageIndex: currentPageIndex));
                                    }
                                  }
                                : null,
                            icon: Icon(Icons.arrow_back),
                          ),
                          if (pages.isNotEmpty)
                            Container(
                              alignment: Alignment.center,
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                pages[currentPageIndex].pageNumber.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          IconButton(
                            padding: const EdgeInsets.only(right: 16),
                            onPressed: currentPageIndex < pages.length - 1
                                ? () {
                                    if (currentPageIndex < pages.length - 1) {
                                      context.read<BookPageBloc>().add(
                                          NextPageEvent(
                                              pageIndex: currentPageIndex));
                                    }
                                  }
                                : null,
                            icon: Icon(Icons.arrow_forward),
                          ),
                        ],
                      ),
                    ),
                  )
                : null,
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget pageBody(BuildContext context) {
    return pages.isNotEmpty
        ? _buildPageView(pages[currentPageIndex])
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppLocalizations.of(context)!.firstPage,
                textAlign: TextAlign.center,
              )
            ],
          );
  }

  Widget buildPagePortrait(BookPageImage pageImage) {
    return Container(
      color: AppColors.transparentBackground,
      margin: EdgeInsets.all(24),
      child: FloatColumn(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Floatable(
            padding: EdgeInsets.only(right: 16),
            float: FCFloat.start,
            child: Container(
              height: MediaQuery.of(context).size.height / 2,
              width: MediaQuery.of(context).size.width / 2,
              child: Image.network(pageImage.imageUrl!),
            ),
          ),
          SizedBox(
            width: 20,
          ),
          WrappableText(text: TextSpan(text: pages[currentPageIndex].text))
        ],
      ),
    );
  }

  Widget buildPageLandscapeAndSquare(BookPageImage pageImage) {
    return Container(
      color: AppColors.transparentBackground,
      margin: EdgeInsets.all(pageMargin),
      child: FloatColumn(
        children: [
          Floatable(
            float: FCFloat.start,
            child: Container(),
          ),
          Floatable(
            padding: EdgeInsets.only(right: 8),
            clearMinSpacing: MediaQuery.of(context).size.height * 0.5,
            float: FCFloat.start,
            maxWidthPercentage: 0.5,
            clear: FCClear.both,
            child: Image.network(pageImage.imageUrl!),
          ),
          WrappableText(
            text: TextSpan(text: pages[currentPageIndex].text),
          ),
        ],
      ),
    );
  }

  Widget buildPageWithoutImage() {
    return Container(
      margin: EdgeInsets.all(pageMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 30,
          ),
          Text(
            pages[currentPageIndex].text,
            textAlign: TextAlign.left,
          ),
          Spacer(),
        ],
      ),
    );
  }

  Widget _buildPageView(BookPage bookPage) {
    if (bookPage.pageImage == null) {
      return buildPageWithoutImage();
    } else if (bookPage.pageImage!.aspectRatio() == ImageAspectRatio.portrait) {
      return buildPagePortrait(bookPage.pageImage!);
    } else {
      return buildPageLandscapeAndSquare(bookPage.pageImage!);
    }
  }
}

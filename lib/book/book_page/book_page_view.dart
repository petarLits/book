import 'package:book/app_colors.dart';
import 'package:book/app_routes.dart';
import 'package:book/app_text_styles.dart';
import 'package:book/app_user.dart';
import 'package:book/app_user_singleton.dart';
import 'package:book/book/book.dart';
import 'package:book/book/book_chapter/book_chapter.dart';
import 'package:book/book/book_chapter/chapter_list_view.dart';
import 'package:book/book/book_page/book_page.dart';
import 'package:book/book/book_page/book_page_image.dart';
import 'package:book/core/constants.dart';
import 'package:book/enums/book_page_mode.dart';
import 'package:book/enums/image_aspect_ratio.dart';
import 'package:book/utils/dialog_utils.dart';
import 'package:float_column/float_column.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'bloc/book_page_bloc.dart';
import 'bloc/book_page_event.dart';
import 'bloc/book_page_state.dart';

class BookPageView extends StatefulWidget {
  BookPageView({required this.book, this.pageIndex});

  final Book book;
  int? pageIndex;

  @override
  State<BookPageView> createState() => _BookPageViewState();
}

class _BookPageViewState extends State<BookPageView> {
  int currentPageIndex = 0;
  late List<BookPage> pages;
  late List<BookChapter> chapters;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  bool isMessageReceived = false;
  late AppUser user;

  @override
  void initState() {
    context.read<BookPageBloc>().add(InitBookEvent(book: widget.book));
    pages = widget.book.bookData?.bookPages ?? [];
    chapters = widget.book.bookData?.bookChapters ?? [];
    if (widget.pageIndex != null) {
      isMessageReceived = true;
    }
    user = AppUserSingleton.instance.appUser!;
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
          widget.book.bookData = state.bookData;
          pages = widget.book.bookData!.bookPages;
          chapters = widget.book.bookData!.bookChapters;
          if (isMessageReceived) {
            currentPageIndex = widget.pageIndex!;
            isMessageReceived = false;
          } else {
            currentPageIndex = state.pageIndex;
          }
        }
      },
      builder: (context, BookPageState state) {
        if (state is DisplayBookPageState) {
          return WillPopScope(
            onWillPop: _onBackPressed,
            child: Scaffold(
              key: scaffoldKey,
              appBar: AppBar(
                backgroundColor: AppColors.primaryColor,
                centerTitle: true,
                title: pages.isEmpty
                    ? Text(widget.book.title)
                    : Text(pages[currentPageIndex].chapter!.title),
                actions: [
                  pages.isNotEmpty
                      ? Visibility(
                          visible: user.isAdmin == true,
                          child: IconButton(
                              onPressed: () async {
                                final BookPage? result =
                                    await Navigator.pushNamed<dynamic>(
                                        context, newPageRoute,
                                        arguments: <String, dynamic>{
                                      "newPage": pages[currentPageIndex],
                                      "bookId": widget.book.docId,
                                      "chapters":
                                          widget.book.bookData!.bookChapters,
                                      "pageMode": BookPageMode.edit,
                                    });
                                if (result != null) {
                                  context
                                      .read<BookPageBloc>()
                                      .add(UpdateBookPagesEvent(page: result));
                                }
                              },
                              icon: Icon(Icons.edit)),
                        )
                      : Container(),
                  pages.isNotEmpty
                      ? Visibility(
                          visible: user.isAdmin == true,
                          child: IconButton(
                            onPressed: () async {
                              final result = await showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(AppLocalizations.of(context)!
                                      .deleteDialogTitle),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context, true);
                                      },
                                      child: Text(
                                          AppLocalizations.of(context)!.yes),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context, false);
                                      },
                                      child: Text(
                                          AppLocalizations.of(context)!.no),
                                    )
                                  ],
                                ),
                              );
                              if (result == true) {
                                context
                                    .read<BookPageBloc>()
                                    .add(DeleteBookPageEvent());
                              }
                            },
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
              floatingActionButton: Visibility(
                visible: user.isAdmin == true,
                child: FloatingActionButton(
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
                        "chapters": widget.book.bookData!.bookChapters,
                        "pageMode": BookPageMode.create,
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
              ),
              drawer: Drawer(
                child: chapters.isNotEmpty
                    ? Stack(
                        children: [
                          Column(
                            children: [
                              Container(
                                child: Container(
                                  margin: EdgeInsets.all(48),
                                  child: Text(
                                    widget.book.title,
                                    maxLines: titleMaxLines,
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.title(),
                                  ),
                                ),
                                height: 200,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(
                                            widget.book.imageUrl))),
                              ),
                              Flexible(
                                child: ChaptersListView(
                                  chapters: chapters,
                                  pages: pages,
                                  onPagePressed: (pageNumber) {
                                    context.read<BookPageBloc>().add(
                                        NavigateToPageEvent(
                                            pageNumber: pageNumber));
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            bottom: 20,
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.maybePop(context);
                              },
                              child: Text(
                                AppLocalizations.of(context)!.leaveBook,
                                style: TextStyle(
                                    decoration: TextDecoration.underline),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container(
                        margin: EdgeInsets.only(bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              child: Container(
                                margin: EdgeInsets.all(48),
                                child: Text(
                                  maxLines: titleMaxLines,
                                  widget.book.title,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.title(),
                                ),
                              ),
                              width: double.infinity,
                              height: 200,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(widget.book.imageUrl),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 16),
                              child: Text(
                                  AppLocalizations.of(context)!.noChapters),
                            ),
                            Spacer(),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.maybePop(context);
                              },
                              child: Text(
                                AppLocalizations.of(context)!.leaveBook,
                                style: TextStyle(
                                    decoration: TextDecoration.underline),
                              ),
                            ),
                          ],
                        ),
                      ),
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
            ),
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
        ? GestureDetector(
            onHorizontalDragEnd: (DragEndDetails details) {
              if (details.primaryVelocity! < 0 &&
                  currentPageIndex < pages.length - 1) {
                context.read<BookPageBloc>().add(SwipeLeftEvent());
              } else if (details.primaryVelocity! > 0 && currentPageIndex > 0) {
                context.read<BookPageBloc>().add(SwipeRightEvent());
              } else if (details.primaryVelocity == 0) {
                return;
              } else {
                final snackBar = SnackBar(
                  backgroundColor: AppColors.errorSnackBar,
                  content: Text(AppLocalizations.of(context)!.swipeError),
                  duration: Duration(seconds: 1),
                );
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
            },
            child: _buildPageView(pages[currentPageIndex]),
          )
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
      color: AppColors.transparentBackground,
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

  Future<bool> _onBackPressed() async {
    bool? opened = scaffoldKey.currentState?.isDrawerOpen;
    if (opened != true) {
      final result = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.leavingBook),
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
      return result;
    }
    return true;
  }
}

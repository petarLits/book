import 'dart:io';

import 'package:book/app_colors.dart';
import 'package:book/app_routes.dart';
import 'package:book/book/book_chapter/book_chapter.dart';
import 'package:book/book/book_page/book_page.dart';
import 'package:book/core/constants.dart';
import 'package:book/enums/book_page_mode.dart';
import 'package:book/login/widgets/custom_text_form_field.dart';
import 'package:book/utils/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';

import 'bloc/book_page_bloc.dart';
import 'bloc/book_page_event.dart';
import 'bloc/book_page_state.dart';

class NewBookPage extends StatefulWidget {
  NewBookPage({
    required this.newPage,
    required this.bookId,
    required this.chapters,
    required this.pageMode,
  });

  BookPage newPage;
  String bookId;
  List<BookChapter> chapters;
  BookPageMode pageMode;

  @override
  State<NewBookPage> createState() => _NewBookPageState();
}

class _NewBookPageState extends State<NewBookPage> {
  final _formKey = GlobalKey<FormState>();
  late String textValue;
  late ImagePicker _picker;
  File? image;
  BookChapter? selectedChapter;
  late BookPage page;

  @override
  void initState() {
    super.initState();
    page = BookPage.copy(page: widget.newPage);
    textValue = widget.newPage.text;
    _picker = ImagePicker();

    if (page.pageImage != null) {
      image = page.pageImage!.image;
    }
    if (widget.pageMode == BookPageMode.edit) {
      selectedChapter = page.chapter;
    } else {
      selectedChapter = widget.chapters.lastOrNull;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookPageBloc, BookPageState>(
      listener: (context, state) async {
        if (state is ErrorState) {
          SnackBarUtils.showSnackBar(
              color: AppColors.errorSnackBar,
              content: AppLocalizations.of(context)!.serverError,
              context: context);
        } else if (state is AddBookPageImageState) {
          image = state.image;
        } else if (state is DeleteBookPageImageState) {
          image = null;
          if (page.pageImage != null) {
            page.pageImage = null;
          }
        } else if (state is SaveNewBookPageState) {
          Navigator.pop(context, state.page);
        } else if (state is AddNewBookChapterState) {
          widget.chapters = state.chapters;
          selectedChapter = widget.chapters.lastOrNull;
        } else if (state is ChangeSelectedChapterState) {
          selectedChapter = state.chapter;
        }
      },
      builder: (context, BookPageState state) {
        return Stack(children: [
          buildPageScaffold(context),
          if (state is LoadingState)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.1),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            )
        ]);
      },
    );
  }

  WillPopScope buildPageScaffold(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.addNewPage),
          centerTitle: true,
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.primaryColor,
          leading: IconButton(
            onPressed: () {
              Navigator.maybePop(context);
            },
            icon: Icon(Icons.arrow_back),
          ),
        ),
        body: Form(
          key: _formKey,
          child: Container(
            margin: EdgeInsets.only(right: 16, left: 16),
            child: ListView(
              shrinkWrap: true,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: widget.chapters.isNotEmpty
                          ? DropdownButton(
                              isExpanded: true,
                              value: selectedChapter,
                              items: _buildItems(),
                              onChanged: widget.pageMode == BookPageMode.create
                                  ? (chapterSelected) {
                                      context.read<BookPageBloc>().add(
                                          ChangeSelectedChapterEvent(
                                              chapter: chapterSelected
                                                  as BookChapter));
                                    }
                                  : null,
                            )
                          : Text(AppLocalizations.of(context)!.addFirstChapter),
                    ),
                    Visibility(
                      visible: widget.pageMode == BookPageMode.create,
                      child: IconButton(
                          onPressed: () async {
                            final result = await Navigator.pushNamed<dynamic>(
                              context,
                              newBookChapterRoute,
                              arguments: widget.chapters.length + 1,
                            );
                            if (result != null) {
                              context
                                  .read<BookPageBloc>()
                                  .add(AddNewBookChapterEvent(chapter: result));
                            }
                          },
                          icon: Icon(Icons.add)),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                if (widget.chapters.isNotEmpty)
                  CustomTextFormField(
                    initialValue: textValue,
                    maxLines: textMaxLines,
                    isNonPasswordField: true,
                    labelText: AppLocalizations.of(context)!.textLabel,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.textError;
                      }
                      return null;
                    },
                    maxLength: textMaxLength,
                    onChanged: (value) {
                      textValue = value;
                      setState(() {});
                    },
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () async {
                        final pickedImage = await _picker.pickImage(
                            source: ImageSource.gallery);
                        if (pickedImage != null) {
                          context.read<BookPageBloc>().add(
                                AddBookPageImageEvent(
                                  image: File(pickedImage.path),
                                ),
                              );
                        }
                      },
                      icon: Icon(Icons.add_a_photo),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                if (image != null || page.pageImage != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: image != null
                            ? Image.file(image!)
                            : page.pageImage?.imageUrl != null
                                ? Image.network(page.pageImage!.imageUrl!)
                                : null,
                      ),
                      IconButton(
                        onPressed: () {
                          context
                              .read<BookPageBloc>()
                              .add(DeleteBookPageImageEvent());
                        },
                        icon: Icon(Icons.cancel),
                      ),
                    ],
                  ),
                SizedBox(height: 200),
                ElevatedButton(
                  onPressed: hasChanges()
                      ? () {
                          if (_formKey.currentState!.validate()) {
                            page.text = textValue;
                            page.chapter = selectedChapter;
                            context
                                .read<BookPageBloc>()
                                .add(SaveNewBookPageEvent(
                                  page: page,
                                  image: image,
                                ));
                          }
                        }
                      : null,
                  child: Text(AppLocalizations.of(context)!.saveButton),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool hasChanges() {
    return (textValue != page.text ||
        image != page.pageImage?.image ||
        (widget.pageMode == BookPageMode.edit &&
            page.pageImage != widget.newPage.pageImage));
  }

  Future<bool> _onBackPressed() async {
    if (hasChanges()) {
      final result = await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.leaveDialog),
          content: Text(AppLocalizations.of(context)!.changesWillBeDiscarded),
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

  List<DropdownMenuItem<BookChapter>> _buildItems() {
    final items = <DropdownMenuItem<BookChapter>>[];

    for (final chapter in widget.chapters) {
      items.add(DropdownMenuItem(
        value: chapter,
        child: Text(
          chapter.title,
          overflow: TextOverflow.ellipsis,
        ),
      ));
    }
    return items;
  }
}

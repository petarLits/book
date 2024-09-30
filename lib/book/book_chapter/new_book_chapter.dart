import 'package:book/app_colors.dart';
import 'package:book/book/book_chapter/book_chapter.dart';
import 'package:book/book/book_page/bloc/book_page_bloc.dart';
import 'package:book/book/book_page/bloc/book_page_event.dart';
import 'package:book/book/book_page/bloc/book_page_state.dart';
import 'package:book/core/constants.dart';
import 'package:book/login/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NewBookChapter extends StatefulWidget {
  NewBookChapter({required this.chapter});

  BookChapter chapter;

  @override
  State<NewBookChapter> createState() => _NewBookChapterState();
}

class _NewBookChapterState extends State<NewBookChapter> {
  late String titleValue;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    titleValue = widget.chapter.title;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookPageBloc, BookPageState>(
      listener: (context, state) {
        if (state is SaveBookChapterState) {
          Navigator.pop(context, state.chapter);
        }
      },
      builder: (context, BookPageState state) {
        return WillPopScope(
          onWillPop: _onBackPressed,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.primaryColor,
              title: Text(AppLocalizations.of(context)!.addNewChapterTitle),
              centerTitle: true,
              automaticallyImplyLeading: false,
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
                margin: EdgeInsets.all(pageMargin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 30),
                    CustomTextFormField(
                      isNonPasswordField: true,
                      labelText: AppLocalizations.of(context)!.titleLabel,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!
                              .chapterTitleError;
                        }
                        return null;
                      },
                      maxLength: titleMaxLength,
                      onChanged: (value) {
                        titleValue = value;
                      },
                    ),
                    Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          widget.chapter.title = titleValue;
                          context.read<BookPageBloc>().add(
                              SaveBookChapterEvent(chapter: widget.chapter));
                        }
                      },
                      child: Text(AppLocalizations.of(context)!.saveButton),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool> _onBackPressed() async {
    if (titleValue != '') {
      final result = await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) =>
            AlertDialog(
              title: Text(AppLocalizations.of(context)!.leaveDialog),
              content: Text(
                  AppLocalizations.of(context)!.changesWillBeDiscarded),
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
                )
              ],
            ),
      );
      if (result == true) {
        Navigator.pop(context);
      }
      return result;
    }
    return true;
  }
}

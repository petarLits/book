import 'dart:io';

import 'package:book/app_colors.dart';
import 'package:book/book/book.dart';
import 'package:book/core/constants.dart';
import 'package:book/home/bloc/home_bloc.dart';
import 'package:book/home/bloc/home_event.dart';
import 'package:book/home/bloc/home_state.dart';
import 'package:book/login/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';

class AddNewBook extends StatefulWidget {
  AddNewBook({required this.newBook});

  final Book newBook;

  @override
  State<AddNewBook> createState() => _AddNewBookState();
}

class _AddNewBookState extends State<AddNewBook> {
  final _formKey = GlobalKey<FormState>();
  late String titleValue;
  late String authorValue;
  ImagePicker picker = ImagePicker();
  File? image;

  @override
  void initState() {

    titleValue = widget.newBook.title;
    authorValue = widget.newBook.author;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(listener: (context, state) {
      if (state is SavedBookState) {
        Navigator.pop(context, state.book);
      } else if (state is AddBookImageState) {
        image = state.image;
      } else if (state is UploadedBookImageAndUrlGotState) {
        context.read<HomeBloc>().add(SaveNewBook(book: state.book));
      } else if (state is ErrorState) {
        final snackBar = SnackBar(
          content: Text(AppLocalizations.of(context)!.serverError),
          backgroundColor: AppColors.errorSnackBar,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else if (state is DeletedBookImage) {
        image = null;
      }
    }, builder: (context, HomeState state) {
      return WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.primaryColor,
            title: Text(AppLocalizations.of(context)!.addNewBook),
            centerTitle: true,
            leading: IconButton(
              onPressed: () {
                Navigator.maybePop(context);
              },
              icon: Icon(Icons.arrow_back),
            ),
          ),
          body: Container(
            margin: EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  CustomTextFormField(
                      isNonPasswordField: true,
                      labelText: AppLocalizations.of(context)!.newBookTitle,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.bookTitleError;
                        }
                        return null;
                      },
                      maxLength: titleMaxLength,
                      onChanged: (value) {
                        titleValue = value;
                      }),
                  SizedBox(
                    height: 20,
                  ),
                  CustomTextFormField(
                      isNonPasswordField: true,
                      labelText: AppLocalizations.of(context)!.authorLabel,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.authorError;
                        }
                        return null;
                      },
                      maxLength: authorMaxLength,
                      onChanged: (value) {
                        authorValue = value;
                      }),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () async {
                          final pickedImage = await picker.pickImage(
                              source: ImageSource.gallery);
                          if (pickedImage != null) {
                            context.read<HomeBloc>().add(
                                  AddBookImage(
                                    image: File(pickedImage.path),
                                  ),
                                );
                          }
                        },
                        icon: Icon(Icons.add_a_photo),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 100,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      image != null
                          ? SizedBox(
                              height: 100,
                              width: 100,
                              child: Image.file(image!),
                            )
                          : Text(
                              AppLocalizations.of(context)!.pickBookImage,
                            ),
                      IconButton(
                        onPressed: image != null
                            ? () {
                                context.read<HomeBloc>().add(DeleteBookImage());
                              }
                            : null,
                        icon: Icon(Icons.delete),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 200,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: image != null
                              ? () async {
                                  if (_formKey.currentState!.validate()) {
                                    widget.newBook.title = titleValue;
                                    widget.newBook.author = authorValue;
                                    widget.newBook.image = image;
                                    context.read<HomeBloc>().add(
                                        UploadBookImageAndGetUrl(
                                            book: widget.newBook));
                                  }
                                }
                              : null,
                          child: Text(
                            AppLocalizations.of(context)!.saveButton,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Future<bool> _onBackPressed() async {
    if (titleValue != '' || authorValue != '' || image != null) {
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
                ),
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

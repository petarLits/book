import 'dart:io';
import 'dart:ui' as ui;

import 'package:book/app_colors.dart';
import 'package:book/book/bloc/book_page_bloc.dart';
import 'package:book/book/bloc/book_page_event.dart';
import 'package:book/book/bloc/book_page_state.dart';
import 'package:book/book/book_page/book_page.dart';
import 'package:book/book/book_page/book_page_image.dart';
import 'package:book/core/constants.dart';
import 'package:book/login/widgets/custom_text_form_field.dart';
import 'package:book/utils/dialog_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';

class NewBookPage extends StatefulWidget {
  NewBookPage({required this.newPage});

  BookPage newPage;

  @override
  State<NewBookPage> createState() => _NewBookPageState();
}

class _NewBookPageState extends State<NewBookPage> {
  final _formKey = GlobalKey<FormState>();
  late String textValue;
  late ImagePicker _picker;
  File? image;
  ui.Image? decodedImage;

  @override
  void initState() {
    super.initState();
    textValue = widget.newPage.text;
    _picker = ImagePicker();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookPageBloc, BookPageState>(
      listener: (context, state) async {
        if (state is LoadingState) {
          DialogUtils.showLoadingScreen(context);
        } else if (state is LoadedState) {
          Navigator.pop(context);
        } else if (state is ErrorState) {
          final snackBar = SnackBar(
            content: Text(AppLocalizations.of(context)!.serverError),
            backgroundColor: AppColors.errorSnackBar,
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else if (state is BookPageImageAdded) {
          image = state.image;
          decodedImage = await decodeImageFromList(image!.readAsBytesSync());
        } else if (state is BookPageImageDeleted) {
          image = null;
        } else if (state is NewBookPageSaved) {
          Navigator.pop(context, state.page);
        }
      },
      builder: (context, BookPageState state) {
        return WillPopScope(
          onWillPop: _onBackPressed,
          child: Scaffold(
            appBar: AppBar(
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
                    SizedBox(height: 30),
                    CustomTextFormField(
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
                                    AddBookPageImage(
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
                    if (image != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: Image.file(image!),
                          ),
                          IconButton(
                            onPressed: () {
                              context
                                  .read<BookPageBloc>()
                                  .add(DeleteBookPageImage());
                            },
                            icon: Icon(Icons.cancel),
                          ),
                        ],
                      ),
                    SizedBox(height: 200),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          widget.newPage.text = textValue;
                          if (image != null && decodedImage != null) {
                            BookPageImage pageImage = BookPageImage(
                                width: decodedImage!.width,
                                height: decodedImage!.height,
                                image: image);
                            widget.newPage.pageImage = pageImage;
                          } else if (image == null) {
                            widget.newPage.pageImage = null;
                          }

                          context
                              .read<BookPageBloc>()
                              .add(SaveNewBookPage(page: widget.newPage));
                        }
                      },
                      child: Text(AppLocalizations.of(context)!.saveButton),
                    )
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
    final result = await showDialog(
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
    if (result == true) {
      Navigator.pop(context);
    }
    return result;
  }
}

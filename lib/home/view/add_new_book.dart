import 'dart:io';
import 'package:book/app_colors.dart';
import 'package:book/core/constants.dart';
import 'package:book/login/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddNewBook extends StatefulWidget {
  @override
  State<AddNewBook> createState() => _AddNewBookState();
}

class _AddNewBookState extends State<AddNewBook> {
  final _formKey = GlobalKey<FormState>();
  late String titleValue;
  late String authorValue;
  late String imageUrl;
  ImagePicker picker = ImagePicker();
  File? image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text(AppLocalizations.of(context)!.addNewBook),
        centerTitle: true,
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
                  labelText: AppLocalizations.of(context)!.author,
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
                      final pickedImage =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (pickedImage != null) {
                        image = File(pickedImage.path);
                      }
                      setState(() {});
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
                            image = null;
                            setState(() {});
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
                      onPressed: image != null ? () async {
                        if(_formKey.currentState!.validate()){

                        }
                      } : null,
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
    );
  }
}

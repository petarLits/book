import 'package:book/book/book_page/book_page.dart';
import 'package:flutter/material.dart';

import 'book_chapter.dart';

class ChaptersListView extends StatefulWidget {
  const ChaptersListView(
      {required this.chapters,
      required this.pages,
      required this.onPagePressed,
      super.key});

  final List<BookChapter> chapters;
  final List<BookPage> pages;
  final ValueChanged<int> onPagePressed;

  @override
  State<ChaptersListView> createState() => ChaptersListViewState();
}

class ChaptersListViewState extends State<ChaptersListView> {
  int? expandedChapterNumber;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: EdgeInsets.only(top: 0),
        shrinkWrap: true,
        itemCount: widget.chapters.length,
        itemBuilder: (BuildContext context, int index) {
          return buildChapter(context,
              chapter: widget.chapters[index],
              chapterPages: extractPagesForChapter(widget.chapters[index]));
        });
  }

  List<BookPage> extractPagesForChapter(BookChapter chapter) {
    return widget.pages
        .where((page) => page.chapter!.number == chapter.number)
        .toList();
  }

  ExpansionTile buildChapter(BuildContext context,
      {required BookChapter chapter, required List<BookPage> chapterPages}) {
    return ExpansionTile(
      shape: Border(
        top: BorderSide(color: Colors.transparent),
        bottom: BorderSide(color: Colors.black),
      ),
      key: UniqueKey(),
      initiallyExpanded: expandedChapterNumber == chapter.number,
      onExpansionChanged: (isExpanded) {
        if (isExpanded) {
          expandedChapterNumber = chapter.number;
        } else {
          expandedChapterNumber = null;
        }
        setState(() {});
      },
      title: Text(chapter.title),
      children: chapterPages
          .map(
            (page) => ListTile(
              title: Text(
                page.pageNumber.toString() + '. ' + page.text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                widget.onPagePressed(page.pageNumber);
              },
            ),
          )
          .toList(),
    );
  }
}

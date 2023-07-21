class Section {
  final String name;
  final List<String> parameters;
  final String content;

  const Section(this.name, this.parameters, this.content);

  factory Section.fromWikiText(String wikitext) {
    // ex: === {{S|nom|fr}} ===
    final sectionPattern = RegExp(r'^=+ {{S(\|.+)+}} =+$');

    final firstLineEndIndex = wikitext.indexOf('\n');
    if (firstLineEndIndex == -1) {
      throw Exception('missing first line :\n$wikitext');
    }

    final firstLine = wikitext.substring(0, firstLineEndIndex);
    print(firstLine);
    final match = sectionPattern.firstMatch(firstLine);
    if (match == null) throw Exception('missing section header :\n$wikitext');

    final sectionParams =
        match.group(1)!.split('|').skip(1); // first param is empty '|'
    return Section(
        sectionParams.first,
        sectionParams.skip(1).toList(),
        wikitext.substring(
            firstLineEndIndex + 1 /* skip section header newline */));
  }

  static List<Section> splitInSections(String wikitext) {
    final sectionsWikitext = wikitext.split('\n=');
    return sectionsWikitext
        .where((swt) => swt != '== {{langue|fr}} ==')
        .map((swt) => Section.fromWikiText('=$swt'))
        .toList();
  }
}

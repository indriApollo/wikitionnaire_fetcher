import 'package:wikitionnaire_fetcher/wikitext_parser.dart';
import 'package:test/test.dart';

import 'wikitext_sample.dart';

void main() {
  test('section from wikitext factory', () {
    final section = Section.fromWikiText(wikitextSingleSectionSample);
    expect(section.name, 'nom');
    expect(section.parameters.length, 1);
    expect(section.parameters.first, 'fr');

    final expectedStart = '{{fr-rég|vi.de.o}}';
    expect(section.content.substring(0, expectedStart.length), expectedStart);

    final expectedEnd =
        "traduit de l'anglais (Inde), éd. Publishroom, 2016, chap. 7}}\n";
    expect(
        section.content.substring(section.content.length - expectedEnd.length),
        expectedEnd);
  });

  test('parse multiple sections', () {
    final sections = Section.splitInSections(wikitextSample);

    expect(sections.length, 11);

    expect(sections[0].name, 'étymologie');

    expect(sections[1].name, 'nom');
    expect(sections[1].parameters.length, 1);
    expect(sections[1].parameters.first, 'fr');
  });
}

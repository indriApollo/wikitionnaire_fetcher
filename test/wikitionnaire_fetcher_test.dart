import 'package:wikitionnaire_fetcher/wikitionnaire_fetcher.dart';
import 'package:test/test.dart';

void main() {
  test('findWikitionnairePageForWord single', () async {
    final foundPages = await findWikitionnairePagesForWord('video');
    expect(foundPages.length, 1);
    expect(foundPages.first, 'vidéo');
  });

  test('findWikitionnairePageForWord multiple', () async {
    // Titre 	Prononciation 	Type
    // ãã	    /a.a/ 	        Nom commun
    // aa	    /a.a/ 	        Nom commun, m
    // aa	    /a.na/ 	        Nom commun 2
    // ââ	    //              symb
    // a͠a	   /a.na/          symb
    final foundPages = await findWikitionnairePagesForWord('aa');
    expect(foundPages.length, 2); // unique, non-symbols
    print(foundPages);
    expect(foundPages.any((p) => p == 'ãã'), true);
    expect(foundPages.any((p) => p == 'aa'), true);
  });
}

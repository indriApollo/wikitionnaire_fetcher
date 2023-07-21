import 'package:wikitionnaire_fetcher/wikitionnaire_fetcher.dart' as fetcher;

void main(List<String> args) async {
  const dbFilename = "words.sqlite";
  final wordlistFilename = args[0];

  fetcher.initDb(dbFilename);

  print('using wordlist file $wordlistFilename');

  //await fetcher.loadWordlistInDb(dbFilename, wordlistFilename);

  await fetcher.findWikitionnairePagesForWords(dbFilename);
}

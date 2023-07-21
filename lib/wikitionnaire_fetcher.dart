import 'dart:convert';
import 'dart:io' as io;

import 'package:sqlite3/sqlite3.dart';

import 'package:http/http.dart' as http;

void initDb(String dbFilename) {
  final db = sqlite3.open(dbFilename, mode: OpenMode.readWriteCreate);

  const String query = '''
  CREATE TABLE IF NOT EXISTS words (
    word TEXT PRIMARY KEY,
    wikitionnaire_page_titles TEXT,
    wikitionnaire_definitions TEXT
  );
  ''';

  db.execute(query);

  db.dispose();
}

Future<void> loadWordlistInDb(
    String dbFilename, String wordlistFilename) async {
  final db = sqlite3.open(dbFilename, mode: OpenMode.readWrite);
  final wordlist = io.File(wordlistFilename).openRead();

  const String insert = '''
  INSERT OR IGNORE INTO words(word) VALUES(?);
  ''';

  final stmt = db.prepare(insert, persistent: true);

  final lines = utf8.decoder.bind(wordlist).transform(const LineSplitter());

  await for (final line in lines) {
    if (line.startsWith('Il y a')) continue;

    line.split(' ').forEach((word) {
      print(word);
      stmt.execute([word]);
    });
  }

  stmt.dispose();
  db.dispose();
}

Future<void> findWikitionnairePagesForWords(String dbFilename) async {
  final db = sqlite3.open(dbFilename, mode: OpenMode.readWrite);

  const String select = '''
  SELECT word FROM words WHERE word > ? ORDER BY word ASC LIMIT 1;
  ''';

  const String update = '''
  UPDATE words SET wikitionnaire_page_titles = ? WHERE word = ? LIMIT 1;
  ''';

  final selectStmt = db.prepare(select);
  final updateStmt = db.prepare(update, persistent: true);

  var previousWord = '';
  while (true) {
    final result = selectStmt.select([previousWord]);
    if (result.isEmpty) break;

    final word = result.first.values.first as String;
    final pageTitles = await findWikitionnairePagesForWord(word);
    final pageTitlesJson = json.encode(pageTitles.toList());
    print('$word -> $pageTitlesJson');
    updateStmt.execute([pageTitlesJson, word]);

    previousWord = word;
  }

  selectStmt.dispose();
  updateStmt.dispose();
  db.dispose();
}

Future<Set<String>> findWikitionnairePagesForWord(String word) async {
  const userAgent = 'wikitionnaire_fetcher';
  const baseUrl =
      "https://anagrimes.toolforge.org/api.php?action=search&lang=fr&flex=false&loc=false&gent=false&nom-pr=false&noflat=false&without_pron=false&wikilist=false&dev=false&string=";

  final uri = Uri.parse('$baseUrl$word');

  final jsonp = await http.read(uri, headers: {'User-Agent': userAgent});
  var jsonStr = jsonp.trim();
  // remove callback chars '(...)'
  jsonStr = jsonStr.substring(1, jsonStr.length - 1);

  //"list": [
  //   {
  //     "a_title": "vid\u00e9o",
  //     "l_type": "nom"

  final response = json.decode(jsonStr) as Map<String, dynamic>;

  final pages = response['list'] as List<dynamic>;
  return pages
      .where((e) => e['l_type'] != 'symb') // ignore symbols
      .map((e) => e['a_title'] as String)
      .toSet(); // unique titles
}

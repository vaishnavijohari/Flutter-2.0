// lib/games/crossword/crossword_data.dart

// import 'dart:math';

enum CrosswordDirection { across, down }

class CrosswordWord {
  final int id;
  final CrosswordDirection direction;
  final String word;
  final String hint;
  int startRow;
  int startCol;

  CrosswordWord({
    required this.id,
    required this.direction,
    required this.word,
    required this.hint,
    required this.startRow,
    required this.startCol,
  });
}

class CrosswordPuzzle {
  final String title;
  final List<CrosswordWord> words;
  final int rows;
  final int cols;

  CrosswordPuzzle._({
    required this.title,
    required this.words,
    required this.rows,
    required this.cols,
  });

  factory CrosswordPuzzle({
    required String title,
    required List<CrosswordWord> words,
  }) {
    final wordList = List<CrosswordWord>.from(words);
    _normalizeOffsets(wordList);
    final int calculatedRows = _calculateRows(wordList);
    final int calculatedCols = _calculateCols(wordList);

    return CrosswordPuzzle._(
      title: title,
      words: wordList,
      rows: calculatedRows,
      cols: calculatedCols,
    );
  }

  static void _normalizeOffsets(List<CrosswordWord> words) {
    if (words.isEmpty) return;
    int minRow = words.first.startRow;
    int minCol = words.first.startCol;

    for (final word in words) {
      if (word.startRow < minRow) minRow = word.startRow;
      if (word.startCol < minCol) minCol = word.startCol;
    }

    for (final word in words) {
      word.startRow -= minRow;
      word.startCol -= minCol;
    }
  }

  /// ✅ **DEFINITIVE FIX**: Rewritten the calculation logic to be more explicit and clear.
  static int _calculateRows(List<CrosswordWord> words) {
    if (words.isEmpty) return 0;
    int maxRow = 0;
    for (final word in words) {
      int currentMax = 0;
      if (word.direction == CrosswordDirection.down) {
        currentMax = word.startRow + word.word.length;
      } else {
        currentMax = word.startRow + 1;
      }
      if (currentMax > maxRow) {
        maxRow = currentMax;
      }
    }
    return maxRow;
  }

  /// ✅ **DEFINITIVE FIX**: Rewritten the calculation logic to be more explicit and clear.
  static int _calculateCols(List<CrosswordWord> words) {
    if (words.isEmpty) return 0;
    int maxCol = 0;
    for (final word in words) {
      int currentMax = 0;
      if (word.direction == CrosswordDirection.across) {
        currentMax = word.startCol + word.word.length;
      } else {
        currentMax = word.startCol + 1;
      }
      if (currentMax > maxCol) {
        maxCol = currentMax;
      }
    }
    return maxCol;
  }
}

// Puzzle data remains the same
final allCrosswordPuzzles = [
  // Level 1
  CrosswordPuzzle(
    title: "LEVEL 1",
    words: [
      CrosswordWord(id: 1, direction: CrosswordDirection.across, word: "VOLCANO", hint: "Mountain That Erupts", startRow: 4, startCol: 6),
      CrosswordWord(id: 4, direction: CrosswordDirection.across, word: "NILE", hint: "Longest River In Africa", startRow: 2, startCol: 4),
      CrosswordWord(id: 5, direction: CrosswordDirection.across, word: "SHIVA", hint: "Hindu Deity Of Destruction", startRow: 0, startCol: 0),
      CrosswordWord(id: 7, direction: CrosswordDirection.across, word: "JUPITER", hint: "Largest Planet In The Solar System", startRow: 10, startCol: 4),
      CrosswordWord(id: 2, direction: CrosswordDirection.down, word: "AERODYNAMICS", hint: "Study Of Motion In Air", startRow: 1, startCol: 7),
      CrosswordWord(id: 3, direction: CrosswordDirection.across, word: "NOAH", hint: "Biblical Ark Builder", startRow: 7, startCol: 7),
      CrosswordWord(id: 6, direction: CrosswordDirection.down, word: "ARNOLD", hint: "Famous Bodybuilder And Actor", startRow: 0, startCol: 4),
    ],
  ),
  // Level 2
  CrosswordPuzzle(
    title: "LEVEL 2",
    words: [
      CrosswordWord(id: 1, direction: CrosswordDirection.across, word: "GALAXY", hint: "Massive Star System", startRow: 2, startCol: 0),
      CrosswordWord(id: 2, direction: CrosswordDirection.across, word: "TRINITY", hint: "Group Of Three", startRow: 4, startCol: 3),
      CrosswordWord(id: 3, direction: CrosswordDirection.across, word: "GALILEO", hint: "Astronomer Who Supported Heliocentrism", startRow: 8, startCol: 6),
      CrosswordWord(id: 4, direction: CrosswordDirection.across, word: "BENGALI", hint: "Language Spoke In Eastern INDIA", startRow: 10, startCol: 1),
      CrosswordWord(id: 5, direction: CrosswordDirection.down, word: "QUARTZ", hint: "Common Crystal Mineral", startRow: 0, startCol: 3),
      CrosswordWord(id: 6, direction: CrosswordDirection.down, word: "INDRAJIT", hint: "Warrior Son Of Ravana", startRow: 4, startCol: 7),
    ],
  ),
  // Level 3
  CrosswordPuzzle(
    title: "LEVEL 3",
    words: [
      CrosswordWord(id: 1, direction: CrosswordDirection.across, word: "EQUATOR", hint: "Imaginary Line Dividing Earth Into Hemispheres", startRow: 5, startCol: 1),
      CrosswordWord(id: 2, direction: CrosswordDirection.across, word: "ASHOKA", hint: "Mauryan Emperor Who Embraced Buddhism", startRow: 6, startCol: 7),
      CrosswordWord(id: 3, direction: CrosswordDirection.across, word: "GABRIEL", hint: "Archangel Who Delivered Divine Messages", startRow: 8, startCol: 6),
      CrosswordWord(id: 4, direction: CrosswordDirection.across, word: "ARISTOTLE", hint: "Philosopher, Teacher Of Alexander The Great", startRow: 10, startCol: 0),
      CrosswordWord(id: 5, direction: CrosswordDirection.down, word: "HANUMAN", hint: "Hindu Monkey God And Devotee Of Rama", startRow: 0, startCol: 4),
      CrosswordWord(id: 6, direction: CrosswordDirection.down, word: "ALGEBRA", hint: "Math Branch Dealing With Symbols And Equations", startRow: 2, startCol: 1),
      CrosswordWord(id: 7, direction: CrosswordDirection.down, word: "RANGOLI", hint: "Indian Art Form With Colored Powders", startRow: 5, startCol: 7),
    ],
  ),
  // Level 4
  CrosswordPuzzle(
    title: "LEVEL 4",
    words: [
      CrosswordWord(id: 1, direction: CrosswordDirection.across, word: "MOZART", hint: "Famous Classical Composer", startRow: 1, startCol: 4),
      CrosswordWord(id: 2, direction: CrosswordDirection.across, word: "SPECTRUM", hint: "Band Of Colors Seen In A Rainbow", startRow: 5, startCol: 2),
      CrosswordWord(id: 3, direction: CrosswordDirection.across, word: "QUASAR", hint: "Highly Energetic Astronomical Object", startRow: 8, startCol: 0),
      CrosswordWord(id: 4, direction: CrosswordDirection.across, word: "JAIPUR", hint: "The Pink City Of India", startRow: 9, startCol: 5),
      CrosswordWord(id: 5, direction: CrosswordDirection.down, word: "MESSIAH", hint: "A Savior Or Liberator", startRow: 3, startCol: 2),
      CrosswordWord(id: 6, direction: CrosswordDirection.down, word: "ZODIAC", hint: "Astrological System With 12 Signs", startRow: 0, startCol: 5),
      CrosswordWord(id: 7, direction: CrosswordDirection.down, word: "ARJUNA", hint: "Warrior Prince In Mahabharata", startRow: 4, startCol: 7),
    ],
  ),
  // Level 5
  CrosswordPuzzle(
    title: "LEVEL 5",
    words: [
      CrosswordWord(id: 1, direction: CrosswordDirection.across, word: "SHAKESPEARE", hint: "Famous English Playwright", startRow: 8, startCol: 3),
      CrosswordWord(id: 2, direction: CrosswordDirection.across, word: "PLATO", hint: "Greek Philosopher, Student Of Socrates", startRow: 4, startCol: 1),
      CrosswordWord(id: 3, direction: CrosswordDirection.across, word: "VAMANA", hint: "Fifth Avatar Of Vishnu", startRow: 6, startCol: 0),
      CrosswordWord(id: 4, direction: CrosswordDirection.down, word: "SAHARA", hint: "Largest Hot Desert In The World", startRow: 1, startCol: 3),
      CrosswordWord(id: 5, direction: CrosswordDirection.down, word: "NEBULA", hint: "Cloud Of Gas And Dust In Space", startRow: 0, startCol: 7),
      CrosswordWord(id: 6, direction: CrosswordDirection.down, word: "PETRA", hint: "Historic Rock-Cut City In Jordan", startRow: 4, startCol: 1),
      CrosswordWord(id: 7, direction: CrosswordDirection.down, word: "EXODUS", hint: "Mass Departure; Second Book Of The Bible", startRow: 8, startCol: 13),
    ],
  ),
];
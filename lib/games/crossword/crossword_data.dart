// lib/games/crossword/crossword_data.dart

import 'dart:math';

/// Represents the direction of a word in the crossword grid.
enum CrosswordDirection {
  across,
  down,
}

/// Represents a single word in the crossword puzzle.
///
/// This class is immutable to prevent accidental modification after creation.
class CrosswordWord {
  final int id;
  final CrosswordDirection direction;
  final String word;
  final String hint;
  final int startRow;
  final int startCol;

  const CrosswordWord({
    required this.id,
    required this.direction,
    required this.word,
    required this.hint,
    required this.startRow,
    required this.startCol,
  });

  /// Creates a new [CrosswordWord] instance by copying the existing one
  /// and replacing the given values.
  CrosswordWord copyWith({int? startRow, int? startCol}) {
    return CrosswordWord(
      id: id,
      direction: direction,
      word: word,
      hint: hint,
      startRow: startRow ?? this.startRow,
      startCol: startCol ?? this.startCol,
    );
  }
}

/// Represents a complete crossword puzzle.
///
/// This class takes a list of words and automatically calculates the required
/// grid size and normalizes word positions to ensure the puzzle fits neatly
/// within the grid, starting from a (0,0) origin.
class CrosswordPuzzle {
  final String title;
  final List<CrosswordWord> words;
  final int rows;
  final int cols;

  /// Private constructor for internal use by the factory.
  const CrosswordPuzzle._({
    required this.title,
    required this.words,
    required this.rows,
    required this.cols,
  });

  /// Creates a new [CrosswordPuzzle].
  ///
  /// This factory constructor processes the list of [CrosswordWord]s to
  /// normalize their starting positions and calculate the overall grid size.
  factory CrosswordPuzzle({
    required String title,
    required List<CrosswordWord> words,
  }) {
    if (words.isEmpty) {
      return CrosswordPuzzle._(title: title, words: const [], rows: 0, cols: 0);
    }

    // Find the minimum row and column to normalize coordinates to a (0,0) origin.
    final int minRow = words.map((w) => w.startRow).reduce(min);
    final int minCol = words.map((w) => w.startCol).reduce(min);

    // Create a new list of words with normalized coordinates.
    final normalizedWords = words
        .map((word) => word.copyWith(
              startRow: word.startRow - minRow,
              startCol: word.startCol - minCol,
            ))
        .toList();

    final int calculatedRows = _calculateRows(normalizedWords);
    final int calculatedCols = _calculateCols(normalizedWords);

    return CrosswordPuzzle._(
      title: title,
      words: normalizedWords,
      rows: calculatedRows,
      cols: calculatedCols,
    );
  }

  /// Calculates the total number of rows required for the grid.
  static int _calculateRows(List<CrosswordWord> words) {
    if (words.isEmpty) return 0;
    int maxRow = 0;
    for (final word in words) {
      final int endRow = word.direction == CrosswordDirection.down
          ? word.startRow + word.word.length
          : word.startRow + 1;
      maxRow = max(maxRow, endRow);
    }
    return maxRow;
  }

  /// Calculates the total number of columns required for the grid.
  static int _calculateCols(List<CrosswordWord> words) {
    if (words.isEmpty) return 0;
    int maxCol = 0;
    for (final word in words) {
      final int endCol = word.direction == CrosswordDirection.across
          ? word.startCol + word.word.length
          : word.startCol + 1;
      maxCol = max(maxCol, endCol);
    }
    return maxCol;
  }
}

/// A list containing all the crossword puzzles for the game.
final allCrosswordPuzzles = [
  // Level 1
  CrosswordPuzzle(
    title: "LEVEL 1",
    words: const [
      CrosswordWord(id: 1, direction: CrosswordDirection.across, word: "VOLCANO", hint: "Mountain That Erupts", startRow: 4, startCol: 6),
      CrosswordWord(id: 2, direction: CrosswordDirection.down, word: "AERODYNAMICS", hint: "Study Of Motion In Air", startRow: 1, startCol: 7),
      CrosswordWord(id: 3, direction: CrosswordDirection.across, word: "NOAH", hint: "Biblical Ark Builder", startRow: 7, startCol: 7),
      CrosswordWord(id: 4, direction: CrosswordDirection.across, word: "NILE", hint: "Longest River In Africa", startRow: 2, startCol: 4),
      CrosswordWord(id: 5, direction: CrosswordDirection.across, word: "SHIVA", hint: "Hindu Deity Of Destruction", startRow: 0, startCol: 0),
      CrosswordWord(id: 6, direction: CrosswordDirection.down, word: "ARNOLD", hint: "Famous Bodybuilder And Actor", startRow: 0, startCol: 4),
      CrosswordWord(id: 7, direction: CrosswordDirection.across, word: "JUPITER", hint: "Largest Planet In The Solar System", startRow: 10, startCol: 4),
    ],
  ),
  // Level 2
  CrosswordPuzzle(
    title: "LEVEL 2",
    words: const [
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
    words: const [
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
    words: const [
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
    words: const [
      CrosswordWord(id: 1, direction: CrosswordDirection.across, word: "SHAKESPEARE", hint: "Famous English Playwright", startRow: 8, startCol: 3),
      CrosswordWord(id: 2, direction: CrosswordDirection.across, word: "PLATO", hint: "Greek Philosopher, Student Of Socrates", startRow: 4, startCol: 1),
      CrosswordWord(id: 3, direction: CrosswordDirection.across, word: "VAMANA", hint: "Fifth Avatar Of Vishnu", startRow: 6, startCol: 0),
      CrosswordWord(id: 4, direction: CrosswordDirection.down, word: "SAHARA", hint: "Largest Hot Desert In The World", startRow: 1, startCol: 3),
      CrosswordWord(id: 5, direction: CrosswordDirection.down, word: "NEBULA", hint: "Cloud Of Gas And Dust In Space", startRow: 0, startCol: 7),
      CrosswordWord(id: 6, direction: CrosswordDirection.down, word: "PETRA", hint: "Historic Rock-Cut City In Jordan", startRow: 4, startCol: 1),
      CrosswordWord(id: 7, direction: CrosswordDirection.down, word: "EXODUS", hint: "Mass Departure; Second Book Of The Bible", startRow: 8, startCol: 13),
    ],
  ),
  // Level 6
  CrosswordPuzzle(
    title: "LEVEL 6",
    words: const [
      CrosswordWord(id: 1, direction: CrosswordDirection.across, word: "LUFFY", hint: "Rubber pirate aiming for the One Piece", startRow: 0, startCol: 2),
      CrosswordWord(id: 2, direction: CrosswordDirection.down, word: "UZUMAKI", hint: "Spiraling surname of a hyperactive ninja", startRow: 0, startCol: 3),
      CrosswordWord(id: 3, direction: CrosswordDirection.across, word: "HAKU", hint: "Masked shinobi with a tragic winter tale", startRow: 2, startCol: 0),
      CrosswordWord(id: 4, direction: CrosswordDirection.across, word: "AKENO", hint: "Thunder priestess with a sadistic smile", startRow: 4, startCol: 3),
      CrosswordWord(id: 5, direction: CrosswordDirection.across, word: "MIKASA", hint: "Silent protector of a boy who won't stay dead", startRow: 6, startCol: 2),
      CrosswordWord(id: 6, direction: CrosswordDirection.across, word: "KRILLIN", hint: "He dies a lot, but still packs a Destructo Disc", startRow: 8, startCol: 1),
      CrosswordWord(id: 7, direction: CrosswordDirection.down, word: "ANNIE", hint: "Titan kicker who breaks out of her crystal shell", startRow: 6, startCol: 7),
      CrosswordWord(id: 8, direction: CrosswordDirection.across, word: "DENDE", hint: "Namekian healer turned Earth's guardian", startRow: 10, startCol: 3),
    ],
  ),
  // Level 7
  CrosswordPuzzle(
    title: "LEVEL 7",
    words: const [
      CrosswordWord(id: 1, direction: CrosswordDirection.across, word: "NATAGUMO", hint: "Mountain where demon spiders lurk (Demon Slayer)", startRow: 1, startCol: 2),
      CrosswordWord(id: 2, direction: CrosswordDirection.across, word: "KAKASHI", hint: "Copy Ninja with a masked face and a thousand techniques", startRow: 4, startCol: 0),
      CrosswordWord(id: 3, direction: CrosswordDirection.across, word: "OGAMI", hint: "Father and assassin in 'Lone Wolf and Cub'", startRow: 6, startCol: 0),
      CrosswordWord(id: 4, direction: CrosswordDirection.across, word: "MARINEFORD", hint: "The place where Whitebeard shook the world", startRow: 8, startCol: 6),
      CrosswordWord(id: 5, direction: CrosswordDirection.across, word: "NAGATO", hint: "Holder of Rinnegan who led the Akatsuki's first assault", startRow: 12, startCol: 7),
      CrosswordWord(id: 6, direction: CrosswordDirection.down, word: "YUJI", hint: "Sukuna’s vessel with a kind heart and iron fists", startRow: 0, startCol: 7),
      CrosswordWord(id: 7, direction: CrosswordDirection.down, word: "GOINGMERRY", hint: "The ship that cried when it burned", startRow: 0, startCol: 9),
      CrosswordWord(id: 8, direction: CrosswordDirection.down, word: "ASTA", hint: "Magicless boy with anti-magic swords", startRow: 1, startCol: 3),
      CrosswordWord(id: 9, direction: CrosswordDirection.down, word: "JIN", hint: "Father of Gon who left behind a Hunter legacy", startRow: 2, startCol: 7),
      CrosswordWord(id: 10, direction: CrosswordDirection.down, word: "KYOJURO", hint: "Flame Hashira who said, 'Your flame will not go out'", startRow: 4, startCol: 0),
      CrosswordWord(id: 11, direction: CrosswordDirection.down, word: "ROBIN", hint: "Archaeologist searching for the Rio Poneglyph", startRow: 4, startCol: 11),
      CrosswordWord(id: 12, direction: CrosswordDirection.down, word: "MYOBOKU", hint: "Frog-filled place where Sage Mode was mastered", startRow: 4, startCol: 14),
      CrosswordWord(id: 13, direction: CrosswordDirection.down, word: "RYOMEN", hint: "The real name of the King of Curses", startRow: 9, startCol: 0),
      CrosswordWord(id: 14, direction: CrosswordDirection.down, word: "MUZAN", hint: "The demon progenitor who fears the sun", startRow: 8, startCol: 7),
    ],
  ),
  // Level 8
  CrosswordPuzzle(
    title: "LEVEL 8",
    words: const [
      CrosswordWord(id: 1, direction: CrosswordDirection.across, word: "SANJI", hint: "Chivalrous chef with deadly legs and a love for ladies (One Piece)", startRow: 2, startCol: 6),
      CrosswordWord(id: 2, direction: CrosswordDirection.across, word: "ROME", hint: "Once the heart of an empire, now a city of ruins and romance", startRow: 5, startCol: 3),
      CrosswordWord(id: 3, direction: CrosswordDirection.across, word: "ALIEN", hint: "Visitor from distant stars — sometimes hostile, sometimes curious", startRow: 5, startCol: 10),
      CrosswordWord(id: 4, direction: CrosswordDirection.across, word: "HELIOSPHERE", hint: "Bubble-like region protecting the solar system from interstellar winds", startRow: 8, startCol: 0),
      CrosswordWord(id: 5, direction: CrosswordDirection.across, word: "HAIKU", hint: "Three-line poem, five-seven-five syllables, born in Japan", startRow: 10, startCol: 3),
      CrosswordWord(id: 6, direction: CrosswordDirection.down, word: "SASUKE", hint: "Uchiha survivor fueled by revenge and lightning", startRow: 0, startCol: 6),
      CrosswordWord(id: 7, direction: CrosswordDirection.down, word: "JEREMIAH", hint: "Code Geass loyalist known as 'Orange' with cybernetic loyalty", startRow: 3, startCol: 3),
      CrosswordWord(id: 8, direction: CrosswordDirection.down, word: "VISHNU", hint: "The preserver deity in Hindu mythology, part of the cosmic trio", startRow: 5, startCol: 0),
    ],
  ),
  // Level 9
  CrosswordPuzzle(
    title: "LEVEL 9",
    words: const [
      CrosswordWord(id: 1, direction: CrosswordDirection.across, word: "MANGA", hint: "Where ink meets imagination — a staple of Japanese pop culture", startRow: 0, startCol: 3),
      CrosswordWord(id: 2, direction: CrosswordDirection.across, word: "ARMAGEDDON", hint: "Not just doomsday — also a Bruce Willis movie", startRow: 2, startCol: 0),
      CrosswordWord(id: 3, direction: CrosswordDirection.down, word: "ARCHIMEDES", hint: "\"Eureka!\" — this genius bathed in physics", startRow: 2, startCol: 0),
      CrosswordWord(id: 4, direction: CrosswordDirection.across, word: "MANALI", hint: "A snowy Himalayan escape popular with backpackers", startRow: 2, startCol: 2),
      CrosswordWord(id: 5, direction: CrosswordDirection.across, word: "NIRVANA", hint: "Spiritual bliss or 90s grunge band — your pick", startRow: 2, startCol: 9),
      CrosswordWord(id: 6, direction: CrosswordDirection.across, word: "PELE", hint: "The King of Football from Brazil", startRow: 3, startCol: 13),
      CrosswordWord(id: 7, direction: CrosswordDirection.across, word: "BALI", hint: "Island known for beaches and temples, not baloney", startRow: 4, startCol: 11),
      CrosswordWord(id: 8, direction: CrosswordDirection.across, word: "VERSAILLES", hint: "Lavish French palace symbolizing royal extravagance", startRow: 6, startCol: 5),
      CrosswordWord(id: 9, direction: CrosswordDirection.across, word: "YOGA", hint: "Spiritual stretching with global reach", startRow: 8, startCol: 6),
      CrosswordWord(id: 10, direction: CrosswordDirection.across, word: "GOA", hint: "Beach paradise on India's west coast", startRow: 8, startCol: 12),
      CrosswordWord(id: 11, direction: CrosswordDirection.across, word: "DENJI", hint: "Chainsaw-wielding protagonist of a bloody anime", startRow: 9, startCol: 0),
      CrosswordWord(id: 12, direction: CrosswordDirection.across, word: "FARADAY", hint: "Pioneer of electromagnetism, and not just a cage name", startRow: 11, startCol: 9),
      CrosswordWord(id: 13, direction: CrosswordDirection.across, word: "SPARTA", hint: "\"THIS IS...\" a historic warrior state", startRow: 6, startCol: 14),
      CrosswordWord(id: 14, direction: CrosswordDirection.across, word: "OMAN", hint: "Arabian nation with rugged mountains and coastlines", startRow: 8, startCol: 7),
    ],
  ),
  // Level 10
  CrosswordPuzzle(
    title: "Legends & Cosmos",
    words: const [
      CrosswordWord(id: 1, direction: CrosswordDirection.down, word: "PYTHAGORAS", hint: "Ancient mathematician known for a famous theorem.", startRow: 0, startCol: 9),
      CrosswordWord(id: 2, direction: CrosswordDirection.across, word: "BABYLON", hint: "Ancient city with hanging gardens.", startRow: 1, startCol: 6),
      CrosswordWord(id: 3, direction: CrosswordDirection.down, word: "BOLLYWOOD", hint: "Indian film industry based in Mumbai.", startRow: 1, startCol: 6),
      CrosswordWord(id: 4, direction: CrosswordDirection.down, word: "HIMALAYAS", hint: "The world’s highest mountain range.", startRow: 3, startCol: 9),
      CrosswordWord(id: 5, direction: CrosswordDirection.across, word: "GRAVITY", hint: "Invisible force that keeps us grounded.", startRow: 5, startCol: 0),
      CrosswordWord(id: 6, direction: CrosswordDirection.across, word: "GENESIS", hint: "First book of the Bible; also means origin.", startRow: 5, startCol: 9),
      CrosswordWord(id: 7, direction: CrosswordDirection.across, word: "BARYON", hint: "A heavy subatomic particle like a proton or neutron.", startRow: 8, startCol: 2),
      CrosswordWord(id: 8, direction: CrosswordDirection.across, word: "SHAKUNI", hint: "Scheming uncle in the Mahabharata.", startRow: 9, startCol: 9),
    ],
  ),
];

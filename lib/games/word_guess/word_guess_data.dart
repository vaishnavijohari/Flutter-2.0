// lib/games/word_guess/word_guess_data.dart

class WordGuessLevel {
  final String word;
  final String hint;
  final List<String>? keyboardLetters; // <-- NEW: Optional custom keyboard

  WordGuessLevel({
    required this.word,
    required this.hint,
    this.keyboardLetters, // <-- ADDED to constructor
  });
}

// A list of 50 levels for the game
final wordGuessLevels = [
  // --- Example of a custom keyboard with 10 letters ---
  WordGuessLevel(
    word: "FLUTTER",
    hint: "A popular UI toolkit",
    keyboardLetters: ["F", "L", "U", "T", "E", "R", "A", "B", "C", "D"],
  ),
  // --- Example of a custom keyboard with only 5 letters (harder) ---
  WordGuessLevel(
    word: "DART",
    hint: "The language of Flutter",
    keyboardLetters: ["D", "A", "R", "T", "S"],
  ),
  // --- Example of a custom keyboard with 13 letters (easier) ---
  WordGuessLevel(
    word: "WIDGET",
    hint: "Everything in Flutter is a...",
    keyboardLetters: ["W", "X", "Y", "G", "O", "T", "I", "D", "Z", "M", "N", "E", "P"],
  ),
  // --- This level will fall back to the default 8 auto-generated letters ---
  WordGuessLevel(
    word: "ANDROID", 
    hint: "A mobile operating system",
    keyboardLetters: ["W", "P", "C", "I", "D", "G", "E", "T", "A", "Y", "Z", "M", "N", "O", "R"],
  ),

  WordGuessLevel(word: "APPLE", hint: "A fruit and a tech company"),
  WordGuessLevel(word: "NOVEL", hint: "A long work of narrative fiction"),
  WordGuessLevel(word: "STORY", hint: "An account of imaginary or real people"),
  WordGuessLevel(word: "CRYPTO", hint: "Digital or virtual currency"),
  WordGuessLevel(word: "BITCOIN", hint: "The first decentralized cryptocurrency"),
  WordGuessLevel(word: "ETHEREUM", hint: "A platform for decentralized apps"),
  WordGuessLevel(word: "GAME", hint: "An activity for amusement"),
  WordGuessLevel(word: "PLAYER", hint: "A person taking part in a game"),
  WordGuessLevel(word: "LEVEL", hint: "A stage in a game"),
  WordGuessLevel(word: "SCREEN", hint: "A flat panel for display"),
  WordGuessLevel(word: "MOBILE", hint: "Relating to cell phones"),
  WordGuessLevel(word: "DESIGN", hint: "A plan or drawing produced to show the look"),
  WordGuessLevel(word: "THEME", hint: "A particular setting or style"),
  WordGuessLevel(word: "LIGHT", hint: "The natural agent that stimulates sight"),
  WordGuessLevel(word: "DARK", hint: "With little or no light"),
  WordGuessLevel(word: "CODE", hint: "A system of words, letters, or figures"),
  WordGuessLevel(word: "DEBUG", hint: "Identify and remove errors from"),
  WordGuessLevel(word: "PROJECT", hint: "An individual or collaborative enterprise"),
  WordGuessLevel(word: "VERSION", hint: "A particular form of something"),
  WordGuessLevel(word: "UPDATE", hint: "Make something more modern"),
  WordGuessLevel(word: "PROFILE", hint: "An outline of something"),
  WordGuessLevel(word: "LOGIN", hint: "Gain access to a computer system"),
  WordGuessLevel(word: "SECURE", hint: "Protected against unauthorized access"),
  WordGuessLevel(word: "BUTTON", hint: "A small disk or knob"),
  WordGuessLevel(word: "ICON", hint: "A pictorial representation of something"),
  WordGuessLevel(word: "ANIMATION", hint: "The technique of making inanimate objects appear to move"),
  WordGuessLevel(word: "CHAPTER", hint: "A main division of a book"),
  WordGuessLevel(word: "AUTHOR", hint: "A writer of a book, article, or report"),
  WordGuessLevel(word: "GENRE", hint: "A style or category of art, music, or literature"),
  WordGuessLevel(word: "FANTASY", hint: "A genre of imaginative fiction"),
  WordGuessLevel(word: "ACTION", hint: "The fact or process of doing something"),
  WordGuessLevel(word: "ADVENTURE", hint: "An unusual and exciting experience"),
  WordGuessLevel(word: "FINANCE", hint: "The management of large amounts of money"),
  WordGuessLevel(word: "MONEY", hint: "A current medium of exchange"),
  WordGuessLevel(word: "WALLET", hint: "A pocket-sized, flat, folding holder for money"),
  WordGuessLevel(word: "MARKET", hint: "A regular gathering of people for the purchase and sale of provisions"),
  WordGuessLevel(word: "PLANET", hint: "A celestial body moving in an elliptical orbit"),
  WordGuessLevel(word: "EARTH", hint: "The planet on which we live"),
  WordGuessLevel(word: "SPACE", hint: "A continuous area or expanse which is free"),
  WordGuessLevel(word: "GALAXY", hint: "A system of millions or billions of stars"),
  WordGuessLevel(word: "STAR", hint: "A fixed luminous point in the night sky"),
  WordGuessLevel(word: "OCEAN", hint: "A very large expanse of sea"),
  WordGuessLevel(word: "RIVER", hint: "A large natural stream of water"),
  WordGuessLevel(word: "MOUNTAIN", hint: "A large natural elevation of the earth's surface"),
  WordGuessLevel(word: "FOREST", hint: "A large area covered chiefly with trees"),
  WordGuessLevel(word: "DESERT", hint: "A barren or desolate area"),
];

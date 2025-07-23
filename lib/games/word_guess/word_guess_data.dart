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
    word: "GOKU",
    hint: "An alien SAIYAN raised on Earth who constantly seeks to become the strongest fighter",
    keyboardLetters: ["K", "F", "G", "T", "E", "O", "A", "B", "C", "U", "R", "Q"],
  ),
  // --- Example of a custom keyboard with only 5 letters (harder) ---
  WordGuessLevel(
    word: "DART",
    hint: "The language of Flutter",
    keyboardLetters: ["P", "A", "Y", "T", "N", "D", "Q", "R", "O", "M"],
  ),
  // --- Example of a custom keyboard with 13 letters (easier) ---
  WordGuessLevel(
    word: "NARUTO",
    hint: "A young ninja who dreams of becoming the leader of his village",
    keyboardLetters: ["D", "A", "F", "Z", "T", "M", "R", "X", "B", "L", "N", "E", "I", "S", "O", "Q", "P", "U"],
  ),
  // --- This level will fall back to the default 8 auto-generated letters ---
  WordGuessLevel(
    word: "ANDROID", 
    hint: "A mobile operating system",
    keyboardLetters: ["W", "P", "C", "I", "D", "G", "E", "L", "T", "A", "Y", "Z", "M", "N", "O", "R"],
  ),

  WordGuessLevel(
    word: "APPLE", 
    hint: "A fruit and a tech company", 
    keyboardLetters: ["W", "P", "Q", "I", "D", "G", "E", "L", "T", "A", "Y", "Z", "M", "N"],
  ),

  WordGuessLevel(
    word: "NOVEL", 
    hint: "A long work of narrative fiction", 
    keyboardLetters: ["P", "I", "V", "J", "T", "E", "S", "L", "B", "M", "O", "A", "C", "N", "Y", "F"],
  ),

  WordGuessLevel(
    word: "BETHLEHEM", 
    hint: "The small town in Judea identified as the birthplace of Jesus", 
    keyboardLetters: ["H", "D", "B", "Y", "T", "X", "E", "Z", "Q", "A", "L", "S", "R", "P", "M", "V"],
  ),

  WordGuessLevel(
    word: "CRYPTO", 
    hint: "Digital or virtual currency", 
    keyboardLetters: ["R", "S", "D", "C", "Q", "X", "B", "M", "Y", "N", "O", "I", "T", "U", "P", "W"],
  ),

  WordGuessLevel(
    word: "KERALA", 
    hint: "Known as Gods Own Country, this Indian state is famous for its backwaters", 
    keyboardLetters: ["A", "W", "K", "S", "R", "D", "C", "E", "I", "U", "P", "L"],
  ),

  WordGuessLevel(
    word: "VENICE", 
    hint: "The Italian City of Canals where gondolas replace cars", 
    keyboardLetters: ["E", "O", "Y", "L", "N", "T", "X", "I", "Z", "M", "V", "B", "W", "Q", "C", "A"],
  ),

  WordGuessLevel(
    word: "SPIELBERG", 
    hint: "The iconic director behind Jaws, E.T., and Jurassic Park", 
    keyboardLetters: ["I", "H", "G", "P", "J", "X", "S", "D", "B", "Y", "E", "T", "K", "L", "N", "M", "R", "Z", "G", "Q"],
  ),

  WordGuessLevel(
    word: "PLAYER", 
    hint: "A person taking part in a game", 
    keyboardLetters: ["Y", "V", "E", "P", "S", "N", "L", "C", "A", "M", "O", "I", "H", "G", "R", "T"],
  ),

  WordGuessLevel(
    word: "BLACKHOLE", 
    hint: "A region of spacetime where gravity is so strong that nothing, not even light, can escape", 
    keyboardLetters: ["A", "B", "E", "O", "D", "S", "C", "T", "L", "V", "H", "F", "I", "M", "K", "N", "X", "Q", "U"],
  ),

  WordGuessLevel(
    word: "ORIGAMI", 
    hint: "The Japanese art of paper folding", 
    keyboardLetters: ["H", "M", "B", "J", "L", "I", "W", "E", "G", "S", "D", "A", "R", "K", "P", "O"],
  ),

  WordGuessLevel(
    word: "ONEPIECE",
    hint: "A sprawling anime adventure about a boy made of rubber searching for the ultimate treasure",
    keyboardLetters: ["C", "O", "B", "I", "V", "E", "Q", "P", "K", "X", "A", "U", "L", "Z", "N", "T"],
  ),

  WordGuessLevel(
    word: "AYODHYA",
    hint: "The ancient Indian city believed to be the birthplace of Lord Rama",
    keyboardLetters: ["D", "F", "A", "J", "Y", "K", "P", "S", "H", "M", "L", "N", "O", "R", "T", "U"],
  ),

  WordGuessLevel(
    word: "ZIDANE",
    hint: "French football legend famous for his elegance, vision, and a notorious headbutt",
    keyboardLetters: ["Z", "L", "B", "M", "C", "T", "S", "D", "U", "A", "Q", "I", "O", "E", "N", "K"],
  ),

  WordGuessLevel(
    word: "HANUMAN",
    hint: "The mighty ape-god who could change his form at will and lift mountains",
    keyboardLetters: ["P", "V", "U", "X", "S", "H", "D", "T", "M", "Q", "A", "K", "Y", "N", "L", "R"],
  ),

  WordGuessLevel(
    word: "MARIECURIE",
    hint: "A pioneering physicist and chemist who conducted groundbreaking research on radioactivity",
    keyboardLetters: ["R", "A", "O", "L", "U", "E", "X", "M", "S", "T", "B", "I", "Q", "C", "Y", "N"],
  ),

  WordGuessLevel(
    word: "DEMONSLAYER",
    hint: "An anime about a boy who joins a secret corps to hunt demons after his family is slaughtered",
    keyboardLetters: ["D", "L", "V", "M", "N", "E", "K", "O", "S", "G", "A", "R", "Y", "T", "J", "U"],
  ),

  WordGuessLevel(
    word: "KEANUREEVES",
    hint: "Known for playing Neo in The Matrix and the titular assassin in John Wick",
    keyboardLetters: ["E", "V", "R", "K", "C", "N", "U", "Z", "S", "B", "A", "O", "L", "Y", "J", "X"],
  ),

  WordGuessLevel(
    word: "UTOPIA",
    hint: "An imagined place or state of things in which everything is perfect",
    keyboardLetters: ["U", "G", "B", "X", "C", "T", "O", "Y", "Q", "A", "I", "M", "K", "P", "L", "D"],
  ),

  WordGuessLevel(
    word: "THEGODFATHER",
    hint: "A crime film epic about the head of a powerful Italian-American crime family",
    keyboardLetters: ["H", "R", "O", "T", "J", "F", "E", "L", "A", "G", "B", "C", "D", "K", "N", "H"],
  ),

  WordGuessLevel(
    word: "PARADOX",
    hint: "A seemingly absurd or self-contradictory statement that when investigated may prove to be well founded or true",
    keyboardLetters: ["X", "A", "F", "R", "C", "Q", "Z", "M", "P", "O", "S", "B", "L", "Y", "D", "K"],
  ),

  WordGuessLevel(
    word: "LEVI",
    hint: "Humanity's strongest soldier in the fight against Titans",
    keyboardLetters: ["L", "V", "Z", "E", "I", "N", "C", "M", "A", "T", "S", "O", "K", "D", "Y", "B"],
  ),

  WordGuessLevel(
    word: "DALAILAMA",
    hint: "The spiritual leader of Tibetan Buddhism, believed to be a reincarnation",
    keyboardLetters: ["M", "A", "D", "K", "I", "L", "P", "F", "S", "Q", "O", "U", "X", "B", "E", "Y"],
  ),

  WordGuessLevel(
    word: "SHINKANSEN",
    hint: "Japan's high-speed bullet train network",
    keyboardLetters: ["S", "K", "H", "B", "N", "I", "C", "E", "A", "T", "Y", "X", "L", "R", "D", "M"],
  ),

  WordGuessLevel(
    word: "INTERSTELLAR",
    hint: "A film where humanity searches for a new home through a wormhole near Saturn",
    keyboardLetters: ["T", "S", "E", "A", "I", "L", "N", "B", "R", "M", "C", "X", "D", "G", "O", "U"],
  ),

  WordGuessLevel(
    word: "ANGELINAJOLIE",
    hint: "Famous for playing Lara Croft and the dark fairy Maleficent",
    keyboardLetters: ["G", "N", "L", "J", "O", "X", "B", "I", "E", "C", "K", "A", "M", "U", "R", "D"],
  ),

  WordGuessLevel(
    word: "VEGETA",
    hint: "The proud prince of the Saiyans and eternal rival to Goku",
    keyboardLetters: ["V", "E", "G", "A", "T", "L", "B", "Y", "C", "S", "I", "N", "U", "P", "O", "H"],
  ),

  WordGuessLevel(
    word: "MARADONA",
    hint: "Argentinian football icon famous for the Hand of God goal",
    keyboardLetters: ["M", "A", "R", "O", "N", "D", "K", "L", "X", "B", "T", "Q", "S", "I", "G", "H"],
  ),

  WordGuessLevel(
    word: "CRUCIFIXION",
    hint: "The method of execution used on Jesus Christ at Calvary",
    keyboardLetters: ["C", "F", "I", "O", "B", "U", "X", "L", "G", "N", "T", "K", "R", "W", "Y", "D"],
  ),

  WordGuessLevel(
    word: "CHERNOBYL",
    hint: "A ghost city in Ukraine, frozen in 1986 due to a catastrophic nuclear accident",
    keyboardLetters: ["C", "H", "Y", "L", "E", "B", "N", "X", "T", "D", "U", "M", "O", "R", "S", "K"],
  ),

  WordGuessLevel(
    word: "ASHOKA",
    hint: "An Indian emperor of the Maurya Dynasty who converted to Buddhism and fought the battle of Kalinga after that.",
    keyboardLetters: ["A", "S", "K", "O", "H", "L", "G", "Y", "T", "N", "C", "V", "P", "I", "E", "D"],
  ),

  WordGuessLevel(
    word: "YOURNAME",
    hint: "An anime film about a boy and a girl who mysteriously swap bodies",
    keyboardLetters: ["Y", "A", "T", "C", "B", "O", "N", "X", "R", "Q", "L", "U", "M", "E", "I", "D"],
  ),

  WordGuessLevel(
    word: "ROGERFEDERER",
    hint: "Swiss tennis maestro known for his graceful style and numerous Grand Slam titles",
    keyboardLetters: ["R", "D", "E", "G", "X", "F", "P", "L", "B", "O", "J", "M", "Y", "C", "U", "N"],
  ),

  WordGuessLevel(
    word: "JODHPUR",
    hint: "The Blue City in the Thar Desert of Rajasthan, India",
    keyboardLetters: ["J", "H", "A", "O", "P", "K", "U", "Q", "R", "L", "N", "M", "X", "D", "C", "T"],
  ),

  WordGuessLevel(
    word: "LEONARDODICAPRIO",
    hint: "Famously fought a bear to win his first Oscar for The Revenant",
    keyboardLetters: ["L", "A", "X", "O", "N", "D", "P", "I", "C", "B", "Y", "E", "R", "G", "M", "U"],
  ),

  WordGuessLevel(
    word: "AKIRA",
    hint: "A landmark 1988 anime film set in a dystopian Neo-Tokyo, known for its stunning animation",
    keyboardLetters: ["A", "X", "G", "K", "R", "M", "O", "I", "S", "T", "U", "D", "P", "N", "C", "E"],
  ),

  WordGuessLevel(
    word: "SUPERNOVA",
    hint: "The explosive death of a massive star",
    keyboardLetters: ["V", "A", "P", "S", "U", "L", "C", "R", "G", "B", "N", "E", "K", "X", "I", "O"],
  ),

  WordGuessLevel(
    word: "ESPIONAGE",
    hint: "The practice of spying or of using spies, typically by governments to obtain political and military information",
    keyboardLetters: ["S", "P", "I", "B", "A", "Q", "E", "O", "M", "L", "N", "G", "U", "X", "C", "Y"],
  ),

  WordGuessLevel(
    word: "HIEROGLYPHS",
    hint: "The ancient Egyptian writing system using pictures and symbols",
    keyboardLetters: ["G", "H", "B", "S", "R", "K", "O", "M", "L", "P", "Y", "C", "X", "E", "I", "T"],
  ),

  WordGuessLevel(
    word: "KURUKSHETRA",
    hint: "The battlefield where the epic war of the Mahabharata was fought",
    keyboardLetters: ["K", "H", "E", "T", "Y", "S", "L", "B", "C", "R", "U", "X", "A", "O", "M", "N"],
  ),

  WordGuessLevel(
    word: "ZENDAYA",
    hint: "A modern Hollywood star known for her roles in Spider-Man and the series Euphoria",
    keyboardLetters: ["Z", "E", "D", "A", "L", "N", "K", "Y", "P", "T", "C", "M", "Q", "I", "R", "B"],
  ),

  WordGuessLevel(
    word: "ERENYEAGER",
    hint: "The protagonist of Attack on Titan who holds a deep-seated hatred for the giant humanoids",
    keyboardLetters: ["R", "E", "Y", "G", "T", "A", "C", "M", "O", "B", "X", "U", "N", "Q", "L", "N"],
  ),

  WordGuessLevel(
    word: "LIGHTYAGAMI",
    hint: "A brilliant high school student who finds a notebook that can kill anyone whose name is written inside",
    keyboardLetters: ["G", "A", "L", "K", "T", "M", "Y", "H", "B", "I", "X", "O", "U", "C", "N", "D"],
  ),

  WordGuessLevel(
    word: "PETRA",
    hint: "The Rose City of Jordan, famous for its treasury carved directly into rock",
    keyboardLetters: ["P", "T", "B", "R", "E", "O", "K", "X", "M", "C", "Y", "U", "I", "N", "S", "D"],
  ),

  WordGuessLevel(
    word: "SAMSON",
    hint: "A biblical hero whose immense strength came from his uncut hair",
    keyboardLetters: ["S", "A", "M", "O", "N", "C", "B", "E", "X", "I", "T", "L", "Y", "H", "R", "U"],
  ),

  WordGuessLevel(
    word: "MEMENTO",
    hint: "A Christopher Nolan film told in reverse, about a man who cannot form new memories",
    keyboardLetters: ["E", "M", "T", "B", "Q", "Y", "C", "X", "O", "N", "R", "A", "G", "L", "U", "S"],
  ),

  WordGuessLevel(
    word: "VISHWAMITRA",
    hint: "A great sage who was once a king and became a revered Brahmin through penance",
    keyboardLetters: ["V", "I", "S", "H", "W", "A", "M", "T", "R", "B", "C", "Y", "L", "N", "O", "D"],
  ),

];

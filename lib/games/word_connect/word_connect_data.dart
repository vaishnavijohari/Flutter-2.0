// lib/games/word_connect/word_connect_data.dart

class WordConnectLevel {
  /// The letters to be displayed in the circle, in order.
  final String letters;
  
  /// A set of all valid words that can be formed. Using a Set for fast lookups.
  final Set<String> solutions;

  WordConnectLevel({
    required this.letters,
    required this.solutions,
  });
}

final wordConnectLevels = [
  // --- 4-Letter Puzzles (6 solutions each) ---
  WordConnectLevel(letters: "SOMA", solutions: {"SAM", "MAS", "OAS", "SOMA", "AMOS", "ROMA"}), // Mythology: SOMA, Place: ROMA
  WordConnectLevel(letters: "VEDA", solutions: {"AVE", "DEV", "EVE", "VADE", "VEDA", "DAVE"}), // Mythology: VEDA, General
  WordConnectLevel(letters: "MARS", solutions: {"ARM", "RAM", "MAR", "RAS", "MARS", "ASURA"}), // Science: MARS, Mythology: ASURA
  WordConnectLevel(letters: "YAMA", solutions: {"YAM", "MAY", "MYA", "MAYA", "YAMA", "ARMY"}), // Mythology: YAMA, MAYA
  WordConnectLevel(letters: "NILE", solutions: {"LIE", "NIL", "LINE", "LIEN", "NILE", "INDRA"}), // Place: NILE, Mythology: INDRA
  WordConnectLevel(letters: "LOKI", solutions: {"OIL", "LOK", "KILO", "COIL", "LOKI", "KALI"}), // Mythology: LOKI, KALI
  WordConnectLevel(letters: "DEVA", solutions: {"DEV", "AVE", "VADE", "DAVE", "DEVA", "DAEVA"}), // Mythology: DEVA, DAEVA
  WordConnectLevel(letters: "BALI", solutions: {"AIL", "LAB", "LIB", "BAIL", "BALI", "ALIB"}), // Mythology: BALI, Place: BALI
  WordConnectLevel(letters: "RAJA", solutions: {"RAJ", "JAR", "JAVA", "RAJA", "JARA", "AJAR"}), // Mythology: RAJA, Place: JAVA
  WordConnectLevel(letters: "NAGA", solutions: {"NAG", "GAN", "ANA", "GAGA", "NAGA", "MANGA"}), // Mythology: NAGA, Anime: MANGA

  // --- 5-Letter Puzzles (7 solutions each) ---
  WordConnectLevel(letters: "SURYA", solutions: {"SAY", "RAY", "RYS", "USA", "YOURS", "SURYA", "ASURA"}), // Mythology: SURYA, ASURA
  WordConnectLevel(letters: "INDRA", solutions: {"RAN", "RID", "DIN", "RAIN", "IRAN", "INDRA", "RADIO"}), // Mythology: INDRA, Technology: RADIO
  WordConnectLevel(letters: "AGNI", solutions: {"GIN", "NAG", "AIN", "GAIN", "GIANT", "AGNI", "ATING"}), // Mythology: AGNI, General
  WordConnectLevel(letters: "VAYU", solutions: {"YAY", "YOU", "YUVA", "VAYU", "YOGA", "YUG", "GUY"}), // Mythology: VAYU, YUGA
  WordConnectLevel(letters: "ASURA", solutions: {"SUE", "SEA", "ARE", "EAR", "RUSE", "SURE", "ASURA"}), // Mythology: ASURA, General
  WordConnectLevel(letters: "GARUD", solutions: {"RUG", "RAD", "DRAG", "GUARD", "DRUID", "GARUDA", "DRUG"}), // Mythology: GARUDA, General
  WordConnectLevel(letters: "LANKA", solutions: {"LANK", "LANA", "ANAL", "ALAN", "LANKA", "NALA", "JAPAN"}), // Mythology: LANKA, Place: JAPAN
  WordConnectLevel(letters: "RAMAY", solutions: {"RAM", "RAY", "MAY", "YAM", "ARMY", "MARY", "RAMAYANA"}), // Mythology: RAMAYANA, General
  WordConnectLevel(letters: "SITA", solutions: {"SAT", "SIT", "ITS", "SATAY", "STAY", "SITA", "SAINT"}), // Mythology: SITA, General
  WordConnectLevel(letters: "MANU", solutions: {"MAN", "NAM", "MUM", "MANA", "MAUI", "MANU", "ANIME"}), // Mythology: MANU, MANA, Anime: ANIME
  WordConnectLevel(letters: "GITA", solutions: {"GIT", "TAG", "AIT", "GAIN", "GIANT", "GITA", "ATING"}), // Mythology: GITA, General
  WordConnectLevel(letters: "NALA", solutions: {"NAL", "ANA", "ALAN", "LANA", "NALA", "NAAN", "ANAL"}), // Mythology: NALA, General
  WordConnectLevel(letters: "VALI", solutions: {"AIL", "VIA", "VAIL", "VIAL", "LAIR", "VALI", "LIRA"}), // Mythology: VALI, Currency: LIRA
  WordConnectLevel(letters: "MAYA", solutions: {"MAY", "YAM", "MYA", "AMY", "MAYA", "YAMA", "MAYO"}), // Mythology: MAYA, YAMA
  WordConnectLevel(letters: "PUMA", solutions: {"PUMA", "MAP", "AMP", "PAM", "UMP", "PRAM", "PURANA"}), // Brand: PUMA, Mythology: PURANA

  // --- 6-Letter Puzzles (8 solutions each) ---
  WordConnectLevel(letters: "VARUNA", solutions: {"RUN", "URN", "VAN", "AURA", "RAUN", "VARUNA", "URANUS", "RUANA"}), // Mythology: VARUNA, Science: URANUS
  WordConnectLevel(letters: "KUBERA", solutions: {"ARE", "BAR", "BRA", "BEAR", "BARE", "BRAE", "KUBERA", "BAKER"}), // Mythology: KUBERA, General
  WordConnectLevel(letters: "MOHINI", solutions: {"HIM", "HEN", "ION", "HOME", "OMEN", "MINE", "MOHINI", "HOMIE"}), // Mythology: MOHINI, General
  WordConnectLevel(letters: "JATAYU", solutions: {"JAY", "JUT", "TAY", "YAY", "JUTA", "JATAYU", "JAYA", "YAUTJA"}), // Mythology: JATAYU, Movie: YAUTJA (Predator)
  WordConnectLevel(letters: "GANDIV", solutions: {"AND", "DIG", "GIN", "VAN", "DIVA", "GAIN", "GANDIVA", "VIDAN"}), // Mythology: GANDIVA, General
  WordConnectLevel(letters: "DHRUVA", solutions: {"HAD", "HARD", "VAHD", "DURA", "DHAR", "DHRUVA", "HARV", "DUBAI"}), // Mythology: DHRUVA, Place: DUBAI
  WordConnectLevel(letters: "NALANDA", solutions: {"AND", "LAD", "LAND", "ANAL", "ALAN", "NALANDA", "CANADA", "NALA"}), // Place: NALANDA, CANADA, Mythology: NALA
  WordConnectLevel(letters: "HIMALAY", solutions: {"HIM", "HAY", "LAM", "LAY", "MAY", "YAM", "HAIL", "HIMALAYA"}), // Place: HIMALAYA, Mythology
  WordConnectLevel(letters: "TAJMAHL", solutions: {"JAM", "HAM", "HAT", "HALT", "MALT", "MATH", "TAJMAHAL", "LATHE"}), // Place: TAJMAHAL, General
  WordConnectLevel(letters: "AVATARA", solutions: {"TAR", "RAT", "ART", "VARA", "RAVA", "TARA", "AVATAR", "RAVANA"}), // Mythology: AVATAR, RAVANA
  WordConnectLevel(letters: "DEVAKI", solutions: {"DIVE", "KID", "VIA", "VIE", "AKIN", "KIVA", "VADE", "DEVAKI"}), // Mythology: DEVAKI, General
  WordConnectLevel(letters: "GANESHA", solutions: {"GAS", "HEN", "HAG", "NAG", "SAGE", "SHAG", "SANE", "GANESHA"}), // Mythology: GANESHA, General
  WordConnectLevel(letters: "VALKYRE", solutions: {"VAL", "RYA", "KEY", "LARK", "VARY", "VALKYRIE", "REAL", "LAKE"}), // Mythology: VALKYRIE, General
  WordConnectLevel(letters: "YAMAHAS", solutions: {"YAM", "ASH", "HAY", "HAS", "MAY", "SHY", "MASH", "YAMAHA"}), // Brand: YAMAHA, Mythology: YAMA
  WordConnectLevel(letters: "PARISN", solutions: {"AIR", "NAP", "PAN", "PAR", "SPIN", "PAIN", "PAIR", "PARIS"}), // Place: PARIS, General
  WordConnectLevel(letters: "MOSCOW", solutions: {"MOW", "COW", "COS", "SOW", "MOWS", "COWS", "MOSCOW", "SCOW"}), // Place: MOSCOW, General
  WordConnectLevel(letters: "EGYPTA", solutions: {"GAP", "GET", "GYP", "PAT", "TAPE", "TYPE", "EGYPT", "PAGE"}), // Place: EGYPT, General
  WordConnectLevel(letters: "AMAZON", solutions: {"MAN", "NAM", "ZOO", "AMAZON", "MANO", "MONA", "AZAN", "ZOOM"}), // Place: AMAZON, General
  WordConnectLevel(letters: "EVERST", solutions: {"EVE", "REV", "SEE", "SET", "REST", "TREE", "VERSE", "EVEREST"}), // Place: EVEREST, General
  WordConnectLevel(letters: "SAHARN", solutions: {"ASH", "HAS", "RAN", "SAN", "SHAH", "RASH", "SAHARA", "SHARN"}), // Place: SAHARA, General
  WordConnectLevel(letters: "BERLIN", solutions: {"BIN", "LIE", "NIB", "REB", "BRINE", "LINER", "BERLIN", "REBEL"}), // Place: BERLIN, General
  WordConnectLevel(letters: "SYDNEY", solutions: {"DEN", "DEY", "DYE", "END", "SEND", "DYNE", "SYDNEY", "DENSE"}), // Place: SYDNEY, General
  WordConnectLevel(letters: "NEBULA", solutions: {"ALE", "BAN", "BEN", "BUN", "LANE", "LEAN", "LUNA", "NEBULA"}), // Science: NEBULA, General
];

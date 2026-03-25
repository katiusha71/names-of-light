class TreePath {
  final int fromId;
  final int toId;
  final String hebrewLetter;

  const TreePath({
    required this.fromId,
    required this.toId,
    required this.hebrewLetter,
  });
}

/// The 22 traditional paths connecting sephirot on the Tree of Life
/// (Kircher Tree / Golden Dawn attribution).
/// Each path corresponds to a Hebrew letter (paths 11–32).
const List<TreePath> treePaths = [
  // Path 11 — Keter (1) to Chokmah (2)
  TreePath(fromId: 1, toId: 2, hebrewLetter: 'א'),  // Aleph

  // Path 12 — Keter (1) to Binah (3)
  TreePath(fromId: 1, toId: 3, hebrewLetter: 'ב'),  // Bet

  // Path 13 — Keter (1) to Tiferet (7)
  TreePath(fromId: 1, toId: 7, hebrewLetter: 'ג'),  // Gimel

  // Path 14 — Chokmah (2) to Binah (3)
  TreePath(fromId: 2, toId: 3, hebrewLetter: 'ד'),  // Dalet

  // Path 15 — Chokmah (2) to Tiferet (7)
  TreePath(fromId: 2, toId: 7, hebrewLetter: 'ה'),  // He

  // Path 16 — Chokmah (2) to Chesed (5)
  TreePath(fromId: 2, toId: 5, hebrewLetter: 'ו'),  // Vav

  // Path 17 — Binah (3) to Tiferet (7)
  TreePath(fromId: 3, toId: 7, hebrewLetter: 'ז'),  // Zayin

  // Path 18 — Binah (3) to Gevurah (6)
  TreePath(fromId: 3, toId: 6, hebrewLetter: 'ח'),  // Chet

  // Path 19 — Chesed (5) to Gevurah (6)
  TreePath(fromId: 5, toId: 6, hebrewLetter: 'ט'),  // Tet

  // Path 20 — Chesed (5) to Tiferet (7)
  TreePath(fromId: 5, toId: 7, hebrewLetter: 'י'),  // Yod

  // Path 21 — Chesed (5) to Netzach (8)
  TreePath(fromId: 5, toId: 8, hebrewLetter: 'כ'),  // Kaf

  // Path 22 — Gevurah (6) to Tiferet (7)
  TreePath(fromId: 6, toId: 7, hebrewLetter: 'ל'),  // Lamed

  // Path 23 — Gevurah (6) to Hod (9)
  TreePath(fromId: 6, toId: 9, hebrewLetter: 'מ'),  // Mem

  // Path 24 — Tiferet (7) to Netzach (8)
  TreePath(fromId: 7, toId: 8, hebrewLetter: 'נ'),  // Nun

  // Path 25 — Tiferet (7) to Yesod (10)
  TreePath(fromId: 7, toId: 10, hebrewLetter: 'ס'), // Samekh

  // Path 26 — Tiferet (7) to Hod (9)
  TreePath(fromId: 7, toId: 9, hebrewLetter: 'ע'),  // Ayin

  // Path 27 — Netzach (8) to Hod (9)
  TreePath(fromId: 8, toId: 9, hebrewLetter: 'פ'),  // Pe

  // Path 28 — Netzach (8) to Yesod (10)
  TreePath(fromId: 8, toId: 10, hebrewLetter: 'צ'), // Tsadi

  // Path 29 — Netzach (8) to Malkhut (11)
  TreePath(fromId: 8, toId: 11, hebrewLetter: 'ק'), // Qof

  // Path 30 — Hod (9) to Yesod (10)
  TreePath(fromId: 9, toId: 10, hebrewLetter: 'ר'), // Resh

  // Path 31 — Hod (9) to Malkhut (11)
  TreePath(fromId: 9, toId: 11, hebrewLetter: 'ש'), // Shin

  // Path 32 — Yesod (10) to Malkhut (11)
  TreePath(fromId: 10, toId: 11, hebrewLetter: 'ת'), // Tav
];

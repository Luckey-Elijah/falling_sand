/// https://en.wikipedia.org/wiki/Tetromino
const tetromino = [
  // t tetromino
  [
    [true, true, true],
    [false, true, false],
  ],
  // square tetromino
  [
    [true, true],
    [true, true],
  ],
  // skew tetromino
  [
    [false, true, true],
    [true, true, false],
  ],
  // straight tetromino
  [
    [true, true, true, true],
  ],
  // L-tetromino
  [
    [true, false],
    [true, false],
    [true, false],
    [true, true],
  ],
  // reverse L-tetromino
  [
    [false, true],
    [false, true],
    [true, true],
    [true, false],
  ],
  // J-tetromino
  [
    [true, false, false],
    [true, true, true],
  ],
  // reverse J-tetromino
  [
    [false, false, true],
    [true, true, true],
  ],
  // S-tetromino
  [
    [false, true, true],
    [true, true, false],
  ],
  // reverse S-tetromino
  [
    [true, true, false],
    [false, true, true],
  ],
  // Z-tetromino
  [
    [true, true, false],
    [false, true, true],
  ],
  // reverse Z-tetromino
  [
    [false, true, true],
    [true, true, false],
  ],
  // I-tetromino (vertical)
  [
    [true],
    [true],
    [true],
    [true],
  ],
  // I-tetromino (horizontal)
  [
    [true, true, true, true],
  ],
  // T-tetromino (rotated)
  [
    [false, true],
    [true, true, true],
  ],
  // T-tetromino (rotated reverse)
  [
    [true, true, true],
    [false, true],
  ],
  // L-tetromino (rotated)
  [
    [true, true],
    [true, false],
    [true, false],
  ],
  // reverse L-tetromino (rotated)
  [
    [false, true],
    [false, true],
    [true, true],
  ],
  // square tetromino (rotated)
  [
    [true, true],
    [true, true],
  ],
  // skew tetromino (rotated)
  [
    [true, true, false],
    [false, true, true],
  ],
  // reverse skew tetromino
  [
    [false, true, true],
    [true, true, false],
  ],
];

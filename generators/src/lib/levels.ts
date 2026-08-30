// Level generator — a port of level_generator.gd.
//
// A level is built as a half-width grid and then mirrored, so every layout is
// symmetric. Generation happens in two independent passes: where the bricks are
// (the silhouette) and what colour they are. Keeping those apart means shapes
// and colour modes multiply instead of add.

import { mulberry32, pick, randInt, type Rng } from "./rng";

/** The empty-cell marker in a level string. */
export const EMPTY = ".";

/** Codes a palette can hand out. */
export type PaletteChar = "R" | "O" | "Y" | "G" | "B" | "P";
/** Every brick code, including the ones the sprinklers add. */
export type BrickChar = PaletteChar | "S" | "$";
export type Cell = BrickChar | typeof EMPTY;

/** One string per row, each `WIDTH` characters wide. */
export type Level = string[];

/** A generated level plus the metadata the workshop UI sorts and labels by. */
export type GeneratedLevel = { id: number; level: Level; score: number };

export const WIDTH = 18;
export const MAX_ROWS = 12;

const HALF = WIDTH / 2;
const MIN_ROWS = 4;
const MIN_BRICKS = 18;
const MAX_STEEL = 6;
const MAX_GOLD = 2;
const STAMP_CHANCE = 0.7;
const MAX_ATTEMPTS = 20;

/** Shown when even a repeat can't be found — never empty, always playable. */
const FALLBACK_LEVEL: Level = [
  "....RRRRRRRRRR....",
  "..GGGGGGGGGGGGGG..",
  "BBBBBBBBBBBBBBBBBB",
  ".YYYYYYYYYYYYYYYY.",
];

const PALETTES: PaletteChar[][] = [
  ["R", "O", "Y", "G", "B"],
  ["B", "B", "G", "G", "Y"],
  ["P", "R", "P", "R", "P"],
  ["O", "O", "R", "R", "P"],
  ["G", "Y", "G", "Y", "G"],
  ["B", "P", "B", "P", "B"],
  ["Y", "O", "R", "O", "Y"],
  ["G", "B", "P", "B", "G"],
  ["R", "R", "O", "O", "Y"],
];

/** Small motifs punched over the coloured half-grid in a single flat colour. */
const STAMPS = [
  [".X.", "XXX", ".X."],
  ["X.X", ".X.", "X.X"],
  ["XX", "XX"],
  ["..X..", "..X..", "XXXXX", "..X..", "..X.."],
  ["X...", "XX..", "XXX.", "XXXX"],
  ["XXXX", "X..X", "XXXX"],
  [".XX.", "XXXX", ".XX."],
  ["X..X", "XXXX", "X..X"],
  ["X..", ".X.", "..X"],
];

// `FREE` appears twice so roughly a third of levels use per-row patterns.
const SHAPES = ["FREE", "FREE", "PYRAMID", "INV_PYRAMID", "FRAME", "CHECKER"] as const;
type Shape = (typeof SHAPES)[number];

/** Whole-level silhouettes. `FREE` has none — it defers to `PATTERNS`. */
const SHAPE_FNS: Record<Exclude<Shape, "FREE">, (row: number, col: number, rowCount: number) => boolean> = {
  // Widens downward toward the mirror seam.
  PYRAMID: (row, col, rowCount) => col >= HALF - Math.ceil(((row + 1) / rowCount) * HALF),
  INV_PYRAMID: (row, col, rowCount) => col >= HALF - Math.ceil(((rowCount - row) / rowCount) * HALF),
  FRAME: (row, col, rowCount) => row === 0 || row === rowCount - 1 || col === 0,
  CHECKER: (row, col) => (row + col) % 2 === 0,
};

// Both are fractions of the half-grid rather than fixed column counts, so the
// shapes keep their proportions as WIDTH changes. At the original HALF of 5 they
// reduce to the old `col >= HALF - 3` and `col < 2`.
const CENTERED_FROM = Math.floor(HALF * 0.4);
const EDGES_TO = Math.ceil(HALF * 0.4);

const PATTERNS = ["FULL", "ALT", "CENTERED", "EDGES", "SPARSE"] as const;
type Pattern = (typeof PATTERNS)[number];

/** Per-row fills, re-rolled for every row of a `FREE` level. */
const PATTERN_FNS: Record<Pattern, (col: number, rng: Rng) => boolean> = {
  FULL: () => true,
  ALT: (col) => col % 2 === 0,
  CENTERED: (col) => col >= CENTERED_FROM,
  EDGES: (col) => col < EDGES_TO,
  SPARSE: (_col, rng) => rng() < 0.4,
};

const COLOR_MODES = ["ROWS", "RINGS", "COLUMNS", "DIAG"] as const;
type ColorMode = (typeof COLOR_MODES)[number];

/** Maps a cell position to a palette index. */
const COLOR_MODE_FNS: Record<ColorMode, (row: number, col: number, rowCount: number) => number> = {
  ROWS: (row) => row,
  COLUMNS: (_row, col) => col,
  RINGS: (row, col, rowCount) => Math.min(row, rowCount - 1 - row, col),
  DIAG: (row, col) => row + col,
};

const halfRow = <T,>(fill: (col: number) => T): T[] => Array.from({ length: HALF }, (_, col) => fill(col));

/** Pass 1: decide *where* bricks are, as a boolean half-grid. */
function buildOccupancy(rng: Rng, rowCount: number): boolean[][] {
  const shape = pick(rng, SHAPES);
  const grid: boolean[][] = [];
  for (let row = 0; row < rowCount; row++) {
    if (shape === "FREE") {
      const pattern = PATTERN_FNS[pick(rng, PATTERNS)];
      grid.push(halfRow((col) => pattern(col, rng)));
    } else {
      const silhouette = SHAPE_FNS[shape];
      grid.push(halfRow((col) => silhouette(row, col, rowCount)));
    }
  }
  return grid;
}

/** Pass 2: decide *what colour* each occupied cell is. */
function colorize(rng: Rng, occupancy: boolean[][]) {
  const palette = pick(rng, PALETTES);
  const paletteIndex = COLOR_MODE_FNS[pick(rng, COLOR_MODES)];
  const rowCount = occupancy.length;
  const cells: Cell[][] = occupancy.map((row, r) =>
    row.map((filled, c) => (filled ? palette[paletteIndex(r, c, rowCount) % palette.length] : EMPTY)),
  );
  return { palette, cells };
}

function applyStamp(rng: Rng, half: Cell[][], palette: PaletteChar[]) {
  const color = pick(rng, palette);
  const stamp = pick(rng, STAMPS);
  const height = stamp.length;
  const width = stamp[0].length;
  if (height > half.length || width > HALF) return;
  const top = randInt(rng, 0, half.length - height);
  const left = randInt(rng, 0, HALF - width);
  for (let row = 0; row < height; row++) {
    for (let col = 0; col < width; col++) {
      if (stamp[row][col] === "X") half[top + row][left + col] = color;
    }
  }
}

/** Indestructible blocks, anywhere in the field. */
function sprinkleSteel(rng: Rng, half: Cell[][]) {
  const count = randInt(rng, 0, MAX_STEEL / 2);
  for (let i = 0; i < count; i++) {
    half[randInt(rng, 0, half.length - 1)][randInt(rng, 0, HALF - 1)] = "S";
  }
}

/** Bonus blocks, kept to the top two rows so they stay a reward to reach. */
function sprinkleGold(rng: Rng, half: Cell[][]) {
  const count = randInt(rng, 0, MAX_GOLD / 2);
  for (let i = 0; i < count; i++) {
    half[randInt(rng, 0, Math.min(1, half.length - 1))][randInt(rng, 0, HALF - 1)] = "$";
  }
}

const mirror = (cells: Cell[]): string => {
  const left = cells.join("");
  return left + [...left].reverse().join("");
};

function generateOnce(rng: Rng): Level {
  const rowCount = randInt(rng, MIN_ROWS, MAX_ROWS);
  const { palette, cells: half } = colorize(rng, buildOccupancy(rng, rowCount));
  if (rng() < STAMP_CHANCE) applyStamp(rng, half, palette);
  sprinkleSteel(rng, half);
  sprinkleGold(rng, half);
  return half.map(mirror);
}

/** `bricks` counts every non-gold cell, steel included. */
export type LevelStats = { bricks: number; steel: number; gold: number };

export function stats(level: Level): LevelStats {
  let bricks = 0;
  let steel = 0;
  let gold = 0;
  for (const line of level) {
    for (const ch of line) {
      if (ch === EMPTY) continue;
      if (ch === "$") gold++;
      else if (ch === "S") {
        steel++;
        bricks++;
      } else bricks++;
    }
  }
  return { bricks, steel, gold };
}

function isPlayable(level: Level): boolean {
  const { bricks, steel, gold } = stats(level);
  return bricks >= MIN_BRICKS && steel <= MAX_STEEL && gold <= MAX_GOLD;
}

/** Silhouette signature: the same layout in different colours is still a repeat. */
const shapeSig = (level: Level) =>
  level.map((line) => [...line].map((ch) => (ch === EMPTY ? EMPTY : "#")).join("")).join("|");

/** More bricks + armoured bricks + taller fields = harder. */
export function difficulty(level: Level): number {
  const { bricks, steel, gold } = stats(level);
  return bricks + steel * 1.5 + gold * 2 + level.length;
}

/** Roll until we get a playable level whose silhouette we haven't seen yet. */
export function generate(rng: Rng, seenShapes: Set<string>): Level {
  let lastPlayable: Level | null = null;
  for (let attempt = 0; attempt < MAX_ATTEMPTS; attempt++) {
    const level = generateOnce(rng);
    if (!isPlayable(level)) continue;
    lastPlayable = level;
    const sig = shapeSig(level);
    if (seenShapes.has(sig)) continue; // playable but a rerun — try again
    seenShapes.add(sig);
    return level;
  }
  // Couldn't find a fresh shape — a playable repeat beats nothing.
  return lastPlayable ?? FALLBACK_LEVEL;
}

/** Generate `count` levels from `seed`, deduplicated by silhouette. */
export function generateBatch(seed: number, count: number): GeneratedLevel[] {
  const rng = mulberry32(seed);
  const seenShapes = new Set<string>();
  return Array.from({ length: count }, (_, id) => {
    const level = generate(rng, seenShapes);
    return { id, level, score: difficulty(level) };
  });
}

// ---------- hand editing ----------

/** The order a cell cycles through when clicked in the editor. */
export const CELL_CYCLE: Cell[] = [EMPTY, "R", "O", "Y", "G", "B", "P", "S", "$"];

/** Next cell code in the cycle; unknown codes fall back to empty. */
export function cycleCell(cell: string): Cell {
  const index = CELL_CYCLE.indexOf(cell as Cell);
  return CELL_CYCLE[(index + 1) % CELL_CYCLE.length];
}

/** A copy of `level` with one cell replaced. */
export function withCell(level: Level, row: number, column: number, cell: Cell): Level {
  return level.map((line, r) =>
    r === row ? line.slice(0, column) + cell + line.slice(column + 1) : line,
  );
}

/** An empty grid to hand-build a level in. */
export function blankLevel(rows = MIN_ROWS, width = WIDTH): Level {
  return Array.from({ length: rows }, () => EMPTY.repeat(width));
}

/**
 * Whether the level can actually be cleared. The Godot loader rejects levels
 * with no breakable bricks, so the editor has to be able to flag them.
 */
export function hasBreakable(level: Level): boolean {
  const { bricks } = stats(level);
  return bricks > 0;
}

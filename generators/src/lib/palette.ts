import type { Cell } from "./levels";

/** Display colour for each brick code, shared by the preview canvas and the editor. */
export const BRICK_COLORS: Record<string, string> = {
  R: "#ff4b5c",
  O: "#ff9f40",
  Y: "#ffd23f",
  G: "#31d17c",
  B: "#3fb8ff",
  P: "#b06bf5",
  $: "#f2c14e",
  S: "#7d8799",
};

export const brickColor = (cell: Cell | string) => BRICK_COLORS[cell] ?? "#fff";

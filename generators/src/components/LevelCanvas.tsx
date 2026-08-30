import { useEffect, useRef } from "react";
import { EMPTY, MAX_ROWS, WIDTH, type Level } from "../lib/levels";
import { brickColor } from "../lib/palette";

const BRICK_W = 14;
const BRICK_H = 7;
const GAP = 1;

// Every canvas is sized for the tallest possible level so cards line up in the
// grid regardless of how many rows a level actually has.
const CANVAS_W = WIDTH * (BRICK_W + GAP) + GAP;
const CANVAS_H = MAX_ROWS * (BRICK_H + GAP) + GAP;

export function LevelCanvas({ level }: { level: Level }) {
  const ref = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    const ctx = ref.current?.getContext("2d");
    if (!ctx) return;

    // Assigning width/height also resets the transform, so the scale below is
    // applied exactly once per draw.
    const dpr = window.devicePixelRatio || 1;
    ctx.canvas.width = CANVAS_W * dpr;
    ctx.canvas.height = CANVAS_H * dpr;
    ctx.scale(dpr, dpr);
    ctx.clearRect(0, 0, CANVAS_W, CANVAS_H);

    level.forEach((line, row) => {
      [...line].forEach((ch, col) => {
        if (ch === EMPTY) return;
        const x = GAP + col * (BRICK_W + GAP);
        const y = GAP + row * (BRICK_H + GAP);

        ctx.fillStyle = brickColor(ch);
        ctx.fillRect(x, y, BRICK_W, BRICK_H);

        // Top highlight, for a little arcade depth.
        ctx.fillStyle = "rgba(255,255,255,0.35)";
        ctx.fillRect(x, y, BRICK_W, 1.5);

        if (ch === "$") {
          ctx.fillStyle = "rgba(255,255,255,0.7)";
          ctx.fillRect(x + 2, y + 2, 2, 2);
        }
      });
    });
  }, [level]);

  return <canvas className="level-canvas" ref={ref} width={CANVAS_W} height={CANVAS_H} />;
}

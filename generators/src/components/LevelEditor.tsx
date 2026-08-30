import type { CSSProperties } from "react";
import { EMPTY, cycleCell, hasBreakable, withCell, type Cell, type Level } from "../lib/levels";
import { brickColor } from "../lib/palette";

type Props = {
  level: Level;
  title: string;
  onChange: (level: Level) => void;
  onClose: () => void;
};

/**
 * Expanded view of a single level. Clicking a cell cycles it through
 * `.` → colours → `S` → `$` → `.`, so a nearly-good level can be fixed by hand
 * instead of culled.
 */
export function LevelEditor({ level, title, onChange, onClose }: Props) {
  const width = level[0]?.length ?? 0;
  const playable = hasBreakable(level);

  return (
    <div className="editor-backdrop" onClick={onClose}>
      <div
        className="editor"
        role="dialog"
        aria-label={`Editing ${title}`}
        onClick={(event) => event.stopPropagation()}
      >
        <div className="editor-head">
          <span className="editor-title">{title}</span>
          <button className="btn" onClick={onClose}>
            Done
          </button>
        </div>

        <div className="editor-grid" style={{ "--cols": width } as CSSProperties}>
          {level.map((line, row) =>
            [...line].map((cell, column) => (
              <button
                key={`${row}:${column}`}
                className={cell === EMPTY ? "cell empty" : "cell"}
                style={cell === EMPTY ? undefined : { background: brickColor(cell) }}
                title={`row ${row + 1}, column ${column + 1}`}
                onClick={() => onChange(withCell(level, row, column, cycleCell(cell)))}
              >
                {cell === EMPTY ? "" : (cell as Cell)}
              </button>
            )),
          )}
        </div>

        <p className={playable ? "editor-note" : "editor-note warn"}>
          {playable
            ? "click a cell to cycle: empty → colours → steel → gold"
            : "no breakable bricks — the game will reject this level"}
        </p>
      </div>
    </div>
  );
}

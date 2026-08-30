import { useEffect, useMemo, useState } from "react";
import { LevelCanvas } from "./components/LevelCanvas";
import { LevelEditor } from "./components/LevelEditor";
import { copyText, downloadText } from "./lib/download";
import { blankLevel, difficulty, generateBatch, hasBreakable, type GeneratedLevel, type Level } from "./lib/levels";
import "./App.css";

const DEFAULT_SEED = 1337;
const DEFAULT_COUNT = 60;
const MIN_COUNT = 1;
const MAX_COUNT = 500;
const COPIED_RESET_MS = 1600;

const toInt = (value: string, fallback: number) => {
  const parsed = Number.parseInt(value, 10);
  return Number.isNaN(parsed) ? fallback : parsed;
};

const clamp = (value: number, min: number, max: number) => Math.min(max, Math.max(min, value));

const label = (position: number) => `#${String(position + 1).padStart(3, "0")}`;

export default function App() {
  const [seed, setSeed] = useState(DEFAULT_SEED);
  const [count, setCount] = useState(DEFAULT_COUNT);
  // Committed on "Generate", so typing in the inputs doesn't rebuild the batch.
  const [request, setRequest] = useState({ seed: DEFAULT_SEED, count: DEFAULT_COUNT });
  const [culled, setCulled] = useState<ReadonlySet<number>>(new Set());
  // Hand-made levels, keyed by negative id so they never collide with the batch.
  const [handMade, setHandMade] = useState<GeneratedLevel[]>([]);
  // Hand edits layered over whichever level shares the id.
  const [edits, setEdits] = useState<ReadonlyMap<number, Level>>(new Map());
  const [editingId, setEditingId] = useState<number | null>(null);
  const [sortByDifficulty, setSortByDifficulty] = useState(true);
  const [copied, setCopied] = useState(false);

  const generated = useMemo(() => generateBatch(request.seed, request.count), [request]);

  const entries = useMemo(
    () =>
      [...handMade, ...generated].map((entry) => {
        const level = edits.get(entry.id) ?? entry.level;
        return { ...entry, level, score: difficulty(level) };
      }),
    [generated, handMade, edits],
  );

  const ordered = useMemo(
    () => (sortByDifficulty ? [...entries].sort((a, b) => a.score - b.score) : entries),
    [entries, sortByDifficulty],
  );

  const kept = ordered.filter((entry) => !culled.has(entry.id));

  useEffect(() => {
    if (!copied) return;
    const timer = setTimeout(() => setCopied(false), COPIED_RESET_MS);
    return () => clearTimeout(timer);
  }, [copied]);

  const regenerate = () => {
    setRequest({ seed, count });
    setCulled(new Set());
    // Edits to generated levels are meaningless once the batch changes; edits to
    // hand-made levels (negative ids) survive.
    setEdits((prev) => new Map([...prev].filter(([id]) => id < 0)));
    setCopied(false);
  };

  const toggle = (id: number) => {
    setCulled((prev) => {
      const next = new Set(prev);
      if (!next.delete(id)) next.add(id);
      return next;
    });
    setCopied(false);
  };

  const edit = (id: number, level: Level) => {
    setEdits((prev) => new Map(prev).set(id, level));
    setCopied(false);
  };

  const addBlank = () => {
    const id = -(handMade.length + 1);
    const level = blankLevel();
    setHandMade((prev) => [...prev, { id, level, score: difficulty(level) }]);
    setEditingId(id);
    setCopied(false);
  };

  const exportJson = () => JSON.stringify(kept.map((entry) => entry.level), null, 1);

  const copy = async () => setCopied(await copyText(exportJson()));

  const editingPosition = ordered.findIndex((entry) => entry.id === editingId);
  const editing = editingPosition === -1 ? null : ordered[editingPosition];

  return (
    <div className="page">
      <header className="page-header">
        <h1 className="page-title">LEVEL&nbsp;WORKSHOP</h1>
        <p className="page-sub">generate &rarr; cull the duds &rarr; export for Godot</p>
      </header>

      <div className="toolbar">
        <label className="field">
          <span className="field-label">seed</span>
          <input
            className="input"
            type="number"
            value={seed}
            onChange={(e) => setSeed(toInt(e.target.value, 0))}
          />
        </label>
        <label className="field">
          <span className="field-label">levels</span>
          <input
            className="input"
            type="number"
            min={MIN_COUNT}
            max={MAX_COUNT}
            value={count}
            onChange={(e) => setCount(clamp(toInt(e.target.value, MIN_COUNT), MIN_COUNT, MAX_COUNT))}
          />
        </label>
        <button className="btn primary" onClick={regenerate}>
          Generate
        </button>
        <button
          className={sortByDifficulty ? "btn active" : "btn"}
          onClick={() => setSortByDifficulty(!sortByDifficulty)}
        >
          {sortByDifficulty ? "Sorted: easy → hard" : "Sorted: raw order"}
        </button>
        <button className="btn" onClick={addBlank}>
          + Blank level
        </button>
      </div>

      <div className="stats-row">
        <span className="stat">
          keeping <b className="stat-num">{kept.length}</b> / {entries.length}
        </span>
        <div className="stats-actions">
          <button className="btn" onClick={copy}>
            {copied ? "Copied ✓" : "Copy JSON"}
          </button>
          <button
            className="btn gold"
            onClick={() => downloadText("levels.json", exportJson())}
            disabled={kept.length === 0}
          >
            Download levels.json
          </button>
        </div>
      </div>

      <div className="grid">
        {ordered.map((entry, position) => {
          const isCulled = culled.has(entry.id);
          const playable = hasBreakable(entry.level);
          return (
            <div key={entry.id} className={isCulled ? "card culled" : "card"}>
              <div className="card-top">
                <span className="card-index">{label(position)}</span>
                <span className="card-score">dif {entry.score.toFixed(0)}</span>
              </div>
              <button
                className="card-body"
                onClick={() => toggle(entry.id)}
                title={isCulled ? "Click to keep" : "Click to cull"}
              >
                <LevelCanvas level={entry.level} />
              </button>
              <div className="card-actions">
                <span className={playable ? "card-tag" : "card-tag warn"}>
                  {!playable ? "UNPLAYABLE" : isCulled ? "CULLED" : "KEPT"}
                </span>
                <button className="card-edit" onClick={() => setEditingId(entry.id)}>
                  edit
                </button>
              </div>
            </div>
          );
        })}
      </div>

      {editing && (
        <LevelEditor
          level={editing.level}
          title={label(editingPosition)}
          onChange={(level) => edit(editing.id, level)}
          onClose={() => setEditingId(null)}
        />
      )}
    </div>
  );
}

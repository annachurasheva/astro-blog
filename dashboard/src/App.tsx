import React, { useCallback, useEffect, useMemo, useState } from "react";
import { KIT_FILES, REPO, type KitFile } from "./data/kit";
import { copyText, downloadFile, downloadZip } from "./lib/download";
import {
  ActivityBar,
  Explorer,
  ProjectPanel,
  StatusBar,
  TitleBar,
  Shortcuts,
} from "./components/ide";
import { Editor } from "./components/Editor";
import { ExplainPanel } from "./components/Panel";
import { PlacementSection } from "./components/Placement";
import { InstallGuide } from "./components/InstallGuide";
import { SavePage } from "./components/SavePage";
import { Review } from "./components/Review";
import { buildDashboardZip } from "./lib/dashboardBundle";
import { ArrowIcon, CheckIcon, DownloadIcon, TerminalIcon, fileIcon } from "./components/icons";

/* ============================================================
 * Комплект .vscode для astro-blog — интерактивная документация.
 * Светлая тема в духе Gmail. Слева — файлы комплекта, в центре —
 * их содержимое с комментариями, снизу — почему каждая строка
 * именно такая. Ниже — разделы про размещение, установку и
 * офлайн-копию страницы.
 * ============================================================ */

type Toast = { id: number; msg: string; ok: boolean };

export default function App() {
  const [openIds, setOpenIds] = useState<string[]>(["readme", "settings"]);
  const [activeId, setActiveId] = useState("readme");
  const [view, setView] = useState<"files" | "project">("files");
  const [zipping, setZipping] = useState(false);
  const [bundleBusy, setBundleBusy] = useState(false);
  const [copied, setCopied] = useState(false);
  const [toast, setToast] = useState<Toast | null>(null);
  const [checked, setChecked] = useState<number[]>([]);
  const [expandedMap, setExpandedMap] = useState<Record<string, number[]>>({ settings: [0] });

  const active: KitFile = useMemo(
    () => KIT_FILES.find((f) => f.id === activeId) ?? KIT_FILES[0],
    [activeId],
  );
  const openFiles = useMemo(
    () => openIds.map((id) => KIT_FILES.find((f) => f.id === id)!).filter(Boolean),
    [openIds],
  );

  const showToast = useCallback((msg: string, ok = true) => {
    const id = Date.now();
    setToast({ id, msg, ok });
    setTimeout(() => setToast((t) => (t && t.id === id ? null : t)), 2800);
  }, []);

  const openFile = useCallback((id: string) => {
    setOpenIds((ids) => (ids.includes(id) ? ids : [...ids, id]));
    setActiveId(id);
  }, []);

  const closeTab = useCallback(
    (id: string) => {
      setOpenIds((ids) => {
        if (ids.length <= 1) return ids;
        const next = ids.filter((x) => x !== id);
        if (activeId === id) setActiveId(next[next.length - 1]);
        return next;
      });
    },
    [activeId],
  );

  const handleCopy = useCallback(async () => {
    const ok = await copyText(active.content);
    if (ok) {
      setCopied(true);
      setTimeout(() => setCopied(false), 1800);
      showToast(`${active.name} скопирован в буфер обмена`);
    } else {
      showToast("Не удалось скопировать — скачайте файл", false);
    }
  }, [active, showToast]);

  const handleCopyText = useCallback(
    async (text: string, label: string) => {
      const ok = await copyText(text);
      showToast(ok ? `Скопировано: ${label}` : "Не удалось скопировать", ok);
    },
    [showToast],
  );

  const handleZip = useCallback(async () => {
    if (zipping) return;
    setZipping(true);
    try {
      await downloadZip(KIT_FILES);
      showToast("Архив vscode-kit-astro-blog.zip скачан");
    } catch {
      showToast("Не удалось собрать архив", false);
    } finally {
      setTimeout(() => setZipping(false), 500);
    }
  }, [zipping, showToast]);

  // упаковка dashboard-бандла (регламент экспорта ревизии f308ee0)
  const handleBundle = useCallback(async () => {
    if (bundleBusy) return;
    setBundleBusy(true);
    try {
      await buildDashboardZip();
      showToast("Бандл dashboard-bundle-f308ee0-r2.zip скачан");
    } catch {
      showToast("Не удалось собрать бандл", false);
    } finally {
      setTimeout(() => setBundleBusy(false), 500);
    }
  }, [bundleBusy, showToast]);

  useEffect(() => {
    const h = (e: KeyboardEvent) => e.key === "Escape" && setToast(null);
    window.addEventListener("keydown", h);
    return () => window.removeEventListener("keydown", h);
  }, []);

  const lines = active.content.trimEnd().split("\n").length;
  const expanded = expandedMap[active.id] ?? [];
  const toggleGroup = (i: number) =>
    setExpandedMap((m) => {
      const cur = m[active.id] ?? [];
      return { ...m, [active.id]: cur.includes(i) ? cur.filter((x) => x !== i) : [...cur, i] };
    });
  const toggleCheck = (i: number) =>
    setChecked((c) => (c.includes(i) ? c.filter((x) => x !== i) : [...c, i]));

  return (
    <div className="relative min-h-screen overflow-x-clip bg-ink-950 text-ink-100">
      {/* живой фон */}
      <div className="pointer-events-none absolute inset-0">
        <div className="bg-blueprint absolute inset-0" />
        <div className="glow glow-mauve -top-32 left-[8%] h-[420px] w-[560px]" />
        <div className="glow glow-teal top-[30%] right-[-120px] h-[380px] w-[480px]" />
        <div className="glow glow-peach bottom-[-140px] left-[30%] h-[340px] w-[460px]" />
      </div>

      <div className="relative mx-auto flex min-h-screen max-w-[1440px] flex-col gap-6 px-3 py-5 sm:px-5 lg:px-8 lg:py-7">
        {/* ─────────── шапка: итоги осмотра ─────────── */}
        <header className="rise-in grid items-end gap-6 lg:grid-cols-[1.6fr_1fr]">
          <div>
            <p className="flex flex-wrap items-center gap-x-2.5 gap-y-1 font-mono text-[11.5px] tracking-wide text-ink-300">
              <span className="pulse-dot inline-block h-2 w-2 rounded-full bg-grass" />
              осмотр репозитория завершён
              <a
                href="https://github.com/annachurasheva/astro-blog"
                target="_blank"
                rel="noreferrer"
                className="text-mauve underline decoration-mauve/40 underline-offset-4 transition-colors hover:decoration-mauve"
              >
                github.com/{REPO.owner}/{REPO.name}
              </a>
            </p>
            <h1 className="mt-3 font-display text-[26px] font-extrabold leading-[1.08] tracking-tight text-ink-100 sm:text-4xl lg:text-[44px]">
              Комплект{" "}
              <span className="text-mauve">.vscode</span>
              <span className="caret ml-2 inline-block h-[0.85em] w-[10px] translate-y-[0.12em] bg-peach sm:w-[13px]" />
              <span className="mt-2 block text-[17px] font-bold text-ink-300 sm:text-[22px] lg:text-2xl">
                для astro-blog — форка Astro-темы {REPO.theme}
              </span>
            </h1>
            <p className="mt-3 max-w-[620px] text-[14px] leading-relaxed text-ink-300">
              Пять конфигов, и в каждом — комментарии к каждой строке: почему{" "}
              <span className="font-mono font-semibold text-peach">pnpm</span>, почему{" "}
              <span className="font-semibold text-peach">без Prettier</span>, почему терминал —{" "}
              <span className="font-mono font-semibold text-teal">pwsh 7.6.5</span>. Откройте файл в
              проводнике слева — панель снизу объяснит каждое решение.
            </p>
          </div>

          {/* карточка машины + CTA */}
          <div className="flex flex-col gap-3">
            <div className="overflow-hidden rounded-lg border border-ink-700 bg-ink-900 font-mono text-[12px]">
              {[
                ["машина", "Windows 10 · кастомная сборка · 1 пользователь (админ)"],
                ["оболочка", "PowerShell 7.6.5 (pwsh) — подхвачен автоматически"],
                ["проект", "pnpm · UnoCSS · ESLint flat · MDX · деплой EdgeOne Pages"],
              ].map(([k, v], i) => (
                <div
                  key={k}
                  className={`flex items-baseline gap-3 px-3.5 py-2 ${i > 0 ? "border-t border-ink-700" : ""}`}
                >
                  <span className="w-20 shrink-0 text-[10.5px] uppercase tracking-widest text-ink-500">{k}</span>
                  <span className="text-ink-200">{v}</span>
                </div>
              ))}
            </div>
            <div className="flex flex-wrap gap-2">
              <button
                onClick={handleZip}
                disabled={zipping}
                className="flex flex-1 items-center justify-center gap-2 rounded-lg bg-mauve px-4 py-2.5 text-[13.5px] font-bold text-white transition-all hover:bg-lav hover:shadow-[0_8px_24px_rgba(26,115,232,0.35)] active:scale-[0.98] disabled:opacity-70"
              >
                {zipping ? (
                  <span className="spin-slow inline-block h-4 w-4 rounded-full border-2 border-white/30 border-t-white" />
                ) : (
                  <DownloadIcon size={16} />
                )}
                {zipping ? "Упаковываю…" : "Скачать комплект (.zip)"}
              </button>
              <a
                href="#install"
                className="flex items-center justify-center gap-2 rounded-lg border border-ink-700 bg-ink-900 px-4 py-2.5 text-[13.5px] font-semibold text-ink-200 transition-all hover:border-mauve hover:text-mauve active:scale-[0.98]"
              >
                <TerminalIcon size={16} className="text-teal" />
                как установить
              </a>
              <a
                href="#review"
                className="flex items-center justify-center gap-2 rounded-lg border border-rose/50 bg-rose/10 px-4 py-2.5 text-[13.5px] font-semibold text-rose transition-all hover:bg-rose/20 active:scale-[0.98]"
                title="Дельта-задачи ревизии f308ee0 и регламент экспорта"
              >
                ревизия f308ee0
              </a>
            </div>
          </div>
        </header>

        {/* ─────────── лента решений: факт → решение ─────────── */}
        <div
          className="rise-in -mx-3 flex gap-2.5 overflow-x-auto px-3 pb-1 sm:mx-0 sm:px-0"
          style={{ animationDelay: "0.12s" }}
        >
          {REPO.findings.map((f, i) => (
            <div
              key={i}
              className="group flex shrink-0 cursor-default items-center gap-2.5 rounded-lg border border-ink-700 bg-ink-900 py-2 pl-3 pr-2.5 transition-all hover:-translate-y-0.5 hover:border-mauve/50 hover:bg-ink-850"
            >
              <span className="max-w-[220px] truncate text-[12px] text-ink-300" title={f.fact}>
                {f.fact}
              </span>
              <ArrowIcon size={13} className="shrink-0 text-mauve transition-transform group-hover:translate-x-0.5" />
              <span className="whitespace-nowrap text-[12px] font-semibold text-peach">{f.decision}</span>
            </div>
          ))}
        </div>

        {/* ─────────── окно VS Code ─────────── */}
        <main
          className="rise-in flex h-[min(80vh,880px)] min-h-[620px] flex-col overflow-hidden rounded-xl border border-ink-700 bg-ink-950 shadow-[0_30px_80px_-40px_rgba(32,33,36,0.4),0_2px_6px_rgba(32,33,36,0.08)]"
          style={{ animationDelay: "0.2s" }}
        >
          <TitleBar />
          <div className="flex min-h-0 flex-1">
            <ActivityBar view={view} onView={setView} />
            <aside className="hidden w-[264px] shrink-0 border-r border-ink-700 bg-ink-900 sm:block">
              {view === "files" ? (
                <Explorer activeId={activeId} onOpen={openFile} zipping={zipping} onZip={handleZip} />
              ) : (
                <ProjectPanel />
              )}
            </aside>

            <div className="flex min-w-0 flex-1 flex-col">
              {/* мобильный переключатель файлов */}
              <div className="flex shrink-0 gap-1.5 overflow-x-auto border-b border-ink-700 bg-ink-900 px-2 py-2 sm:hidden">
                {KIT_FILES.map((f) => (
                  <button
                    key={f.id}
                    onClick={() => openFile(f.id)}
                    className={`flex shrink-0 items-center gap-1.5 rounded-md border px-2.5 py-1.5 font-mono text-[11.5px] transition-colors ${
                      activeId === f.id
                        ? "border-mauve/60 bg-mauve/10 text-mauve"
                        : "border-ink-700 bg-ink-950 text-ink-300"
                    }`}
                  >
                    {fileIcon(f.kind, 13)}
                    {f.name}
                  </button>
                ))}
              </div>

              <Editor
                openFiles={openFiles}
                active={active}
                onActivate={setActiveId}
                onClose={closeTab}
                copied={copied}
                onCopy={handleCopy}
                onDownloadOne={() => {
                  downloadFile(active.name, active.content);
                  showToast(`Файл ${active.name} скачан`);
                }}
              />

              <ExplainPanel
                file={active}
                expanded={expanded}
                onToggle={toggleGroup}
                checked={checked}
                onCheck={toggleCheck}
              />
            </div>
          </div>
          <StatusBar file={active} lines={lines} />
        </main>

        {/* ─────────── ревизия f308ee0: дельта-задачи ─────────── */}
        <Review onCopy={handleCopyText} onBundle={handleBundle} bundleBusy={bundleBusy} />

        {/* ─────────── офлайн-копия страницы ─────────── */}
        <SavePage onCopy={handleCopyText} />

        {/* ─────────── куда положить файлы ─────────── */}
        <PlacementSection onCopy={handleCopyText} />

        {/* ─────────── как установить ─────────── */}
        <InstallGuide onCopy={handleCopyText} />

        {/* ─────────── строка горячих клавиш ─────────── */}
        <Shortcuts />

        {/* ─────────── подвал ─────────── */}
        <footer className="flex flex-wrap items-center gap-x-5 gap-y-2 px-1 pb-2 font-mono text-[11.5px] text-ink-400">
          <span className="flex items-center gap-2 text-ink-300">
            <CheckIcon size={12} className="text-grass" />
            собрано по осмотру репозитория · форк темы {REPO.theme}
          </span>
          <span>
            ветка <span className="text-ink-200">{REPO.branch}</span> · {REPO.commits} коммитов ·{" "}
            <span className="text-ink-200">{REPO.deploy}</span>
          </span>
          <span className="ml-auto">
            JSONC — комментарии в конфигах VS Code допустимы, <span className="text-ink-200">это не ошибка</span>
          </span>
        </footer>
      </div>

      {/* ─────────── тост ─────────── */}
      {toast && (
        <div
          key={toast.id}
          className={`toast-in fixed bottom-6 right-6 z-50 flex items-center gap-2.5 rounded-lg border bg-ink-100 px-4 py-3 text-[13px] font-medium shadow-[0_12px_32px_rgba(32,33,36,0.35)] ${
            toast.ok ? "border-grass/50 text-grass" : "border-rose/50 text-rose"
          }`}
        >
          {toast.ok ? <CheckIcon size={15} /> : <TerminalIcon size={15} />}
          <span className="text-white">{toast.msg}</span>
        </div>
      )}
    </div>
  );
}

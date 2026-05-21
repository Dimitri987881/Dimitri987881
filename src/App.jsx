import { useState } from "react";
import {
  BarChart, Bar, XAxis, YAxis, Tooltip,
  ResponsiveContainer, CartesianGrid,
} from "recharts";

const PILLARS = [
  {
    id: 1, icon: "🎬", label: "TikTok Affiliation",
    desc: "Scripts IA → FR/EN/DE → ClickBank + Digistore24",
    tech: ["Claude Haiku", "Google Trends", "Telegram"],
    rev: [0, 150, 600, 2000], color: "#1D9E75", status: "ACTIF",
    detail: "3 scripts/jour × 3 marchés = 9 contenus automatiques",
  },
  {
    id: 2, icon: "🤖", label: "Master Agent Bot",
    desc: "Telegram bot IA → Stats / Scripts / Commissions",
    tech: ["n8n", "Claude Haiku", "Google Sheets"],
    rev: [0, 0, 200, 800], color: "#534AB7", status: "ACTIF",
    detail: "/stats /commissions /script [topic] — réponse instantanée",
  },
  {
    id: 3, icon: "🎥", label: "Sora Vidéo Auto",
    desc: "OpenAI Sora → vidéos virales → Telegram",
    tech: ["Sora API", "OpenAI", "Telegram"],
    rev: [0, 50, 400, 1500], color: "#BA7517", status: "SETUP",
    detail: "Génération vidéo IA automatique — animaux/viral content",
  },
  {
    id: 4, icon: "⚙️", label: "Make.com Stack",
    desc: "8 workflows — fichiers / analytics / alertes ventes",
    tech: ["Make.com", "Notion", "Google Drive"],
    rev: [0, 0, 100, 500], color: "#185FA5", status: "SETUP",
    detail: "Digest quotidien + alerte commission + sync analytics",
  },
  {
    id: 5, icon: "📦", label: "Actifs Digitaux",
    desc: "Prompt packs + templates → Gumroad auto-delivery",
    tech: ["Gumroad", "Brevo", "Systeme.io"],
    rev: [0, 80, 300, 1200], color: "#993C1D", status: "FUTUR",
    detail: "Produits créés 1x → vendus à l'infini",
  },
];

const PHASES = [
  { label: "BOOT J1–14",    total: 280,   fr: 150,  en: 80,   de: 50   },
  { label: "GROW J15–60",   total: 1130,  fr: 500,  en: 380,  de: 250  },
  { label: "SCALE J61–120", total: 4600,  fr: 1600, en: 1800, de: 1200 },
  { label: "EMPIRE J121–180", total: 12000, fr: 3500, en: 5000, de: 3500 },
];

const INIT_STEPS = [
  { done: true,  label: "VPS Hetzner online + n8n installé" },
  { done: true,  label: "Clé Anthropic NEXUS créée" },
  { done: false, label: "Importer NEXUS_EMPIRE_n8n_master.json dans n8n" },
  { done: false, label: "Remplir .env (4 variables: BOT_TOKEN / CHAT_ID / SHEETS_ID / API_KEY)" },
  { done: false, label: "Tester: python3 pipeline_test.py" },
  { done: false, label: "Activer workflow → 1er script auto à 6h" },
  { done: false, label: "Configurer Make.com W4 Daily Digest" },
  { done: false, label: "Configurer webhook Digistore24 (alerte vente)" },
  { done: false, label: "Publier 1er script TikTok manuellement" },
  { done: false, label: "Valider 100€/j avant scaling multi-comptes" },
];

const ENV_TEMPLATE = `ANTHROPIC_API_KEY=sk-ant-NEXUS_KEY_ICI
TELEGRAM_BOT_TOKEN=bot_TOKEN_ICI
TELEGRAM_CHAT_ID=TON_CHAT_ID_ICI
GOOGLE_SHEETS_ID=ID_SPREADSHEET_ICI
ELEVENLABS_API_KEY=el_KEY_ICI`;

const statusColor = (s) =>
  s === "ACTIF" ? "#1D9E75" : s === "SETUP" ? "#BA7517" : "#888780";
const statusBg = (s) =>
  s === "ACTIF" ? "#E1F5EE" : s === "SETUP" ? "#FAEEDA" : "#F1EFE8";

export default function App() {
  const [tab, setTab] = useState("overview");
  const [sel, setSel] = useState(null);
  const [steps, setSteps] = useState(INIT_STEPS);
  const [copied, setCopied] = useState(false);

  const done = steps.filter((s) => s.done).length;
  const pct = Math.round((done / steps.length) * 100);

  const copy = () => {
    navigator.clipboard.writeText(ENV_TEMPLATE);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const toggleStep = (i) =>
    setSteps((st) => st.map((x, j) => (j === i ? { ...x, done: !x.done } : x)));

  return (
    <div style={{ width: "100%", maxWidth: 600, display: "flex", flexDirection: "column", gap: 16 }}>

      {/* Header */}
      <div style={{
        background: "var(--color-background-primary)",
        border: "0.5px solid var(--color-border-secondary)",
        borderRadius: "var(--border-radius-lg)",
        padding: "16px 20px",
      }}>
        <div style={{ fontSize: 15, fontWeight: 700, letterSpacing: "-0.02em", color: "var(--color-text-primary)" }}>
          NEXUS EMPIRE — Système Multi-Revenus
        </div>
        <div style={{ fontSize: 11, color: "var(--color-text-secondary)", marginTop: 3 }}>
          5 piliers automatisés · 3 marchés FR/EN/DE · 24h/24 · ~11€/mois d'infra
        </div>
      </div>

      {/* Tabs */}
      <div style={{ display: "flex", gap: 6 }}>
        {["overview", "revenus", "setup"].map((t) => (
          <button
            key={t}
            onClick={() => setTab(t)}
            style={{
              padding: "5px 14px", fontSize: 11, fontFamily: "inherit",
              background: tab === t ? "var(--color-text-primary)" : "transparent",
              color: tab === t ? "var(--color-background-primary)" : "var(--color-text-secondary)",
              border: "0.5px solid var(--color-border-secondary)",
              borderRadius: "var(--border-radius-md)",
              cursor: "pointer", textTransform: "uppercase", letterSpacing: "0.05em",
            }}
          >
            {t}
          </button>
        ))}
      </div>

      {/* OVERVIEW */}
      {tab === "overview" && (
        <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>

          {/* Metrics */}
          <div style={{
            display: "grid", gridTemplateColumns: "repeat(5,1fr)", gap: 8,
          }}>
            {[
              { l: "Piliers",    v: "5 (2 actifs)" },
              { l: "Marchés",    v: "FR · EN · DE" },
              { l: "Scripts/j",  v: "9 auto" },
              { l: "Coût/jour",  v: "~0.02€" },
              { l: "Cible J180", v: "12k€/j" },
            ].map((m) => (
              <div key={m.l} style={{
                background: "var(--color-background-primary)",
                border: "0.5px solid var(--color-border-tertiary)",
                borderRadius: "var(--border-radius-md)",
                padding: "10px 8px", textAlign: "center",
              }}>
                <div style={{ fontSize: 9, color: "var(--color-text-secondary)", textTransform: "uppercase", letterSpacing: "0.04em", marginBottom: 4 }}>
                  {m.l}
                </div>
                <div style={{ fontSize: 12, fontWeight: 700, color: "var(--color-text-primary)" }}>
                  {m.v}
                </div>
              </div>
            ))}
          </div>

          {/* Pillars */}
          {PILLARS.map((p) => (
            <div key={p.id}>
              <div
                onClick={() => setSel(sel?.id === p.id ? null : p)}
                style={{
                  background: "var(--color-background-primary)",
                  border: "0.5px solid var(--color-border-tertiary)",
                  borderRadius: "var(--border-radius-lg)",
                  padding: "12px 14px",
                  cursor: "pointer",
                  borderLeft: `3px solid ${p.color}`,
                }}
              >
                <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 4 }}>
                  <span style={{ fontSize: 18 }}>{p.icon}</span>
                  <span style={{ fontSize: 13, fontWeight: 600 }}>{p.label}</span>
                  <span style={{
                    marginLeft: "auto", fontSize: 9, fontWeight: 700,
                    color: statusColor(p.status), background: statusBg(p.status),
                    padding: "2px 7px", borderRadius: 99,
                  }}>
                    {p.status}
                  </span>
                </div>
                <div style={{ fontSize: 11, color: "var(--color-text-secondary)", marginBottom: 4 }}>{p.desc}</div>
                <div style={{ fontSize: 11, color: p.color, fontWeight: 600 }}>
                  J180: {p.rev[3].toLocaleString()}€/j
                </div>
              </div>

              {sel?.id === p.id && (
                <div style={{
                  background: "var(--color-background-secondary)",
                  border: "0.5px solid var(--color-border-tertiary)",
                  borderTop: "none",
                  borderRadius: "0 0 var(--border-radius-lg) var(--border-radius-lg)",
                  padding: "12px 14px",
                  display: "flex", flexDirection: "column", gap: 10,
                }}>
                  <div style={{ fontSize: 11, color: "var(--color-text-secondary)" }}>{p.detail}</div>

                  <div style={{ display: "flex", gap: 6, flexWrap: "wrap" }}>
                    {p.tech.map((t) => (
                      <span key={t} style={{
                        fontSize: 10, padding: "2px 8px",
                        background: "var(--color-background-primary)",
                        border: "0.5px solid var(--color-border-secondary)",
                        borderRadius: 99, color: "var(--color-text-secondary)",
                      }}>
                        {t}
                      </span>
                    ))}
                  </div>

                  <div style={{ display: "grid", gridTemplateColumns: "repeat(4,1fr)", gap: 6 }}>
                    {["BOOT", "GROW", "SCALE", "EMPIRE"].map((ph, i) => (
                      <div key={ph} style={{
                        background: "var(--color-background-primary)",
                        border: "0.5px solid var(--color-border-tertiary)",
                        borderRadius: "var(--border-radius-sm)",
                        padding: "6px 8px", textAlign: "center",
                      }}>
                        <div style={{ fontSize: 9, color: "var(--color-text-secondary)", marginBottom: 2 }}>{ph}</div>
                        <div style={{ fontSize: 12, fontWeight: 700, color: p.color }}>{p.rev[i]}€</div>
                      </div>
                    ))}
                  </div>
                </div>
              )}
            </div>
          ))}
        </div>
      )}

      {/* REVENUS */}
      {tab === "revenus" && (
        <div style={{ display: "flex", flexDirection: "column", gap: 14 }}>
          <div style={{
            background: "var(--color-background-primary)",
            border: "0.5px solid var(--color-border-tertiary)",
            borderRadius: "var(--border-radius-lg)",
            padding: "16px",
          }}>
            <div style={{ fontSize: 11, fontWeight: 600, color: "var(--color-text-secondary)", textTransform: "uppercase", letterSpacing: "0.05em", marginBottom: 12 }}>
              Projections par phase — conversion estimée 1–3% (conservateur)
            </div>
            <ResponsiveContainer width="100%" height={200}>
              <BarChart data={PHASES} margin={{ top: 4, right: 4, left: 0, bottom: 4 }}>
                <CartesianGrid strokeDasharray="3 3" stroke="var(--color-border-tertiary)" />
                <XAxis dataKey="label" tick={{ fontSize: 9, fill: "var(--color-text-secondary)" }} />
                <YAxis tickFormatter={(v) => v >= 1000 ? (v / 1000) + "k" : v} tick={{ fontSize: 9, fill: "var(--color-text-secondary)" }} />
                <Tooltip
                  formatter={(v) => [v.toLocaleString() + "€/j", ""]}
                  contentStyle={{ fontSize: 11, borderRadius: 8, border: "0.5px solid var(--color-border-tertiary)" }}
                />
                <Bar dataKey="fr"    fill="#1D9E75" stackId="a" name="FR" />
                <Bar dataKey="en"    fill="#534AB7" stackId="a" name="EN" />
                <Bar dataKey="de"    fill="#BA7517" stackId="a" name="DE" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>

          <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
            {PHASES.map((ph) => (
              <div key={ph.label} style={{
                background: "var(--color-background-primary)",
                border: "0.5px solid var(--color-border-tertiary)",
                borderRadius: "var(--border-radius-md)",
                padding: "10px 14px",
                display: "flex", alignItems: "center", justifyContent: "space-between",
              }}>
                <div>
                  <div style={{ fontSize: 12, fontWeight: 600 }}>{ph.label}</div>
                  <div style={{ fontSize: 10, color: "var(--color-text-secondary)", marginTop: 2 }}>
                    FR:{ph.fr} · EN:{ph.en} · DE:{ph.de}
                  </div>
                </div>
                <div style={{ fontSize: 18, fontWeight: 800, color: "#1D9E75" }}>
                  {ph.total.toLocaleString()}€/j
                </div>
              </div>
            ))}
          </div>

          <div style={{
            background: "var(--color-background-primary)",
            border: "0.5px solid var(--color-border-tertiary)",
            borderRadius: "var(--border-radius-lg)",
            padding: "14px 16px",
          }}>
            <div style={{ fontSize: 11, fontWeight: 600, color: "var(--color-text-secondary)", textTransform: "uppercase", letterSpacing: "0.05em", marginBottom: 10 }}>
              Coûts infra mensuels
            </div>
            {[
              ["VPS Hetzner CX22",          "5.49€"],
              ["Claude Haiku (9 scripts/j)", "~0.50€"],
              ["ElevenLabs Starter",         "5€"],
              ["Make.com Free",              "0€"],
              ["TOTAL",                      "~11€"],
            ].map(([k, v]) => (
              <div key={k} style={{
                display: "flex", justifyContent: "space-between",
                padding: "6px 0",
                borderBottom: k !== "TOTAL" ? "0.5px solid var(--color-border-tertiary)" : "none",
                fontWeight: k === "TOTAL" ? 700 : 400,
              }}>
                <span style={{ fontSize: 12, color: "var(--color-text-primary)" }}>{k}</span>
                <span style={{ fontSize: 12, color: k === "TOTAL" ? "#1D9E75" : "var(--color-text-secondary)" }}>
                  {v}/mois
                </span>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* SETUP */}
      {tab === "setup" && (
        <div style={{ display: "flex", flexDirection: "column", gap: 12 }}>

          {/* Progress bar */}
          <div style={{
            background: "var(--color-background-primary)",
            border: "0.5px solid var(--color-border-tertiary)",
            borderRadius: "var(--border-radius-lg)",
            padding: "14px 16px",
          }}>
            <div style={{ display: "flex", justifyContent: "space-between", marginBottom: 8 }}>
              <span style={{ fontSize: 11, fontWeight: 600, color: "var(--color-text-secondary)", textTransform: "uppercase", letterSpacing: "0.05em" }}>
                Progression
              </span>
              <span style={{ fontSize: 11, fontWeight: 700, color: "#1D9E75" }}>
                {pct}% — {done}/{steps.length}
              </span>
            </div>
            <div style={{ height: 6, background: "var(--color-border-tertiary)", borderRadius: 99, overflow: "hidden" }}>
              <div style={{ height: "100%", width: `${pct}%`, background: "#1D9E75", borderRadius: 99, transition: "width 0.3s" }} />
            </div>
          </div>

          {/* Checklist */}
          <div style={{ display: "flex", flexDirection: "column", gap: 6 }}>
            {steps.map((s, i) => (
              <div
                key={i}
                onClick={() => toggleStep(i)}
                style={{
                  display: "flex", gap: 10, alignItems: "center",
                  padding: "10px 14px",
                  background: "var(--color-background-primary)",
                  border: "0.5px solid var(--color-border-tertiary)",
                  borderRadius: "var(--border-radius-md)",
                  borderLeft: `3px solid ${s.done ? "#1D9E75" : "var(--color-border-tertiary)"}`,
                  cursor: "pointer",
                  opacity: s.done ? 0.75 : 1,
                }}
              >
                <span style={{ fontSize: 14 }}>{s.done ? "✅" : "⬜"}</span>
                <span style={{
                  fontSize: 12,
                  color: "var(--color-text-primary)",
                  textDecoration: s.done ? "line-through" : "none",
                }}>
                  {i + 1}. {s.label}
                </span>
              </div>
            ))}
          </div>

          {/* .env block */}
          <div style={{
            background: "var(--color-background-primary)",
            border: "0.5px solid var(--color-border-tertiary)",
            borderRadius: "var(--border-radius-lg)",
            overflow: "hidden",
          }}>
            <div style={{
              display: "flex", justifyContent: "space-between", alignItems: "center",
              padding: "10px 14px",
              borderBottom: "0.5px solid var(--color-border-tertiary)",
            }}>
              <span style={{ fontSize: 11, fontWeight: 600, color: "var(--color-text-secondary)", textTransform: "uppercase", letterSpacing: "0.05em" }}>
                .env — Variables requises
              </span>
              <button
                onClick={copy}
                style={{
                  fontSize: 10, padding: "3px 10px", fontFamily: "inherit",
                  background: copied ? "#E1F5EE" : "var(--color-background-secondary)",
                  color: copied ? "#1D9E75" : "var(--color-text-secondary)",
                  border: "0.5px solid var(--color-border-secondary)",
                  borderRadius: "var(--border-radius-sm)", cursor: "pointer",
                }}
              >
                {copied ? "✅ Copié" : "Copier"}
              </button>
            </div>
            <pre style={{
              padding: "12px 14px", fontSize: 11, lineHeight: 1.7,
              fontFamily: "monospace",
              background: "#1a1a2e",
              color: "#a8e6cf",
              overflowX: "auto",
            }}>
              {ENV_TEMPLATE}
            </pre>
          </div>
        </div>
      )}
    </div>
  );
}

// Andromeda's solid cosmic palette. Aurora supplies the derivation engine.
import { resolveTokens } from "@eamonxg/luci-theme-tokens/aurora";

export const COLORS = {
  light: {
    bg: "oklch(0.98 0.008 285)",
    surface: "oklch(1 0 0)",
    text: "oklch(0.24 0.04 275)",
    brand: "oklch(0.49 0.22 285)",
    on_brand: "oklch(1 0 0)",
    link: "oklch(0.47 0.20 285)",
    info: "oklch(0.46 0.12 230)",
    warning: "oklch(0.43 0.10 80)",
    success: "oklch(0.40 0.10 160)",
    danger: "oklch(0.46 0.18 20)",
  },
  dark: {
    bg: "oklch(0.16 0.035 275)",
    surface: "oklch(0.22 0.035 275)",
    text: "oklch(0.95 0.015 275)",
    brand: "oklch(0.72 0.14 285)",
    on_brand: "oklch(0.16 0.035 275)",
    link: "oklch(0.78 0.12 280)",
    info: "oklch(0.80 0.10 225)",
    warning: "oklch(0.82 0.13 80)",
    success: "oklch(0.76 0.13 160)",
    danger: "oklch(0.76 0.14 20)",
  },
};

export function resolveMode(mode) {
  const tokens = resolveTokens(mode, { ...COLORS[mode] });
  // Small table headings need the same readable contrast as secondary text.
  tokens.text_subtle = tokens.text_muted;
  return tokens;
}

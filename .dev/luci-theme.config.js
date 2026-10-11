// Theme identity read by the Vite build (vite.config.ts) and the devkit dev
// layer / bins (@eamonxg/luci-theme-devkit). Everything theme-specific lives
// here; the machinery is generic.
export default {
  name: "andromeda", // media dir (/luci-static/andromeda) + ucode theme dir
  css: ["main", "login"], // src/media/<e>.css → /luci-static/andromeda/<e>.css
  resources: ["menu-andromeda"], // src/resource/<m>.js served at /luci-static/resources/<m>.js in dev
  assets: { dir: "public/andromeda" }, // served under /luci-static/andromeda/ in dev
  patchAliases: {}, // built patch payloads duplicated under extra page names
};

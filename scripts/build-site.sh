#!/usr/bin/env bash
# Assemble the GitHub Pages site: copy each PDF to <site>/<repo path> and
# write an index.html that lists them grouped by directory.
#
# Usage: scripts/build-site.sh <site-dir> <pdf>...
set -euo pipefail

site=$1
shift

rm -rf "$site"
mkdir -p "$site"
touch "$site/.nojekyll"   # serve files as-is, no Jekyll processing

html_escape() {
  local s=$1
  s=${s//&/&amp;}
  s=${s//</&lt;}
  s=${s//>/&gt;}
  s=${s//\"/&quot;}
  printf '%s' "$s"
}

# "double-reverse-4-bar-derivation" → "Double reverse 4 bar derivation"
pretty_name() {
  local s=${1//-/ }
  s=${s//_/ }
  printf '%s' "${s^}"
}

# Sort so top-level papers come first, then each subdirectory in order.
mapfile -t pdfs < <(
  for pdf in "$@"; do
    dir=$(dirname "$pdf")
    [[ $dir == . ]] && key=0 || key="1$dir"
    printf '%s\t%s\n' "$key" "$pdf"
  done | LC_ALL=C sort | cut -f2
)

{
  cat <<'EOF'
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Papers</title>
<style>
  :root { color-scheme: light dark; }
  body { font: 16px/1.5 system-ui, sans-serif; max-width: 46rem; margin: 2.5rem auto; padding: 0 1.25rem; }
  h1 { margin-bottom: 0.25rem; }
  h2 { font-size: 1.05rem; margin-top: 2rem; border-bottom: 1px solid #8884; padding-bottom: 0.25rem; }
  ul { list-style: none; padding: 0; }
  li { margin: 0.3rem 0; }
  a { text-decoration: none; }
  a:hover { text-decoration: underline; }
  .path { color: #888; font-size: 0.85em; margin-left: 0.5rem; }
  footer { margin-top: 3rem; color: #888; font-size: 0.85em; }
</style>
</head>
<body>
<h1>Papers</h1>
EOF

  current=
  for pdf in "${pdfs[@]}"; do
    mkdir -p "$site/$(dirname "$pdf")"
    cp "$pdf" "$site/$pdf"

    dir=$(dirname "$pdf")
    [[ $dir == . ]] && heading="Papers" || heading=$dir
    if [[ $heading != "$current" ]]; then
      [[ -n $current ]] && echo "</ul>"
      echo "<h2>$(html_escape "$heading")</h2>"
      echo "<ul>"
      current=$heading
    fi
    name=$(pretty_name "$(basename "$pdf" .pdf)")
    echo "<li><a href=\"$(html_escape "$pdf")\">$(html_escape "$name")</a><span class=\"path\">$(html_escape "$pdf")</span></li>"
  done
  [[ -n $current ]] && echo "</ul>"

  echo "<footer>Built $(date -u '+%Y-%m-%d %H:%M UTC')${GITHUB_SHA:+ from ${GITHUB_SHA:0:7}}.</footer>"
  echo "</body>"
  echo "</html>"
} > "$site/index.html"

echo "✔ Site assembled in $site/ (${#pdfs[@]} PDFs)."

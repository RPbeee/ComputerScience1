#!/bin/zsh
# 使い方: tools/build-pdf.sh 1st.md [2nd.md ...]   → 同じ場所に .pdf を出力
set -euo pipefail
here=${0:A:h}
(( $# )) || { echo "usage: $0 file.md ..." >&2; exit 1 }
tmp=$(mktemp -d); trap 'rm -rf $tmp' EXIT
for md in "$@"; do
  out=${md%.md}.pdf
  # 前処理: __強調__→太字 / ####注 の空白補完 / **見出し** 後の空行 / ### 1. → ### 問1
  sed -E -e 's/^(#+)([^# ])/\1 \2/' -e 's/__([^_]+)__/**\1**/g' \
         -e 's/^(\*\*[^*]+\*\*)$/\1\n/' -e 's/^### ([0-9]+)\./### 問\1/' "$md" \
    | LC_ALL=C awk '/^```/{ if(!f){f=1; if($0=="```") $0="```text"} else f=0 } {print}' | LC_ALL=C awk -f $here/detail.awk > $tmp/in.md
  pandoc $tmp/in.md -o "$out" --pdf-engine=xelatex -f markdown+east_asian_line_breaks \
    -V CJKmainfont="Hiragino Sans" -V mainfont="Hiragino Sans" -V monofont="Menlo" \
    -V geometry:margin=22mm -V fontsize=11pt -H $here/header.tex --lua-filter=$here/box.lua --syntax-highlighting=tango
  echo "created: $out"
done

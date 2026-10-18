-- ::: kaisetsu ... ::: を枠(tcolorbox)に変換
function Div(el)
  if el.classes:includes("kaisetsu") then
    local out = {pandoc.RawBlock("latex",
      "\\begin{kaisetsu}")}
    for _, b in ipairs(el.content) do out[#out+1] = b end
    out[#out+1] = pandoc.RawBlock("latex", "\\end{kaisetsu}")
    return out
  end
end

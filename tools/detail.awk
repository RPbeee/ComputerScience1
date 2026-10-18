# 「**細かい解説**」から次の見出し/太字見出しまでを ::: kaisetsu で囲む(コードブロック内は無視)
function close_box() { if (inbox) { print ""; print ":::"; print ""; inbox=0 } }
/^```/ { fence = !fence }
{
  if (!fence && $0 == "**細かい解説**") { close_box(); print ""; print "::: kaisetsu"; inbox=1; next }
  if (!fence && inbox && ($0 ~ /^#/ || $0 ~ /^\*\*[^*]+\*\*$/)) close_box()
  print
}
END { close_box() }

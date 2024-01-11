#!/bin/bash
# (C) Simon Urbanek, License: MIT

set -e

if [ -e RJwrapper.tex-orig ]; then
    echo "** Using original wrapper"
    cp RJwrapper.tex-orig RJwrapper.tex
fi

tex=$(sed -n 's/.*\\input{//p' RJwrapper.tex | sed 's:}.*::')
echo "LaTeX file: $tex.tex"

if echo $tex | grep ^RJ- >/dev/null; then
    echo "ERROR: I need the original RJwrapper - please use"
    echo "  mv RJwrapper.tex RJwrapper.tex-md"
    echo "  cp .../RJwrapper.tex RJwrapper.tex-orig"
    exit 1
fi

if [ ! -e RJwrapper.bbl ]; then
    echo " - generating bib entries"
   
    latexmk -pdf -C RJwrapper
    latexmk -pdf RJwrapper 
fi

slug=$(basename `pwd`)

if [ -e "$slug.Rmd-orig" ]; then
    echo "** Note: reverting to previous Rmd-orig version"
    mv "$slug.Rmd-orig" "$slug.Rmd"
fi

Rscript --no-save - <<EOF
cat("Using $tex.tex, slug: $slug\n")
a=readLines("$tex.tex")
i<-grep("\\\\\\\\section.*Introduction", a)
b<-grep("\\\\\\\\bibliography", a)
if (length(i) == 1 && length(b) == 1 && b > i) {
  cat("Writing $slug-src.tex\n")
  writeLines(a[i:(b-1)], "$slug-src.tex")
} else {
  stop("Invalid tex source")
}
bi=readLines("RJwrapper.bbl")
noc=sapply(grep("^\\\\\\\\bibitem", bi), function(i) {
q=bi[i:min(length(bi),i+3)]
eb=grep("\\\\]",q)
q=q[eb[1]]
gsub("\\\\}.*","",gsub(".*\\\\]\\\\{","",q))
})
noc=paste0('@',noc,collapse=',')
noc=c("nocite: |", paste0("  ", noc))
a=readLines("$slug.Rmd")
i=grep("^---", a)
## only use the first two
if (length(i) && sum(i > 1) > 1) i = i[1:2]
if (length(i) && sum(i > 1) == 1) {
  i = i[i>1] 
  a = a[1:i]
  bi = grep("^bibliography:", a)
  if (!length(grep("^preamble:", a)) && file.exists("preamble.tex")) noc = c("preamble: \\\\input{preamble.tex}",noc)
  a = c(a[1:(bi-1)], "tex_native: yes", noc, a[bi:length(a)])
  writeLines(a, "$slug.Rmd-new")
} else {
  stop("Cannot identify metadata in Rmd file")
}
EOF

mv "$slug.Rmd" "$slug.Rmd-orig" && mv "$slug.Rmd-new" "$slug.Rmd"

cat >> "$slug.Rmd" <<EOF
\`\`\`{=latex}
\\input{$slug-src.tex}
\`\`\`
EOF

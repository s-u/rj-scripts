#!/bin/bash
#
# renders proofs (typically in th2 Proofs/YYYY-NN directory) both
# in pdf (always) and web (for Rmd papers). It attempts to detect whether
# the article is Rmd or TeX. In the fromer case it stores the name
# of the Rmd in ../rmd-<ID>
# on success it creates tag files in ../log/<ID>-<type>-OK (if present)
#
# (C) Simon Urbanek, License: MIT

OWD="`pwd`"
if [ -n "$1" ]; then
    cd "$OWD/$1"
fi

if [ ! -e DESCRIPTION ]; then
    echo "Cannot find DESCRIPTION file"
    exit 1
fi

id=`pwd|sed 's:.*/::'`

rmd=`ls *.[Rr]md 2>/dev/null`
nrmd=`ls *.[Rr]md 2>/dev/null|wc -l|sed 's:^ *::'`

if [ ! -d "../log" ]; then mkdir ../log; fi

if [ -z "$CLEAN" -o "x$CLEAN" = x0 ]; then
    CLEAN=FALSE
else
    CLEAN=TRUE
fi

if [ "$nrmd" = 0 ]; then
    echo $id: TeX
    rm -f RJwrapper.pdf
    STY=$(Rscript -e 'cat(system.file("tex","RJournal.sty",package="rjtools"))')
    if [ -n "$STY" -a -e "$STY" ]; then
	rm -f RJournal.sty
	cp -p "$STY" .
    fi
    latexmk -C -pdf RJwrapper
    latexmk -pdf RJwrapper && touch ../log/$id-tex-OK
elif [ "$nrmd" = 1 ]; then
    echo "$id: Rmd ($rmd)"
    echo $rmd > ../rmd-$id
    echo " - PDF"
    fbase=$(echo $rmd|sed 's:\.[Rr]md$::')
    if [ -z "$fbase" ]; then
	echo "$id: *** ERROR - cannot determine output file base name"
	exit 1
    fi
    rm -f "${fbase}.pdf" RJwrapper.pdf
    Rscript -e "rmarkdown::render('$rmd', 'rjtools::rjournal_pdf_article', output_options=list(), clean=$CLEAN)" && touch ../log/$id-rmd-pdf-OK && cp "${fbase}.pdf" RJwrapper.pdf
    Rscript -e "rmarkdown::render('$rmd', 'rjtools::rjournal_web_article', output_options=list(), clean=$CLEAN)" && touch ../log/$id-rmd-web-OK
else
    echo "$id: *** ERROR - more than one Rmd ***"
    exit 1
fi

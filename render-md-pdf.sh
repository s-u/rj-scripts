#!/bin/bash

if [ -z "$1" ]; then
    if [ "`ls *.[Rr]md | wc -l | sed 's: *::'`" != 1 ]; then
	echo "ERROR: cannot find unique Rmd file"
	ls -l *.[Rr]md
	exit 1
    fi
    md=`ls *.[Rr]md`
else
    md="$1"
fi

echo " - Rendering $md"

Rscript -e 'rmarkdown::render("'"$md"'", "rjtools::rjournal_pdf_article", output_options=list(), clean=FALSE)'

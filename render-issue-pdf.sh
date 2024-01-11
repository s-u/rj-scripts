#!/bin/bash

if ! command -v pdftk >/dev/null; then
    echo pdftk is not on the PATH
    for i in /opt/R/`uname -m` /usr/local /usr/local/pdftk /Volumes/Builds/unix/pdftk/pdftk; do
	if [ -x $i/bin/pdftk ]; then
	    echo Found pdftk in $i
	    export PATH=$PATH:$i/bin
	    break
	fi
    done
    if ! command -v pdftk >/dev/null; then
	echo ERROR: cannot find pdftk - please install it first
	exit 1
    fi
fi

ISSUE=$(basename `pwd`)
if [ ! -e "$ISSUE.Rmd" ]; then
    echo "ERROR: missing $ISSUE.Rmd - run me from the issue directory" >&2
    exit 1
fi

Rscript -e 'rmarkdown::render("'$ISSUE'.Rmd", "rjtools::rjournal_pdf_issue", output_options=list())'

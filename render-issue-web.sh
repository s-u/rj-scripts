#!/bin/bash

ISSUE=$(basename `pwd`)
if [ ! -e "$ISSUE.Rmd" ]; then
    echo "ERROR: missing $ISSUE.Rmd - run me from the issue directory" >&2
    exit 1
fi

Rscript -e 'rmarkdown::render("'$ISSUE'.Rmd", "rjtools::rjournal_web_issue", output_options=list())'

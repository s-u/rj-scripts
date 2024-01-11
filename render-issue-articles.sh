#!/bin/bash
#
# Usage: render-issue-articles.sh [YYYY-V]
#
# Renders all articles from an issue. If no issue is specified,
# a) uses current directory (if it is an issue directory) else
# b) uses last issue
#
# Creates 00render-(web|pdf}.log in each article directory and
# web-OK and/or pdf-OK on success
#
# (C) Simon Urbanek, License: MIT

where=
for i in . .. ../.. ../rjournal.github.io/ ../../rjournal.github.io ../../rjournal.github.io; do
    if [ -d $i/_articles ]; then
	where=$( cd "$i/_articles" && pwd )
	break
    fi
done
if [ -z "$where" ]; then
    echo "Error: cannot find _articles"
    exit 1
fi

if [ -n "$1" ]; then
    ISSUE="$1"
else
    ISSUE=$(basename `pwd` | grep -E '^20[0-9]{2}-[0-9]$')
    if [ -z "$ISSUE" -o ! -e "$ISSUE.Rmd" ]; then
	ISSUE=$(ls $where/../_issues | grep ^20 | tail -n1)
	echo "WARNING: no issue found in the current directory, assuming last issue: $ISSUE"
    fi
fi

ISSUE0=$(echo $ISSUE | grep -E '^20[0-9]{2}-[0-9]$')
if [ -z "$ISSUE0" ]; then
    echo Sorry, invalid issue format: $ISSUE, must be YYYY-V
    exit 1
fi

IYEAR=$(echo $ISSUE | sed 's:-.*::')
INUM=$(echo $ISSUE | sed 's:.*-::')
IVOL=$(expr $IYEAR - 2008)

echo "Rendering articles for issue $ISSUE (volume $IVOL, issue $INUM)"

## Unfortunately slugs don't correspond to year due to a bug in rj, so search all to make sure
## NOTE: this is quite fragile as it assumes issue: follows volume:, but more exact search will slow things down too much
for i in `grep -A1 -i "volume: *$IVOL *\$" $where/RJ-20??-???/RJ-20??-???.Rmd | grep -i "issue: *$INUM *\$" | sed 's/:.*//'`; do (
    id=$(basename `dirname $i`)
    cd $where/$id
    if [ -z "$UPDATE" -o ! -e "$id.html" ]; then
	Rscript -e 'rmarkdown::render("'$id'.Rmd", "rjtools::rjournal_web_article", output_options=list(), clean=FALSE)' > 00render-web.log 2>&1 && touch web-OK && echo ' - web OK'
    fi
    if [ -z "$UPDATE" -o ! -e "$id.pdf" ]; then
	Rscript -e 'rmarkdown::render("'$id'.Rmd", "rjtools::rjournal_pdf_article", output_options=list(), clean=FALSE)' > 00render-pdf.log 2>&1 && touch pdf-OK && echo ' - pdf OK'
    fi
); done

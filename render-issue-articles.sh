where=
for i in . .. ../.. ../rjournal.github.io/ ../../rjournal.github.io ../../rjournal.github.io; do
    if [ -d $i/_articles ]; then
	where="$i/_articles"
	break
    fi
done
if [ -z "$where" ]; then
    echo "Error: cannot find _articles"
    exit 1
fi

## FIXME: how do we get the correct issue pattern?
for i in `ls -d $where/RJ-2023-0[45]?`; do (
    cd $i
    id=`echo $i|sed 's:.*/::'`
    echo $i
    if [ -z "$UPDATE" -o ! -e "$id.html" ]; then
	Rscript -e 'rmarkdown::render("'$id'.Rmd", "rjtools::rjournal_web_article", output_options=list(), clean=FALSE)' > 00render-web.log 2>&1 && touch web-OK && echo ' - web OK'
    fi
    if [ -z "$UPDATE" -o ! -e "$id.pdf" ]; then
	Rscript -e 'rmarkdown::render("'$id'.Rmd", "rjtools::rjournal_pdf_article", output_options=list(), clean=FALSE)' > 00render-pdf.log 2>&1 && touch pdf-OK && echo ' - pdf OK'
    fi
); done

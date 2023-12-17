echo Rscript -e "'"'rmarkdown::render("'`pwd|sed 's:.*/::'`'.Rmd", "rjtools::rjournal_web_article", output_options=list(), clean=FALSE)'"'"

Rscript -e 'rmarkdown::render("'`pwd|sed 's:.*/::'`'.Rmd", "rjtools::rjournal_web_article", output_options=list(), clean=FALSE)'

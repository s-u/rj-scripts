Rscript -e 'rmarkdown::render("'`pwd|sed 's:.*/::'`'.Rmd", "rjtools::rjournal_pdf_article", output_options=list(), clean=FALSE)'

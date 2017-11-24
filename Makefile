# Options for name (remember that .tex extension is not needed):
# article.tex
# cv.tex
# letter.tex
# presentation.tex
# standalone.tex
#
NAME="standalone"

# The final name of the .pdf file (without extension). Defaults to original
# name with "_FINAL" appended. In my setup, works "out of the box" with spaces,
# foreigh chars, ...
# I also use this to keep a "full version" of a large document (for
# consultation only), while writing on a reduced version (\includeonly, etc...)
ENDNAME="$(NAME)_FINAL"

TEXCMD=lualatex
TEXCMDOPTS=--interaction=batchmode --shell-escape --synctex=1
DEBUG_TEXCMDOPTS=--interaction=errorstopmode --shell-escape --synctex=1
BIBCMD=biber

all : 
	$(TEXCMD) $(TEXCMDOPTS) $(NAME)

debug :
	$(TEXCMD) $(DEBUG_TEXCMDOPTS) $(NAME)

full :
	$(TEXCMD) $(TEXCMDOPTS) $(NAME)
	$(BIBCMD) $(NAME)
	$(TEXCMD) $(TEXCMDOPTS) $(NAME)
	$(TEXCMD) $(TEXCMDOPTS) $(NAME)

final :
	make full
	cp $(NAME).pdf $(ENDNAME).pdf

clean :
	rm -f *.{dvi,ps,aux,log,out,toc,gnuplot,table,vrb} *.synctex.gz
	rm -f *.{bcf,bbl,blg,ent,run.xml,acn,acr,alg,glg,glo,xdy}
	rm -f *.{gls,glsdefs,ind,idx,ilg,ist,lol,lof,lot} *-blx.bib

# see Note (1)
get_compiler_pid :
	pidof $(TEXCMD) || echo -n ""

.PHONY : all debug full clean name_final get_compiler_pid

# NOTES
#
# (1) - `pidof` sets $? to 1 if no process of the given name is running, which
# in turn causes `make` to spew a lengthy error message; the `echo` hack makes it
# work properly.

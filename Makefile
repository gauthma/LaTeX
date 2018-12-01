# Options for name (remember that .tex extension is not needed):
# report.tex
# cv.tex
# letter.tex
# llncs.tex
# presentation.tex
# standalone.tex
#
NAME="report"

# The final name of the .pdf file (without extension). Defaults to original
# name with "_FINAL" appended. In my setup, works "out of the box" with spaces,
# foreigh chars, ...
ENDNAME="$(NAME)_FINAL"

# See Note (2)
TEXCMD=xelatex
TEXCMDOPTS=--interaction=batchmode --shell-escape --synctex=1
DEBUG_TEXCMDOPTS=--interaction=errorstopmode --shell-escape --synctex=1
BIBCMD=bibtex

all :
	$(TEXCMD) $(TEXCMDOPTS) $(NAME)

debug :
	$(TEXCMD) $(DEBUG_TEXCMDOPTS) $(NAME)

full :
	$(TEXCMD) $(TEXCMDOPTS) $(NAME)
	$(BIBCMD) $(NAME)
	$(TEXCMD) $(TEXCMDOPTS) $(NAME)
	$(TEXCMD) $(TEXCMDOPTS) $(NAME)

# Runs in subdir created by Fullcopy target.
# Comments out all the \includeonly, if any
# (so as to produce a Fullcopy).
_Fullcopy_subdir :
	sed -e '/^\s*\\includeonly/ s/^/% /' -i $(NAME).tex
	${MAKE} full

Fullcopy :
	mkdir -p _FULLCOPY
	cp -r `ls | grep -v _FULLCOPY` _FULLCOPY/
	${MAKE} -C _FULLCOPY _Fullcopy_subdir
	mv "_FULLCOPY/$(NAME).pdf" "Fullcopy.pdf"

final :
	${MAKE} clean
	${MAKE} full
	cp "$(NAME).pdf" "$(ENDNAME).pdf"

clean :
	rm -f *.{dvi,ps,aux,log,out,toc,gnuplot,table,vrb} *.synctex.gz
	rm -f *.{bcf,bbl,blg,ent,run.xml,acn,acr,alg,glg,glo,xdy}
	rm -f *.{gls,glsdefs,ind,idx,ilg,ist,lol,lof,lot,brf} *-blx.bib

# See Note (1)
get_compiler_pid :
	pidof $(TEXCMD) || echo -n ""

.PHONY : all debug full Fullcopy final clean get_compiler_pid

# NOTES
#
# (1) - `pidof` sets $? to 1 if no process of the given name is running, which
# in turn causes `make` to spew a lengthy error message; the `echo` hack makes it
# work properly.
# (2) - For `llncs` and `presentation` uses pdflatex:
# TEXCMD=pdflatex
# BIBCMD=bibtex

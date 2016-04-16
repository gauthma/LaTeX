# Options for name (remember that .tex extension is not needed):
# article.tex
# cv.tex
# letter.tex
# presentation.tex
# tikzfig.tex
#
NAME="article"

# Optional: the final name of the .pdf file (without extension).
# In my setup, works "out of the box" with spaces, foreigh chars, ...
# ENDNAME="my complicated file name"
ENDNAME=$(NAME)

# IMPORTANT: before changing this, see Note (1)
TEXCMD=lualatex
TEXCMDOPTS=--interaction=batchmode --shell-escape
DEBUG_TEXCMDOPTS=--interaction=errorstopmode --shell-escape
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

clean :
	rm -f *.{dvi,ps,aux,log,out,toc,gnuplot,table,vrb}
	rm -f *.{bcf,bbl,blg,ent,run.xml,acn,acr,alg,glg,glo,xdy}
	rm -f *.{gls,glsdefs,ind,idx,ilg,ist,lol,lof,lot} *-blx.bib

name_final :
	mv $(NAME).pdf $(ENDNAME).pdf

# see Note (2)
get_compiler_pid :
	pidof $(TEXCMD) || echo -n ""

.PHONY : all debug full clean name_final get_compiler_pid

# NOTES
# (1) - When changing the TEXCMD variable, ~/.vim/ftplugin/tex.vim#BuildOnWrite
# must be changed accordingly (the `pidof` line).
#
# (2) - `pidof` sets $? to 1 if no process of the given name is running, which
# in turn causes `make` to spew a lengthy error message; the `echo` hack makes it
# work properly.

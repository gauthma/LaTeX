NAME="article"

# IMPORTANT: before changing this, see Note (1)
TEXCMD=lualatex
TEXCMDOPTS=--interaction=batchmode --shell-escape
DEBUG_TEXCMDOPTS=--interaction=errorstopmode --shell-escape
BIBCMD=biber
VIEWER=okular

all : 
	$(TEXCMD) $(TEXCMDOPTS) $(NAME)

debug :
	$(TEXCMD) $(DEBUG_TEXCMDOPTS) $(NAME)

big :
	$(TEXCMD) $(TEXCMDOPTS) $(NAME)
	$(BIBCMD) $(NAME)
	$(TEXCMD) $(TEXCMDOPTS) $(NAME)
	$(TEXCMD) $(TEXCMDOPTS) $(NAME)

clean :
	rm -f *.{dvi,ps,aux,log,out,toc,gnuplot,table}
	rm -f *.{bcf,bbl,blg,ent,run.xml,acn,acr,alg,glg,glo,xdy}
	rm -f *.{gls,glsdefs,ind,idx,ilg,ist,lol,lof,lot} *-blx.bib

# see Note (2)
get_compiler_pid :
	pidof $(TEXCMD) || echo -n ""

.PHONY : bib all viewer full clean get_compiler_pid

# NOTES
# (1) - When changing the TEXCMD variable, ~/.vim/ftplugin/tex.vim#BuildOnWrite
# must be changed accordingly (the `pidof` line).
#
# (2) - `pidof` sets $? to 1 if no process of the given name is running, which
# in turn causes `make` to spew a lengthy error message; the `echo` hack makes it
# work properly.

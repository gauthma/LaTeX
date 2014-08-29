NAME="tikzfig"

# IMPORTANT: before changing this, see Note (1)
TEXCMD=lualatex
TEXCMDOPTS=--interaction=nonstopmode --shell-escape
BIBCMD=biber
VIEWER=okular

# shortcut: <F6>
all : 
	$(TEXCMD) $(NAME)	$(TEXCMDOPTS)

# shortcut: <F5>
bib :
	$(BIBCMD) $(NAME)

# shortcut: <F7>
viewer : 
	$(VIEWER) --unique &> /dev/null $(NAME).pdf &

# shortcut: <F8>
full :
	$(TEXCMD) $(NAME)	$(TEXCMDOPTS)
	$(BIBCMD) $(NAME)
	$(TEXCMD) $(NAME)	$(TEXCMDOPTS)
	$(TEXCMD) $(NAME)	$(TEXCMDOPTS)

# shortcut: <F9>
clean :
	rm -f *.{dvi,ps,aux,log,out,toc,gnuplot,table,bbl,blg,ent,run.xml} *-blx.bib

.PHONY : bib all viewer full clean

# NOTES
# (1) - When changing the TEXCMD variable, ~/.vim/ftplugin/tex.vim#BuildOnWrite
# must be changed accordingly (the `pidof` line).

NAME="article_skel"

TEXCMD="lualatex"
TEXCMDOPTS="--interaction=nonstopmode --shell-escape"
BIBCMD="bibtex"
VIEWER="okular"

# shortcut: <F5>
bib :
	$(BIBCMD) $(NAME)
	
# shortcut: <F6>
all : 
	$(TEXCMD) $(TEXCMDOPTS) $(NAME)	

# shortcut: <F6>
viewer : 
	$(VIEWER) &> /dev/null $(NAME).pdf &	

# shortcut: <F8>
full :
	$(TEXCMD) $(TEXCMDOPTS) $(NAME)	
	$(BIBCMD) $(NAME)
	$(TEXCMD) $(TEXCMDOPTS) $(NAME)	
	$(TEXCMD) $(TEXCMDOPTS) $(NAME)	

# shortcut: <F9>
clean :
	rm -f *.{dvi,ps,aux,log,out,toc,gnuplot,table,bbl,blg,ent,run.xml} *-blx.bib

.PHONY : bib all viewer full clean


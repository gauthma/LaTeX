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
# name with ".FINAL" appended. In my setup, works "out of the box" with spaces,
# foreign chars, ...
ENDNAME="$(NAME).FINAL"

BUILD_DIR="build"

# See Note 2.
TEXCMD=xelatex
TEXCMDOPTS=--interaction=batchmode --shell-escape --synctex=1 --output-directory=$(BUILD_DIR)
DEBUG_TEXCMDOPTS=--interaction=errorstopmode --shell-escape --synctex=1 --output-directory=$(BUILD_DIR)
BIBCMD=bibtex

all :
	$(TEXCMD) $(DEBUG_TEXCMDOPTS) $(NAME)

nodebuginfo :
	$(TEXCMD) $(TEXCMDOPTS) $(NAME)

# See Note 3.
full : | clean
	$(TEXCMD) $(TEXCMDOPTS) $(NAME)
	cd $(BUILD_DIR) && $(BIBCMD) $(NAME)
	$(TEXCMD) $(TEXCMDOPTS) $(NAME)
	$(TEXCMD) $(TEXCMDOPTS) $(NAME)
	$(TEXCMD) $(TEXCMDOPTS) $(NAME)

# Runs in subdir created by Unabridged target.
# Comments out all the \includeonly, if any
# (so as to produce a Unabridged copy).
_Unabridged_subdir :
	sed -e '/^\s*\\includeonly/ s/^/% /' -i $(NAME).tex
	${MAKE} full

# Copy contents of current dir to _UNABRIDGED. Change to 
# that dir (-C option) and run _Unabridged_subdir.
Unabridged :
	mkdir _UNABRIDGED
	cp -r `ls | grep -v _UNABRIDGED` _UNABRIDGED/
	${MAKE} -C _UNABRIDGED _Unabridged_subdir
	mv _UNABRIDGED/build/$(NAME).pdf Unabridged.pdf
	rm -rf _UNABRIDGED

# This works, even when $(NAME).pdf is a symlink to the pdf in $(BUILD_DIR).
# Run the compilation command an extra two times, just to be sure (cf. Note 3).
final : | clean full
	$(TEXCMD) $(TEXCMDOPTS) $(NAME)
	$(TEXCMD) $(TEXCMDOPTS) $(NAME)
	cp $(BUILD_DIR)/$(NAME).pdf "$(ENDNAME).pdf"

clean :
	rm -rf $(BUILD_DIR)/*
	ln -sr sources.bib $(BUILD_DIR)

# See Note 1.
get_compiler_pid :
	pidof $(TEXCMD) || echo -n ""

.PHONY : all clean final full get_compiler_pid nodebuginfo Unabridged _Unabridged_subdir

# NOTES
#
# (1) - `pidof` sets $? to 1 if no process of the given name is running, which
# in turn causes `make` to spew a lengthy error message; the `echo` hack makes it
# work properly.
# (2) - For `llncs` and `presentation` uses pdflatex:
# TEXCMD=pdflatex
# BIBCMD=bibtex
# (3) - When running bibtex, we don't need to cd back (-), because each command
# runs in its own shell.
#     - Also, after bibtex, we run latex *3* times (instead of the usual 2)
#     because that is sometimes needed to ensure bibliographic backreferences
#     are correct.

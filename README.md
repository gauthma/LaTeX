My LaTeX templates 
===

These are the templates I use for most of my interactions with
LaTeX. It's somewhat integrated with my Vim settings (see for
example the shortcuts in the Makefile).

The example *LaTeX* files are processed using *LuaTeX.*.

The *addons.tex* file includes code for using images (among a couple
of other stuff). Bear in mind that PDF is a vector format [2], so
including raster images might lead to poor results. You can
ameliorate the problem by trial and error, tweaking scale factors,
image width, etc. 

Usage 
---

```bash
$ mkdir article_dir
$ cd article_dir
$ git clone https://github.com/gauthma/LaTeX.git .
$ rm -rf .git()
```

Do work with LaTeX skeletons provided, compile using adequate
Makefile target and enjoy profit!! You will have to edit `Makefile`
and set `NAME` to the *main file*'s name. Beware: in the makefile,
the command lines *must* start with a *TAB* (not some number of
spaces!!).

The files starting with `inc_` are files that are supposed to be
*included* in another file, and *not* compiled on their own. This
includes the article preamble, as it was getting too long...

The *PRESENTATION* skeleton (*presentation.tex*) depends on the
*projector* class, found [here](http://www.shoup.net/projector/).
Installing it is described in the __TeX Trickery__ section. Also,
when displaying presentations, bold is often more emphasizing than
italics. Thus, the \emph command is redefined to put the text in
bold; for italics there is the \iemph command.

Tweakings
---

### One vs. two columns  

The **inc_preamble.tex** file contains two comments that start
with XXX. One is before the two `\documentclass` lines, and another
is before the `\usepackage[...]{geometry}` lines. The first line of
each pair of lines is to produce an article with *one* column; and
the second of each set is to produce an article with *two* columns.
Comment and uncomment accordingly.

The rationale is that for just one column, we use a 12pt font, and
3.5cm lateral margins. For two columns, 10pt and 1.5 respectively.

### The *microtype* package

The last line in the code for fonts loads the *microtype* package
(commented by default). This package improves the way spacing is
computed, which usually results in an improved layout. However, it
slows down, very noticeably, the compile time; which is why it is
recommended to use (uncomment) it only when producing the final
version.

### The xcolor package

The *documentclass* line contains two options (`usenames` and
`dvipsnames`) that belong to the *xcolor* package, but setting those
options only when loading it might cause conflicts with other
packages that also automagically load *xcolor* (namely *tikz*).
Having those options given to *documentclass* avoids the possibility
of any such conflict.

ArchLinux (AL) packages 
---

The __endnotes__ package can be found in the AL package:
*texlive-latexextra*. The Charis SIL font can be found in an AUR
package, but seems not be working. So for now the best approach
seems to be to get the font's sources from
[here](http://scripts.sil.org/cms/scripts/page.php?item_id=CharisSIL_download#b3a62bff)
and install them as described in the __TeX Trickery__ section.

LaTeX Trickery
---

```tex
\usepackage[bitstream-charter]{mathdesign}
\DeclareSymbolFont{usualmathcal}{OMS}{cmsy}{m}{n}
\DeclareSymbolFontAlphabet{\mathcal}{usualmathcal} 
```

The last two lines are to use the default mathcal font, instead of
the one with bitstream-charter, which is harder to read [1].

TeX Trickery
---
For installing custom fonts, styles, etc., the easiest way is to replicate in
your home directory the TeX Directory Structure [3][4]. The first thing to do is
to discover where is your TeX home:

```bash
$ kpsewhich -var-value=TEXMFHOME
```

In my case it is in `/home/user/texmf`. Create that folder if it does not
exist. The exact location of things depends on what that thing is concretely
(fonts, styles, bib styles, etc.). For our purposes, the projector class goes
in `/home/user/texmf/tex/latex/` and the Charis SIL font (which consist of a
bunch of \*.ttf files) goes in `/home/user/texmf/fonts/truetype/` (create the
sub-folders as needed) .

[1] - http://www.latex-community.org/forum/viewtopic.php?f=48&t=6989   
[2] - http://www.youthedesigner.com/2012/08/12/how-to-explain-raster-vs-vector-to-your-clients/   
[3] - http://en.wikipedia.org/wiki/TeX_Directory_Structure  
[4] - http://tex.stackexchange.com/questions/1137/where-do-i-place-my-own-sty-files-to-make-them-available-to-all-my-tex-files  

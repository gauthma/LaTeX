My LaTeX templates 
===

These are the templates I use for most of my interactions with LaTeX.
It's somewhat integrated with my Vim settings (see for example the
shortcuts in the Makefile).

The example *LaTeX* files are processed using *LuaLaTeX.*.

Bear in mind that PDF is a [vector format][2], so including raster
images might lead to poor results. You can ameliorate the problem by
trial and error, tweaking scale factors, image width, etc.

All of these templates depend on a... *sizable* number of packages.
However, all of these should be available in TeXLive. If such is not the
case, the reader can always install them on a local TeX tree (see the
[TeX Trickery](#tex-trickery) section).

Usage 
---

```bash
$ git clone https://github.com/gauthma/LaTeX.git article_dir
$ cd article_dir
$ sh setup.sh [article, cv, letter, presentation, tikzfig]
```

The `setup.sh` script will edit `Makefile` and set `NAME` to the *main
file*'s name. It will also **remove the .git folder**, in addition to
any undeeded files, depending on the value of its argument. E.g. if
argument is `cv`, then it will remove `article.*`, `letter.*`, etc.

Do work with LaTeX skeletons provided, compile using adequate Makefile
target and enjoy profit!! Beware: in the makefile, the command lines
*must* start with a *TAB* (not some number of spaces!!).

If you need the final PDF document to have a different, then you can use
the `ENDNAME` Makefile variable, together with the `name_final` target.

The files starting with `inc_` are files that are supposed to be
*included* in another file, and *not* compiled on their own. This
includes the article preamble, as it was getting too long...

### The Letter skeleton

It's pretty straightforward, except for one detail: if you don't use
footnotes (i.e. don't have any `\endnote{blah blah}` in the text), then
you must comment out the `\theendnotes` command, otherwise compiling the
document you get an error saying that the `.ent` file was not found.

### The Presention skeleton

The `PRESENTATION` skeleton (`presentation.tex`) depends on the
`projector` class, found [here](http://www.shoup.net/projector/).
Installing it is described in the [TeX Trickery](#tex-trickery) section.
Also, when displaying presentations, bold is often more emphasizing than
italics. Thus, the `\emph` command is redefined to put the text in bold;
for italics there is the `\iemph` command.

For math, include the file `inc_mathematics_presentation.tex`---comment
out if not needed.

### The Tikz skeleton

The file for this is named `tikzfig.tex`. The example is adapted from
[here][5]. I use it as a playground for TikZ. The PDF produced will be a
"full-scale" picture. To include it say, on a presentation, do
`\centering{\graphicbox{figures/quantum_diag}}`.

Tweakings
---

### One vs. two columns  

The **inc_preamble.tex** file contains two comments that start with XXX.
One is before the two `\documentclass` lines, and another is before the
`\usepackage[...]{geometry}` lines. The first line of each pair of lines
is to produce an article with *one* column; and the second of each set
is to produce an article with *two* columns. Comment and uncomment
accordingly.

The rationale is that for just one column, we use a 12pt font, and 3.5cm
lateral margins. For two columns, 10pt and 1.5 respectively.

### Draft mode

The second from last line in the code for fonts loads the `microtype`
package. This package improves the way spacing is computed, which
usually results in an improved layout. However, it slows down, very
noticeably, the compile time; the solution is the line after it, which
indicates to `microtype` that the document is to be processed in draft
mode---which disables all the layout improvements. When producing the
final version, set `draft=false`.

The above method only disables the `microtype` improvements (which
already improves compilation time considerably). But to improve it even
further, you can set *the whole document* in draft mode, by adding
`draft` to the `documentclass` options. This, besides also disabling
`microtype`, further disables all sorts of things, like images,
cross-references, etc. If you use this latter option, there is no need
to disable `microtype`---it is done automagically.

### The xcolor package

The *documentclass* line contains two options (`usenames` and
`dvipsnames`) that belong to the *xcolor* package, but setting those
options only when loading it might cause conflicts with other packages
that also automagically load *xcolor* (namely *tikz*). Having those
options given to *documentclass* avoids the possibility of any such
conflict.

ArchLinux (AL) packages 
---

The __endnotes__ package can be found in the AL package:
*texlive-latexextra*. The Charis SIL font can be found in an AUR
package, but seems not be working. So for now the best approach seems to
be to get the font's sources from
[here](http://software.sil.org/charis/download/) and install them as
described in the [TeX Trickery](#tex-trickery) section.

LaTeX Trickery
---

```tex
\usepackage[bitstream-charter]{mathdesign}
\DeclareSymbolFont{usualmathcal}{OMS}{cmsy}{m}{n}
\DeclareSymbolFontAlphabet{\mathcal}{usualmathcal} 
```

The last two lines are to use the default mathcal font, instead of the
one with bitstream-charter, which is [harder to read][1].

TeX Trickery
---

For installing custom fonts, styles, etc., the easiest way is to
replicate in your home directory the TeX Directory Structure (details
[here][3] and [here][4]). The first thing to do is to discover where is
your TeX home:

```bash
$ kpsewhich -var-value=TEXMFHOME
```

In my case it is in `/home/user/.texmf`[^1]. Create that folder if it
does not exist. The exact location of things depends on what that thing
is concretely (fonts, styles, bib styles, etc.). For our purposes, the
projector class goes in `/home/user/.texmf/tex/latex/` and the Charis
SIL font (which consist of a bunch of `\*.ttf` files) goes in
`/home/user/.texmf/fonts/truetype/` (create the sub-folders as needed).

More generally, the first thing to do, to discover where whatever you
want to install should be installed, is using a tool named `kpsewhich`,
which should get installed when you install LaTeX. It can be used to do
a lot of things (`$ kpsewhich --help`), but the one we’re interested in
here, location of styles, uses the `--show-path NAME` option. The list
of allowed names is part of the output of the `--help-formats` option.
So for instance, to discover where to place BiBTeX style files
(`*.bst`), run:

~~~ bash
kpsewhich --show-path bst
~~~

This will output a list of locations where BiBTeX style files are
searched for. So if you have a file called `mystyle.bst`, create a
folder named "mystyle" in the appropriate location (I use
`/home/user/.texmf/bibtex/bst/`), and put `mystyle.bst` inside the
folder you just created. Then run `$ texhash .` (don't forget the dot!)
from the "appropriate location" folder you used. And you're done!

----

[^1]: The default for me was `/home/user/texmf`. But if you don't want
		yet another directory littering your $HOME, you can change it like
		described [here][6]. In my case it amounted to (replace `~/.texmf`
		with whatever location you like):

```bash
$ mv ~/texmf ~/.texmf
$ mkdir -p ~/.texmf/web2c
$ cp /usr/share/texmf-dist/web2c/texmf.cnf .texmf/web2c/
# change the TEXMFHOME line to look like this: "TEXMFHOME = ~/.texmf", 
$ vim .texmf/web2c/texmf.cnf
$ echo -e "TEXMFCNF=$HOME/.texmf/web2c\nexport TEXMFCNF" >> ~.bashrc
$ source ~/.bashrc
```

[1]: http://www.latex-community.org/forum/viewtopic.php?f=48&t=6989   
[2]: http://www.youthedesigner.com/2012/08/12/how-to-explain-raster-vs-vector-to-your-clients/   
[3]: http://en.wikipedia.org/wiki/TeX_Directory_Structure  
[4]: http://tex.stackexchange.com/questions/1137/where-do-i-place-my-own-sty-files-to-make-them-available-to-all-my-tex-files  
[5]: http://www.texample.net/tikz/examples/quantum-circuit/  
[6]: http://www.tex.ac.uk/cgi-bin/texfaq2html?label=privinst

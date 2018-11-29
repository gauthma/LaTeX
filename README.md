My LaTeX templates 
===

These are the templates I use for most of my interactions with LaTeX. It's somewhat integrated with my Vim settings (see for example the shortcuts in the Makefile).

The example *LaTeX* files are processed using *XeLaTeX.*.

Bear in mind that PDF is a [vector format][2], so including raster images might lead to poor results. You can ameliorate the problem by trial and error, tweaking scale factors, image width, etc.

All of these templates depend on a... *sizable* number of packages. However, all of these should be available in TeXLive. If such is not the case, the reader can always install them on a local TeX tree (see the [TeX Trickery](#tex-trickery) section).

Usage 
---

```bash
$ git clone https://github.com/gauthma/LaTeX.git document_dir
$ cd document_dir
$ sh setup.sh [cv, letter, llncs, presentation, report, standalone]
```

The `setup.sh` script will edit `Makefile` and set `NAME` to the *main file*'s name. It will also **remove the .git folder**, in addition to any undeeded files, depending on the value of its argument. E.g. if argument is `cv`, then it will remove `report.*`, `letter.*`, etc.

**Warning**: the script requires **GNU sed** to edit the `Makefile`; if you don't have it, then comment that line and edit the `Makefile` manually.

Do work with LaTeX skeletons provided, compile using adequate `Makefile` target and enjoy profit!! Beware: in the makefile, the command lines *must* start with a *TAB* (not some number of spaces!!). The workings of the `Makefile` targets are as follows:

- `all`: default target; run `LaTeX` compiling command once, without debug output. 

- `debug`: run `LaTeX` compiling command once, *with* debug output. 

- `full`: run `LaTeX` command, then `BibTeX` command, then `LaTeX` command twice more. This is to put properly all references, TOC, etc.

- `Fullcopy` (`_Fullcopy_subdir` is an auxilliary target for this one): create a "full copy" of the current document, named `Fullcopy.pdf`. This is useful when working with large documents, `\include[ing]only` a part of them; this target allows to keep an updated copy of the full version, should it be required for consultation (happens to me with some frequency).

- `final`: runs the `clean` target (see below) and them makes a `full` build. If you need the final PDF document to have a different name, then you can use the `ENDNAME` variable, which the last command in this target sets as its name.

- `clean`: removes the files matching the patterns in the `.gitignore` file.

- `get_compiler_pid`: used in the `vim` code that builds the `LaTeX` command on writing the `.tex` file (see [myvim](https://github.com/gauthma/myvim)).

The files starting with `inc_` are files that are supposed to be *included* in another file, and *not* compiled on their own. This includes the report preamble, as it was getting too long...

### The Letter skeleton

It's pretty straightforward, except for one detail: if you don't use footnotes (i.e. don't have any `\endnote{blah blah}` in the text), then you must comment out the `\theendnotes` command, otherwise compiling the document you get an error saying that the `.ent` file was not found.

### The llncs skeleton

Like an article, using Springer's `llncs` style (including bibliography), which is assumed installed. Useful because it is designed to run with `pdflatex` and `bibtex`, which is what is expected when submitting papers to conferences or journals (you usually have to submit the `.tex` sources and check the PDF that the submission site generates)---and they almost always assume those sources compile with `pdflatex`.

If you think the bibliography style looks ugly with some sentences that don't end up a dot (I do), you can add that dot, like so: in the style file, by default `splncs03.bst`, look for this piece of code:

~~~ {.text .numberLines}
FUNCTION {fin.entry}
{ duplicate$ empty$
    'pop$
    'write$
  if$
  newline$
}
~~~

Replace it with the below code, recompile your BibTeX/LaTeX, and now you should have proper(ly ended) sentences in your bibliography.

~~~ {.text .numberLines}
FUNCTION {fin.entry}
{
  add.period$
  duplicate$ empty$
    'pop$
    'write$
  if$
  newline$
}
~~~

### The Presention skeleton

The `PRESENTATION` skeleton (`presentation.tex`) depends on the `projector` class, found [here](http://www.shoup.net/projector/). Installing it is described in the [TeX Trickery](#tex-trickery) section. Also, when displaying presentations, bold is often more emphasizing than italics. Thus, the `\emph` command is redefined to put the text in bold; for italics there is the `\iemph` command.

### The Standalone skeleton

The file for this is named `standalone.tex`. I use it as a playground for graphics packages, like `xy` or `TikZ`. The PDF produced will be a "full-scale" picture. To include it say, on a presentation, do `\centering{\graphicbox{figures/standalone}}`.

Tweakings
---

### Draft mode

IN the code for fonts, the `microtype` package is loaded. This package improves the way spacing is computed, which usually results in an improved layout. However, it slows down, very noticeably, the compile time; the solution is the line after it, which indicates to `microtype` that the document is to be processed in draft mode---which disables all the layout improvements. When producing the final version, set `draft=false`.

The above method only disables the `microtype` improvements (which already improves compilation time considerably). But to improve it even further, you can set *the whole document* in draft mode, by adding `draft` to the `documentclass` options. This, besides also disabling `microtype`, further disables all sorts of things, like images, cross-references, etc. If you use this latter option, there is no need to disable `microtype`---it is done automagically.

### The xcolor package

The *documentclass* line contains two options (`usenames` and `dvipsnames`) that belong to the *xcolor* package, but setting those options only when loading *xcolor* might cause conflicts with other packages that also automagically load that package (namely *tikz*). Having those options given to *documentclass* avoids the possibility of any such conflict.

SyncTeX
---

This is a technology that allows you to go from a specific place in a TeX source file, to the corresponding place in the PDF file (**forward search**), or the other way round (**backward search**). The `vim` plugin I use for LaTeX management---the awesome TeX-9---is synctex enabled, but sadly only for *graphical* `vim` (`gvim`) and `evince`. The setup I elaborate below will get us synctex for *terminal* `vim` and `okular` (it still requires TeX-9, though). And of course, your document must have been compiled with `--synctex=1`, or have synctex enabled in some other manner.

### Forward direction

Dump the following in `~/.vim/ftplugin/tex.vim` (and change the mapping to your liking):

~~~ vim
function! SyncTexForward()
	let cmd = "silent !okular --unique ".tex_nine#GetOutputFile()."\\#src:".line(".")."%:p &> /dev/null &"
	exec cmd
	redraw!
	redrawstatus!
endfunction
nmap <Leader>f :call SyncTexForward()<CR>
~~~

That's it; triggering that map in a specific place in the source file should cause `okular` to go to the corresponding location in the PDF file.

### Backward direction

The secret is to, when editing TeX file, invoke `vim` with the `--servername` option (traditionally this is done just for graphical environment, but it can be used in the terminal as well). To do this, first create an alias in `~/.bashrc` that directs vim to a script, that we shall aptly name `vim.sh` (don't forget to re-source that file, `. ~/.bashrc`).

~~~ bash
alias vim='sh /path/to/vim.sh'
~~~

That script shall contain the following:

~~~ bash
#!/bin/bash

ARGS=("$@") # Needed to iterate over arguments with spaces.

# Add --servername option (for synctex) when opening .tex files.
for f in "${ARGS[@]}" ; do 
	if [[ $f == *.tex ]] ; then
		vim --servername VIM "$@"
		exit 0
	fi
done

# Call vim as usual when opening other files.
vim "$@"
~~~

Lastly, in `okular`'s preferences, set the **Editor** to 

`vim --servername VIM --remote +%l %f`

Now, **in browse mode only** (`Ctrl+1`), hitting `Shift` and left clicking in a word should move the cursor in `vim` to the relevant place. If you're using TeX-9's `mainfile:` modeline, `vim` will also open the relevant file, if necessary. How awesome is that?!

ArchLinux (AL) packages 
---

The __endnotes__ package can be found in the AL package: *texlive-latexextra*. The Charis SIL font can be found in an AUR package, but seems not be working. So for now the best approach seems to be to get the font's sources from [here](http://software.sil.org/charis/download/) and install them as described in the [TeX Trickery](#tex-trickery) section.

LaTeX Trickery
---

```tex
\usepackage[bitstream-charter]{mathdesign}
\DeclareSymbolFont{usualmathcal}{OMS}{cmsy}{m}{n}
\DeclareSymbolFontAlphabet{\mathcal}{usualmathcal} 
```

The last two lines are to use the default mathcal font, instead of the one with bitstream-charter, which is [harder to read][1].

TeX Trickery
---

For installing custom fonts, styles, etc., the easiest way is to replicate in your home directory the TeX Directory Structure (details [here][3] and [here][4]). The first thing to do is to discover where is your TeX home:

```bash
$ kpsewhich -var-value=TEXMFHOME
```

In my case it is in `/home/user/.texmf`[^1]. Create that folder if it does not exist. The exact location of things depends on what that thing is concretely (fonts, styles, bib styles, etc.). For our purposes, the projector class goes in `/home/user/.texmf/tex/latex/` and the Charis SIL font (which consist of a bunch of `\*.ttf` files) goes in `/home/user/.texmf/fonts/truetype/` (create the sub-folders as needed).

`XeLaTeX` has a peculiarity regarding fonts, however: if installed per user, it expects them to be in the `~/.fonts` directory. Simple solution, though, just create a sym link:

~~~ bash
ln -s ~/.texmf/fonts ~/.fonts
~~~

More generally, the first thing to do, to discover where whatever you want to install should be installed, is using a tool named `kpsewhich`, which should get installed when you install LaTeX. It can be used to do a lot of things (`$ kpsewhich --help`), but the one we’re interested in here, location of styles, uses the `--show-path NAME` option. The list of allowed names is part of the output of the `--help-formats` option. So for instance, to discover where to place BiBTeX style files (`*.bst`), run:

~~~ bash
kpsewhich --show-path bst
~~~

This will output a list of locations where BiBTeX style files are searched for. So if you have a file called `mystyle.bst`, create a folder named "mystyle" in the appropriate location (I use `/home/user/.texmf/bibtex/bst/`), and put `mystyle.bst` inside the folder you just created. Then run `$ texhash .` (don't forget the dot!) from the "appropriate location" folder you used. And you're done!

----

[^1]: The default for me was `/home/user/texmf`. But if you don't want yet another directory littering your \$HOME, you can change it like described [here][6]. In my case it amounted to (replace `~/.texmf` with whatever location you like):

```bash
$ mv ~/texmf ~/.texmf
$ mkdir -p ~/.texmf/web2c
$ cp /usr/share/texmf-dist/web2c/texmf.cnf .texmf/web2c/
# change the TEXMFHOME line to look like this: "TEXMFHOME = ~/.texmf", 
$ vim .texmf/web2c/texmf.cnf
$ echo -e "TEXMFCNF=$HOME/.texmf/web2c\nexport TEXMFCNF" >> ~/.bashrc
$ source ~/.bashrc
```

[1]: http://www.latex-community.org/forum/viewtopic.php?f=48&t=6989   
[2]: http://www.youthedesigner.com/2012/08/12/how-to-explain-raster-vs-vector-to-your-clients/   
[3]: http://en.wikipedia.org/wiki/TeX_Directory_Structure  
[4]: http://tex.stackexchange.com/questions/1137/where-do-i-place-my-own-sty-files-to-make-them-available-to-all-my-tex-files  
[6]: http://www.tex.ac.uk/cgi-bin/texfaq2html?label=privinst

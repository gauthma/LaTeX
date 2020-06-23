My LaTeX setup 
===

These are the templates I use for most of my interactions with LaTeX (there are PDF examples for each in the `build/` directory):

- `bare.tex`: A very simple template, that I use for what one might dub "quick notes".

- `cv.tex`: The template I use for my Curriculum Vitæ.

- `essay.tex`: Writing is often a good way to vent complaints. I write them with this template and then dump them on my website.

- `llncs.tex`: Springer's template for writing papers, with a few tweaks of my own (for more on these, see below section "Further Reading").

- `presentation.tex`: This uses the `beamer` class, tweaked to my liking. Because in what slide making (and presentation giving) is concerned, the simpler the better.

- `report.tex`: I use this template as a sort of "offline wiki". For notes about research.

- `standalone.tex`: This I use when I need to try out some sketch, in `TikZ` or `xy-pic`, or something like that. Instead of experimenting in the document where I need to place the picture, I try it out in this standalone template. If nothing else, it compiles a lot faster! The PDF produced will be a "full-scale" picture. To include it say, on a presentation, do `\centering{\graphicbox{standalone}}`.


The example *LaTeX* files are processed using `XeLaTeX`, except for `cv`, which uses `LuaLaTeX`, to simplify using pretty fonts, and `llncs` which requires `PdfLaTeX`.

All of these templates use a... *sizable* number of packages. However, all of these should be available in the TeXLive package (in Archlinux, at least, they are). If such is not the case, the reader can always install them on a local TeX tree. Also, I use a custom font, `Charis SIL`, which requires manual installation (see below, the "Further Reading" section). If the user does *not* wish to use them, just comment out the lines concerning the `fontspec` package, and any related lines (that should be just above, or just below).

Usage 
---

In the first command below, `your_document_dir` must not exist; it should be the name of the new folder which will contain your document.

```bash
$ git clone https://github.com/notnotrandom/LaTeX.git your_document_dir
$ cd your_document_dir
$ sh setup.sh [bare, cv, essay, llncs, presentation, report, standalone]
```

In the last command, if you tab-complete (as the argument has the same name of the `\*.tex` file, minus extension), either the final dot or the whole extension will also be "completed"; this is ok, the script will filter it (i.e. work correctly even with the ending dot and/or extension).

The `setup.sh` script will patch `CompileTeX.sh`---running this script is how you compile the templates---and set all the required options for the chosen template. It will also **remove the .git folder**, in addition to any unneeded files, depending on the value of its argument (i.e. the chosen template). E.g. if argument is `cv`, then it will remove `report.*`, `essay.*`, etc.

**Warning**: the script requires **GNU sed** to edit the `CompileTeX.sh`! If you don't have it, then comment that line and edit the `CompileTeX.sh` manually (check `setup.sh` to see where `sed` was used).

Do work with LaTeX skeletons provided, compile using `CompileTeX.sh`, and enjoy profit!!

Unabridged copy
---

When reading PDFs in front of a computer screen, it is exceedingly useful to have two copies of the document being read. In this way, one can quickly cross-reference different parts of the document---and this is all the more useful, the larger the document happens to be. With LaTeX, however, there is an extra nuance: the larger the document, the longer it will take **to compile**. So here's how I tackle the problem.

First, for the simpler types---`bare`, `cv`, and `standalone`---there is `CompileTeX.bare.minimum.sh`, which `setup.sh` will rename to `CompileTeX.sh`, that just does a simple compile run---which is all that is required.

For the not so simple types (everything else), the `CompileTeX.sh` script can do two kinds of builds: a "regular" build, and an "unabridged" build. The idea is that if the document is large, it can be divided into several partial documents, which are then `\include`'d in the main file. This makes it possible to build only a part of the document, using `\includeonly`. `CompileTeX.sh` will then also produce an unabridged copy, as if there was no `\includeonly`. This is done by copying the main `.tex`file into a new file called `Unabridged.tex`, and inserting in this latter file's preamble the line:

~~~ {.tex .numberLines}
\let\include\input
~~~

This done because `\include` always starts a new page, as it is supposed to be primarily used with chapters (which usually start in a new page). But, as this is not the case with `\input`, with the above `\let` we can include, say, `\section`'s---and while the regular copy will, in the case of `\section`'s, have extraneous `\newpage`'s, the unabridged one will not.

**Note:** if `\include`'ng sections of a document with chapters, the chapter declarations **must be in the mainfile**. Otherwise the numbering of the sections will change; see below.

Anyway, `Unabridged.tex` is then compiled into a different directory---so that the auxiliary files of both versions don't mingle.

There is an important catch, however: when compiling a document with `include`'s, the compiler will generate some auxiliary files per `\include` (stored in the build directory). This is used to keep references and chapter/section numbers correct, when compiling a reduced version with `\includeonly`. If those auxiliary files are not there---e.g. after using the `clean` options to clean the build dir---compiling a mainfile with an `\includeonly` will yield an error. This is the reason for the `rebuild_build_files` option to the compile script. I detail all those options below.

By default, only the `report` type has enabled the building of an unabridged copy. For the other non-simple types, set `do_unabridged` to `true` in `CompileTeX.sh`, and then use the `clean` option to setup the build directory for the unabridged copy.

LaTeX compiling
---

Compiling LaTeX files is not a simple matter. Here I will just describe the command line options of the script `CompileTeX.sh`. There exists a `small_build()` function, which just runs the compiler once; and a `big_build()` function, which compile once, builds bibliography, etc., if set, and then compiles three more times. Both functions also do the same actions to the unabridged copy, if there exists one. See the comments in `CompileTeX.sh` for more details.

Note: there exists a variable, `do_bib`, which can be used---set it to `false`---to cause the script to ignore any `\cite` or `\nocite` commands, and never run the bibliography command. It is set to `true` by default. Similarly, there exists variable `do_idx` to enable or disable building the index.

- no argument: run `small_build()`;

- `big`: A full LaTeX build run, i.e. `big_build()`.

- `clean`: removes everything in the build directories. And rebuilds its structure. By default this means create a link, inside the build directory, to the bibliography file  (this is always done, regardless of the value of `got_bib`). However, more actions may be required; see the remark on the structure of the build directory, below.

- `debug`: run `small_build()`, but *with* debug output. 

- `final`: `clean`s everything up, and them makes a `full` build. If you need the final PDF document to have a different name, then you can use the `endname` variable, which the last command in this function sets as its name;

- `get_compiler_pid`: used in the `vim` code that builds the `LaTeX` command on writing the `.tex` file (see [myvim](https://github.com/gauthma/myvim));

- `killall_tex`: used to kill a running compile process (only used from within `vim`);

- `rebuild_build_files`: reconstructs the auxiliary files stored in both (regular and unabridged) build dirs.

- `symlinks`: reconstructs the symlinks needed in build directory(ies);

- `u2r`: replaces the regular, possibly abridged PDF file, with its unabridged counterpart. This is useful when one wants to read, more than to write, the document. As I usually have both version open in the PDF viewer, and it auto-updates, doing this leaves me with two open copies of the full document, which makes reading all that much easier.

**Structure of the build directory.** If you split your input, say, by placing all chapters inside a `chapters/` folder, then that folder needs to exist inside the build directory. More generally, the same hierarchy of inclusion of input files needs to be replicated inside the build directory. To accomplishing this, list those folders in the `folders_to_be_rsyncd` array. E.g. if you have two folders with `.tex` files in them, say `chapters` and `images`, that line should look something like:

~~~ {.shell .numberLines}
folders_to_be_rsyncd=( "chapters" "images" )
~~~

Add to the list any folders where you have placed the `.tex` files.

**IMPORTANT:** the source folder(s)---`chapters` and `images` in the above example---**MUST NOT** end with a forward slash (/), because that tells `rsync` to copy folder *contents*, rather than the folder itself---which is not what we want.

A final note: the files in the `includes/` directory are files that are supposed to be *included* (actually `\input`'d) into another file, and *not* compiled on their own.

Further reading
---

For more details on the things I describe here, see <https://randomwalk.eu/notes/TeX-Trickery.pdf>.

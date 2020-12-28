LaTeX, made simple (or at least, simpler...) 
===

Short intro
---

In my interactions with LaTeX, I use a set of templates (some of which have an accompanying preamble in the `inputs/` folder), together with a couple of scripts for compilation. Here's the list of which script compiles which templates (the latter are described below, on section "The templates"):

- `compileTeX.minimum.sh` for the minimalist templates, `bare.tex`, `presentation.tex`, `standalone.tex`, and also for `cv.tex`, which compilation requirements are similarly straightforward.

- `compileTeX.medium.sh` for `essay.tex` and `llncs.tex`. Essentially, it adds to the previous compiling script the capability of building a bibliography.

- `compileTeX.reports.sh` for `report.sh`. This adds to the previous compiling script the capability of producing an **unabridged copy**. This introduces a bunch of complications, and so both the script and template are dealt with in a specific section below, viz. "Reports: template and compilation".

The `setup.sh` script will, for the chosen template, rename the adequate compile script to `CompileTeX.sh`, and setup the required options therein (see "LaTeX Compiling" below, for further details about these options). Usage is as simple as:

```bash
$ git clone https://github.com/notnotrandom/LaTeX.git your_document_dir
$ cd your_document_dir
$ sh setup.sh [bare, cv, essay, llncs, presentation, report, standalone]
```

where `your_document_dir` should be the name of the (new) folder which will contain your LaTeX project. PDF samples of the templates can be seen in the `build/` directory. Sounds simple enough, right?

Well, it gets even better. In the last command (`sh setup.sh ...`), if the argument ends in `.tex`, or just a dot `.`---which can happen with `<Tab>` completion if there are files with the same name but different extensions---the script will still work correctly. So just type the first characters of the name of the template you want, hit `<Tab>`, and the `setup.sh` script will take care of the rest!

Speaking of which, the `setup.sh` script will also **remove the .git folder** (plus `.gitignore`), in addition to any unneeded files, depending on the value of its argument (i.e. the chosen template). E.g. if the argument is `cv`, then it will remove `report.*`, `essay.*`, etc. It is up to decide if, and how, any version control should be used. It will leave the `inputs/` folder with the files needed for the chosen template. E.g. if you choose `essay`, it will delete `inputs/report_preamble.tex`, `inputs/llncs_preamble.tex`, etc.

So all that is left is to do your writing with LaTeX templates provided, compile using `CompileTeX.sh`, and enjoy profit!! If you're interested, read on!

(Well, technically, that's a lie. You still have to deal with the font configuration and the compiler for bibliography entries---but don't let that stop you! It's simple---instructions below.)

Fonts
---

Except for `llncs`, which uses its own font, I use a custom font, `Charis SIL`, because I don't really like *Computer Modern* and its cousins (condemn me if you will). If you don't feel like dealing with font issues, just comment the line `\input{inputs/fonts}` in the preamble file.

If you do decide to try out `Charis SIL`, then download the font from <http://software.sil.org/charis/download/>. It will consist of a bunch of `*.ttf` files. Put them in a location of your choice; here I will assume `$HOME/.fonts/truetype/` (yes, the `$HOME` variable can be used!). If you use another location, then just change that location in `inputs/fonts.tex`, and you are ready to go---except for `cv`.

For `cv`, you need to you also need the `fontawesome` font (it is for icons). It should come with TeXLive, but I'm afraid XeLaTeX, for some reason, requires a path... So find the path for the `fontawesome.otf` file, and modify the path (line after the one starting with `\newfontfamily{\FA}`) to point to the *directory* where the `fontawesome.otf` file is located. see the example configuration in `inputs/fonts.tex` (note that before running the `setup.sh` script, this file is named `inputs/cv_fonts.tex`).

That's it: now you can experiment with the templates; and come back to read the rest of this README when/if you need to. Have fun!

Bibliography building
---

For `report` and `essay` templates, I build the bibliography using the `bibulous` tool (`llncs` uses `bibtex`, and the other templates do not have bibliographies). It allows you to build your own templates, which a much simpler syntax than that used by `bibtex` templates. I use a template of my own doing, named `sane.bst`. `bibulous` is a python script that can be downloaded from <https://nzhagen.github.io/bibulous/>. To use it, I do as follows: save the script in some location of your choice, and then symlink it to some location in your `$PATH`; I use `$HOME/.local/bin`:

~~~ {.bash .numberLines}
$ ln -s /path/to/bibulous.py $HOME/.local/bin/bibulous
~~~

Thus in the compilation script, I can set `bibcmd="bibulous"`. As for the `sane.bst` template, it can be downloaded from <https://randomwalk.eu/public/sane.bst>, and it must be placed in a location where the `LaTeX` compiler will search for bibliographic templates (this is dependent on how you set up your TeX tree; see <https://randomwalk.eu/notes/TeX-Trickery.pdf> for a sugestion.)

To revert back to `bibtex`, just change the `bibcmd` line in the compile script to use `bibtex`, and the `\bibliographystyle` line in the `.tex` file to use one of the standard bibliographic styles, like `plainnat`, for example.

The templates
---

I know provide a general description of the templates I use (there are PDF examples for each in the `build/` directory):

- `bare.tex`: A very simple template, that I use for what one might dub "quick notes".

- `cv.tex`: The template I use for my Curriculum Vitæ.

- `essay.tex`: Writing is often a good way to vent complaints. I write them with this template and then dump them on my website. `\input`s preamble `inputs/essay_preamble.tex`.

- `llncs.tex`: Springer's template for writing papers, with a few tweaks of my own (for more on these, see below section "Further Reading"). `\input`s preamble `inputs/llncs_preamble.tex`.

- `presentation.tex`: This uses the `beamer` class, tweaked to my liking. Because in what slide making (and presentation giving) is concerned, the simpler the better. `\input`'s preamble `inputs/presentation_preamble.tex`.

- `report.tex`: `\input`'s `inputs/report_preamble.tex`. See section "Reports: template and compilation" below.

- `standalone.tex`: This I use when I need to try out some sketch, in `TikZ` or `xy-pic`, or something like that. Instead of experimenting in the document where I need to place the picture, I try it out in this standalone template. If nothing else, it compiles a lot faster! The PDF produced will be a "full-scale" picture; to include it say, on a presentation, do `\centering{\graphicbox{standalone}}`.

**Note:** the files in the `inputs/` directory are files that are supposed to `\input`ed into another file, and *not* compiled on their own.

The example *LaTeX* files are processed using `XeLaTeX`, except for `cv`, which uses `LuaLaTeX`, to simplify using pretty fonts, and `llncs` which requires `PdfLaTeX`---but `setup.sh` takes care of this for you!

Of the non-simple templates (plus `cv`), they all use a... *sizable* number of packages. However, all of these should be available in the TeXLive package (in Archlinux, at least, they are). If such is not the case, the user can always install them on a local TeX tree; cf. the "TeX-Trickery.pdf" document mentioned in the "Further Reading" section below.

LaTeX compiling
---

Compiling LaTeX files is not a simple matter---after all, there is a reason to use three different scripts... For all those scripts, calling with no argument runs the compiler once, i.e. calls the function `small_build`.

### `compileTeX.minimum.sh`

This script has one variable that the user can set: `finalname`, which is used to build a final version where the PDF name will be `finalname.pdf`. See below the option `final` to the compile script.

This script accepts the following options:

- `clean`: removes everything in the build directory.

- `debug`: run `small_build()`, but *with* debug output.

- `final`: compiles document twice and renames it to the value of `finalname` variable---by default, it is `${name}.FINAL.pdf`, where `${name}` is the original name of the PDF file.

- `get_compiler_pid`: in my `vim` setup, I have a map that builds the `LaTeX` command on writing the `.tex` file (see [myvim](https://github.com/gauthma/myvim)); it requires the pid of the compiler process to see if there is already a LaTeX compilation process going on. If you don't use `vim`, just ignore this.

- `killall_tex`: used to kill a running compile process (only used from within `vim`); if you don't use it, it's safe to ignore.

- `symlinks`: reconstructs the symlinks required.

### `compileTeX.medium.sh`

Besides the `finalname` variable (see above `compileTeX.minimum.sh`), which also exists for this script, we have only one additional variable:

- `do_bib`: if `true` (the default), when doing a big build (see below), also build the bibliography.

As for the options, besides all of the above options for `compileTeX.minimum.sh`, we have:

- `big`: full LaTeX build run, i.e. `big_build()`. This means compile once, build bibliography (if not disabled), and run three times more (two if bibliography building is disabled).

The `final` option works slightly differently:

- `final`: `clean`s everything up, and them makes a `big_build`. Then renames the PDF document to the value of `finalname` variable---by default, it is `${name}.FINAL.pdf`, where `${name}` is the original name of the PDF file.

### `compileTeX.reports.sh`

As mentioned in the beginning, this particular compile script is meant for the `report.tex` template, which, as also mentioned at the beginning, has its own section---the next one.

Reports: template and compilation
---

I use the `report.tex` template as a sort of "offline wiki". That is, to keep notes on specific subjects, and thus it can become quite large. Hence, compiling always produces two PDF files, `report.pdf` and `Unabridged.pdf`. The idea is that if the document is large, it can be divided into several chapters, which are then `\include`'d in the main file. This makes it possible to build only a part of the document, using `\includeonly`. `CompileTeX.sh` will then also produce an unabridged copy, as if there was no `\includeonly`. This is done by copying the main `.tex`file into a new file called `Unabridged.tex`, and inserting in this latter file's preamble the line:

~~~ {.tex .numberLines}
\let\include\input
~~~

This yields an `Unabridged.pdf` that will be the full, complete, document. Incidently, `Unabridged.tex` is then compiled into a different build directory---so the auxiliary files of both versions don't mingle.

So when and if, to speed up the compilation process, the user decides to use `\includeonly`, then the `report.pdf` will be that smaller (abridged) document, whilst `Unabridged.pdf` will still be the full document. When running the compile script, the smaller version will compiled first---and when it is done, a large notice will be displayed, allowing you to get back to work ASAP.

**Caveat: structure of the build directory.** If your split input is placed inside specific folders---say, placing all chapters inside a `chapters/` folder---then `\include` requires that those folders exist inside the build directories. More generally, the same hierarchy of files that are `include`'d needs to be replicated inside the build directories. To accomplish this, list those folders in the `folders_to_be_rsyncd` array. E.g. if you have two folders with `.tex` files in them, say `chapters` and `images`, that line should look something like:

~~~ {.shell .numberLines}
folders_to_be_rsyncd=( "chapters" "images" )
~~~

Add to the list any folders where you have placed the `.tex` files---**EXCEPT** files in the `\inputs/` directory, as these are supposed to be `\input`ed (and hence, cause no problem).

Finally, note that **whenever you add a new folder**, you need to clean and do a `big_build()`, so as to have that new folder replicated in the build dir. To do this, compile first with the `clean` option, and then with the `big` option.

---

Now onto the `CompileTeX.sh` script.

So for variables that the user can set, in addition to the ones mentioned previously---`finalname` and `do_bib`; see above if necessary---we have:

- `do_idx`: if "true", then the is constructed when doing a `big_build`.

- `folders_to_be_rsyncd`: explained above, for when `\include`'d files are spread in subdirectories.

- `tmp_build_dir`: when doing a `big_build`, and `\includeonly` is used, the first run must "see" the entire document. (Sctricty speaking, this is only required after a `clean` of the build dir, but I think it good practice to start a `big_build` like this.) So the `\includeonly` statement needs to be commented out, but in a file the user is likely editing. So the script does a compilation in another folder, namely `tmp_build_dir`, and then copies back the auxiliary files. **If possible**,this should be a folder in a RAM-based `tmpfs` filesystem. In Archlinux, one such filesystem is mounted at `/run/user/$UID/` (that variable should contain your user id; usually starts at 1000).

As for command line options, they are the same as for the two simpler compile scripts documented above, with two changes and one addition:

- `clean` (changed): besides cleaning per se, it also rebuilds the build dirs' structure (see above).

- `final` (changed): always uses the unabridged copy, so as to ensure that it is the complete version PDF that is renamed to its final name (the default is again `${name}.FINAL.pdf`).

- `u2r` (new): replaces the regular, possibly abridged PDF file, with its unabridged counterpart. This is useful when one wants to read, more than to write, the document. As I usually have both versions---abridged and unabridged---open in the PDF viewer, and it auto-updates, doing this leaves me---instantly!---with two open copies of the full document, which makes reading all that much easier.

Further reading
---

For more details on the things I describe here, see <https://randomwalk.eu/notes/TeX-Trickery.pdf>.

# Symlinks

In case you accidentally delete one or more of the symlinks required for this setup to work, here are the commands to re-create them (used in `setup.sh`). The final dot (`.`) is the folder where the `build` directory is. Replace the variables accordingly (all commands are ran from the directory that contains the main file).

~~~ {.shell .numberLines}
$ ln -sr "${build_dir}/${doctype}.pdf" .
$ ln -sr "${unabridged_dir}/${build_dir}/${doctype}.pdf" "Unabridged.pdf"
$ ln -sr sources.bib "${build_dir}"/
~~~

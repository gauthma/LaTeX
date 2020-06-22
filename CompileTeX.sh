#! /bin/bash

# IMPORTANT: if you have .tex files in their own folders, indicate them here
# (space separated). E.g. if you have your chapters in a folder named
# "chapters" (no quotes), then add it like this (WITH quotes):
# folders_to_be_rsyncd=( "chapters" )
# VERY IMPORTANT: the folders' name MUST NOT end with a forward slash (/),
# because that tells rsync to copy folder *contents*, rather than the folder
# itself.
folders_to_be_rsyncd=( "chapters" "frontmatter" )
# IMPORTANT: to disable building bibliography, set this to false.
do_bib="true"
# IMPORTANT: to enable building the index, set this to true.
do_idx="false"
# IMPORTANT: to enable building an unabridged copy, set this to true.
do_unabridged="true"

###############################################################################

# Much like targets in a Makefile, this scripts provides functions to do a
# simple build, a full build, etc, for a LaTeX project.

# Three main functions, compile(), small_build(), and big_build():
#
# - compile() just runs the LaTeX compiler on whatever file it is given;
#
# - small_build() runs compile() on the regular copy, and then on the
# unabridged copy, it there is one.
#
# - big_build() runs compile() once, then build bibliography etc. (if
# required), and then runs compile() three more times. And does the same to the
# unabridged copy, if there exists one.
#
# Most of the remaining functions revolve around these three, to compile both
# the report and its unabridged version (only in the case of reports), and to
# check for errors and give feedback properly, and so on.

# $name is one of: cv, bare, essay, llncs, presentation, report, or standalone.
name="report"

# The final name of the .pdf file (without extension). Defaults to original
# name with ".FINAL" appended. In my setup, works "out of the box" with spaces,
# foreign chars, ...
finalname="${name}.FINAL"

# Name of the .bib file (sans extension).
sourcesname="sources"

# Build dir for the regular (possibly abridged) copy.
build_dir_regular="build"

texcmd="xelatex"
texcmdopts="-halt-on-error --interaction=batchmode --shell-escape --synctex=1"
debug_texcmdopts="--interaction=errorstopmode --shell-escape --output-directory=${build_dir_regular}"
bibcmd="bibtex"
indexcmd="makeindex"

# Data for unabridged copy.
name_unabridged="Unabridged"
build_dir_unabridged="build_UNABRIDGED"

# Please do note that this WIPES OUT THE ENTIRE unabridged_dir!
function clean() {

  echo -e "\nWARNING: after cleaning the build dir, it is VERY RECOMMENDED
  to do a big build, WITHOUT \\includeonly (run this script with the
  rebuild_build_files option). Otherwise things like bibliography
  might not build properly!\n"
  read -p "Press any key to continue... [ctrl-c cancels]" -n 1 -r

  if [[ -d "$build_dir_regular" ]]; then
    echo "Wiping contents of ${build_dir_regular} (except PDF files)"
    cd "${build_dir_regular}" && rm -rf $(ls | grep -v ".pdf") && cd ..
  else
    echo "Creating directory ${build_dir_regular}"
    mkdir $build_dir_regular
  fi

  if [[ "${do_unabridged}" == "true" ]]; then
    if [[ -d "$build_dir_unabridged" ]]; then
      echo "Wiping contents of ${build_dir_unabridged} (except PDF files)"
      cd "${build_dir_unabridged}" && rm -rf $(ls | grep -v ".pdf") && cd ..
    else
      echo "Creating directory ${build_dir_unabridged}"
      mkdir $build_dir_unabridged
    fi
  fi

# Rebuilding structure of build_dirs. Begin with symlinks.
  unabridged_dir_and_symlinks_rebuild

# If any .tex files are in their own custom directories, those dirs
# must also exist in $build_dir, with the same hierarchy. See README.md for
# more details. Handled with rsync.

  if [[ ${#folders_to_be_rsyncd[@]} -gt 0 ]] ; then
    rsync -a --include '*/' --exclude '*' "${folders_to_be_rsyncd[@]}" "${build_dir_regular}"

    if [[ "${do_unabridged}" == "true" ]]; then
      rsync -a --include '*/' --exclude '*' "${folders_to_be_rsyncd[@]}" "${build_dir_unabridged}"
    fi
  fi
}

# A normal (single) LaTeX compile.
function compile() {
  ${texcmd} ${texcmdopts} --output-directory="$2" "$1"
  local ret=$?
  echo "" # Print a newline (SyncTeX doesn't).
  return $ret
}

# A normal (single) LaTeX compile.
function debugbuild() {
  ${texcmd} ${debug_texcmdopts} ${name}
  return $?
}

# A big LaTeX compile: compile once (and build index, if it is set), then compile
# bib (if it is set), then compile three more times (usually two are enough, but in
# some thorny cases three are required, so...). If using bib is not set, just
# compile three times.
function big_build() {

  local bibliography_was_actuall_built="false"

# First, run compile().
  compile "$name" "$build_dir_regular"
# If the compile failed, notify the user and quit.
  if [[ $? -ne 0 ]]; then
    echo "Compile of ${name}.tex file was not successful!"
    exit 1
  fi

# If the compile succeeded, then build the index.
  if [[ "$do_idx" == "true" ]] ; then
    cd "${build_dir_regular}" && pwd
    ${indexcmd} ${name}
# If the building the index failed, notify the user and quit.
    if [[ $? -ne 0 ]]; then
      echo "Building of the index (regular copy) was not successful!"
      exit 1
    fi
# Otherwise leave the regular build dir.
    cd ..
  fi

# If the previous compile succeeded, and we are not building bibliography, then
# just compile twice more and exit.
  if [[ "$do_bib" == "false" ]] ; then
    echo "$0: The \$do_bib var is set to false, so I am skipping the bibliography part."
      echo "$0: I will just run compile() twice more."
    compile "$name" "$build_dir_regular" && \
      compile "$name" "$build_dir_regular"
# If one of the compile runs failed, notify the user and quit.
    if [[ $? -ne 0 ]]; then
      echo "(2nd or 3rd) compile run of ${name}.tex file was not successful!"
      exit 1
    fi

# Else, if there are uncommented \cite or \nocite commands, then build the
# bibliography. The reason for *three* compiles, instead of the usual two, is
# that an extra compile is required for backreferences in bib entries to be
# constructed (e.g. "Cited in page ...").
  else
    local have_cite_entries=$(grep --extended-regexp --recursive '^[^%]*\\(no)?cite' --include=*.tex)
    if [[ -z "$have_cite_entries" ]]; then
      echo "$0: The $do_bib var is set to true, but no \\cite entries found.
      So I will just do two more small compiles..."
      compile "$name" "$build_dir_regular" && \
        compile "$name" "$build_dir_regular"
# If one of the compile runs failed, notify the user and quit.
      if [[ $? -ne 0 ]]; then
        echo "(2nd or 3rd) compile run of ${name}.tex file was not successful!"
        exit 1
      fi
    else
      cd "${build_dir_regular}" && pwd
      ${bibcmd} ${name}
      if [[ $? -eq 0 ]]; then
        bibliography_was_actuall_built="true"
        cd ..
        compile "$name" "$build_dir_regular" && \
          compile "$name" "$build_dir_regular" && \
          compile "$name" "$build_dir_regular"
# If the compile compile after bib update failed, notify the user and quit.
        if [[ $? -ne 0 ]]; then
          echo "Compile of ${name}.tex, after building bibliography, was not successful!"
          exit 1
        fi
      else
        echo "Building bibliography (regular copy) file was not successful!"
        exit 1
      fi
    fi
  fi

# Now we deal with unabridged copy, if there is one. If the three compiles
# after a bib update did not fail, then update bib && triple compile in
# unabridged_dir.
  if [[ "${do_unabridged}" == "true" ]]; then
    update_unabridged_tex_files

    echo -e "\n*************************************************************************"
    echo -e "* Now continuing with (background) unabridged (full) build..."
    echo -e "*************************************************************************\n"

# Just as above, first, do a single compile.
    compile "${name_unabridged}" "$build_dir_unabridged"
# If the compile failed, notify the user and quit.
    if [[ $? -ne 0 ]]; then
      echo "Compile of ${name_unabridged}.tex file was not successful!"
      exit 1
    fi

# If the compile succeeded, then build the index.
    if [[ "$do_idx" == "true" ]] ; then
      cd "${build_dir_unabridged}" && pwd
      ${indexcmd} ${name_unabridged}
# If the building the index failed, notify the user and quit.
      if [[ $? -ne 0 ]]; then
        echo "Building of the index (unabridged copy) was not successful!"
        exit 1
      fi
# Otherwise leave the regular build dir.
      cd ..
    fi

# Then build bibliography, if requested.
    if [[ "$bibliography_was_actuall_built" == "true" ]] ; then
      cd "${build_dir_unabridged}" && pwd
      ${bibcmd} ${name_unabridged}
# If bibliography builds properly, then do more three runs.
      if [[ $? -eq 0 ]]; then
        cd ..
        compile "${name_unabridged}" "$build_dir_unabridged" && \
          compile "${name_unabridged}" "$build_dir_unabridged" && \
          compile "${name_unabridged}" "$build_dir_unabridged"
# If the compile compile after bib update failed, notify the user and quit.
        if [[ $? -ne 0 ]]; then
          echo "Compile of ${name_unabridged}.tex file was not successful!"
          exit 1
        fi
# Bibliography did NOT build property; notify user and quit.
      else
        echo "Building bibliography (unabridged copy) file was not successful!"
        exit 1
      fi
# If we are skipping bibliography, just do two compile() runs.
    else
      compile "${name_unabridged}" "$build_dir_unabridged" && \
        compile "${name_unabridged}" "$build_dir_unabridged"
# If one of the compile runs failed, notify the user and quit.
      if [[ $? -ne 0 ]]; then
        echo "(2nd or 3rd) compile run of ${name_unabridged}.tex file was not successful!"
        exit 1
      fi
    fi # If $do_bib is true.
  fi # If got unabridged copy.
  # Script execution should never reach this point.
}

function final_document() {
  big_build

  if [[ "${do_unabridged}" == "true" ]]; then
    cp "${build_dir_unabridged}"/"${name_unabridged}.pdf" "${finalname}.pdf"
  else
    cp "${build_dir_regular}"/"${name}.pdf" "${finalname}.pdf"
  fi
}

# This function creates a copy of the main dir (including unabridged stuff),
# deletes the \includeonly line, if it exists, in $name.tex, patches
# $name_unabridged the same way update_unabridged_tex_files() does, and then
# does a big compile. The goal of this function is to rebuild the same
# auxiliary files that would be produced by building the entire document. This
# is required, e.g., after clean(): doing a big compile with \includeonly might
# lead to errors in, for example, bibliography building).
#
# (The reason we build also an unabridged copy here is that in that case,
# \include's are remapped to \input's, but that is not the case with the
# regular copy, even when not using \includeonly. So the auxiliary files might
# differ in the two cases.)
#
# It then waits for the big compile to finish, replaces the main folder's (../)
# build dirs with these ones, and deletes the copy folder.
function rebuild_build_files() {

  rm -rf .temp_build_rebuild && mkdir .temp_build_rebuild

  cp -r $(ls | grep -v "docs\|README.md") .temp_build_rebuild
  cd .temp_build_rebuild

# Comment \includeonly line in $name.tex, if any.
  sed -e 's/^\s*\\includeonly.*$//' -i "${name}.tex"

# See comments in update_unabridged_tex_files().
  cp "${name}.tex" "${name_unabridged}.tex"
  sed '/^\s*\\begin{document}/i \
\\let\\include\\input' -i "${name_unabridged}.tex"

  sh CompileTeX.sh big
  rm -rf ../"${build_dir_regular}"
  rm -rf ../"${build_dir_unabridged}"
  mv "${build_dir_regular}" ../
  mv "${build_dir_unabridged}" ../

  cd .. && rm -rf .temp_build_rebuild
  echo "Finished rebuilding auxiliary files."
}


# Get the pid of the running $texcmd process (if any). This is needed to avoid
# starting (from within vim) a new compilation, if one is already running.
function get_compiler_pid() {
  pidof ${texcmd}
}

# Kill a running $texcmd process (useful when an error occurs, for example).
function killall_tex() {
  killall ${texcmd}
}

# Do a normal compile. If we are dealing with a report, also do a single compile build
# on the unabridged copy.
#
# First do a simple compile. Then, if it was successful, and if we are dealing with
# report, build unabridged copy.
function small_build() {
  compile "$name" "$build_dir_regular" # compile() returns the $? of the LaTeX command. See Note (1).
  if [[ $? -ne 0 ]]; then
    echo "Compile of ${name}.tex file was not successful!"
    exit 1
  fi

# If compile was successful, and we have an unabridged copy, then update unabridged
# copy.
  if [[ "${do_unabridged}" == "true" ]]; then
    update_unabridged_tex_files

    echo -e "\n*************************************************************************"
    echo -e "* Now continuing with (background) unabridged (normal, non-full) build..."
    echo -e "*************************************************************************\n"

    compile "${name_unabridged}" "$build_dir_unabridged"
    if [[ $? -ne 0 ]]; then
      echo "Compile of ${name_unabridged}.tex file was not successful!"
      exit 1
    fi
  fi
}

function u2r() {
  cp "$build_dir_unabridged/$name_unabridged".pdf "$build_dir_regular/$name".pdf
}

# Copy main .tex file as $name_unabridged, patch it to redefine all \include's
# as \input's. This causes for \includeonly to be ignored (if it exists). Then
# build unabridged copy in $build_dir_unabridged.
function update_unabridged_tex_files() {
  rm -f "${name_unabridged}.tex"

# Delete any \includeonly line from ${name_unabridged}.tex. This should not be
# necessary, as the sed below redefines \include to \input, which means that
# \includeonly lines will be ignored. But it is possible that there will exist
# other code that runs (or doesn't run) when an \includeonly line exists. So
# better wipe it out, just to be sure.
  sed -e 's/^\s*\\includeonly.*$//' "${name}.tex" > "${name_unabridged}.tex"

# Insert the following line before \begin{document}:
# \let\include\input
  sed '/^\s*\\begin{document}/i \
\\let\\include\\input' -i "${name_unabridged}.tex"
}

function unabridged_dir_and_symlinks_rebuild() {
  if [[ ! -d "$build_dir_regular" ]]; then
    echo "Build dir does not exist! Run clean() to fix it."
    return 1
  fi

# First deal with regular build dir.
  rm -f "${name}.pdf"
  rm -f "${name}.synctex.gz"
  rm -f "${build_dir_regular}/${sourcesname}.bib"

  ln -sr "${build_dir_regular}/${name}.pdf" .
  ln -sr "${build_dir_regular}/${name}.synctex.gz" .
  ln -sr ${sourcesname}.bib "${build_dir_regular}"/

# And then with unabridged build dir (only for reports).
  if [[ "${do_unabridged}" == "true" ]]; then
    if [[ ! -d "$build_dir_unabridged" ]]; then
      echo "Unabridged build dir does not exist! Run clean() to fix it."
      return 1
    fi

    rm -f "${name_unabridged}.pdf"
    rm -f "${name_unabridged}.synctex.gz"
    rm -f "${build_dir_unabridged}/${sourcesname}.bib"

    ln -sr "${build_dir_unabridged}/${name_unabridged}.pdf" .
    ln -sr "${build_dir_unabridged}/${name_unabridged}.synctex.gz" .
    ln -sr ${sourcesname}.bib "${build_dir_unabridged}"/
  fi
}

#
# *** Main function ***
#
function main() {
# Check that we are in the dir containing the main file.
  if ! [[ -f "${name}.tex" ]]; then
    echo "Could not find main file ${name}.tex. Exiting..."
    exit 1
  fi

# If no arguments given, do a normal build;
# - argument is debug: do debug build;
# - argument is get_compiler_pid: compile that function;
# - argument is killall_tex: compile that function.
  if [[ $# -eq 0 ]] ; then
    small_build
  elif [[ $# -eq 1 && "$1" == "big" ]] ; then
    big_build
  elif [[ $# -eq 1 && "$1" == "clean" ]] ; then
    clean
  elif [[ $# -eq 1 && "$1" == "debug" ]] ; then
    debugbuild
  elif [[ $# -eq 1 && "$1" == "final" ]] ; then
    final_document
  elif [[ $# -eq 1 && "$1" == "get_compiler_pid" ]] ; then
    get_compiler_pid
  elif [[ $# -eq 1 && "$1" == "killall_tex" ]] ; then
    killall_tex
  elif [[ $# -eq 1 && "$1" == "rebuild_build_files" ]] ; then
    rebuild_build_files
  elif [[ $# -eq 1 && "$1" == "symlinks" ]] ; then
    unabridged_dir_and_symlinks_rebuild
  elif [[ $# -eq 1 && "$1" == "u2r" ]] ; then
    u2r
  else
    echo "Unknown option(s): $@"
    exit 1
  fi
}

main "$@"

#####
# Notes:
# - (1) After an unsuccessful compilation, and after fixing the mistake that
#   caused it, a normal compile, in batchmode with halt on errors, will still lead
#   to a natbib error. It goes away after doing another normal compile. But perhaps
#   the best strategy is to do debug mode in case of errors...

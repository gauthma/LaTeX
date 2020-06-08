#! /bin/bash

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
# required), and then runs compile() three more times.
#
# Most of the remaining functions revolve around these three, to compile both
# the report and its unabridged version (only in the case of reports), and to
# check for errors and give feedback properly, and so on.

# IMPORTANT: to disable bibliography, set this to false.
got_bib="true"
# IMPORTANT: to disable building the index, set this to false.
got_idx="false"

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
got_unabridged="false"
name_unabridged="Unabridged"
build_dir_unabridged="build_UNABRIDGED"

# Please do note that this WIPES OUT THE ENTIRE unabridged_dir!
function clean() {

  echo -e "\nWARNING: after cleaning the build dir, it is VERY RECOMMENDED
  to do a big build, WITHOUT \\includeonly (use FULL option to this
  script). Otherwise things like bibliography might not build properly!\n"
  read -p "Press any key to continue... [ctrl-c cancels]" -n 1 -r

  if [[ -d "$build_dir_regular" ]]; then
    echo "Wiping contents of ${build_dir_regular} (except PDF files)"
    cd "${build_dir_regular}" && rm -rf $(ls | grep -v ".pdf") && cd ..
  else
    echo "Creating directory ${build_dir_regular}"
    mkdir $build_dir_regular
  fi

  if [[ "${got_unabridged}" == "true" ]]; then
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

# NOTA BENE: if any .tex files are in their own custom directories, those dirs
# must also exist in $build_dir, with the same hierarchy. See README.md for
# more details. Can be handled with rsync. Put code below, if/when needed.
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

function final_document() {
  big_build

  if [[ "${got_unabridged}" == "true" ]]; then
    cp "${build_dir_unabridged}"/"${name_unabridged}.pdf" "${finalname}.pdf"
  else
    cp "${build_dir_regular}"/"${name}.pdf" "${finalname}.pdf"
  fi
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
  if [[ "$got_idx" == "true" ]] ; then
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

# If the previous compile succeeded, and we have no bibliography, then just compile
# twice more and exit.
  if [[ "$got_bib" == "false" ]] ; then
    echo "$0: The \$got_bib var is set to false, so I assume there is no bibliography to build."
      echo "$0: I will just run compile() twice more."
    compile "$name" "$build_dir_regular" && \
      compile "$name" "$build_dir_regular"
# If one of the compile runs failed, notify the user and quit.
    if [[ $? -ne 0 ]]; then
      echo "(2nd or 3rd) compile run of ${name}.tex file was not successful!"
      exit 1
    fi

# If $got_bib is true, then build bib and do three compiles. The reason for *three*
# compiles, instead of the usual two, is that an extra compile is required for
# backreferences in bib entries to be constructed (e.g. "Cited in page ...").
  else
    local have_cite_entries=$(grep --recursive '\\cite' --include=*.tex)
    if [[ -z "$have_cite_entries" ]]; then
      echo "$0: The $got_bib var is set to true, but no \\cite entries found.
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
        bibliography_was_actuall_built = "true"
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
  if [[ "${got_unabridged}" == "true" ]]; then
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
    if [[ "$got_idx" == "true" ]] ; then
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
# If no bibliography requested, just do two small compile runs.
    else
      compile "${name_unabridged}" "$build_dir_unabridged" && \
        compile "${name_unabridged}" "$build_dir_unabridged"
# If one of the compile runs failed, notify the user and quit.
      if [[ $? -ne 0 ]]; then
        echo "(2nd or 3rd) compile run of ${name_unabridged}.tex file was not successful!"
        exit 1
      fi
    fi # If $got_bib is true.
  fi # If got unabridged copy.
  # Script execution should never reach this point.
}

function final_document() {
  big_build

  if [[ "${got_unabridged}" == "true" ]]; then
    cp "${build_dir_unabridged}"/"${name_unabridged}.pdf" "${finalname}.pdf"
  else
    cp "${build_dir_regular}"/"${name}.pdf" "${finalname}.pdf"
  fi
}

# This function comments the \includeonly line, if it exists, in $name.tex (it
# makes a backup copy first), and then does a big compile (by calling
# big_build). It temporarily sets $got_unabridged to false, to prevent
# big_build from building the unabridged copy as well (because the goal of this
# function is to build a complete instance of the main copy. This is required,
# e.g., after clean(): doing a big compile with \includeonly might lead to
# errors in, for example, bibliography building).
#
# It then waits for the big compile to finish, and restores (renames) the
# backup copy to $name.tex
function FULL_build() {

  local big_build_failed="false"

  rm -f "${name}.tex.orig" && cp "${name}.tex" "${name}.tex.orig"

  got_unabridged="false"
# Comment any \includeonly lines.
  sed -e '/^\s*\\includeonly/ s/^\s*\\/% \\/' -i "${name}.tex"
  big_build || big_build_failed = "true"
  wait

  if [[ $big_build_failed == "true" ]]; then
    echo "Big compile failed!"
    rm -f "${name}.tex" && mv "${name}.tex.orig" "${name}.tex"
    return 1
  fi

  echo "Finished big build."
  rm -f "${name}.tex" && mv "${name}.tex.orig" "${name}.tex"
  got_unabridged="true"
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
  if [[ "${got_unabridged}" == "true" ]]; then
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

# Copy main .tex file as $name_unabridged, patch it to comment all
# \includeonly's, and then build unabridged copy in $build_dir_unabridged.
function update_unabridged_tex_files() {
  cp "${name}.tex" "${name_unabridged}.tex"

  sed -e '/^\s*\\includeonly/ s/^/% /' -i "${name_unabridged}.tex"
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
  if [[ "${got_unabridged}" == "true" ]]; then
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
  elif [[ $# -eq 1 && "$1" == "FULL" ]] ; then
    FULL_build
  elif [[ $# -eq 1 && "$1" == "get_compiler_pid" ]] ; then
    get_compiler_pid
  elif [[ $# -eq 1 && "$1" == "killall_tex" ]] ; then
    killall_tex
  elif [[ $# -eq 1 && "$1" == "symlinks" ]] ; then
    unabridged_dir_and_symlinks_rebuild
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

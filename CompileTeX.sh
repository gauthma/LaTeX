#!/bin/bash

# Much like targets in a Makefile, this scripts provides functions to do a
# simple build, a full build, etc, for a LaTeX project.

# $name is one of: report, presentation, letter, llncs, cv, or standalone.
name="report"

# The final name of the .pdf file (without extension). Defaults to original
# name with ".FINAL" appended. In my setup, works "out of the box" with spaces,
# foreign chars, ...
finalname="${name}.FINAL"

# Name of the .bib file (sans extension).
sourcesname="sources"

build_dir="build"
docs_dir="docs"
unabridged_dir="_UNABRIDGED"

texcmd="xelatex"
texcmdopts="-halt-on-error --interaction=batchmode --shell-escape --output-directory=${build_dir}"
debug_texcmdopts="--interaction=errorstopmode --shell-escape --output-directory=${build_dir}"
bibcmd="bibtex"

# IMPORTANT: to disable bibliography, set this to false.
got_bib=true

# Can be useful when showing bib entries in say, a presentation.
function bibliography() {
  if [[ "$got_bib" = true ]] ; then

    # First see if there are actually any \cite commands in the .tex files. The
    # -F option to grep is to interpret the pattern as a fixed string.
    # If there is no such command, then do not build bibliography (and tell
    # that to the user).
    grep_for_cite=$(grep -rF "\cite" *.tex)
    if [[ -n "$grep_for_cite" ]]; then
      cd "${build_dir}" && pwd && ${bibcmd} ${name} && cd ..
      return 0
    else
      echo "$0: The \$got_bib var is set to true, but I cannot find any \\cite commands, so not building bibliography."
    fi
  else
    echo "$0: The \$got_bib var is set to false, so I assume there is no bibliography to build."
  fi
  return 1
}

# Please do note that this WIPES OUT THE ENTIRE unabridged_dir!
function clean() {
  echo "Wiping contents of build/ (except PDF files)"
  cd "${build_dir}" && rm -rf $(ls | grep -v ".pdf") && cd ..

  echo "Wiping contents of ${unabridged_dir}"
  rm -rf "${unabridged_dir}"/*

  # Rebuilding structure of $build_dir/.
  # NOTA BENE: if any .tex files are in their own custom directories, those
  # dirs must also exist in $build_dir, with the same hierarchy. See README.md
  # for more details.
  echo "ln -sr ${sourcesname}.bib ${build_dir}"
  ln -sr ${sourcesname}.bib ${build_dir}
}

# A normal (single) LaTeX compile run.
function debugbuild() {
  ${texcmd} ${debug_texcmdopts} ${name}
  return $?
}

function finalfullrun() {
  normalfullrun

  if [[ "${name}" == "report" ]]; then
    cp "${unabridged_dir}"/"${build_dir}"/"${name}.pdf" "${finalname}.pdf"
  else
    cp "${build_dir}"/"${name}.pdf" "${finalname}.pdf"
  fi
}

# A full LaTeX build run: run once, then run bib (if it is set), then run three
# more times (usually two a are enough, but in some thorny cases three are
# required, so...). If using bib is not set, just run twice.
function fullrun() {
  clean
  ${texcmd} ${texcmdopts} ${name}
  if [[ "$got_bib" = true ]] ; then
    bibliography
    local exit_status=$?
    if [[ "$exit_status" -eq 0 ]]; then
      ${texcmd} ${texcmdopts} ${name}
      ${texcmd} ${texcmdopts} ${name}
    fi
  fi
  ${texcmd} ${texcmdopts} ${name}
  return $?
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

# Do a normal run. If we are dealing with a report, also do a single run build
# on the unabridged copy.
#
# First do a simple run. Then, if it was successful, and if we are dealing with
# report, copy the files to $unabridged_dir. Lastly, do the normal run in the
# $unabridged_dir.
function normalbuild() {
  run # run() returns the $? of the LaTeX command. See Note (1).
  if [[ $? -ne 0 ]]; then
    echo "Compile of *.tex file was not successful!"
    exit 1
  fi

  # If run was successful, and we are dealing with report, then update
  # unabridged copy.
  if [[ "${name}" == "report" ]]; then
    update_unabridged_tex_files

    echo -e "\n*************************************************************************"
    echo -e "* Now continuing with (background) unabridged (normal, non-full) build..."
    echo -e "*************************************************************************\n"

    cd "${unabridged_dir}" && run &> /dev/null && cd .. &
  fi
}

function normalfullrun() {
  fullrun # run() returns the $? of the LaTeX command. See Note (1).
  if [[ $? -ne 0 ]]; then
    echo "Compile of *.tex file was not successful!"
    exit 1
  fi

  # If run was successful (LaTeX compiler should halt on errors), and we are
  # dealing with report, then update unabridged copy.
  if [[ "${name}" == "report" ]]; then
    update_unabridged_tex_files

    echo -e "\n*************************************************************************"
    echo -e "* Now continuing with (background) unabridged (normal, full) build..."
    echo -e "*************************************************************************\n"

    cd "${unabridged_dir}" && fullrun &> /dev/null && cd .. &
  fi
}

# A normal (single) LaTeX compile run.
function run() {
  ${texcmd} ${texcmdopts} ${name}
  return $?
}

# Copy all stuff (except $docs_dir and the $unabridged_dir itself) into
# $unabridged_dir, and comment all \includeonly lines, to produce an unabridged
# copy. After copying, remove Unabridged.pdf symlink inside $unabridged_dir, as
# it is not needed.
function update_unabridged_tex_files() {
  cp -r $(ls | grep -v "${unabridged_dir}\|${docs_dir}") "${unabridged_dir}"
  rm -f "${unabridged_dir}"/Unabridged.pdf
  sed -e '/^\s*\\includeonly/ s/^/% /' -i "${unabridged_dir}"/"${name}.tex"
}

function unabridged_dir_and_symlinks_rebuild() {
  mkdir -p "${unabridged_dir}"
  rm -f "${name}.pdf"
  rm -f "Unabridged.pdf"
  rm -f "${build_dir}/${sourcesname}.bib"

  ln -sr "${build_dir}/${name}.pdf" .
  ln -sr "${unabridged_dir}/${build_dir}/${name}.pdf" "Unabridged.pdf"
  ln -sr ${sourcesname}.bib "${build_dir}"/
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
  # - argument is get_compiler_pid: run that function;
  # - argument is killall_tex: run that function.
  if [[ $# -eq 0 ]] ; then
    normalbuild
  elif [[ $# -eq 1 && "$1" == "bib" ]] ; then
    bibliography
  elif [[ $# -eq 1 && "$1" == "clean" ]] ; then
    clean
  elif [[ $# -eq 1 && "$1" == "debug" ]] ; then
    debugbuild
  elif [[ $# -eq 1 && "$1" == "final" ]] ; then
    finalfullrun
  elif [[ $# -eq 1 && "$1" == "full" ]] ; then
    normalfullrun
  elif [[ $# -eq 1 && "$1" == "get_compiler_pid" ]] ; then
    get_compiler_pid
  elif [[ $# -eq 1 && "$1" == "killall_tex" ]] ; then
    killall_tex
  elif [[ $# -eq 1 && "$1" == "symlinks" ]] ; then
    unabridged_dir_and_symlinks_rebuild
  fi
}

main "$@"

#####
# Notes:
# - (1) After an unsuccessful compilation, and after fixing the mistake that
#   caused it, a normal run, in batchmode with halt on errors, will still lead
#   to a natbib error. It goes away after doing another normal run. But perhaps
#   the best strategy is to do debug mode in case of errors...

#!/bin/bash

doctype="$1"

# If the argument is actually a *.tex filename, then remove the extension to
# get the type.
if [[ "$doctype" == *.tex ]] ; then
  doctype="${doctype%????}" # Removes the .tex extension.
fi

function usage()
{
	cat <<EOF
Usage: $ sh $0 [report, cv, letter, llncs, presentation, standalone]

To call script pwd must be same as script location.

EOF
}

# full dir path of script
fullpath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# current dir
curr_dir="$(pwd)"

# make sure that pwd and script location are the same.
if [ "$fullpath" != "$curr_dir" ]; then
	usage
	exit 1
fi

case "$doctype" in
	report)
		;;
	cv)
		;;
	letter)
		;;
	llncs)
		;;
	presentation)
		;;
	standalone)
		;;
	-h)
		usage
		exit 0
		;;
	*)
		if [[ -z $doctype ]]; then
			usage
			exit 0
		else
			echo "Unknown type $doctype"
			exit 1
		fi
esac

echo "WARNING! WARNING! WARNING!"
echo "You are about to DELETE .git folder and data files (and THIS SCRIPT)!!"
read -p "Are you sure you want to continue? [type uppercase y]" -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Y]$ ]]; then
  rm -rf .git
  rm -f \
  $(ls  report.* \
        cv.* \
        letter.* docs/letter_logo* \
        llncs.* \
        presentation.* \
        standalone.* \
  | grep -v $doctype)

  rm -f \
  $(ls  includes/inc_report_preamble.tex \
        includes/inc_llncs_preamble.tex \
        includes/inc_presentation_preamble.tex \
  | grep -v $doctype)

  rm -f $(ls  build/*.pdf | grep -v $doctype)

  # Setup the Makefile (requires GNU sed)
  # Begin with setting what type of document we want (report, presentation, ...)
  sed -i "/^NAME=/c\NAME=\"$doctype\"" Makefile

  # For some documents, special tools must be used for compiling them.
  if [[ "${doctype}" == "llncs" ]] ; then
    sed -i "/^TEXCMD=/c\TEXCMD=pdflatex" Makefile
  elif [[ "${doctype}" == "presentation" ]]; then
    sed -i "/^TEXCMD=/c\TEXCMD=pdflatex" Makefile
  fi

  # standalone doesn't need either inc_* or .bib files,
  # which we can delete.
  # Otherwise, symlink bib file to build dir (bibtex has to be run inside this dir).
  if [[ "${doctype}" == "standalone" ]] ; then
    rm -rf includes/
    rm sources.bib
  else
    ln -sr sources.bib build/
  fi

  # Remove the README.md symlink; the file is the doc/ directory is needed.
  rm README.md

  # The actual pdf is in the build directory; instead of moving it, we symlink
  # it up. The same must also be done for the synctex file.
  ln -sr build/"${doctype}.pdf" .
  ln -sr build/"${doctype}.synctex.gz" .

  # Finally delete this script (no use for it after everything is set up).
  rm -- "$0"
fi

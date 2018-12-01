#!/bin/bash

TYPE="$1" 

function usage()
{
	cat <<EOF
Usage: $ sh $0 [report, cv, letter, llncs, presentation, standalone]

To call script pwd must be same as script location.

EOF
}

# full dir path of script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# current dir
CURR_DIR="$(pwd)"

# make sure that pwd and script location are the same.
if [ "$DIR" != "$CURR_DIR" ]; then
	usage
	exit 1
fi

case "$TYPE" in
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
		if [[ -z $TYPE ]]; then
			usage
			exit 0
		else
			echo "Unknown type $TYPE"
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
        letter.* letter_logo* \
        llncs.* \
        presentation.* \
        standalone.* \
  | grep -v $TYPE)
  rm -f \
  $(ls  includes/inc_report_preamble.tex \
        includes/inc_llncs_preamble.tex \
        includes/inc_presentation_preamble.tex \
  | grep -v $TYPE)

  # Setup the Makefile (requires GNU sed)
  # Begin with setting what type of document we want (report, presentation, ...)
  sed -i "/^NAME=/c\NAME=\"$TYPE\"" Makefile

  # For some documents, special tools must be used for compiling them.
  # Additionally, standalone doesn't need either inc_* or .bib files,
  # which we can delete.
  if [[ "${TYPE}" == "llncs" ]]; then
    sed -i "/^TEXCMD=/c\TEXCMD=pdflatex" Makefile
  elif [[ "${TYPE}" == "presentation" ]]; then
    sed -i "/^TEXCMD=/c\TEXCMD=pdflatex" Makefile
  elif [[ "${TYPE}" == "standalone" ]]; then
    rm -rf includes/
    rm sources.bib
  fi
  # Finally remove README and delete this script (no use for it after everything is set up)
  rm README.md
  rm -- "$0"
fi

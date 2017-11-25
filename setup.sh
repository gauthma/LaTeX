#!/bin/bash

TYPE="$1" 

function usage()
{
	cat <<EOF
Usage: $ sh $0 [article, cv, letter, llncs, presentation, standalone]

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
	article)
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

rm -rf .git
rm -f \
$(ls  article.* \
      cv.* \
      letter.* letter_logo* \
      llncs.* \
      presentation.* \
      standalone.* \
| grep -v $TYPE)

# Setup the Makefile (requires GNU sed)
sed -i "/^NAME=/c\NAME=\"$TYPE\"" Makefile

if [[ "${TYPE}" == "llncs" ]]; then
  sed -i "/^TEXCMD=/c\TEXCMD=pdflatex" Makefile
  sed -i "/^BIBCMD=/c\BIBCMD=bibtex" Makefile
fi

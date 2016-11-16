#!/bin/bash

TYPE="$1" 

function usage()
{
	cat <<EOF
Usage: $ sh $0 [article, cv, letter, presentation, tikzfig]

To call script pwd must be same as script location.

EOF
}

# full path of script
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
	presentation)
		;;
	tikzfig)
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
  		presentation.* \
  		tikzfig.* \
| grep -v $TYPE)

# Setup the Makefile (using sed the portable way)
sed -e "/^NAME=/c\NAME=\"$TYPE\"" Makefile > Makefile.new
mv Makefile.new Makefile

#!/bin/bash

invalidOptionMessage="is an invalid option! Exiting..."
maxDepth=1
minDepth=1
newDirName=$(date +"%y-%m-%d_%H%M%S")_dtarraySetup

function usage {
	echo -e '\nusage: DTsetup [--output <name>] [--maxdepth <depth>] [-h] [<input_dirs> ...]\n'
}

#get arguments
while ! [[ -z "$1" ]] ; do
	case $1 in
        "-o" | "--output")
            shift
            newDirName="$1"
        ;;
		"-d" | "--maxdepth")
			shift
			maxDepth="$1"
		;;
		"--mindepth")
			shift
			minDepth="$1"
		;;
		'-h' | '--help')
			usage
			exit
		;;
		*)
            while ! [[ -z "$1" ]] ; do
                if [[ "$1" == -* ]] ; then
                   usage
                else
                    posArgs+=( "$1" )
                    destDir="$temp"
                fi
                shift
            done
        ;;
	esac
	shift
done

inDirs=()
#if no posArgs were given, use current working dir
if [ ${#posArgs[@]} -eq 0 ]; then
    filterFiles=($(find $(printf '%s\n' "./" | xargs) -maxdepth $maxDepth -mindepth $minDepth |grep 'DTASelect-filter.txt$'))
else
    filterFiles=($(find $(printf '%s\n' "${posArgs[@]}" | xargs) -maxdepth $maxDepth -mindepth $minDepth |grep 'DTASelect-filter.txt$'))
fi

# echo "${#filterFiles[@]}"
# printf '%s\n' "${filterFiles[@]}"

if [ ${#filterFiles[@]} == 0 ] ; then
    echo -e "No filter files found! Exiting...\n"
    exit
fi

echo "Creating dtarraySetup folder in parent dirrectory..."
mkdir -p "$newDirName"
echo "Copying DTA filter files to $newDirName..."
    for f in ${filterFiles[@]} ; do
        newBase=$(dirname "$f"| sed 's/^\.\///g' |sed 's/\//_/g')
        cp -v "$f" $newDirName/"$newBase".dtafilter
    done

echo Done


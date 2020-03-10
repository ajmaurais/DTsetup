#!/bin/bash

invalidOptionMessage="is an invalid option! Exiting..."
inputFormat="std"

function usage {
	echo -e '\nusage: DTsetup [--inputFormat {std,subdir}] [-h]\n'
}

#get arguments
while ! [[ -z "$1" ]] ; do
	case $1 in
		"-i" | "--inputFormat")
			shift
			inputFormat="$1"
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
    for d in ./* ; do
        inDirs+=( $d )
    done
else
    for ((i=0;i<${#posArgs[@]};++i)); do
        inDirs+=( ${posArgs[i]} )
    done
fi

#genearte a folder in parent dir with the name $newDirName and copy all DTA-filter
#files into $nweDirName using specified inputFormat
newDirName=$(date +"%y-%m-%d_%H%M%S")_dtarraySetup
echo "Creating dtarraySetup folder in parent dirrectory..."
mkdir $newDirName
echo "Copying DTA filter files to $newDirName..."
case $inputFormat in
	"std")
		#itterate through all dirs one level below parent dir looking for
		#DTA_filter files
        for D in ${inDirs[@]} ; do
			#skip new dir just made
			if ! [ "${D/dtarraySetup}" = "$D" ] ; then
				continue;
			fi
			#copy each DTA filter file into dtarraySetup folder with the name of the dir
			#that it is currently stored in
			if [ -d "$D" ] ; then
				cd $D
				if [ -f DTASelect-filter.txt ] ; then
                    base_temp=$(basename "$D")
					echo -e "\tAdding $base_temp..."
					cp DTASelect-filter.txt ../$newDirName/"$base_temp".dtafilter
				fi
				cd ..
			fi
		done
	;;
	"subdir")
        # Find all DTAFilter files one level below current directory.
		for f in $(printf '%s\n' "${inDirs[@]}" | xargs find|grep 'DTASelect-filter.txt$') ; do
            newBase=$(dirname "$f"| sed 's/\//_/g')
            cp -v "$f" $newDirName/"$newBase".dtafilter
		done
	;;
	*)
		echo $inputFormat" is not a valid input format! Exiting..."
	;;
esac

echo Done


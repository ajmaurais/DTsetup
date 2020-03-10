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
			echo "$1" $invalidOptionMessage
			usage
			exit
		;;
	esac
	shift
done

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
		for D in ./* ; do
			#skip new dir just made
			if ! [ "${D/dtarraySetup}" = "$D" ] ; then
				continue;
			fi
			#copy each DTA filter file into dtarraySetup folder with the name of the dir
			#that it is currently stored in
			if [ -d "$D" ] ; then
				cd $D
				if [ -f DTASelect-filter.txt ] ; then
					echo -e "\tAdding $D..."
					cp DTASelect-filter.txt ../$newDirName/"$D".dtafilter
				fi
				cd ..
			fi
		done
	;;
	"subdir")
        # Find all DTAFilter files one level below current directory.
		for f in $(find *|grep 'DTASelect-filter.txt$') ; do
            newBase=$(dirname "$f"| sed 's/\//_/g')
            cp -v "$f" $newDirName/"$newBase".dtafilter
		done
	;;
	*)
		echo $inputFormat" is not a valid input format! Exiting..."
	;;
esac

echo Done


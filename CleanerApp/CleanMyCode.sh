
#!/bin/bash
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>log.out 2>&1

if [ -z "$1" ]; then    #empty param
  echo "You have to enter the complete file's name you want to clean."
  exit 1
else
    if [[ $1 != *.* ]] ; then   #extension missing
        echo "You have to enter the complete file's name you want to clean, don't forget the file's extension."
        exit 2
    fi
fi

#$0 = current file's path
#$1 = 1st parameter = file's name
#$2 = 2nd parameter = commit's name

DirtyFile=$1
commit=$2
today=$(date +"%m-%d-%y"_"%Hh%Mm%Ssec")

##copy past the file to a dediacted folder
SourcePath=$commit'_'$today
echo "folder" $SourcePath "has been created."
mkdir $SourcePath

cp $DirtyFile $SourcePath
File=$SourcePath'/'$DirtyFile

str=$(cat $File | grep -oP '<\K.*(?=>)' | grep -oP '="\K.*(?=" )' || grep -oP '="\K.*(?=")' || grep -oP "='\K.*(?=' )")

oldArr=()
newArr=()
arrLen=0

cd CleanerApp
    for value in $str; do
        oldArr+=("$value"); 
        res=$(dotnet run Program.cs $value); 
        newArr+=("$res"); 
    done

    for i in ${newArr[@]}; do 
        arrLen=$((arrLen+1));
    done
cd ..
for((word=0;word<$arrLen;word++));
do
    if [ ${oldArr[word]} != ${newArr[word]} ]; then
        echo "we will replace the word" ${oldArr[word]}
        echo ${newArr[word]}
        sed -i 's/${oldArr[word]}/${newArr[word]}/g' $File
    fi
done
echo "Your file is clean."
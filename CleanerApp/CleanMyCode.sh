
#!/bin/sh
#
# A hook script to verify that no images with capital letters are committed.
# Called by "git commit" with no arguments and check on the file and see if 
# variables name contains any non-english char.
# The hook should exit with non-zero status after issuing an appropriate message if
# it wants to stop the commit.

# Test only php files
php_pattern="\.php"
# Check for changed lines
added_lines="^\+"
# Check for lines with comments
comment="(//|/\*).*"
beginning_of_line="^\+[\s]*"
# Set exit code to 0, will be set to 1 on error.
exit_code=0
# Grep git diff of files to commit
php_files=$(	
	git diff --cached --find-copies --find-renames --name-only --diff-filter=ACMRTXBU | 
	grep -E "$php_pattern" 
)


if [[ -n $php_files ]]; 
then
	for file in $php_files; do
		# Get only changed lines AND
		# Only lines starting with '+' AND
		# NOT lines with comments
		lines_with_no_comment=$(	
			git diff --cached $file | 
			grep -E "$added_lines" |
			grep -Ev "$comment" 
		)
		# Get only changed lines AND
		# Only lines starting with '+' AND
		# NOT lines starting with a comment
		lines_with_comment=$( 
			git diff --cached $file | 
			grep -E "$added_lines" |
			grep -Ev "$beginning_of_line$comment" 
		)
		
		
		if [[ -n $lines_with_no_comment || -n $lines_with_comment ]];
		then
			echo 
			echo -e "Found illegal commands in \033[1m$file:\033[0m"
			echo -e '\E[0;32m'"$lines_with_no_comment"
			echo -e "$lines_with_comment"'\033[0m'
			echo			
			# Abort commit
			exit_code=1		
		fi

        # we check on the file and see if variables name contains any non-english char (é,à,ù,ô...) and if so we correct it
        str=$(cat $file | grep -oP '<\K.*(?=>)' | grep -oP '="\K.*(?=" )' || grep -oP '="\K.*(?=")' || grep -oP "='\K.*(?=' )")
        oldArr=()
        newArr=()
        arrLen=0

        cd /home/git/clone/CleanerApp/CleanerApp
            for value in $str; do
                oldArr+=("$value"); 
                res=$(dotnet run Program.cs $value); 
                newArr+=("$res"); 
            done

            for i in ${newArr[@]}; do 
                arrLen=$((arrLen+1));
            done
            cd ..
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
                
    done
fi

# Check if file is an image JPG|GIF|PNG|JPEG and check for uppercase letters

# Check for image file types 
mime_pattern="\.(gif|png|jpg|jpeg)"
# Check for capital letters only in file names
extra_pattern="(^|/)[^/]*([A-Z]+)[^/]*\.[A-Za-z]{3}$"
# Grep git diff of files to commit
files=$(	git diff --cached --find-copies --find-renames --name-only --diff-filter=ACMRTXBU | 
			grep -Ei "$mime_pattern" | 
			grep -E  "$extra_pattern" )

if [[ -n $files ]]; 
then
	echo 
	echo "Found image files that contain capital letters."
	echo "Please rename the following files and commit again:" 
	
	for file in $files; do
		echo -e '\E[0;32m'"$file"'\033[0m'
	done		
	# Abort commit
	exit_code=1
fi

if [ $exit_code == 0 ]; then
	echo
	echo -e '\033[1m'"Pre-commit validation Passed"'\033[0m'
	echo
else
	echo
	echo -e '\033[1m'"Commit Aborted!"'\033[0m' 
	echo
fi
exit $exit_code


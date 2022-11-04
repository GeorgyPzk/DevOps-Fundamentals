#!/bin/bash
csv_file_path=$1
#echo $csv_file_path
#/home/georgy/task1
part_csv_file_path=${csv_file_path::${#csv_file_path}-4} # delite last 4 symbols
new_csv_file_path="${part_csv_file_path}_new.csv"
rm -R $new_csv_file_path
touch $new_csv_file_path

oldfield1="0"
oldfield2="0"
oldfield3="0"
oldfield4="0"
oldfield5="0"
oldfield6="0"


while IFS=, read -r field1 field2 field3 field4 field5 field6 field7 field8 # read all line and separate columns
do
if [[ "$field1" = "id" ]]; then
    echo "${field1},${field2},${field3},${field4},${field5},${field6}" >> $new_csv_file_path # writing column names
else
    SUB="\""
    if [[ "$field4" == *"$SUB"* ]] && [[ "$field5" == *"$SUB"* ]]; then # if string have "
        field4="${field4},${field5}"
        field5=$field6
        field6=$field7
    elif [[ "$field4" == *"$SUB"* ]] && [[ "$field6" == *"$SUB"* ]]; then
        field4="${field4},${field5},${field6}"
        field5=$field7
        field6=$field8
    fi

    IFS=" " # separator sign for name
    read -a name <<< "$field3"  # separating name
    field3="${name[0]^} ${name[1]^}" # Write name with upper frist symbol

    if [[ "$oldfield3" == "$field3" ]]; then 
        name[1]=$(echo ${name[1]} | sed 's/-//g') # Replace -
        email5="${name[0]:0:1}${name[1]}${field2}@abc.com" # Compiling an email
        field5="${email5,,}" # lower case
        #fix old email
        oldemail5="${name[0]:0:1}${name[1]}${oldfield2}@abc.com" # Compiling an email
        oldfield5="${oldemail5,,}" # lower case
    else 
        name[1]=$(echo ${name[1]} | sed 's/-//g') # Replace -
        email5="${name[0]:0:1}${name[1]}@abc.com" # Compiling an email
        field5="${email5,,}" # lower case
    fi

    if [[ "$oldfield1" != "0" ]]; then 
        echo "${oldfield1},${oldfield2},${oldfield3},${oldfield4},${oldfield5},${oldfield6}" >> $new_csv_file_path # write
    fi
    oldfield1=$field1
    oldfield2=$field2
    oldfield3=$field3
    oldfield4=$field4
    oldfield5=$field5
    oldfield6=$field6
fi
done < $csv_file_path 

echo "${oldfield1},${oldfield2},${oldfield3},${oldfield4},${oldfield5},${oldfield6}" >> $new_csv_file_path
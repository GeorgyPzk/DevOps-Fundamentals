#!/bin/bash
csv_file_path=$1
#echo $csv_file_path
#/home/georgy/task1
part_csv_file_path=${csv_file_path::${#csv_file_path}-4} # delite last 4 symbols
new_csv_file_path="${part_csv_file_path}_new.csv"
rm -R $new_csv_file_path
touch $new_csv_file_path

while IFS=, read -r field1 field2 field3 field4 field5 field6 # read all line and separate columns
do
if [[ "$field1" = "id" ]]; then
    echo "${field1},${field2},${field3},${field4},${field5},${field6}" >> $new_csv_file_path # writing column names
else
    IFS=" " # separator sign for name
    read -a name <<< "$field3"  # separating name 
    field3="${name[0]^} ${name[1]^}" # Write name with upper frist symbol
    name[1]=$(echo ${name[1]} | sed 's/-//g') # Replace -
    #field5="${name[0]:0:1}${name[1]}${field2}@abc.com" # Compiling an email
    email5="${name[0]:0:1}${name[1]}${field2}@abc.com" # Compiling an email
    email5=$(echo ${email5} | sed 's/-//g') # Replace -
    field5="${email5,,}" # lower case
    echo "${field1},${field2},${field3},${field4},${field5},${field6}" >> $new_csv_file_path # write to file
fi
done < $csv_file_path 

#!/bin/bash
path=$1
echo $path
#/home/georgy/task1
rm -R $path/accounts_new.csv
touch $path/accounts_new.csv

while IFS=, read -r field1 field2 field3 field4 field5 field6 # read all line and separate columns
do
if [[ "$field1" = "id" ]]; then
    echo "${field1},${field2},${field3},${field4},${field5},${field6}" >> $path/accounts_new.csv # writing column names
else
    IFS=" " # separator sign for name
    read -a name <<< "$field3"  # separating name 
    field3="${name[0]^} ${name[1]^}" # Write name with upper frist symbol
    field5="${name[0]:0:1}${name[1]}${field2}@abc.com" # Compiling an email
    field5="${field5,,}" # lower case
    echo "${field1},${field2},${field3},${field4},${field5},${field6}" >> $path/accounts_new.csv # write to file
fi
done < $path/accounts.csv 

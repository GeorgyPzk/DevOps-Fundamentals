#!/bin/bash
rm -R /home/georgy/task1/accounts_new.csv
touch /home/georgy/task1/accounts_new.csv

while IFS=, read -r field1 field2 field3 field4 field5 field6 # read all line and separate columns
do
if [[ "$field1" = "id" ]]; then
    echo "${field1},${field2},${field3},${field4},${field5},${field6}" >> /home/georgy/task1/accounts_new.csv # writing column names
else
    #echo "${#field3}" # вывод кол во символов
    #echo "${field3:3}" #вывод с 3 символа
    IFS=" " # separator sign for name
    read -a name <<< "$field3"  # separating name 
    field3="${name[0]^} ${name[1]^}" # Write name with upper frist symbol
    field5="${name[0]:0:1}${name[1]}${field2}@abc.com" # Compiling an email
    field5="${field5,,}" # lower case
    echo "${field1},${field2},${field3},${field4},${field5},${field6}" >> /home/georgy/task1/accounts_new.csv # write to file
fi
done < /home/georgy/task1/accounts.csv 

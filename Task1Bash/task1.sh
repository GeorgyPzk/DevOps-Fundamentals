#!/bin/bash
rm -R /home/georgy/task1/accounts_new.csv
touch /home/georgy/task1/accounts_new.csv

while IFS=, read -r field1 field2 field3 field4 field5 field6
do
if [[ "$field1" = "id" ]]; then
    echo "${field1},${field2},${field3},${field4},${field5},${field6}" >> /home/georgy/task1/accounts_new.csv
else
    #echo "${#field3}" # вывод кол во символов
    #echo "${field3:3}" #вывод с 3 символа
    IFS=" "
    read -a name <<< "$field3"
    field3="${name[0]^}"
    field3+=" ${name[1]^}"
    field5="${name[0]:0:1}${name[1]}${field2}@abc.com"
    field5="${field5,,}"
    echo "${field1},${field2},${field3},${field4},${field5},${field6}" >> /home/georgy/task1/accounts_new.csv
fi
done < /home/georgy/task1/accounts.csv 

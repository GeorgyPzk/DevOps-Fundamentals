# Вырезать всё после “BLABLABLA”, фразу “BLABLABLA” оставить:
# sed -r 's/(.+BLABLABLA).+/\1/'

file_path_txt=$1
echo $file_path_txt
part_file_path=${csv_file_path::${#csv_file_path}-4} # delite last 4 symbols
file_path_json=${file_path_txt/%".txt"/".json"}
echo $file_path_json
rm -R $file_path_json
touch $file_path_json

#$path/output.json
#C:\GeorgeWork\Git\DevOps-Fundamentals\PSTask1\output.txt
stage="start"
success=0
failed=0
while IFS= read -r line
do
    if [[ "${line:0:1}" = "[" ]] && [ "$stage" == "start" ]; then
        testName=${line:2}
        testName=$(echo $testName | sed -r 's/].+//')
        echo "{" >> $file_path_json
        echo "\"testName\":\"$testName\"," >> $file_path_json

    elif [[ "${line:1:1}" != "-" ]] && [ "$stage" == "main" ]; then
        status=$(echo $line | sed -r 's/(.+k).+/\1/')
        countstatus="${#status}"
        number=$(echo ${line:${#status}+2} | sed -r 's/ .+//')
        startName="${line:${#status}+${#number}+4}" # full line starts when start name
        name=$(echo $startName | sed -r 's/(.+\)).+/\1/') # delite all after ")"
        duration="${line:${#status}+${#number}+${#name}+6}"
        #Change "ok" to "true"
        if [  "$status" == "ok"  ]; then
            status="true"
        elif [ "$status" == "not ok" ]; then
            status="false"
        else
            status="not valid"
        fi
        # Print to json
        echo " {" >> $file_path_json
        echo "  \"name\":\"$name\"," >> $file_path_json
        echo "  \"status\":$status," >> $file_path_json
        echo "  \"duration\":\"$duration\"" >> $file_path_json
        echo " }," >> $file_path_json
    fi
    # Start main part
    if [[ "${line:1:1}" = "-" ]] && [ "$stage" == "start" ]; then
        stage="main"
        echo "\"tests\":[" >> $file_path_json
    # End main part
    elif [[ "${line:1:1}" = "-" ]] && [ "$stage" == "main" ]; then
        stage="result"
        sed -i '$ d' output.json # Delite last string in file
        echo " }" >> $file_path_json
        echo "]," >> $file_path_json
    fi

done < $file_path_txt

# Take last string and print res
if [[ "${line:1:1}" != "-" ]] && [ "$stage" == "result" ]; then
        success=$(echo $line | sed -r 's/ .+//')
        duration=$(echo $line | sed -r 's|.*, ||' | sed 's|.* ||')
        countfailed=$(echo $line | sed -r 's/,.+//')
        failed=$(echo ${line:${#countfailed}+1} | sed -r 's/ .+//')
        rating=$(echo ${line:${#countfailed}+${#failed}+2} | sed -r 's/%.+//' | sed 's|.*as ||')
        echo "\"summary\": {" >> $file_path_json
        echo " \"success\": $success," >> $file_path_json
        echo " \"failed\": $failed," >> $file_path_json
        echo " \"rating\": $rating," >> $file_path_json
        echo " \"duration\": \"$duration\"" >> $file_path_json
        echo " }" >> $file_path_json
        echo "}" >> $file_path_json
fi
#echo "$stage"

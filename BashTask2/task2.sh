# Вырезать всё после “BLABLABLA”, фразу “BLABLABLA” оставить:
# sed -r 's/(.+BLABLABLA).+/\1/'

path=$1
echo $path
rm -R $path/output.json
touch $path/output.json

#$path/output.json
#$path/output.txt
stage="start"
success=0
failed=0
while IFS= read -r line
do
    if [[ "${line:0:1}" = "[" ]] && [ "$stage" == "start" ]; then
        testName=${line:2}
        testName=$(echo $testName | sed -r 's/].+//')
        echo "{" >> $path/output.json
        echo "\"testName\":\"$testName\"," >> $path/output.json

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
        echo " {" >> $path/output.json
        echo "  \"name\":\"$name\"," >> $path/output.json
        echo "  \"status\":$status," >> $path/output.json
        echo "  \"duration\":\"$duration\"" >> $path/output.json
        echo " }," >> $path/output.json
    fi
    # Start main part
    if [[ "${line:1:1}" = "-" ]] && [ "$stage" == "start" ]; then
        stage="main"
        echo "\"tests\":[" >> $path/output.json
    # End main part
    elif [[ "${line:1:1}" = "-" ]] && [ "$stage" == "main" ]; then
        stage="result"
        sed -i '$ d' output.json # Delite last string in file
        echo " }" >> $path/output.json
        echo "]," >> $path/output.json
    fi

done < $path/output.txt

# Take last string and print res
if [[ "${line:1:1}" != "-" ]] && [ "$stage" == "result" ]; then
        success=$(echo $line | sed -r 's/ .+//')
        duration=$(echo $line | sed -r 's|.*, ||' | sed 's|.* ||')
        countfailed=$(echo $line | sed -r 's/,.+//')
        failed=$(echo ${line:${#countfailed}+1} | sed -r 's/ .+//')
        rating=$(echo ${line:${#countfailed}+${#failed}+2} | sed -r 's/%.+//' | sed 's|.*as ||')
        echo "\"summary\": {" >> $path/output.json
        echo " \"success\": $success," >> $path/output.json
        echo " \"failed\": $failed," >> $path/output.json
        echo " \"rating\": $rating," >> $path/output.json
        echo " \"duration\": \"$duration\"" >> $path/output.json
        echo " }" >> $path/output.json
        echo "}" >> $path/output.json
fi
#echo "$stage"

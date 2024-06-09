#!/bin/sh
###############################################################
## Spreadsheet test script                                   ##
###############################################################
# * By Howard and Sam
###############################################################

HOST=localhost:3000

SCORE=0

###############################################################
## Test [1]: List Empty Database                             ##
###############################################################
RESOURCE=$HOST/cells
ANSWER="\[\]"

STATUS=$(curl -s -X GET -o body -w "%{http_code}" $RESOURCE)
if [ $STATUS == "200" ]; then
    grep -q $ANSWER body
    if [ $? -eq 0 ]; then
        echo "Test [1]: OK"; SCORE=$(expr $SCORE + 1)
    else
        echo "Test [1]: FAIL"
    fi
else
    echo "Test [1]: FAIL (" $STATUS "!= 200 )"
fi

###############################################################
## Test [2]: Create B2 with single integer                   ##
###############################################################
ID="B2"; FORMULA="6"
RESOURCE=$HOST/cells/$ID

STATUS=$(curl -s -X PUT -d "{\"id\":\"$ID\",\"formula\":\"$FORMULA\"}" \
    -H "Content-Type: application/json" -w "%{http_code}" $RESOURCE)
if [ $STATUS == "201" ]; then
    echo "Test [2]: OK"; SCORE=$(expr $SCORE + 1)
else
    echo "Test [2]: FAIL (" $STATUS "!= 201 )"
fi

###############################################################
## Test [3]: Create B3 with integer calculation              ##
###############################################################
ID="B3"; FORMULA="3 + 4"
RESOURCE=$HOST/cells/$ID

STATUS=$(curl -s -X PUT -d "{\"id\":\"$ID\",\"formula\":\"$FORMULA\"}" \
    -H "Content-Type: application/json" -w "%{http_code}" $RESOURCE)
if [ $STATUS == "201" ]; then
    echo "Test [3]: OK"; SCORE=$(expr $SCORE + 1)
else
    echo "Test [3]: FAIL (" $STATUS "!= 201 )"
fi

###############################################################
## Test [4]: Create D4 with single integer                   ##
###############################################################
ID="D4"; FORMULA="3000"
RESOURCE=$HOST/cells/$ID

STATUS=$(curl -s -X PUT -d "{\"id\":\"$ID\",\"formula\":\"$FORMULA\"}" \
    -H "Content-Type: application/json" -w "%{http_code}" $RESOURCE)
if [ $STATUS == "201" ]; then
    echo "Test [4]: OK"; SCORE=$(expr $SCORE + 1)
else
    echo "Test [4]: FAIL (" $STATUS "!= 201 )"
fi

###############################################################
## Test [5]: Update D4 with cells calculation                ##
###############################################################
ID="D4"; FORMULA="B2 * B3"
RESOURCE=$HOST/cells/$ID

STATUS=$(curl -s -X PUT -d "{\"id\":\"$ID\",\"formula\":\"$FORMULA\"}" \
    -H "Content-Type: application/json" -w "%{http_code}" $RESOURCE)
if [ $STATUS == "204" ]; then
    echo "Test [5]: OK"; SCORE=$(expr $SCORE + 1)
else
    echo "Test [5]: FAIL (" $STATUS "!= 204 )"
fi

###############################################################
## Test [6]: Read cells calculation from D4                  ##
###############################################################
ID="D4"
ANSWER="\"formula\":\"42\""
RESOURCE=$HOST/cells/$ID

STATUS=$(curl -s -X GET -o body -w "%{http_code}" $RESOURCE)
if [ $STATUS == "200" ]; then
    grep -q $ANSWER body
    if [ $? -eq 0 ]; then
        echo "Test [6]: OK"; SCORE=$(expr $SCORE + 1)
    else
        echo "Test [6]: FAIL"
    fi
else
    echo "Test [6]: FAIL (" $STATUS "!= 200 )"
fi

###############################################################
## Test [7]: Create A9 without formula JSON                  ##
###############################################################
ID="A9"
RESOURCE=$HOST/cells/$ID

STATUS=$(curl -s -X PUT -d "{\"id\":\"$ID\"}" \
    -H "Content-Type: application/json" -w "%{http_code}" $RESOURCE)
if [ $STATUS == "400" ]; then
    echo "Test [7]: OK"; SCORE=$(expr $SCORE + 1)
else
    echo "Test [7]: FAIL (" $STATUS "!= 400 )"
fi

###############################################################
## Test [8]: Create A9 without id JSON                       ##
###############################################################
ID="A9"
FORMULA="3000 + 7000"
RESOURCE=$HOST/cells/$ID

STATUS=$(curl -s -X PUT -d "{\"formula\":\"$FORMULA\"}" \
    -o body -H "Content-Type: application/json" -w "%{http_code}" $RESOURCE)
if [ $STATUS == "400" ]; then
    echo "Test [8]: OK"; SCORE=$(expr $SCORE + 1)
else
    echo "Test [8]: FAIL (" $STATUS "!= 400 )"
fi

###############################################################
## Test [9]: Update cell with unmatched id                   ##
###############################################################
ID="B2"; ID2="B3"; FORMULA="3 + 4"
RESOURCE=$HOST/cells/$ID2

STATUS=$(curl -s -X PUT -d "{\"id\":\"$ID\",\"formula\":\"$FORMULA\"}" \
    -H "Content-Type: application/json" -w "%{http_code}" $RESOURCE)
if [ $STATUS == "400" ]; then
    echo "Test [9]: OK"; SCORE=$(expr $SCORE + 1)
else
    echo "Test [9]: FAIL (" $STATUS "!= 400 )"
fi

###############################################################
## Test [10]: List current cells                             ##
###############################################################
RESOURCE=$HOST/cells
ANSWER1="B2"
ANSWER2="B3"
ANSWER3="D4"

STATUS=$(curl -s -X GET -o body -w "%{http_code}" $RESOURCE)
if [ $STATUS == "200" ]; then
    grep -q $ANSWER1 body
    if [ $? -eq 0 ]; then
        grep -q $ANSWER2 body
        if [ $? -eq 0 ]; then
            grep -q $ANSWER3 body
            if [ $? -eq 0 ]; then
                echo "Test [10]: OK"; SCORE=$(expr $SCORE + 1)
            else
                echo "Test [10]: FAIL"
            fi
        else
            echo "Test [10]: FAIL"
        fi
    else
        echo "Test [10]: FAIL"
    fi
else
    echo "Test [10]: FAIL (" $STATUS "!= 200 )"
fi

###############################################################
## Test [11]: Read cell that not exist                       ##
###############################################################
ID="D99"
RESOURCE=$HOST/cells/$ID

STATUS=$(curl -s -X GET -o body -w "%{http_code}" $RESOURCE)
if [ $STATUS == "404" ]; then
    echo "Test [11]: OK"; SCORE=$(expr $SCORE + 1)
else
    echo "Test [11]: FAIL (" $STATUS "!= 404 )"
fi

###############################################################
## Test [12]: Create B5 with complex cells formula           ##
###############################################################
ID="B5"; FORMULA="D4 * B3"
RESOURCE=$HOST/cells/$ID

STATUS=$(curl -s -X PUT -d "{\"id\":\"$ID\",\"formula\":\"$FORMULA\"}" \
    -H "Content-Type: application/json" -w "%{http_code}" $RESOURCE)
if [ $STATUS == "201" ]; then
    echo "Test [12]: OK"; SCORE=$(expr $SCORE + 1)
else
    echo "Test [12]: FAIL (" $STATUS "!= 201 )"
fi

###############################################################
## Test [13]: Read B5 with complex cells formula             ##
###############################################################
ID="B5"
ANSWER="\"formula\":\"294\""
RESOURCE=$HOST/cells/$ID

STATUS=$(curl -s -X GET -o body -w "%{http_code}" $RESOURCE)
if [ $STATUS == "200" ]; then
    grep -q $ANSWER body
    if [ $? -eq 0 ]; then
        echo "Test [13]: OK"; SCORE=$(expr $SCORE + 1)
    else
        echo "Test [13]: FAIL"
    fi
else
    echo "Test [13]: FAIL (" $STATUS "!= 200 )"
fi

###############################################################
## Test [14]: Update B5 with complex negative calculation    ##
###############################################################
ID="B5"; FORMULA="D4 * -B3"
RESOURCE=$HOST/cells/$ID

STATUS=$(curl -s -X PUT -d "{\"id\":\"$ID\",\"formula\":\"$FORMULA\"}" \
    -H "Content-Type: application/json" -w "%{http_code}" $RESOURCE)
if [ $STATUS == "204" ]; then
    echo "Test [14]: OK"; SCORE=$(expr $SCORE + 1)
else
    echo "Test [14]: FAIL (" $STATUS "!= 204 )"
fi

###############################################################
## Test [15]: Read B5 with complex negative calculation      ##
###############################################################
ID="B5"
ANSWER="\"formula\":\"-294\""
RESOURCE=$HOST/cells/$ID

STATUS=$(curl -s -X GET -o body -w "%{http_code}" $RESOURCE)
if [ $STATUS == "200" ]; then
    grep -q $ANSWER body
    if [ $? -eq 0 ]; then
        echo "Test [15]: OK"; SCORE=$(expr $SCORE + 1)
    else
        echo "Test [15]: FAIL"
    fi
else
    echo "Test [15]: FAIL (" $STATUS "!= 200 )"
fi

###############################################################
## Test [16]: Read B3 with integer calculation               ##
###############################################################
ID="B3"
ANSWER="\"formula\":\"7\""
RESOURCE=$HOST/cells/$ID

STATUS=$(curl -s -X GET -o body -w "%{http_code}" $RESOURCE)
if [ $STATUS == "200" ]; then
    grep -q $ANSWER body
    if [ $? -eq 0 ]; then
        echo "Test [16]: OK"; SCORE=$(expr $SCORE + 1)
    else
        echo "Test [16]: FAIL"
    fi
else
    echo "Test [16]: FAIL (" $STATUS "!= 200 )"
fi

###############################################################
## Test [17]: Read B3 with a single integer                  ##
###############################################################
ID="B2"
ANSWER="\"formula\":\"6\""
RESOURCE=$HOST/cells/$ID

STATUS=$(curl -s -X GET -o body -w "%{http_code}" $RESOURCE)
if [ $STATUS == "200" ]; then
    grep -q $ANSWER body
    if [ $? -eq 0 ]; then
        echo "Test [17]: OK"; SCORE=$(expr $SCORE + 1)
    else
        echo "Test [17]: FAIL"
    fi
else
    echo "Test [17]: FAIL (" $STATUS "!= 200 )"
fi

###############################################################
## Test [18]: Create P2 which have empty formula             ##
###############################################################
ID="P2"; FORMULA=""
RESOURCE=$HOST/cells/$ID

STATUS=$(curl -s -X PUT -d "{\"id\":\"$ID\",\"formula\":\"$FORMULA\"}" \
    -H "Content-Type: application/json" -w "%{http_code}" $RESOURCE)
if [ $STATUS == "201" ]; then
    echo "Test [18]: OK"; SCORE=$(expr $SCORE + 1)
else
    echo "Test [18]: FAIL (" $STATUS "!= 201 )"
fi


###############################################################
## Test [20]: Create AB19 which is complex float calculation ##
###############################################################
ID="AB19"; FORMULA="B2 - B3 + D4 / B5"
RESOURCE=$HOST/cells/$ID

STATUS=$(curl -s -X PUT -d "{\"id\":\"$ID\",\"formula\":\"$FORMULA\"}" \
    -H "Content-Type: application/json" -w "%{http_code}" $RESOURCE)
if [ $STATUS == "201" ]; then
    echo "Test [20]: OK"; SCORE=$(expr $SCORE + 1)
else
    echo "Test [20]: FAIL (" $STATUS "!= 201 )"
fi

###############################################################
## Test [21]: Read AB19 which is complex float calculation   ##
###############################################################
ID="AB19"
ANSWER="\"formula\":\"-1.1428571428571428\""
RESOURCE=$HOST/cells/$ID

STATUS=$(curl -s -X GET -o body -w "%{http_code}" $RESOURCE)
if [ $STATUS == "200" ]; then
    grep -q $ANSWER body
    if [ $? -eq 0 ]; then
        echo "Test [21]: OK"; SCORE=$(expr $SCORE + 1)
    else
        echo "Test [21]: FAIL"
    fi
else
    echo "Test [21]: FAIL (" $STATUS "!= 200 )"
fi

###############################################################
## Test [22]: Delete AB19                                    ##
###############################################################
ID="AB19";
RESOURCE=$HOST/cells/$ID

STATUS=$(curl -s -X DELETE -o body -w "%{http_code}" $RESOURCE)
if [ $STATUS == "204" ]; then
    echo "Test [22]: OK"; SCORE=$(expr $SCORE + 1)
else
    echo "Test [22]: FAIL (" $STATUS "!= 204 )"
fi

###############################################################
## Test [23]: Read P2 which have empty formula               ##
###############################################################
ID="P2"
ANSWER="\"formula\":\"0\""
RESOURCE=$HOST/cells/$ID

STATUS=$(curl -s -X GET -o body -w "%{http_code}" $RESOURCE)
if [ $STATUS == "200" ]; then
    grep -q $ANSWER body
    if [ $? -eq 0 ]; then
        echo "Test [23]: OK"; SCORE=$(expr $SCORE + 1)
    else
        echo "Test [23]: FAIL"
    fi
else
    echo "Test [23]: FAIL (" $STATUS "!= 200 )"
fi

###############################################################
## Test [24]: Delete D99                                     ##
###############################################################
ID="D99";
RESOURCE=$HOST/cells/$ID

STATUS=$(curl -s -X DELETE -o body -w "%{http_code}" $RESOURCE)
if [ $STATUS == "404" ]; then
    echo "Test [24]: OK"; SCORE=$(expr $SCORE + 1)
else
    echo "Test [24]: FAIL (" $STATUS "!= 404 )"
fi

###############################################################
## Test [25]: Update D24 with cells calculation               ##
###############################################################
ID="D24"; FORMULA="B2*B3"
RESOURCE=$HOST/cells/$ID

STATUS=$(curl -s -X PUT -d "{\"id\":\"$ID\",\"formula\":\"$FORMULA\"}" \
    -H "Content-Type: application/json" -w "%{http_code}" $RESOURCE)
if [ $STATUS == "201" ]; then
    echo "Test [25]: OK"; SCORE=$(expr $SCORE + 1)
else
    echo "Test [25]: FAIL (" $STATUS "!= 201 )"
fi


###############################################################
## Test [26]: Read cells calculation from D24                ##
###############################################################
ID="D24"
ANSWER="\"formula\":\"42\""
RESOURCE=$HOST/cells/$ID

STATUS=$(curl -s -X GET -o body -w "%{http_code}" $RESOURCE)
if [ $STATUS == "200" ]; then
    grep -q $ANSWER body
    if [ $? -eq 0 ]; then
        echo "Test [26]: OK"; SCORE=$(expr $SCORE + 1)
    else
        echo "Test [26]: FAIL"
    fi
else
    echo "Test [26]: FAIL (" $STATUS "!= 200 )"
fi

###############################################################
## Test [27]: Update D24 with empty formula calculation      ##
###############################################################
ID="D24"; FORMULA="B2 * B3 + 12 + P2"
RESOURCE=$HOST/cells/$ID

STATUS=$(curl -s -X PUT -d "{\"id\":\"$ID\",\"formula\":\"$FORMULA\"}" \
    -H "Content-Type: application/json" -w "%{http_code}" $RESOURCE)
if [ $STATUS == "204" ]; then
    echo "Test [27]: OK"; SCORE=$(expr $SCORE + 1)
else
    echo "Test [27]: FAIL (" $STATUS "!= 204 )"
fi

###############################################################
## Test [28]: Read cells calculation from D24                ##
###############################################################
ID="D24"
ANSWER="\"formula\":\"54\""
RESOURCE=$HOST/cells/$ID

STATUS=$(curl -s -X GET -o body -w "%{http_code}" $RESOURCE)
if [ $STATUS == "200" ]; then
    grep -q $ANSWER body
    if [ $? -eq 0 ]; then
        echo "Test [28]: OK"; SCORE=$(expr $SCORE + 1)
    else
        echo "Test [28]: FAIL"
    fi
else
    echo "Test [28]: FAIL (" $STATUS "!= 200 )"
fi

###############################################################
## Test [29]: Delete D24                                     ##
###############################################################
ID="D24";
RESOURCE=$HOST/cells/$ID

STATUS=$(curl -s -X DELETE -o body -w "%{http_code}" $RESOURCE)
if [ $STATUS == "204" ]; then
    echo "Test [29]: OK"; SCORE=$(expr $SCORE + 1)
else
    echo "Test [29]: FAIL (" $STATUS "!= 204 )"
fi

###############################################################
## Test [30]: Delete D24                                     ##
###############################################################
ID="P2";
RESOURCE=$HOST/cells/$ID

STATUS=$(curl -s -X DELETE -o body -w "%{http_code}" $RESOURCE)
if [ $STATUS == "204" ]; then
    echo "Test [30]: OK"; SCORE=$(expr $SCORE + 1)
else
    echo "Test [30]: FAIL (" $STATUS "!= 204 )"
fi

###############################################################
## Test [31]: Delete D2                                      ##
###############################################################
ID="B2";
RESOURCE=$HOST/cells/$ID

STATUS=$(curl -s -X DELETE -o body -w "%{http_code}" $RESOURCE)
if [ $STATUS == "204" ]; then
    echo "Test [31]: OK"; SCORE=$(expr $SCORE + 1)
else
    echo "Test [31]: FAIL (" $STATUS "!= 204 )"
fi

###############################################################
## Test [32]: Read D4 which reference not exist cell         ##
###############################################################
ID="D4"
ANSWER="\"formula\":\"0\""
RESOURCE=$HOST/cells/$ID

STATUS=$(curl -s -X GET -o body -w "%{http_code}" $RESOURCE)
if [ $STATUS == "200" ]; then
    grep -q $ANSWER body
    if [ $? -eq 0 ]; then
        echo "Test [32]: OK"; SCORE=$(expr $SCORE + 1)
    else
        echo "Test [32]: FAIL"
    fi
else
    echo "Test [32]: FAIL (" $STATUS "!= 200 )"
fi

###############################################################
## Test [33]: Delete B5                                      ##
###############################################################
ID="B5";
RESOURCE=$HOST/cells/$ID

STATUS=$(curl -s -X DELETE -o body -w "%{http_code}" $RESOURCE)
if [ $STATUS == "204" ]; then
    echo "Test [33]: OK"; SCORE=$(expr $SCORE + 1)
else
    echo "Test [33]: FAIL (" $STATUS "!= 204 )"
fi

###############################################################
## Test [34]: Delete B3                                      ##
###############################################################
ID="B3";
RESOURCE=$HOST/cells/$ID

STATUS=$(curl -s -X DELETE -o body -w "%{http_code}" $RESOURCE)
if [ $STATUS == "204" ]; then
    echo "Test [34]: OK"; SCORE=$(expr $SCORE + 1)
else
    echo "Test [34]: FAIL (" $STATUS "!= 204 )"
fi

###############################################################
## Test [35]: Delete B3 which have been deleted              ##
###############################################################
ID="B3";
RESOURCE=$HOST/cells/$ID

STATUS=$(curl -s -X DELETE -o body -w "%{http_code}" $RESOURCE)
if [ $STATUS == "404" ]; then
    echo "Test [35]: OK"; SCORE=$(expr $SCORE + 1)
else
    echo "Test [35]: FAIL (" $STATUS "!= 404 )"
fi

###############################################################
## Test [36]: Delete B4                                      ##
###############################################################
ID="D4";
RESOURCE=$HOST/cells/$ID

STATUS=$(curl -s -X DELETE -o body -w "%{http_code}" $RESOURCE)
if [ $STATUS == "204" ]; then
    echo "Test [36]: OK"; SCORE=$(expr $SCORE + 1)
else
    echo "Test [36]: FAIL (" $STATUS "!= 204 )"
fi


###############################################################
## Test [37]: List for empty database                        ##
###############################################################
RESOURCE=$HOST/cells
ANSWER="\[\]"

STATUS=$(curl -s -X GET -o body -w "%{http_code}" $RESOURCE)
if [ $STATUS == "200" ]; then
    grep -q $ANSWER body
    if [ $? -eq 0 ]; then
        echo "Test [37]: OK"; SCORE=$(expr $SCORE + 1)
    else
        echo "Test [37]: FAIL"
    fi
else
    echo "Test [37]: FAIL (" $STATUS "!= 200 )"
fi

echo "** Overall score:" $SCORE "/ 37 **"
/*
    Example usage with valid and invalid test cases.

    Released to Public Domain.
    --------------------------------------------------------------------------------------
*/

REQUEST HB_CODEPAGE_UTF8EX

memvar cSchema,cFunName

procedure Main()

    CLS

    hb_cdpSelect("UTF8")
    hb_cdpSelect("UTF8EX")

    #ifdef __ALT_D__    // Compile with -b -D__ALT_D__
        AltD(1)         // Enables the debugger. Press F5 to go.
        AltD()          // Invokes the debugger
    #endif

    Execute()

return

static procedure Execute()

    local aTests as array
    local aColors as array
    local aFunTst as array

    local cJSON as character

    local lValid as logical

    local i as numeric
    local nTest as numeric
    local nTestCount as numeric:=0

    local oJSONValidator as object

    private cSchema as character
    private cFunName as character

    aFunTst:=Array(0)
    aAdd(aFunTst,@getTst01())
    aAdd(aFunTst,@getTst02())
    aAdd(aFunTst,@getTst03())
    aAdd(aFunTst,@getTst04())
    aAdd(aFunTst,@getTst05())
    aAdd(aFunTst,@getTst06())
    aAdd(aFunTst,@getTst07())
    aAdd(aFunTst,@getTst08())

    aColors:=getColors(Len(aFunTst))

    oJSONValidator:=JSONValidator():New("")
    oJSONValidator:SetFastMode(.F.)

    for i:=1 to Len(aFunTst)

        aTests:=hb_execFromArray(aFunTst[i])

        oJSONValidator:SetSchema(cSchema)

        lValid:=(!oJSONValidator:HasError())

        if (lValid)
            SetColor("g+/n")
            QOut("Result: Valid Schema!")
            SetColor("")
        else
            SetColor("r+/n")
            QOut("Result: Invalid JSON Schema. Errors found:")
            SetColor("")
            aEval(oJSONValidator:GetErros(),{|x| QOut("  "+x)})
        endif

        QOut(Replicate("=",80))

        // Run each test case
        for nTest:=1 to Len(aTests)

            nTestCount++

            SetColor(aColors[i])
            QOut("=== Test "+hb_NToC(nTestCount)+" ("+cFunName+"): "+aTests[nTest][1]+" ===")
            SetColor("") /* Reset color to default */

            cJSON:=aTests[nTest][2]
            lValid:=oJSONValidator:Validate(cJSON)

            if (lValid)
                SetColor("g+/n")
                QOut("Result: Valid JSON!")
                SetColor("")
            else
                SetColor("r+/n")
                QOut("Result: Invalid JSON. Errors found:")
                SetColor("")
                aEval(oJSONValidator:GetErros(),{|x| QOut("  "+x)})
            endif

            oJSONValidator:Reset()

            // Verify expected outcome
            if (lValid==aTests[nTest][3])
                SetColor("g+/n")
                QOut("Test passed: Expected "+if(aTests[nTest][3],"valid","invalid")+", got "+if(lValid,"valid","invalid"))
                SetColor("")
            else
                SetColor("r+/n")
                QOut("Test failed: Expected "+if(aTests[nTest][3],"valid","invalid")+", got "+if(lValid,"valid","invalid"))
                SetColor("")
            endif

            QOut("")

        next nTest

    next i

    return

static function getColors(nTests as numeric)

    local aColors as array:=Array(nTests)
    local aColorBase as array:={;
        "N","B","G","BG","R","RB","GR","W",;
        "N*","B*","G*","BG*","R*","RB*","GR*","W*";
    }

    local i as numeric

    // initialise colors
    for i:=1 to nTests
        aColors[i]:="W+/"+aColorBase[(i-1)%16+1]
    next i

    return(aColors)

static function DateDiffYear(dDate1 as date,dDate2 as date)

    local nMonth1 as numeric
    local nMonth2 as numeric
    local nYearDiff as numeric

    nMonth1:=((Year(dDate1)*12)+Month(dDate1))
    nMonth2:=((Year(dDate2)*12)+Month(dDate2))
    nYearDiff:=((nMonth1-nMonth2)-1)
    if (Day(dDate1)>=Day(dDate2))
        ++nYearDiff
    endif
    nYearDiff/=12
    nYearDiff:=Int(nYearDiff)

    return(nYearDiff)

static function getTst01()

    local aTests as array

    cFunName:=ProcName()

    // JSON Schema example
    #pragma __cstream|cSchema:=%s
{
    "type": "object",
    "required": [
        "name",
        "age",
        "tags",
        "salary"
    ],
    "properties": {
        "name": {
            "type": "string",
            "minLength": 3,
            "maxLength": 80,
            "pattern": "^(?=.* )[A-Z]+(?: [A-Z]+)*$"
        },
        "age": {
            "type": "integer",
            "exclusiveMinimum": 0,
            "exclusiveMaximum": 150
        },
        "salary": {
            "type": "number",
            "minimum": 1500.00,
            "maximum": 120000.00,
            "multipleOf": 10
        },
        "address": {
            "type": "object",
            "properties": {
                "city": {
                    "type": "string"
                },
                "zip": {
                    "type": "string",
                    "pattern": "^[0-9]{5}-[0-9]{3}$"
                }
            }
        },
        "tags": {
            "description": "Tags for the product",
            "type": "array",
            "items": {
                "type": "string"
            },
            "minItems": 1,
            "maxItems": 10,
            "contains": {
                "type": "string",
                "pattern": "^product-"
            },
            "minContains": 1,
            "maxContains": 3,
            "uniqueItems": true
        }
    }
}
    #pragma __endtext

    // Array of test cases: {description, JSON data, expected validity}
    aTests:={;
        {;//1
             "=> Valid case: All fields are correct";
            ,'{"name": "JOHN B","age": 30,"salary": 15000,"tags": ["product-123"],"address": {"city": "New York","zip": "12345-678"}}';
            ,.T.;
        };
        ,{;//2
             "=> Invalid case: Missing required fields: 'name' and 'salary'";
            ,'{"age": 25,"tags": ["test"]}';
            ,.F.;
        };
        ,{;//3
             "=> Invalid case: Incorrect type for 'age'";
            ,'{"name": "ALICE K","age": "thirty","salary": 1501.054,"tags": ["demo"]}';
            ,.F.;
        };
        ,{;//4
             "=> Invalid case: Incorrect item type in 'tags'";
            ,'{"name": "BOB D","age": 40,"salary": 15000,"tags": ["tag1",123]}';
            ,.F.;
        };
        ,{;//5
             "=> Invalid case: 'tags' contains fewer items than the minimum required";
            ,'{"name": "EVE T","age": 22,"salary": 15000,"tags": []}';
            ,.F.;
        };
        ,{;//6
             "=> Invalid case: 'tags' contains more items than the maximum allowed";
            ,'{"name": "FRANK M","age": 35,"salary": 15000,"tags": ["product-000","product-001","product-002","product-003","product-004","product-005","product-006","product-007","product-008","product-009","product-010"]}';
            ,.F.;
        };
        ,{;//7
             "=> Invalid case: 'zip' does not match the required pattern";
            ,'{"name": "GRACE K","age": 28,"salary": 15000,"tags": ["valid"],"address": {"city": "LA","zip": "1234-567"}}';
            ,.F.;
        };
        ,{;//8
             "=> Valid case: Minimal valid data";
            ,'{"name": "HANK D","age": 50,"salary": 15000,"tags": ["product-123"]}';
            ,.T.;
        };
        ,{;//9
             "=> Invalid case: 'address' has an incorrect type";
            ,'{"name": "IVY P","age": 33,"salary": 15000,"tags": ["test"],"address": "not an object"}';
            ,.F.;
        };
        ,{;//10
             "=> Valid case: At least one tag satisfies the 'contains' condition";
            ,'{"name": "JOHN W","age": 30,"salary": 15000,"tags": ["product-123","other"]}';
            ,.T.;
        };
        ,{;//11
             "=> Invalid case: No tag satisfies the 'contains' condition";
            ,'{"name": "ALICE S","age": 25,"salary": 15000,"tags": ["other","another"]}';
            ,.F.;
        };
        ,{;//12
             "=> Invalid case: Too many tags satisfy the 'contains' condition";
            ,'{"name": "BOB B","age": 40,"salary": 15000,"tags": ["product-1","product-2","product-3","product-4"]}';
            ,.F.;
        };
        ,{;//13
             "=> Valid case: Exactly two tags satisfy the 'contains' condition";
            ,'{"name": "EVE Z","age": 22,"salary": 15000,"tags": ["product-a","product-b","other"]}';
            ,.T.;
        };
        ,{;//14
             "=> Valid case: Unique tags";
            ,'{"name": "JOHN J","age": 30,"salary": 15000,"tags": ["product-123","other"]}';
            ,.T.;
        };
        ,{;//15
             "=> Invalid case: Duplicate tags found";
            ,'{"name": "ALICE A","age": 25,"salary": 15000,"tags": ["product-123","product-132","product-123","product-132","product-123"]}';
            ,.F.;
        };
        ,{;//16
             "=> Invalid case: 'salary' is below the minimum allowed";
            ,'{"name": "EVE K","age": 0,"salary": 0,"tags": ["product-000","product-001","product-002"]}';
            ,.F.;
        };
        ,{;//17
             "=> Invalid case: 'salary' is above the maximum allowed";
            ,'{"name": "FRANK T","age": 155,"salary": 999999,"tags": ["product-000","product-001","product-002"]}';
            ,.F.;
        };
        ,{;//18
             "=> Invalid case: 'name' exceeds the maximum length";
            ,'{"name": "PEDRO DE ALCÂNTARA JOÃO CARLOS LEOPOLDO SALVADOR BIBIANO FRANCISCO XAVIER DE PAULA LEOCÁDIO MIGUEL GABRIEL RAFAEL GONZAGA","age": '+hb_NToC(DateDiffYear(Date(),SToD("18251202")))+',"salary": 999999,"tags": ["product-000","product-001","product-002"]}';
            ,.F.;
        };
    }

    return(aTests)

static function getTst02()

    local aTests as array

    cFunName:=ProcName()

    // JSON Schema Enum example
    #pragma __cstream|cSchema:=%s
{
    "type": "object",
    "required": ["fruit","number","option","status"],
    "properties": {
        "fruit": {
            "type": "string",
            "enum": ["apple","banana","cherry"]
        },
        "number": {
            "type": "number",
            "enum": [1,2,3]
        },
        "option": {
            "type": "string",
            "enum": ["yes","no"]
        },
        "status": {
            "type": ["string","null"],
            "enum": [null,"active","inactive"]
        }
    }
}
    #pragma __endtext

    // Array of test cases: Enum
    aTests:={;
         {"Valid case: All fields are valid",'{"fruit": "banana","number": 2,"option": "yes","status": "active"}',.T.};
        ,{"Invalid case: 'fruit' value is not allowed",'{"fruit": "orange","number": 2,"option": "yes","status": "active"}',.F.};
        ,{"Invalid case: 'number' value is not allowed",'{"fruit": "banana","number": 4,"option": "yes","status": "active"}',.F.};
        ,{"Invalid case: 'option' value is not allowed",'{"fruit": "banana","number": 3,"option": "maybe","status": "active"}',.F.};
        ,{"Valid case: All fields are valid",'{"fruit": "banana","number": 2,"option": "yes","status": null}',.T.};
        ,{"Invalid case: All fields are invalid",'{"fruit": "watermelon","number": 9,"option": "no","status": "pending"}',.F.};
    }

    return(aTests)

static function getTst03()

    local aTests as array

    cFunName:=ProcName()

    // JSON Schema prefixItems example
    #pragma __cstream|cSchema:=%s
{
  "type": "array",
  "prefixItems": [
    { "type": "number" },
    { "type": "string" },
    { "enum": ["Street","Avenue","Boulevard"] },
    { "enum": ["NW","NE","SW","SE"] }
  ]
}
    #pragma __endtext

    // Array of test cases: prefixItems without extra items
    aTests:={;
         {"Valid case: All items are valid",'[1600,"Pennsylvania","Avenue","NW"]',.T.};
        ,{"Invalid case: 'Drive' is not an acceptable street type",'[24,"Sussex","Drive"]',.F.};
        ,{"Invalid case: Missing street number in address",'["Palais de l`Élysée"]',.F.};
        ,{"Valid case: Omitting some items is acceptable",'[10,"Downing","Street"]',.T.};
        ,{"Valid case: Additional items at the end are acceptable by default",'[1600,"Pennsylvania","Avenue","NW","Washington"]',.T.};
    }

    return(aTests)

static function getTst04()

    local aTests as array

    cFunName:=ProcName()

    // JSON Schema prefixItems example with "items": false
    #pragma __cstream|cSchema:=%s
{
  "type": "array",
  "prefixItems": [
    { "type": "number" },
    { "type": "string" },
    { "enum": ["Street","Avenue","Boulevard"] },
    { "enum": ["NW","NE","SW","SE"] }
  ],
  "items": false
}
    #pragma __endtext

    // Array of test cases: prefixItems with items: false
    aTests:={;
         {"Valid case: All items are valid",'[1600,"Pennsylvania","Avenue","NW"]',.T.};
        ,{"Invalid case: 'Drive' is not an acceptable street type",'[24,"Sussex","Drive"]',.F.};
        ,{"Invalid case: Missing street number in address",'["Palais de l`Élysée"]',.F.};
        ,{"Valid case: Omitting some items is acceptable",'[10,"Downing","Street"]',.T.};
        ,{"Invalid case: Additional items at the end are not allowed",'[1600,"Pennsylvania","Avenue","NW","Washington"]',.F.};
    }

    return(aTests)

static function getTst05()

    local aTests as array

    cFunName:=ProcName()

    // JSON Schema prefixItems example with "items" as an object
    #pragma __cstream|cSchema:=%s
{
  "type": "array",
  "prefixItems": [
    { "type": "number" },
    { "type": "string" },
    { "enum": ["Street","Avenue","Boulevard"] },
    { "enum": ["NW","NE","SW","SE"] }
  ],
  "items": { "type": "string" }
}
    #pragma __endtext

    // Array of test cases: prefixItems with items as an object
    aTests:={;
         {"Valid case: All items are valid",'[1600,"Pennsylvania","Avenue","NW"]',.T.};
        ,{"Invalid case: 'Drive' is not an acceptable street type",'[24,"Sussex","Drive"]',.F.};
        ,{"Invalid case: Missing street number in address",'["Palais de l`Élysée"]',.F.};
        ,{"Valid case: Omitting some items is acceptable",'[10,"Downing","Street"]',.T.};
        ,{"Valid case: Additional items at the end are acceptable",'[1600,"Pennsylvania","Avenue","NW","Washington"]',.T.};
        ,{"Invalid case: Additional items at the end are not allowed",'[1600,"Pennsylvania","Avenue","NW","Washington",10]',.F.};
    }

    return(aTests)

static function getTst06()

    local aTests as array

    cFunName:=ProcName()

    // JSON Schema string
    #pragma __cstream|cSchema:=%s
{
  "type": "string"
}
    #pragma __endtext

    // Array of test cases: string
    aTests:={;
         {"Valid case: String is valid",'"Street"',.T.};
        ,{"Invalid case: Number is not a valid string",'24',.F.};
    }

    return(aTests)

static function getTst07()

    local aTests as array

    cFunName:=ProcName()

    // JSON Schema string example with "enum"
    #pragma __cstream|cSchema:=%s
{
  "type": "string",
  "enum": ["Street","Avenue","Boulevard"]
}
    #pragma __endtext

    // Array of test cases: enum
    aTests:={;
         {"Valid case: 'Street' is allowed",'"Street"',.T.};
        ,{"Valid case: 'Avenue' is allowed",'"Avenue"',.T.};
        ,{"Valid case: 'Boulevard' is allowed",'"Boulevard"',.T.};
        ,{"Invalid case: Value is not allowed",'"Hello World"',.F.};
    }

    return(aTests)

static function getTst08()

    local aTests as array

    cFunName:=ProcName()

    // JSON Schema string example with "pattern"
    #pragma __cstream|cSchema:=%s
{
  "type": "string",
  "pattern": "^(?:Yes|No)$"
}
    #pragma __endtext

    // Array of test cases: pattern
    aTests:={;
         {"Valid case: 'Yes' is allowed",'"Yes"',.T.};
        ,{"Valid case: 'No' is allowed",'"No"',.T.};
        ,{"Invalid case: Value does not match the required pattern",'"Mabe"',.F.};
    }

    return(aTests)

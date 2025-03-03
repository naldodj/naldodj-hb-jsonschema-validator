/*
    Example usage with valid and invalid test cases.

    Released to Public Domain.
    --------------------------------------------------------------------------------------
*/

REQUEST HB_CODEPAGE_UTF8EX

procedure Main()

    local aTests as array

    local cJSON as character
    local cSchema as character

    local lValid as logical

    local nTest as numeric
    local nTestCount as numeric:=0

    local oJSONValidator as object

    CLS

    hb_cdpSelect("UTF8")
    hb_cdpSelect("UTF8EX")

    #ifdef __ALT_D__    // Compile with -b -D__ALT_D__
        AltD(1)         // Enables the debugger. Press F5 to go.
        AltD()          // Invokes the debugger
    #endif

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
             "=> Valid case: all fields correct";
            ,'{"name": "JOHN B","age": 30,"salary": 15000,"tags": ["product-123"],"address": {"city": "New York","zip": "12345-678"}}';
            ,.T.;
        };
        ,{;//2
             "=> Invalid case: missing required 'name' and 'salary'";
            ,'{"age": 25,"tags": ["test"]}';
            ,.F.;
        };
        ,{;//3
             "=> Invalid case: wrong type for 'age'";
            ,'{"name": "ALICE K","age": "thirty","salary": 1501.054,"tags": ["demo"]}';
            ,.F.;
        };
        ,{;//4
             "=> Invalid case: 'tags' with wrong item type";
            ,'{"name": "BOB D","age": 40,"salary": 15000,"tags": ["tag1",123]}';
            ,.F.;
        };
        ,{;//5
             "=> Invalid case: 'tags' below minItems";
            ,'{"name": "EVE T","age": 22,"salary": 15000,"tags": []}';
            ,.F.;
        };
        ,{;//6
             "=> Invalid case: 'tags' above maxItems";
            ,'{"name": "FRANK M","age": 35,"salary": 15000,"tags": ["product-000","product-001","product-002","product-003","product-004","product-005","product-006","product-007","product-008","product-009","product-010"]}';
            ,.F.;
        };
        ,{;//7
             "=> Invalid case: invalid 'zip' pattern";
            ,'{"name": "GRACE K","age": 28,"salary": 15000,"tags": ["valid"],"address": {"city": "LA","zip": "1234-567"}}';
            ,.F.;
        };
        ,{;//8
             "=> Valid case: minimal valid data";
            ,'{"name": "HANK D","age": 50,"salary": 15000,"tags": ["product-123"]}';
            ,.T.;
        };
        ,{;//9
             "=> Invalid case: 'address' with wrong type";
            ,'{"name": "IVY P","age": 33,"salary": 15000,"tags": ["test"],"address": "not an object"}';
            ,.F.;
        };
        ,{;//10
             "=> Valid case: at least one tag satisfies 'contains'";
            ,'{"name": "JOHN W","age": 30,"salary": 15000,"tags": ["product-123", "other"]}';
            ,.T.;
        };
        ,{;//11
             "=> Invalid case: no tags satisfy 'contains'";
            ,'{"name": "ALICE S","age": 25,"salary": 15000,"tags": ["other", "another"]}';
            ,.F.;
        };
        ,{;//12
             "=> Invalid case: too many tags satisfy 'contains'";
            ,'{"name": "BOB B","age": 40,"salary": 15000,"tags": ["product-1", "product-2", "product-3", "product-4"]}';
            ,.F.;
        };
        ,{;//13
             "=> Valid case: exactly 2 tags satisfy 'contains'";
            ,'{"name": "EVE Z","age": 22,"salary": 15000,"tags": ["product-a", "product-b", "other"]}';
            ,.T.;
        };
        ,{;//14
             "=> Valid case: unique tags";
            ,'{"name": "JOHN J","age": 30,"salary": 15000,"tags": ["product-123", "other"]}';
            ,.T.;
        };
        ,{;//15
             "=> Invalid case: duplicate tags";
            ,'{"name": "ALICE A","age": 25,"salary": 15000,"tags": ["product-123", "product-132","product-123","product-132","product-123"]}';
            ,.F.;
        };
        ,{;//16
             "=> Invalid case: 'salary' below minimum";
            ,'{"name": "EVE K","age": 0,"salary": 0,"tags": ["product-000","product-001","product-002"]}';
            ,.F.;
        };
        ,{;//17
             "=> Invalid case: 'salary' above maximum";
            ,'{"name": "FRANK T","age": 155,"salary": 999999,"tags": ["product-000","product-001","product-002"]}';
            ,.F.;
        };
        ,{;//18
             "=> Invalid case: 'name'";
            ,'{"name": "PEDRO DE ALCÂNTARA JOÃO CARLOS LEOPOLDO SALVADOR BIBIANO FRANCISCO XAVIER DE PAULA LEOCÁDIO MIGUEL GABRIEL RAFAEL GONZAGA","age": 155,"salary": 999999,"tags": ["product-000","product-001","product-002"]}';
            ,.F.;
        };
    }

    oJSONValidator:=JSONValidator():New(cSchema)
    oJSONValidator:lFastMode:=.F.
    lValid:=(!oJSONValidator:lHasError)

    if (lValid)
        SetColor("g+/n")
        QOut("Result: Valid Schema!")
        SetColor("")
    else
        SetColor("r+/n")
        QOut("Result: Invalid JSON Schema. Errors found:")
        SetColor("")
        aEval(oJSONValidator:aErrors,{|x| QOut("  "+x)})
    endif

    QOut(Replicate("=",80))

    // Run each test case
    for nTest:=1 to Len(aTests)

        nTestCount++

        SetColor("BR/W+")
        QOut("=== Test "+hb_NToC(nTestCount)+": "+aTests[nTest][1]+" ===")
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
            aEval(oJSONValidator:aErrors,{|x| QOut("  "+x)})
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

    // JSON Schema Enum example
    #pragma __cstream|cSchema:=%s
{
    "type": "object",
    "required": ["fruta", "numero", "opcao", "status"],
    "properties": {
        "fruta": {
            "type": "string",
            "enum": ["maçã", "banana", "cereja"]
        },
        "numero": {
            "type": "number",
            "enum": [1, 2, 3]
        },
        "opcao": {
            "type": "string",
            "enum": ["sim", "não"]
        },
        "status": {
            "type": ["string", "null"],
            "enum": [null, "ativo", "inativo"]
        }
    }
}
    #pragma __endtext

    // Array of test cases: Enum
    aTests:={;
         {"Todos válidos",'{"fruta": "banana", "numero": 2, "opcao": "sim", "status": "ativo"}',.T.};
        ,{"Fruta inválida",'{"fruta": "laranja", "numero": 2, "opcao": "sim", "status": "ativo"}',.F.};
        ,{"Número inválido",'{"fruta": "banana", "numero": 4, "opcao": "sim", "status": "ativo"}',.F.};
        ,{"Opção inválida",'{"fruta": "banana", "numero": 3, "opcao": "tim", "status": "ativo"}',.F.};
        ,{"Todos válidos",'{"fruta": "banana", "numero": 2, "opcao": "sim", "status": null}',.T.};
        ,{"Todos Inválidos",'{"fruta": "melância", "numero": 9, "opcao": "nao", "status": "em espera"}',.F.};
    }

    oJSONValidator:Reset(cSchema)

    lValid:=(!oJSONValidator:lHasError)
    oJSONValidator:lFastMode:=.F.

    if (lValid)
        SetColor("g+/n")
        QOut("Result: Valid Schema!")
        SetColor("")
    else
        SetColor("r+/n")
        QOut("Result: Invalid JSON Schema. Errors found:")
        SetColor("")
        aEval(oJSONValidator:aErrors,{|x| QOut("  "+x)})
    endif

    QOut(Replicate("=",80))

    // Run each test case
    for nTest:=1 to Len(aTests)

        nTestCount++

        SetColor("W+/BR")
        QOut("=== Test "+hb_NToC(nTestCount)+": "+aTests[nTest][1]+" ===")
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
            aEval(oJSONValidator:aErrors,{|x| QOut("  "+x)})
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

    return

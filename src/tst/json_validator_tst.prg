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
        "tags"
    ],
    "properties": {
        "name": {
            "type": "string"
        },
        "age": {
            "type": "number"
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
             "Test 1 => Valid case: all fields correct";
            ,'{"name": "John","age": 30,"tags": ["product-123"],"address": {"city": "New York","zip": "12345-678"}}';
            ,.T.;
        };
        ,{;//2
             "Test 2 => Invalid case: missing required 'name'";
            ,'{"age": 25,"tags": ["test"]}';
            ,.F.;
        };
        ,{;//3
             "Test 3 => Invalid case: wrong type for 'age'";
            ,'{"name": "Alice","age": "thirty","tags": ["demo"]}';
            ,.F.;
        };
        ,{;//4
             "Test 4 => Invalid case: 'tags' with wrong item type";
            ,'{"name": "Bob","age": 40,"tags": ["tag1",123]}';
            ,.F.;
        };
        ,{;//5
             "Test 5 => Invalid case: 'tags' below minItems";
            ,'{"name": "Eve","age": 22,"tags": []}';
            ,.F.;
        };
        ,{;//6
             "Test 6 => Invalid case: 'tags' above maxItems";
            ,'{"name": "Frank","age": 35,"tags": ["product-000","product-001","product-002","product-003","product-004","product-005","product-006","product-007","product-008","product-009","product-010"]}';
            ,.F.;
        };
        ,{;//7
             "Test 7 => Invalid case: invalid 'zip' pattern";
            ,'{"name": "Grace","age": 28,"tags": ["valid"],"address": {"city": "LA","zip": "1234-567"}}';
            ,.F.;
        };
        ,{;//8
             "Test 8 => Valid case: minimal valid data";
            ,'{"name": "Hank","age": 50,"tags": ["product-123"]}';
            ,.T.;
        };
        ,{;//9
             "Test 9 => Invalid case: 'address' with wrong type";
            ,'{"name": "Ivy","age": 33,"tags": ["test"],"address": "not an object"}';
            ,.F.;
        };
        ,{;//10
             "Test 10 => Valid case: at least one tag satisfies 'contains'";
            ,'{"name": "John","age": 30,"tags": ["product-123", "other"]}';
            ,.T.;
        };
        ,{;//11
             "Test 11 => Invalid case: no tags satisfy 'contains'";
            ,'{"name": "Alice","age": 25,"tags": ["other", "another"]}';
            ,.F.;
        };
        ,{;//12
             "Test 12 => Invalid case: too many tags satisfy 'contains'";
            ,'{"name": "Bob","age": 40,"tags": ["product-1", "product-2", "product-3", "product-4"]}';
            ,.F.;
        };
        ,{;//13
             "Test 13 => Valid case: exactly 2 tags satisfy 'contains'";
            ,'{"name": "Eve","age": 22,"tags": ["product-a", "product-b", "other"]}';
            ,.T.;
        };
        ,{;//14
             "Test 14 => Valid case: unique tags";
            ,'{"name": "John","age": 30,"tags": ["product-123", "other"]}';
            ,.T.;
        };
        ,{;//15
             "Test 15 => Invalid case: duplicate tags";
            ,'{"name": "Alice","age": 25,"tags": ["product-123", "product-132","product-123","product-132","product-123"]}';
            ,.F.;
        };
    }

    oJSONValidator:=JSONValidator():New(cSchema)

    // Run each test case
    for nTest:=1 to Len(aTests)

        SetColor("BR/W+")
        QOut("=== Test "+hb_NToC(nTest)+": "+aTests[nTest][1]+" ===")
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
         {"Test 16 => Todos válidos",'{"fruta": "banana", "numero": 2, "opcao": "sim", "status": "ativo"}',.T.};
        ,{"Test 17 => Fruta inválida",'{"fruta": "laranja", "numero": 2, "opcao": "sim", "status": "ativo"}',.F.};
        ,{"Test 18 => Número inválido",'{"fruta": "banana", "numero": 4, "opcao": "sim", "status": "ativo"}',.F.};
        ,{"Test 19 => Opção inválida",'{"fruta": "banana", "numero": 3, "opcao": "tim", "status": "ativo"}',.F.};
        ,{"Test 20 => Todos válidos",'{"fruta": "banana", "numero": 2, "opcao": "sim", "status": null}',.T.};
        ,{"Test 21 => Todos Inválidos",'{"fruta": "melância", "numero": 9, "opcao": "nao", "status": "em espera"}',.F.};
    }

    oJSONValidator:Reset(cSchema)

    // Run each test case
    for nTest:=1 to Len(aTests)

        SetColor("W+/BR")
        QOut("=== Test "+hb_NToC(nTest)+": "+aTests[nTest][1]+" ===")
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

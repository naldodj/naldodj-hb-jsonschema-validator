# tests

### JSON Schema
```json
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
            "maxItems": 10
        }
    }
}
```
---
### Valid
```xBase
procedure Main()

    local aTests as array

    local cSchema as character
    local cJSON as character

    local lValid as logical

    local nTest as numeric

    local oJSONValidator as object


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
            "maxItems": 10
        }
    }
}
    #pragma __endtext

    // Array of test cases: {description,JSON data,expected validity}
    aTests:={;
        {;//1
            "Valid case: all fields correct";
            ,'{"name": "John","age": 30,"tags": ["product"],"address": {"city": "New York","zip": "12345-678"}}';
            ,.T.;
        };
        ,{;//2
            "Invalid case: missing required 'name'";
            ,'{"age": 25,"tags": ["test"]}';
            ,.F.;
        };
        ,{;//3
            "Invalid case: wrong type for 'age'";
            ,'{"name": "Alice","age": "thirty","tags": ["demo"]}';
            ,.F.;
        };
        ,{;//4
            "Invalid case: 'tags' with wrong item type";
            ,'{"name": "Bob","age": 40,"tags": ["tag1",123]}';
            ,.F.;
        };
        ,{;//5
            "Invalid case: 'tags' below minItems";
            ,'{"name": "Eve","age": 22,"tags": []}';
            ,.F.;
        };
        ,{;//6
            "Invalid case: 'tags' above maxItems";
            ,'{"name": "Frank","age": 35,"tags": ["a","b","c","d","e","f","g","h","i","j","k"]}';
            ,.F.;
        };
        ,{;//7
            "Invalid case: invalid 'zip' pattern";
            ,'{"name": "Grace","age": 28,"tags": ["valid"],"address": {"city": "LA","zip": "1234-567"}}';
            ,.F.;
        };
        ,{;//8
            "Valid case: minimal valid data";
            ,'{"name": "Hank","age": 50,"tags": ["simple"]}';
            ,.T.;
        };
        ,{;//9
            "Invalid case: 'address' with wrong type";
            ,'{"name": "Ivy","age": 33,"tags": ["test"],"address": "not an object"}';
            ,.F.;
        };
    }

    oJSONValidator:=JSONValidator():New(cSchema)

    // Run each test case
    for nTest:=1 to Len(aTests)

        QOut("=== Test "+hb_NToC(nTest)+": "+aTests[nTest][1]+" ===")
        cJSON:=aTests[nTest][2]

        lValid:=oJSONValidator:Validate(cJSON)

        if (lValid)
            QOut("Result: Valid JSON!")
        else
            QOut("Result: Invalid JSON. Errors found:")
            aEval(oJSONValidator:aErrors,{|x| QOut("  "+x)})
        endif

        oJSONValidator:Reset()

        // Verify expected outcome
        if (lValid==aTests[nTest][3])
            QOut("Test passed: Expected "+if(aTests[nTest][3],"valid","invalid")+",got "+if(lValid,"valid","invalid"))
        else
            QOut("Test failed: Expected "+if(aTests[nTest][3],"valid","invalid")+",got "+if(lValid,"valid","invalid"))
        endif

        QOut("")

    next nTest

    return
```
### Result
```
=== Test 1: Valid case: all fields correct ===
Result: Valid JSON!
Test passed: Expected valid,got valid

=== Test 2: Invalid case: missing required 'name' ===
Result: Invalid JSON. Errors found:
Required property missing at root.name
Test passed: Expected invalid,got invalid

=== Test 3: Invalid case: wrong type for 'age' ===
Result: Invalid JSON. Errors found:
Type mismatch at root.age. Expected: number,Found: string
Test passed: Expected invalid,got invalid

=== Test 4: Invalid case: 'tags' with wrong item type ===
Result: Invalid JSON. Errors found:
Type mismatch at root.tags.item(2). Expected: string,Found: number
Test passed: Expected invalid,got invalid

=== Test 5: Invalid case: 'tags' below minItems ===
Result: Invalid JSON. Errors found:
Array at root.tags has too few items. Found: 0,Minimum: 1
Test passed: Expected invalid,got invalid

=== Test 6: Invalid case: 'tags' above maxItems ===
Result: Invalid JSON. Errors found:
Array at root.tags has too many items. Found: 11,Maximum: 10
Test passed: Expected invalid,got invalid

=== Test 7: Invalid case: invalid 'zip' pattern ===
Result: Invalid JSON. Errors found:
Pattern mismatch at root.address.zip. Value: '1234-567' does not match pattern: '^[0-9]{5}-[0-9]{3}$'
Test passed: Expected invalid,got invalid

=== Test 8: Valid case: minimal valid data ===
Result: Valid JSON!
Test passed: Expected valid,got valid

=== Test 9: Invalid case: 'address' with wrong type ===
Result: Invalid JSON. Errors found:
Type mismatch at root.address. Expected: object,Found: string
Type mismatch at root.address. Expected: object,Found: string
Test passed: Expected invalid,got invalid
```

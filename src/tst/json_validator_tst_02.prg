/*

   _                                      _  _      _         _                    _         _
  (_) ___   ___   _ __     __   __  __ _ | |(_)  __| |  __ _ | |_   ___   _ __    | |_  ___ | |_
  | |/ __| / _ \ | '_ \    \ \ / / / _` || || | / _` | / _` || __| / _ \ | '__|   | __|/ __|| __|
  | |\__ \| (_) || | | |    \ V / | (_| || || || (_| || (_| || |_ | (_) || |      | |_ \__ \| |_
 _/ ||___/ \___/ |_| |_|     \_/   \__,_||_||_| \__,_| \__,_| \__| \___/ |_|       \__||___/ \__|
|__/

    Example usage with valid and invalid test cases.

    Released to Public Domain.
    --------------------------------------------------------------------------------------
*/
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

/*

   _                                _                                            _  _      _         _                 _         _
  (_) ___   ___   _ __   ___   ___ | |__    ___  _ __ ___    __ _ __   __  __ _ | |(_)  __| |  __ _ | |_   ___   _ __ | |_  ___ | |_
  | |/ __| / _ \ | '_ \ / __| / __|| '_ \  / _ \| '_ ` _ \  / _` |\ \ / / / _` || || | / _` | / _` || __| / _ \ | '__|| __|/ __|| __|
  | |\__ \| (_) || | | |\__ \| (__ | | | ||  __/| | | | | || (_| | \ V / | (_| || || || (_| || (_| || |_ | (_) || |   | |_ \__ \| |_
 _/ ||___/ \___/ |_| |_||___/ \___||_| |_| \___||_| |_| |_| \__,_|  \_/   \__,_||_||_| \__,_| \__,_| \__| \___/ |_|    \__||___/ \__|
|__/

    Example usage with valid and invalid test cases.

    Released to Public Domain.
    --------------------------------------------------------------------------------------
*/
static function getTst17(cSchema as character)

    local aTests as array

    // JSON Schema array example with "patternProperties"
    #pragma __cstream|cSchema:=%s
{
    "type": "object",
    "properties": {
        "name" :{
            "type": "string"
        },
        "age" :{
            "type": "integer"
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
            },
            "additionalProperties": {
                "type": "integer"
            }
        }
    }
}
    #pragma __endtext

    // Array of test cases: "patternProperties"
    aTests:={;
        {"Invalid case: Additional Properties is OK",'{"name": "John Doe", "age": 21 ,"address": {"city": "New York","zip": "12345-678","additionalPropertiesValid":0}}',.T.};
       ,{"Invalid case: Additional Properties is Not OK",'{"name": 21, "age": "John Doe","address": {"city": "New York","zip": "12345-678","additionalPropertiesInValid":"0"} }',.F.};
    }

    return(aTests)

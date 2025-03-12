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
static function getTst18(cSchema as character)

    local aTests as array

    // JSON Schema array example with "patternProperties"
    #pragma __cstream|cSchema:=%s
{
    "allOf": [
        {
            "type": "object",
            "properties": {
                "street_address": {
                    "type": "string"
                },
                "city": {
                    "type": "string"
                },
                "state": {
                    "type": "string"
                }
            },
            "required": [
                "street_address",
                "city",
                "state"
            ]
        }
    ],
    "properties": {
        "type": {
            "enum": [
                "residential",
                "business"
            ]
        }
    },
    "required": [
        "type"
    ]
}
    #pragma __endtext

    // Array of test cases: "patternProperties"
    aTests:={;
        {"Valid case: allOf is OK",'{ "street_address": "1600 Pennsylvania Avenue NW", "city": "Washington", "state": "DC", "type": "business" }',.T.};
       ,{"Valid case: allOf is OK",'{ "street_address": "1600 Pennsylvania Avenue NW", "city": "Washington", "state": "DC", "type": "business", "zip": 20500 }',.T.};
       ,{"Invalid case: allOf is Not OK",'{ "street_address": "1600 Pennsylvania Avenue NW", "city": "Washington", "type": "business", "zip": 20500 }',.F.};
    }

    return(aTests)

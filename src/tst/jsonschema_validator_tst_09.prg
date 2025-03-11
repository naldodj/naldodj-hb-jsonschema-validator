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
static function getTst09(cSchema as character)

    local aTests as array

    // JSON Schema array example with "$ref"
    #pragma __cstream|cSchema:=%s
{
    "type": "array",
    "items": { "$ref": "#/$defs/positiveInteger" },
    "$defs": {
        "positiveInteger": {
            "type": "integer",
            "exclusiveMinimum": 0
        }
    }
}
    #pragma __endtext

    // Array of test cases: $ref
    aTests:={;
         {"Valid case: All elements are positive integers",'[1,2,3,4,5,6]',.T.};
        ,{"Invalid case: Contains an element that is not a positive integer",'[1,2,3,4,5,"A"]',.F.};
    }

    return(aTests)

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

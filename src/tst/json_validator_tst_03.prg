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
static function getTst03()

    local aTests as array

    cFunName:=ProcName()

    // JSON Schema prefixItems example
    #pragma __cstream|M->cSchema:=%s
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

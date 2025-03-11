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
static function getTst07(cSchema as character)

    local aTests as array

    // JSON Schema string example with "enum"
    #pragma __cstream|cSchema:=%s
{
  "type": "string",
  "enum": [{"pattern": "^Street"},"Avenue","Boulevard"]
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

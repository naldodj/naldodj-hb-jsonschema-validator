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
static function getTst08()

    local aTests as array

    cFunName:=ProcName()

    // JSON Schema string example with "pattern"
    #pragma __cstream|M->cSchema:=%s
{
  "type": "string",
  "pattern": "^(?:Yes|No)$"
}
    #pragma __endtext

    // Array of test cases: pattern
    aTests:={;
         {"Valid case: 'Yes' is allowed",'"Yes"',.T.};
        ,{"Valid case: 'No' is allowed",'"No"',.T.};
        ,{"Invalid case: Value does not match the required pattern",'"Mabe"',.F.};
    }

    return(aTests)

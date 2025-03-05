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
static function getTst06()

    local aTests as array

    cFunName:=ProcName()

    // JSON Schema string
    #pragma __cstream|cSchema:=%s
{
  "type": "string"
}
    #pragma __endtext

    // Array of test cases: string
    aTests:={;
         {"Valid case: String is valid",'"Street"',.T.};
        ,{"Invalid case: Number is not a valid string",'24',.F.};
    }

    return(aTests)

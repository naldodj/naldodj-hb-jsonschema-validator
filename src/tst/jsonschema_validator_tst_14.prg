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
static function getTst14(cSchema as character)

    local aTests as array

    // JSON Schema array example with "patternProperties"
    #pragma __cstream|cSchema:=%s
{
  "type": "object",
  "patternProperties": {
    "^S_": { "type": "string" },
    "^I_": { "type": "integer" }
  }
}
    #pragma __endtext

    // Array of test cases: "patternProperties"
    aTests:={;
        {"Valid case: If the name starts with S_, it must be a string",'{"S_25": "This is a string"}',.T.};
       ,{"Valid case: If the name starts with I_, it must be a number",'{"I_0": 42}',.T.};
       ,{"Invalid case: If the name starts with S_, it must be a string",'{"S_0": 42 }',.F.};
       ,{"Invalid case: If the name starts with I_, it must be an integer",'{ "I_42": "This is a string" }',.F.};
       ,{"Invalid case: This is a key that doesn't match any of the regular expressions",'{ "keyword": "value" }',.T.};
    }

    return(aTests)

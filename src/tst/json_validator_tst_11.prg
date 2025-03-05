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
static function getTst11()

    local aTests as array

    cFunName:=ProcName()

    // JSON Schema array example with "$ref"
    #pragma __cstream|cSchema:=%s
{
    "title": "Feature list",
    "type": "array",
    "minItems": 2,
    "prefixItems": [
        {
            "title": "Feature A",
            "properties": {
                "enabled": {
                    "$ref": "#/$defs/enabledToggle",
                    "default": true
                }
            }
        },
        {
            "title": "Feature B",
            "properties": {
                "enabled": {
                    "description": "If set to null, Feature B inherits the enabled value from Feature A",
                    "$ref": "#/$defs/enabledToggle"
                }
            }
        }
    ],
    "$defs": {
        "enabledToggle": {
            "title": "Enabled",
            "description": "Whether the feature is enabled (true), disabled (false), or under automatic control (null)",
            "type": [
                "boolean",
                "null"
            ],
            "default": null
        }
    }
}
    #pragma __endtext

    // Array of test cases: $ref
    aTests:={;
        {"Valid case: Meets the schema; 'enabled' is boolean or null.",'[{"enabled": true},{"enabled": null}]',.T.};
       ,{"Valid case: Uses default values (true for Feature A, null for Feature B).",'[{},{}]',.T.};
       ,{"Invalid case: 'enabled' in Feature A is a string, not boolean or null.",'[{"enabled": "true"},{"enabled": null}]',.F.};
       ,{"Invalid case: Array contains only one item; it must have two.",'[{"enabled": true}]',.F.};
       ,{"Invalid case: 'enabled' in Feature B is a number, not boolean or null.",'[{"enabled": true},{"enabled": 5}]',.F.};
    }

    return(aTests)

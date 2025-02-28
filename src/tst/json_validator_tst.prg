/*
    Example usage

    Released to Public Domain.
    --------------------------------------------------------------------------------------
*/
procedure Main()

    local cSchema,cJSON as character

    local lValid as logical

    local oValidator as object

    #ifdef __ALT_D__    // Compile with -b -D__ALT_D__
        AltD(1)         // Enables the debugger. Press F5 to go.
        AltD()          // Invokes the debugger
    #endif

    // JSON Schema example
    #pragma __cstream|cSchema:=%s
{
    "type": "object",
    "required": [
        "name",
        "age"
    ],
    "properties": {
        "name": {
            "type": "string"
        },
        "age": {
            "type": "number"
        },
        "address": {
            "type": "object",
            "properties": {
                "city": {
                    "type": "string"
                },
                "zip": {
                    "type": "number"
                }
            }
        }
    }
}
    #pragma __endtext
    // JSON data to validate
    #pragma __cstream|cJSON:=%s
{
    "name": "John",
    "age": "30",
    "address": {
        "city": "New York",
        "zip": "10001"
    }
}
    #pragma __endtext

    oValidator:=JSONValidator():New(cSchema)
    lValid:=oValidator:Validate(cJSON)

    if (lValid)
        QOut("Valid JSON!")
    else
        QOut("Invalid JSON. Errors found:")
        aEval(oValidator:aErrors,{|x|QOut(x)})
    endif

return

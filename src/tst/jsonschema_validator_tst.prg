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

REQUEST HB_CODEPAGE_UTF8EX

memvar cSchema,cFunName

procedure Main()

    CLS

    hb_cdpSelect("UTF8")
    hb_cdpSelect("UTF8EX")

    #ifdef __ALT_D__    // Compile with -b -D__ALT_D__
        AltD(1)         // Enables the debugger. Press F5 to continue.
        AltD()          // Invokes the debugger
    #endif

    Execute()

return

static procedure Execute()

    local aTests as array
    local aColors as array
    local aFunTst as array

    local cJSON as character

    local lValid as logical

    local i as numeric
    local nTest as numeric
    local nTestCount as numeric:=0

    local oJSONSchemaValidator as object

    private cSchema as character
    private cFunName as character

    aFunTst:=Array(0)
    aAdd(aFunTst,{@getTst01(),"getTst01",.T.})
    aAdd(aFunTst,{@getTst02(),"getTst02",.T.})
    aAdd(aFunTst,{@getTst03(),"getTst03",.T.})
    aAdd(aFunTst,{@getTst04(),"getTst04",.T.})
    aAdd(aFunTst,{@getTst05(),"getTst05",.T.})
    aAdd(aFunTst,{@getTst06(),"getTst06",.T.})
    aAdd(aFunTst,{@getTst07(),"getTst07",.T.})
    aAdd(aFunTst,{@getTst08(),"getTst08",.T.})
    aAdd(aFunTst,{@getTst09(),"getTst09",.T.})
    aAdd(aFunTst,{@getTst10(),"getTst10",.T.})
    aAdd(aFunTst,{@getTst11(),"getTst11",.T.})
    aAdd(aFunTst,{@getTst12(),"getTst12",.T.})
    aAdd(aFunTst,{@getTst13(),"getTst13",.T.})

    aColors:=getColors(Len(aFunTst))

    oJSONSchemaValidator:=JSONSchemaValidator():New("")
    oJSONSchemaValidator:SetFastMode(.F.)

    for i:=1 to Len(aFunTst)

        aTests:=hb_execFromArray(aFunTst[i][1])

        oJSONSchemaValidator:SetSchema(cSchema)

        lValid:=(!oJSONSchemaValidator:HasError())

        if (lValid)
            SetColor("g+/n")
            QOut("Result: Valid Schema!")
            SetColor("")
        else
            SetColor("r+/n")
            QOut("Result: Invalid JSON Schema. Errors found:")
            SetColor("")
                aEval(oJSONSchemaValidator:GetErros(),;
                    {|x as character|
                        QOut("  "+x)
                        return(nil)
                    };
                )
        endif

        QOut(Replicate("=",80))

        // Run each test case
        for nTest:=1 to Len(aTests)

            nTestCount++

            SetColor(aColors[i])
            QOut("=== Test "+hb_NToC(nTestCount)+" ("+cFunName+"): "+aTests[nTest][1]+" ===")
            SetColor("") /* Reset color to default */

            cJSON:=aTests[nTest][2]
            lValid:=oJSONSchemaValidator:Validate(cJSON)

            if (lValid)
                SetColor("g+/n")
                QOut("Result: Valid JSON!")
                SetColor("")
            else
                SetColor("r+/n")
                QOut("Result: Invalid JSON. Errors found:")
                SetColor("")
                aEval(oJSONSchemaValidator:GetErros(),;
                    {|x as character|
                        QOut("  "+x)
                        return(nil)
                    };
                )
            endif

            oJSONSchemaValidator:Reset()

            // Verify expected outcome
            aFunTst[i][3]:=((aFunTst[i][3]).and.(lValid==aTests[nTest][3]))
            if ((lValid==aTests[nTest][3]))
                SetColor("g+/n")
                QOut("Test passed: Expected "+if(aTests[nTest][3],"valid","invalid")+", got "+if(lValid,"valid","invalid"))
                SetColor("")
            else
                SetColor("r+/n")
                QOut("Test failed: Expected "+if(aTests[nTest][3],"valid","invalid")+", got "+if(lValid,"valid","invalid"))
                SetColor("")
            endif

            QOut("")

        next nTest

    next i

    QOut(Replicate("=",80))

    Eval(;
        {|aFunTst as array|
            local lValid as logical
            local i as numeric
            for i:=1 to Len(aFunTst)
                // Verify expected outcome
                lValid:=aFunTst[i][3]
                if (lValid)
                    SetColor("g+/n")
                    QOut("("+aFunTst[i][2]+"): passed")
                    SetColor("")
                else
                    SetColor("r+/n")
                    QOut("("+aFunTst[i][2]+"): failed")
                    SetColor("")
                endif
            next i
            return(nil)
        };
    ,aFunTst)

    return

static function getColors(nTests as numeric)

    local aColors as array:=Array(nTests)
    local aColorBase as array:={"N","B","G","BG","R","RB","GR","W"}

    local i as numeric

    for i:=1 to nTests
        aColors[i]:="W+/"+aColorBase[(i-1)%8+1]
    next i

    return(aColors)

static function DateDiffYear(dDate1 as date, dDate2 as date)

    local nMonth1 as numeric
    local nMonth2 as numeric
    local nYearDiff as numeric

    nMonth1:=((Year(dDate1)*12)+Month(dDate1))
    nMonth2:=((Year(dDate2)*12)+Month(dDate2))
    nYearDiff:=((nMonth1-nMonth2)-1)
    if (Day(dDate1)>=Day(dDate2))
        ++nYearDiff
    endif
    nYearDiff/=12
    nYearDiff:=Int(nYearDiff)

    return(nYearDiff)

#include "./jsonschema_validator_tst_01.prg"
#include "./jsonschema_validator_tst_02.prg"
#include "./jsonschema_validator_tst_03.prg"
#include "./jsonschema_validator_tst_04.prg"
#include "./jsonschema_validator_tst_05.prg"
#include "./jsonschema_validator_tst_06.prg"
#include "./jsonschema_validator_tst_07.prg"
#include "./jsonschema_validator_tst_08.prg"
#include "./jsonschema_validator_tst_09.prg"
#include "./jsonschema_validator_tst_10.prg"
#include "./jsonschema_validator_tst_11.prg"
#include "./jsonschema_validator_tst_12.prg"
#include "./jsonschema_validator_tst_13.prg"

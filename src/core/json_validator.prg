/*

 _      _           _                                   _  _      _         _
| |__  | |__       (_) ___   ___   _ __  __   __  __ _ | |(_)  __| |  __ _ | |_   ___   _ __
| '_ \ | '_ \      | |/ __| / _ \ | '_ \ \ \ / / / _` || || | / _` | / _` || __| / _ \ | '__|
| | | || |_) | _   | |\__ \| (_) || | | | \ V / | (_| || || || (_| || (_| || |_ | (_) || |
|_| |_||_.__/ (_) _/ ||___/ \___/ |_| |_|  \_/   \__,_||_||_| \__,_| \__,_| \__| \___/ |_|
                 |__/

    Released to Public Domain.
    --------------------------------------------------------------------------------------
*/

#include "hbclass.ch"

class JSONValidator

    data aErrors as array

    data cSchema as character

    data hSchema as hash
    data hJSONData as hash

    data lHasError as logical

    method New(cSchema as character) constructor

    method CheckArray(aValue as array,hSchema as hash,cPath as character) as logical
    method CheckEnum(xValue as anytype,aEnum as array,cPath as character) as logical
    method CheckPattern(cValue as character,cPattern as character,cPath as character) as logical
    method CheckRequired(hData as hash,aRequired as array,cPath as character) as logical
    method CheckType(xValue as anytype,xType as anytype,cPath as character) as logical

    method Reset(cSchema as character) as logical

    method SetSchema(cSchema as character) as logical

    method Validate(cJSONData as character) as logical
    method ValidateObject(hData as hash,hSchema as hash,cPath as character) as logical

endclass

method New(cSchema as character) class JSONValidator
    self:aErrors:={}
    self:lHasError:=(!self:SetSchema(cSchema))
    if (self:lHasError)
        aAdd(self:aErrors,"Invalid JSON schema provided")
    endif
    return(self)

method Reset(cSchema as character) class JSONValidator
    hb_default(@cSchema,self:cSchema)
return(self:SetSchema(cSchema))

method SetSchema(cSchema as character) class JSONValidator
    aSize(self:aErrors,0)
    self:cSchema:=cSchema
    self:hSchema:=hb_JSONDecode(self:cSchema)
    self:lHasError:=(ValType(self:hSchema)!="H")
return (!self:lHasError)

method Validate(cJSONData as character) class JSONValidator
    begin sequence
        self:hJSONData:=hb_JSONDecode(cJSONData)
        if (self:hJSONData==NIL)
            aAdd(self:aErrors,"Invalid JSON data provided")
            break
        endif
        self:ValidateObject(self:hJSONData,self:hSchema,"root")
    end sequence
    self:lHasError:=(!Empty(self:aErrors))
    return (!self:lHasError)

method ValidateObject(hData as hash,hSchema as hash,cPath as character) class JSONValidator

    local aRequired as array

    local cType as character
    local cProperty as character

    local hProperties as hash

    local lValid as logical

    local xType as anytype

    hb_Default(@cPath,"root")

    begin sequence
        if (hb_HHasKey(hSchema,"type"))
            xType:=hSchema["type"]
            lValid:=self:CheckType(hData,xType,cPath)
            if (!lValid)
                break
            endif
            if (hb_HHasKey(hSchema,"enum"))
                self:CheckEnum(hData,hSchema["enum"],cPath)
            endif
            if (valType(xType)=="C")
                cType:=xType
                switch Lower(cType)
                    case "array"
                        if (hb_HHasKey(hSchema,"items"))
                            lValid:=self:CheckArray(hData,hSchema,cPath)
                            if (!lValid)
                                break
                            endif
                        endif
                        exit
                    case "string"
                        if (hb_HHasKey(hSchema,"pattern"))
                            lValid:=self:CheckPattern(hData,hSchema["pattern"],cPath)
                            if (!lValid)
                                break
                            endif
                        endif
                        exit
                end switch
            endif
        endif

        if (hb_HHasKey(hSchema,"required"))
            aRequired:=hSchema["required"]
            self:CheckRequired(hData,aRequired,cPath)
        endif

        if (hb_HHasKey(hSchema,"properties") .and.(ValType(hData)=="H"))
            hProperties:=hSchema["properties"]
            for each cProperty in hb_HKeys(hProperties)
                if (hb_HHasKey(hData,cProperty))
                    if (hb_HHasKey(hProperties[cProperty],"type"))
                        xType:=hProperties[cProperty]["type"]
                        self:CheckType(hData[cProperty],xType,cPath+"."+cProperty)
                        if (hb_HHasKey(hProperties[cProperty],"enum"))
                            self:CheckEnum(hData[cProperty],hProperties[cProperty]["enum"],cPath+"."+cProperty)
                        endif
                        if (valtype(xType)=="C")
                            cType:=xType
                            switch Lower(cType)
                                case "array"
                                    if (hb_HHasKey(hProperties[cProperty],"items"))
                                        self:CheckArray(hData[cProperty],hProperties[cProperty],cPath+"."+cProperty)
                                    endif
                                    exit
                                case "string"
                                    if (hb_HHasKey(hProperties[cProperty],"pattern"))
                                        self:CheckPattern(hData[cProperty],hProperties[cProperty]["pattern"],cPath+"."+cProperty)
                                    endif
                                    exit
                                case "object"
                                    self:ValidateObject(hData[cProperty],hProperties[cProperty],cPath+"."+cProperty)
                                    exit
                            end switch
                        endif
                    endif
                endif
            next each //cProperty
        endif
    end sequence

    self:lHasError:=(!Empty(self:aErrors))

    return (!self:lHasError)

method CheckArray(aValue as array,hSchema as hash,cPath as character) class JSONValidator

    local lValid as logical:=.T.
    local nItem as numeric
    local nItems as numeric:=Len(aValue)

    hb_Default(@cPath,"root")

    for nItem:=1 to nItems
        if (!self:ValidateObject(aValue[nItem],hSchema["items"],cPath+".item("+hb_NToC(nItem)+")"))
            lValid:=.F.
        endif
    next

    if (hb_HHasKey(hSchema,"minItems"))
        if (nItems<hSchema["minItems"])
            lValid:=.F.
            aAdd(self:aErrors,"Array at "+cPath+" has too few items. Found: "+hb_NToC(nItems)+", Minimum: "+hb_NToC(hSchema["minItems"]))
        endif
    endif

    if (hb_HHasKey(hSchema,"maxItems"))
        if (nItems>hSchema["maxItems"])
            lValid:=.F.
            aAdd(self:aErrors,"Array at "+cPath+" has too many items. Found: "+hb_NToC(nItems)+", Maximum: "+hb_NToC(hSchema["maxItems"]))
        endif
    endif

    return(lValid)

method CheckEnum(xValue as anytype,aEnum as array,cPath as character) class JSONValidator
    local cValue as character:=hb_JSONEncode(xValue)
    local cEnums as character:=hb_JSONEncode(aEnum)
    local lValid as logical:=(cValue$cEnums)
    if (!lValid)
        aAdd(self:aErrors,"Invalid enum value at "+cPath+". Value: "+cValue+", Allowed values: "+cEnums)
    endif
    return(lValid)

method CheckType(xValue as anytype,xType as anytype,cPath as character) class JSONValidator

    local cType as character
    local cValueType as character:=ValType(xValue)

    local lResult as logical:=.F.

    cType:=ValType(xType)
    if (cType=="C")
        // Tipo único
        cType:=xType
        switch Lower(cType)
            case "string"
                lResult:=(cValueType=="C")
                exit
            case "number"
                lResult:=(cValueType=="N")
                exit
            case "boolean"
                lResult:=(cValueType=="L")
                exit
            case "object"
                lResult:=(cValueType=="H")
                exit
            case "array"
                lResult:=(cValueType=="A")
                exit
            case "null"
                lResult:=(cValueType=="U")
                exit
        end switch
        if (!lResult)
            aAdd(self:aErrors,"Type mismatch at "+cPath+". Expected: "+cType+", Found: "+__HB2JSON(cValueType))
        endif
    elseif (cType=="A")
        // Array de tipos
        cType:=hb_JSONEncode(xType)
        cValueType:=__HB2JSON(cValueType)
        lResult:=(cValueType$cType)
        if (!lResult)
            aAdd(self:aErrors, "Type mismatch at "+cPath+". Expected: one of: "+cType+", Found: "+cValueType)
        endif
    else
        // Tipo inválido para cType
        aAdd(self:aErrors, "Invalid type specification at "+cPath+". Expected string or array of strings, Got "+__HB2JSON(cType))
        lResult:=.F.
    endif

return lResult

method CheckPattern(cValue as character,cPattern as character,cPath as character) class JSONValidator

    local lValid as logical

    hb_Default(@cPath,"root")

    lValid:=__regexMatch(cValue,cPattern)
    if (!lValid)
        aAdd(self:aErrors,"Pattern mismatch at "+cPath+". Value: '"+cValue+"' does not match pattern: '"+cPattern+"'")
    endif

    return(lValid)

method CheckRequired(hData as hash,aRequired as array,cPath as character) class JSONValidator

    local cProperty as character

    local lValid as logical:=.T.

    local nProperty as numeric

    hb_Default(@cPath,"root")

    begin sequence

        if (ValType(hData)!="H")
            aAdd(self:aErrors,"Expected an object at "+cPath+" to check required properties")
            lValid:=.F.
            break
        endif

        for nProperty:=1 to Len(aRequired)
            cProperty:=aRequired[nProperty]
            if (!hb_HHasKey(hData,cProperty))
                aAdd(self:aErrors,"Required property missing at "+cPath+"."+cProperty)
                lValid:=.F.
            endif
        next
    end sequence

    return(lValid)

static function __HB2JSON(cType as character)
    local cResult as character
    switch Upper(cType)
        case "C"
            cResult:="string"
            exit
        case "N"
            cResult:="number"
            exit
        case "L"
            cResult:="boolean"
            exit
        case "H"
            cResult:="object"
            exit
        case "A"
            cResult:="array"
            exit
        case "U"
            cResult:="null"
            exit
        otherwise
            cResult:="unknown"
    end switch

    return(cResult)

static function __regexMatch(cString as character,cPattern as character)

    local aMatch as array

    local lMatch as logical

    local pRegex as pointer:=hb_regexComp(cPattern,.T./* case-sensitive */,.F./* no multiline */)

    aMatch:=hb_regex(pRegex,cString,.T./* case-sensitive */)
    lMatch:=(!Empty(aMatch))

    return(lMatch)

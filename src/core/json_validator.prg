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
    data hSchema as hash
    data hJSONData as hash
    data lHasError as logical

    method New(cSchema as character) constructor
    method SetSchema(cSchema as character) as logical
    method Validate(cJSONData as character) as logical
    method CheckType(xValue as anytype,cType as character,cPath as character) as logical
    method CheckRequired(hData as hash,aRequired as array,cPath as character) as logical
    method ValidateObject(hData as hash,hSchema as hash,cPath as character) as logical

endclass

method New(cSchema as character) class JSONValidator
    self:aErrors:={}
    self:lHasError:=(!self:SetSchema(cSchema))
    if (self:lHasError)
        aAdd(self:aErrors,"Invalid JSON schema")
    endif
return(self)

method SetSchema(cSchema as character) class JSONValidator
    aSize(self:aErrors,0)
    self:hSchema:=hb_JSONDecode(cSchema)
    self:lHasError:=(ValType(self:hSchema)!="H")
return(!self:lHasError)

method Validate(cJSONData as character) class JSONValidator

    begin sequence
        self:hJSONData:=hb_JSONDecode(cJSONData)
        if (self:hJSONData==NIL)
            aAdd(self:aErrors,"Invalid JSON data")
            break
        endif
        self:ValidateObject(self:hJSONData,self:hSchema,"root")
    end sequence

    self:lHasError:=(!Empty(self:aErrors))

return(!self:lHasError)

method ValidateObject(hData as hash,hSchema as hash,cPath as character) class JSONValidator

    local aRequired as array
    local cType as character
    local cProperty as character
    local hProperties as hash
    local lValid as logical

    // Define o valor padrão como "root" se não for fornecido
    hb_Default(@cPath,"root")

    begin sequence

        // Verifica se o schema tem uma definição de tipo
        if (hb_HHasKey(hSchema,"type"))
            cType:=hSchema["type"]
            lValid:=self:CheckType(hData,cType,cPath)
            if (!lValid)
                break
            endif
        endif

        // Verifica propriedades obrigatórias
        if (hb_HHasKey(hSchema,"required"))
            aRequired:=hSchema["required"]
            self:CheckRequired(hData,aRequired,cPath)
        endif

        // Valida propriedades do objeto
        if ((hb_HHasKey(hSchema,"properties")).and.(ValType(hData)=="H"))
            hProperties:=hSchema["properties"]
            for each cProperty in hb_HKeys(hProperties)
                if (hb_HHasKey(hData,cProperty))
                    if (hb_HHasKey(hProperties[cProperty],"type"))
                        self:CheckType(hData[cProperty],hProperties[cProperty]["type"],cPath+"."+cProperty)
                    endif
                    // Validação recursiva para objetos aninhados
                    if (hProperties[cProperty]["type"]=="object")
                        self:ValidateObject(hData[cProperty],hProperties[cProperty],cPath+"."+cProperty)
                    endif
                endif
            next each
        endif
    end sequence

    self:lHasError:=(!Empty(self:aErrors))

return(!self:lHasError)

method CheckType(xValue as anytype,cType as character,cPath as character) class JSONValidator

    local cValueType as character:=ValType(xValue)
    local lResult as logical:=.F.

    switch Lower(cType)
        case "string"
            lResult:=cValueType=="C"
            exit
        case "number"
            lResult:=cValueType=="N"
            exit
        case "boolean"
            lResult:=cValueType=="L"
            exit
        case "object"
            lResult:=cValueType=="H"
            exit
        case "array"
            lResult:=cValueType=="A"
            exit
        case "null"
            lResult:=cValueType=="U"
            exit
    end switch

    if (!lResult)
        aAdd(self:aErrors,"Invalid type for property: "+cPath+". Expected: "+cType+", Assigned: "+__HB2JSON(cValueType))
    endif

return(lResult)

method CheckRequired(hData as hash,aRequired as array,cPath as character) class JSONValidator

    local cProperty as character
    local lValid as logical
    local nProperty as numeric

    begin sequence
        lValid:=(ValType(hData)=="H")
        if (!lValid)
            aAdd(self:aErrors,"Data at "+cPath+" must be an object to check required properties")
            break
        endif

        for nProperty:=1 to Len(aRequired)
            cProperty:=aRequired[nProperty]
            if (!hb_HHasKey(hData,cProperty))
                aAdd(self:aErrors,"Missing required property: "+cPath+"."+cProperty)
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
            cResult:="undefined type"
    end switch
return(cResult)

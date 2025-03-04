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

#ifndef __ALT_D__
    HIDDEN:
#endif

    data aErrors as array init {}
    data aOnlyCheck as array init {}

    data cSchema as character init ""

    data hSchema as hash init {=>}
    data hRegexMatch as hash init {=>}

    data lFastMode as logical init .T.
    data lHasError as logical init .F.
    data lOnlyCheck as logical init .F.

    data xJSONData as anytype

//-----------------------------------------------------------------------
    method AddError(cError)

    method CheckArrayItems(aValues as array,hSchema as hash,cPath as character) as logical
    method CheckArrayPrefixItems(aValues as array,hSchema as hash,cPath as character) as logical
    method CheckEnum(xValue as anytype,aEnum as array,cPath as character) as logical
    method CheckNumber(nValue as numeric,hSchema as hash,cPath as character) as logical
    method CheckPattern(cValue as character,cPattern as character,cPath as character) as logical
    method CheckRequired(hData as hash,aRequired as array,cPath as character) as logical
    method CheckString(cValue as numeric,hSchema as hash,cPath as character) as logical
    method CheckType(xValue as anytype,xType as anytype,cPath as character) as logical

    method ValidateObject(xData as anytype,hSchema as hash,cPath as character) as logical

    method regexMatch(cString as character,cPattern as character) as character

//-----------------------------------------------------------------------

    EXPORTED:

    method GetErros() INLINE self:aErrors
    method HasError() INLINE self:lHasError

    method New(cSchema as character) constructor

    method Reset(cSchema as character) as logical
    method SetSchema(cSchema as character) as logical
    method SetFastMode(lFastMode as logical) as logical

    method Validate(cJSONData as character) as logical

endclass

method New(cSchema as character) class JSONValidator
    self:SetSchema(cSchema)
    return(self)

method procedure AddError(cError) class JSONValidator
    if (!self:lOnlyCheck)
        aAdd(self:aErrors,cError)
    else
        aAdd(self:aOnlyCheck,cError)
    endif
    return

method CheckArrayItems(aValues as array,hSchema as hash,cPath as character) class JSONValidator

    local cItemPath as character

    local lValid as logical:=.T.
    local lContains as logical:=hb_HHasKey(hSchema,"contains")
    local lOnlyCheck:=self:lOnlyCheck
    local lUniqueItems as logical:=(hb_HHasKey(hSchema,"uniqueItems").and.hSchema["uniqueItems"])

    local hUniqueItems as hash

    local nItem as numeric
    local nItems as numeric:=Len(aValues)
    local nItemNext as numeric
    local nContainsCount as numeric:=0

    hb_Default(@cPath,"root")

    if (lUniqueItems)
        hUniqueItems:={=>}
    endif

    begin sequence

        for nItem:=1 to nItems
            cItemPath:=(cPath+".item("+hb_NToC(nItem)+")")
            if (!self:ValidateObject(aValues[nItem],hSchema["items"],cItemPath))
                lValid:=.F.
                if (self:lFastMode)
                    break
                endif
            endif
            if (lContains)
                self:lOnlyCheck:=.T.
                if (self:ValidateObject(aValues[nItem],hSchema["contains"],cItemPath))
                    nContainsCount++
                endif
                self:lOnlyCheck:=lOnlyCheck
            endif
            if (lUniqueItems)
                nItemNext:=nItem+1
                if (;
                    aScan(;
                         aValues;
                        ,{|x,y|;
                            if(hb_HHasKey(hUniqueItems,y),hUniqueItems[y],hb_HSet(hUniqueItems,y,hb_Serialize(x))[y]);
                            ==;
                            if(hb_HHasKey(hUniqueItems,nItem),hUniqueItems[nItem],hb_HSet(hUniqueItems,nItem,hb_Serialize(aValues[nItem]))[nItem]);
                        };
                        ,nItemNext;
                    )!=0;
                )
                    lValid:=.F.
                    if (self:lFastMode)
                        self:AddError("Array at "+cPath+" contains duplicate items. All items must be unique as per schema 'uniqueItems' requirement.")
                        break
                    endif
                    self:AddError("Array at "+cPath+".Item("+hb_NToC(nItem)+") contains duplicate item: ("+hb_JSONEncode(aValues[nItem])+"). All items must be unique as per schema 'uniqueItems' requirement.")
                endif
            endif
        next nItem

        if (lContains)
            // Additional checks after iteration
            nContainsCount:=Max(nContainsCount-=Len(self:aOnlyCheck),0)
            aSize(self:aOnlyCheck,0)
            if ((hb_HHasKey(hSchema,"minContains").and.(nContainsCount<hSchema["minContains"])))
                lValid:=.F.
                self:AddError("Array at "+cPath+" has too few items satisfying 'contains'. Found: "+hb_NToC(nContainsCount))
                if (self:lFastMode)
                    break
                endif
            elseif (nContainsCount<1)  // Default: at least 1 item
                lValid:=.F.
                self:AddError("Array at "+cPath+" does not contain at least one item satisfying 'contains'.")
                if (self:lFastMode)
                    break
                endif
            endif
            if (hb_HHasKey(hSchema,"maxContains").and.(nContainsCount>hSchema["maxContains"]))
                lValid:=.F.
                self:AddError("Array at "+cPath+" has too many items satisfying 'contains'. Found: "+hb_NToC(nContainsCount))
                if (self:lFastMode)
                    break
                endif
            endif
        endif

        if (hb_HHasKey(hSchema,"minItems"))
            if (nItems<hSchema["minItems"])
                lValid:=.F.
                self:AddError("Array at "+cPath+" has too few items. Found: "+hb_NToC(nItems)+", Minimum: "+hb_NToC(hSchema["minItems"]))
                if (self:lFastMode)
                    break
                endif
            endif
        endif

        if (hb_HHasKey(hSchema,"maxItems"))
            if (nItems>hSchema["maxItems"])
                lValid:=.F.
                self:AddError("Array at "+cPath+" has too many items. Found: "+hb_NToC(nItems)+", Maximum: "+hb_NToC(hSchema["maxItems"]))
                if (self:lFastMode)
                    break
                endif
            endif
        endif

    end sequence

    return(lValid)

method CheckArrayPrefixItems(aValues as array,hSchema as hash,cPath as character) class JSONValidator

    local aPrefixItems as array:=hSchema["prefixItems"]
    local aAdditionalValues as array

    local cItemPath as character
    local cItemType as character

    local lValid as logical:=.T.
    local lContains as logical:=hb_HHasKey(hSchema,"contains")
    local lOnlyCheck:=self:lOnlyCheck
    local lUniqueItems as logical:=(hb_HHasKey(hSchema,"uniqueItems").and.hSchema["uniqueItems"])

    local hUniqueItems as hash

    local nItem as numeric
    local nItems as numeric:=Len(aValues)
    local nPrefixItems as numeric:=Len(aPrefixItems)
    local nItemNext as numeric
    local nContainsCount as numeric:=0
    local nAdditionalValues as numeric

    hb_Default(@cPath,"root")

    if (lUniqueItems)
        hUniqueItems:={=>}
    endif

    begin sequence

        for nItem:=1 to Min(nItems,nPrefixItems)
            cItemPath:=(cPath+".item("+hb_NToC(nItem)+")")
            if (!self:ValidateObject(aValues[nItem],aPrefixItems[nItem],cItemPath))
                lValid:=.F.
                if (self:lFastMode)
                    break
                endif
            endif
            if (lContains)
                self:lOnlyCheck:=.T.
                if (self:ValidateObject(aValues[nItem],hSchema["contains"],cItemPath))
                    nContainsCount++
                endif
                self:lOnlyCheck:=lOnlyCheck
            endif
            if (lUniqueItems)
                nItemNext:=nItem+1
                if (;
                    aScan(;
                         aValues;
                        ,{|x,y|;
                            if(hb_HHasKey(hUniqueItems,y),hUniqueItems[y],hb_HSet(hUniqueItems,y,hb_Serialize(x))[y]);
                            ==;
                            if(hb_HHasKey(hUniqueItems,nItem),hUniqueItems[nItem],hb_HSet(hUniqueItems,nItem,hb_Serialize(aValues[nItem]))[nItem]);
                        };
                        ,nItemNext;
                    )!=0;
                )
                    lValid:=.F.
                    if (self:lFastMode)
                        self:AddError("Array at "+cPath+" contains duplicate items. All items must be unique as per schema 'uniqueItems' requirement.")
                        break
                    endif
                    self:AddError("Array at "+cPath+".Item("+hb_NToC(nItem)+") contains duplicate item: ("+hb_JSONEncode(aValues[nItem])+"). All items must be unique as per schema 'uniqueItems' requirement.")
                endif
            endif
        next nItem

        //Additional Items
        if ((nItems>nPrefixItems).and.(hb_HHasKey(hSchema,"items")))
            cItemType:=valType(hSchema["items"])
            //Length of Additional Items
            nAdditionalValues:=(nItems-nPrefixItems)
            if ((cItemType=="L").and.(!hSchema["items"]))
                lValid:=.F.
                self:AddError("Array at "+cPath+" does not allow additional items. Extra items found: "+hb_NToC(nAdditionalValues))
                if (self:lFastMode)
                    break
                endif
            elseif (cItemType=="H")
                //Additional Items
                aAdditionalValues:=aCopy(aValues,Array(nAdditionalValues),(nPrefixItems+1),nAdditionalValues)
                if (!self:CheckArrayItems(aAdditionalValues,hSchema,cPath))
                    if (self:lFastMode)
                        break
                    endif
                endif
            endif
        endif

        if (lContains)
            // Additional checks after iteration
            nContainsCount:=Max(nContainsCount-=Len(self:aOnlyCheck),0)
            aSize(self:aOnlyCheck,0)
            if ((hb_HHasKey(hSchema,"minContains").and.(nContainsCount<hSchema["minContains"])))
                lValid:=.F.
                self:AddError("Array at "+cPath+" has too few items satisfying 'contains'. Found: "+hb_NToC(nContainsCount))
                if (self:lFastMode)
                    break
                endif
            elseif (nContainsCount<1)  // Default: at least 1 item
                lValid:=.F.
                self:AddError("Array at "+cPath+" does not contain at least one item satisfying 'contains'.")
                if (self:lFastMode)
                    break
                endif
            endif
            if (hb_HHasKey(hSchema,"maxContains").and.(nContainsCount>hSchema["maxContains"]))
                lValid:=.F.
                self:AddError("Array at "+cPath+" has too many items satisfying 'contains'. Found: "+hb_NToC(nContainsCount))
                if (self:lFastMode)
                    break
                endif
            endif
        endif

        if (hb_HHasKey(hSchema,"minItems"))
            if (nItems<hSchema["minItems"])
                lValid:=.F.
                self:AddError("Array at "+cPath+" has too few items. Found: "+hb_NToC(nItems)+", Minimum: "+hb_NToC(hSchema["minItems"]))
                if (self:lFastMode)
                    break
                endif
            endif
        endif

        if (hb_HHasKey(hSchema,"maxItems"))
            if (nItems>hSchema["maxItems"])
                lValid:=.F.
                self:AddError("Array at "+cPath+" has too many items. Found: "+hb_NToC(nItems)+", Maximum: "+hb_NToC(hSchema["maxItems"]))
                if (self:lFastMode)
                    break
                endif
            endif
        endif

    end sequence

    return(lValid)

method CheckEnum(xValue as anytype,aEnum as array,cPath as character) class JSONValidator
    local cValue as character:=hb_JSONEncode(xValue)
    local cEnums as character:=hb_JSONEncode(aEnum)
    local lValid as logical:=(cValue$cEnums)
    if (!lValid)
        self:AddError("Invalid enum value at "+cPath+". Value: "+cValue+", Allowed values: "+cEnums)
    endif
    return(lValid)

method CheckNumber(nValue as numeric,hSchema as hash,cPath as character) class JSONValidator

    local cType as character:=hSchema["type"]

    local lValid as logical:=.T.

    local nTempN as numeric

    begin sequence

        // Check the basic type
        if (cType=="integer")
            nTempN:=Int(nValue)
            lValid:=((nValue-nTempN)==0)
            if (!lValid)
                self:AddError("Type mismatch at " + cPath + ". Expected: " + cType + ", Found: number")
                if (self:lFastMode)
                    break
                endif
            endif
        elseif ((cType!="number").and.(cType!="integer"))
            lValid:=.F.
            self:AddError("Type mismatch at "+cPath+". Expected: "+cType+", Found: number")
            if (self:lFastMode)
                break
            endif
        endif

        // Check multipleOf, if present
        if (hb_HHasKey(hSchema,"multipleOf"))
            nTempN:=(nValue/hSchema["multipleOf"])
            // Check if the result is 'almost' integer (tolerance for floating-point errors)
            lValid:=(Abs(nTempN-Round(nTempN,0))<0.0000001)  // epsilon = 1e-7
            if (!lValid)
                self:AddError("Value "+hb_JSONEncode(nValue)+" at "+cPath+" is not a multiple of "+hb_JSONEncode(hSchema["multipleOf"]))
                if (self:lFastMode)
                    break
                endif
            endif
        endif

        // Check minimum, if present
        if (hb_HHasKey(hSchema,"minimum"))
            if (nValue<hSchema["minimum"])
                lValid:=.F.
                self:AddError("Value "+hb_JSONEncode(nValue)+" at "+cPath+" is smaller than minimum: "+hb_JSONEncode(hSchema["minimum"]))
                if (self:lFastMode)
                    break
                endif
            endif
        endif

        // Check maximum, if present
        if (hb_HHasKey(hSchema,"maximum"))
            if (nValue>hSchema["maximum"])
                lValid:=.F.
                self:AddError("Value "+hb_JSONEncode(nValue)+" at "+cPath+" is bigger than maximum: "+hb_JSONEncode(hSchema["maximum"]))
                if (self:lFastMode)
                    break
                endif
            endif
        endif

        // Check exclusiveMinimum, if present
        if (hb_HHasKey(hSchema,"exclusiveMinimum"))
            if (nValue<=hSchema["exclusiveMinimum"])
                lValid:=.F.
                self:AddError("Value "+hb_JSONEncode(nValue)+" at "+cPath+" is smaller than or equal to exclusiveMinimum: "+hb_JSONEncode(hSchema["exclusiveMinimum"]))
                if (self:lFastMode)
                    break
                endif
            endif
        endif

        // Check exclusiveMaximum, if present
        if (hb_HHasKey(hSchema,"exclusiveMaximum"))
            if (nValue>=hSchema["exclusiveMaximum"])
                lValid:=.F.
                self:AddError("Value "+hb_JSONEncode(nValue)+" at "+cPath+" is bigger than or equal to exclusiveMaximum: "+hb_JSONEncode(hSchema["exclusiveMaximum"]))
                if (self:lFastMode)
                    break
                endif
            endif
        endif

    end sequence

    return(lValid)

method CheckPattern(cValue as character,cPattern as character,cPath as character) class JSONValidator

    local lValid as logical

    hb_Default(@cPath,"root")

    lValid:=self:regexMatch(cValue,cPattern)
    if (!lValid)
        self:AddError("Pattern mismatch at "+cPath+". Value: '"+cValue+"' does not match pattern: '"+cPattern+"'")
    endif

    return(lValid)

method CheckRequired(hData as hash,aRequired as array,cPath as character) class JSONValidator

    local cProperty as character

    local lValid as logical:=.T.

    local nProperty as numeric

    hb_Default(@cPath,"root")

    begin sequence

        if (ValType(hData)!="H")
            lValid:=.F.
            self:AddError("Expected an object at "+cPath+" to check required properties")
            break
        endif

        for nProperty:=1 to Len(aRequired)
            cProperty:=aRequired[nProperty]
            if (!hb_HHasKey(hData,cProperty))
                lValid:=.F.
                self:AddError("Required property missing at "+cPath+"."+cProperty)
                if (self:lFastMode)
                    break
                endif
            endif
        next

    end sequence

    return(lValid)

method CheckString(cValue as numeric,hSchema as hash,cPath as character) class JSONValidator

    local lValid as logical:=.T.

    local nLen as numeric:=Len(cValue)

    begin sequence

        // Check minLength, if present
        if (hb_HHasKey(hSchema,"minLength"))
            if (nLen<hSchema["minLength"])
                lValid:=.F.
                self:AddError("Lenght ("+hb_NToC(nLen)+") of string "+hb_JSONEncode(cValue)+" at "+cPath+" is smaller than minLength: "+hb_JSONEncode(hSchema["minLength"]))
                if (self:lFastMode)
                    break
                endif
            endif
        endif

        // Check maxLength, if present
        if (hb_HHasKey(hSchema,"maxLength"))
            if (nLen>hSchema["maxLength"])
                lValid:=.F.
                self:AddError("Lenght ("+hb_NToC(nLen)+") of string "+hb_JSONEncode(cValue)+" at "+cPath+" is bigger than maxLength: "+hb_JSONEncode(hSchema["maxLength"]))
                if (self:lFastMode)
                    break
                endif
            endif
        endif

        // Check pattern, if present
        if (hb_HHasKey(hSchema,"pattern"))
            lValid:=self:CheckPattern(cValue,hSchema["pattern"],cPath)
        endif

    end sequence

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
            case "integer"
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
            self:AddError("Type mismatch at "+cPath+". Expected: "+cType+", Found: "+__HB2JSON(cValueType))
        endif
    elseif (cType=="A")
        // Array de tipos
        cType:=hb_JSONEncode(xType)
        cValueType:=__HB2JSON(cValueType)
        lResult:=(cValueType$cType)
        if (!lResult)
            self:AddError( "Type mismatch at "+cPath+". Expected: one of: "+cType+", Found: "+cValueType)
        endif
    else
        // Tipo inválido para cType
        self:AddError( "Invalid type specification at "+cPath+". Expected string or array of strings, Got "+__HB2JSON(cType))
        lResult:=.F.
    endif

    return(lResult)

method Reset(cSchema as character) class JSONValidator
    hb_default(@cSchema,self:cSchema)
    return(self:SetSchema(cSchema))

method SetSchema(cSchema as character) class JSONValidator
    local nLengthDecoded as numeric
    aSize(self:aErrors,0)
    aSize(self:aOnlyCheck,0)
    self:lOnlyCheck:=.F.
    if ((self:cSchema!=cSchema).or.(Empty(self:hSchema)))
        self:cSchema:=cSchema
        nLengthDecoded:=hb_JSONDecode(self:cSchema,@self:hSchema)
        self:lHasError:=((nLengthDecoded==0).or.ValType(self:hSchema)!="H")
    else
        self:lHasError:=(ValType(self:hSchema)!="H")
    endif
    if (self:lHasError)
        self:AddError("Invalid JSON Schema provided")
    endif
    return(!self:lHasError)

method SetFastMode(lFastMode as logical) class JSONValidator
    local lValue as logical:=self:lFastMode
    self:lFastMode:=lFastMode
    return(lValue)

method Validate(cJSONData as character) class JSONValidator
    local nLengthDecoded as numeric
    begin sequence
        nLengthDecoded:=hb_JSONDecode(cJSONData,@self:xJSONData)
        if (((nLengthDecoded==0).or.(!ValType(self:xJSONData)$"A|C|H|L|N")))
            self:AddError("Invalid JSON data provided")
            break
        endif
        self:ValidateObject(self:xJSONData,self:hSchema,"root")
    end sequence
    self:lHasError:=(!Empty(self:aErrors))
    return(!self:lHasError)

method ValidateObject(xData as anytype,hSchema as hash,cPath as character) class JSONValidator

    local aRequired as array

    local cType as character
    local cDataType as character
    local cProperty as character
    local cPropertyPath as character

    local hProperties as hash

    local lValid as logical

    local xType as anytype

    hb_Default(@cPath,"root")

    begin sequence

        if (hb_HHasKey(hSchema,"type"))
            xType:=hSchema["type"]
            lValid:=self:CheckType(xData,xType,cPath)
            if (!lValid)
                break
            endif
        endif

        if (hb_HHasKey(hSchema,"enum"))
            self:CheckEnum(xData,hSchema["enum"],cPath)
        endif

        if (valtype(xType)=="C")
            cType:=xType
            switch Lower(cType)
                case "array"
                    if (hb_HHasKey(hSchema,"prefixItems"))
                        if (!self:CheckArrayPrefixItems(xData,hSchema,cPath))
                            if (self:lFastMode)
                                break
                            endif
                        endif
                    elseif (hb_HHasKey(hSchema,"items"))
                        if (!self:CheckArrayItems(xData,hSchema,cPath))
                            if (self:lFastMode)
                                break
                            endif
                        endif
                    endif
                    exit
                case "string"
                    if (!self:CheckString(xData,hSchema,cPath))
                        if (self:lFastMode)
                            break
                        endif
                    endif
                    exit
                case "object"
                    exit
                case "integer"
                case "number"
                    if (!self:CheckNumber(xData,hSchema,cPath))
                        if (self:lFastMode)
                            break
                        endif
                    endif
                    exit
            end switch
        endif

        cDataType:=valtype(xData)
        if (cDataType!="H")
            break
        endif

        if (hb_HHasKey(hSchema,"required"))
            aRequired:=hSchema["required"]
            if (!self:CheckRequired(xData,aRequired,cPath))
                if (self:lFastMode)
                    break
                endif
            endif
        endif

        if (!hb_HHasKey(hSchema,"properties"))
            break
        endif

        hProperties:=hSchema["properties"]
        for each cProperty in hb_HKeys(hProperties)
            if (hb_HHasKey(xData,cProperty))
                cPropertyPath:=(cPath+"."+cProperty)
                if (hb_HHasKey(hProperties[cProperty],"type"))
                    xType:=hProperties[cProperty]["type"]
                    lValid:=self:CheckType(xData[cProperty],xType,cPropertyPath)
                    if (!lValid)
                        if (self:lFastMode)
                            break
                        endif
                        loop
                    endif
                    if (hb_HHasKey(hProperties[cProperty],"enum"))
                        if (!self:CheckEnum(xData[cProperty],hProperties[cProperty]["enum"],cPropertyPath))
                            if (self:lFastMode)
                                break
                            endif
                        endif
                    endif
                    if (valtype(xType)=="C")
                        cType:=xType
                        switch Lower(cType)
                            case "array"
                                if (hb_HHasKey(hProperties[cProperty],"prefixItems"))
                                    if (!self:CheckArrayPrefixItems(xData[cProperty],hProperties[cProperty],cPropertyPath))
                                        if (self:lFastMode)
                                            break
                                        endif
                                    endif
                                elseif (hb_HHasKey(hProperties[cProperty],"items"))
                                    if (!self:CheckArrayItems(xData[cProperty],hProperties[cProperty],cPropertyPath))
                                        if (self:lFastMode)
                                            break
                                        endif
                                    endif
                                endif
                                exit
                            case "string"
                                if (!self:CheckString(xData[cProperty],hProperties[cProperty],cPropertyPath))
                                    if (self:lFastMode)
                                        break
                                    endif
                                endif
                                exit
                            case "object"
                                if (!self:ValidateObject(xData[cProperty],hProperties[cProperty],cPropertyPath))
                                    if (self:lFastMode)
                                        break
                                    endif
                                endif
                                exit
                            case "integer"
                            case "number"
                                if (!self:CheckNumber(xData[cProperty],hProperties[cProperty],cPropertyPath))
                                    if (self:lFastMode)
                                        break
                                    endif
                                endif
                                exit
                        end switch
                    endif
                endif
            endif
        next each //cProperty

    end sequence

    self:lHasError:=(!Empty(self:aErrors))

    return(!self:lHasError)

method regexMatch(cString as character,cPattern as character) class JSONValidator

    local aMatch as array

    local lMatch as logical

    local pRegex as pointer

    if (hb_HHasKey(self:hRegexMatch,cPattern))
        pRegex:=self:hRegexMatch[cPattern]
    else
        pRegex:=hb_regexComp(cPattern,.T./* case-sensitive */,.F./* no multiline */)
        self:hRegexMatch[cPattern]:=pRegex
    endif

    aMatch:=hb_regex(pRegex,cString,.T./* case-sensitive */)
    lMatch:=(!Empty(aMatch))

    return(lMatch)

static function __HB2JSON(cType as character)
    local cResult as character
    switch Upper(cType)
        case "C"
            cResult:="string"
            exit
        case "N"
            cResult:="number"
            exit
        case "I"
            cResult:="integer"
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

/*

   _                                _                                            _  _      _         _
  (_) ___   ___   _ __   ___   ___ | |__    ___  _ __ ___    __ _ __   __  __ _ | |(_)  __| |  __ _ | |_   ___   _ __
  | |/ __| / _ \ | '_ \ / __| / __|| '_ \  / _ \| '_ ` _ \  / _` |\ \ / / / _` || || | / _` | / _` || __| / _ \ | '__|
  | |\__ \| (_) || | | |\__ \| (__ | | | ||  __/| | | | | || (_| | \ V / | (_| || || || (_| || (_| || |_ | (_) || |
 _/ ||___/ \___/ |_| |_||___/ \___||_| |_| \___||_| |_| |_| \__,_|  \_/   \__,_||_||_| \__,_| \__,_| \__| \___/ |_|
|__/

    Released to Public Domain.
    --------------------------------------------------------------------------------------
*/

#include "hbcurl.ch"
#include "hbclass.ch"

#require "hbssl"
#require "hbtip"

memvar m__hRefSchema

class JSONSchemaValidator

#ifndef __ALT_D__
    HIDDEN:
#endif

    data aErrors as array init {}
    data aOnlyCheck as array init {}

    data cSchema as character init ""

    data hSchema as hash init {=>}
    data hRefSchema as hash init {=>}
    data hRegexMatch as hash init {=>}

    data lFastMode as logical init .T.
    data lHasError as logical init .F.
    data lOnlyCheck as logical init .F.

    data xJSONData as anytype

//-----------------------------------------------------------------------
    method AddError(cError)

    method CheckArrayItems(aValues as array,hSchema as hash,cNode as character) as logical
    method CheckArrayPrefixItems(aValues as array,hSchema as hash,cNode as character) as logical
    method CheckEnum(xValue as anytype,aEnum as array,cNode as character) as logical
    method CheckFormat(cValue as character,cFormat as character,cNode as character) as logical
    method CheckNumber(nValue as numeric,hSchema as hash,cNode as character) as logical
    method CheckPattern(cValue as character,cPattern as character,cNode as character) as logical
    method CheckRequired(hData as hash,aRequired as array,cNode as character) as logical
    method CheckString(cValue as numeric,hSchema as hash,cNode as character) as logical
    method CheckType(xValue as anytype,xType as anytype,cNode as character) as logical

    method ValidateObject(xData as anytype,hSchema as hash,cNode as character) as logical

    method RegexMatch(cString as character,cPattern as character,lOnlyCompile as logical) as character

    method ResolveRef(cRef as character,cNode as character) as hash
    method ResolveInternalRef(cRef as character,cNode as character) as hash
    method ResolveExternalRef(cRef as character,cNode as character) as hash

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

method New(cSchema as character) class JSONSchemaValidator
    self:SetSchema(cSchema)
    return(self)

method procedure AddError(cError) class JSONSchemaValidator
    if (!self:lOnlyCheck)
        aAdd(self:aErrors,cError)
    else
        aAdd(self:aOnlyCheck,cError)
    endif
    return

method CheckArrayItems(aValues as array,hSchema as hash,cNode as character) class JSONSchemaValidator

    local cItemPath as character

    local lValid as logical:=.T.
    local lHasRef as logical:=hb_HHasKey(hSchema["items"],"$ref")
    local lOnlyCheck:=self:lOnlyCheck
    local lHasContains as logical:=hb_HHasKey(hSchema,"contains")
    local lUniqueItems as logical:=(hb_HHasKey(hSchema,"uniqueItems").and.hSchema["uniqueItems"])

    local hSchemaItems as hash
    local hUniqueItems as hash

    local nItem as numeric
    local nItems as numeric:=Len(aValues)
    local nItemNext as numeric
    local nContainsCount as numeric:=0


    hb_Default(@cNode,"root")

    if (lUniqueItems)
        hUniqueItems:={=>}
    endif

    if (lHasRef)
        hSchemaItems:=self:ResolveRef(hSchema["items"]["$ref"],cNode)
    else
        hSchemaItems:=hSchema["items"]
    endif

    begin sequence

        for nItem:=1 to nItems
            cItemPath:=(cNode+".item("+hb_NToC(nItem)+")")
            if (!self:ValidateObject(aValues[nItem],hSchemaItems,cItemPath))
                lValid:=.F.
                if (self:lFastMode)
                    break
                endif
            endif
            if (lHasContains)
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
                        self:AddError("Array at "+cNode+" contains duplicate items. All items must be unique as per schema 'uniqueItems' requirement.")
                        break
                    endif
                    self:AddError("Array at "+cNode+".Item("+hb_NToC(nItem)+") contains duplicate item: ("+hb_JSONEncode(aValues[nItem])+"). All items must be unique as per schema 'uniqueItems' requirement.")
                endif
            endif
        next nItem

        if (lHasContains)
            // Additional checks after iteration
            nContainsCount:=Max(nContainsCount-=Len(self:aOnlyCheck),0)
            aSize(self:aOnlyCheck,0)
            if ((hb_HHasKey(hSchema,"minContains").and.(nContainsCount<hSchema["minContains"])))
                lValid:=.F.
                self:AddError("Array at "+cNode+" has too few items satisfying 'contains'. Found: "+hb_NToC(nContainsCount))
                if (self:lFastMode)
                    break
                endif
            elseif (nContainsCount<1)  // Default: at least 1 item
                lValid:=.F.
                self:AddError("Array at "+cNode+" does not contain at least one item satisfying 'contains'.")
                if (self:lFastMode)
                    break
                endif
            endif
            if (hb_HHasKey(hSchema,"maxContains").and.(nContainsCount>hSchema["maxContains"]))
                lValid:=.F.
                self:AddError("Array at "+cNode+" has too many items satisfying 'contains'. Found: "+hb_NToC(nContainsCount))
                if (self:lFastMode)
                    break
                endif
            endif
        endif

        if (hb_HHasKey(hSchema,"minItems"))
            if (nItems<hSchema["minItems"])
                lValid:=.F.
                self:AddError("Array at "+cNode+" has too few items. Found: "+hb_NToC(nItems)+", Minimum: "+hb_NToC(hSchema["minItems"]))
                if (self:lFastMode)
                    break
                endif
            endif
        endif

        if (hb_HHasKey(hSchema,"maxItems"))
            if (nItems>hSchema["maxItems"])
                lValid:=.F.
                self:AddError("Array at "+cNode+" has too many items. Found: "+hb_NToC(nItems)+", Maximum: "+hb_NToC(hSchema["maxItems"]))
                if (self:lFastMode)
                    break
                endif
            endif
        endif

    end sequence

    return(lValid)

method CheckArrayPrefixItems(aValues as array,hSchema as hash,cNode as character) class JSONSchemaValidator

    local aPrefixItems as array:=hSchema["prefixItems"]
    local aAdditionalValues as array

    local cItemPath as character
    local cItemType as character

    local lHasRef as logical
    local lValid as logical:=.T.
    local lHasContains as logical:=hb_HHasKey(hSchema,"contains")
    local lOnlyCheck:=self:lOnlyCheck
    local lUniqueItems as logical:=(hb_HHasKey(hSchema,"uniqueItems").and.hSchema["uniqueItems"])

    local hSchemaItems as hash
    local hUniqueItems as hash

    local nItem as numeric
    local nItems as numeric:=Len(aValues)
    local nPrefixItems as numeric:=Len(aPrefixItems)
    local nItemNext as numeric
    local nContainsCount as numeric:=0
    local nAdditionalValues as numeric

    hb_Default(@cNode,"root")

    if (lUniqueItems)
        hUniqueItems:={=>}
    endif

    begin sequence

        for nItem:=1 to Min(nItems,nPrefixItems)
            cItemPath:=(cNode+".item("+hb_NToC(nItem)+")")
            lHasRef:=hb_HHasKey(aPrefixItems[nItem],"$ref")
            if (lHasRef)
                hSchemaItems:=self:ResolveRef(aPrefixItems[nItem]["$ref"],cItemPath)
            else
                hSchemaItems:=aPrefixItems[nItem]
            endif
            if (!self:ValidateObject(aValues[nItem],hSchemaItems,cItemPath))
                lValid:=.F.
                if (self:lFastMode)
                    break
                endif
            endif
            if (lHasContains)
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
                        self:AddError("Array at "+cNode+" contains duplicate items. All items must be unique as per schema 'uniqueItems' requirement.")
                        break
                    endif
                    self:AddError("Array at "+cNode+".Item("+hb_NToC(nItem)+") contains duplicate item: ("+hb_JSONEncode(aValues[nItem])+"). All items must be unique as per schema 'uniqueItems' requirement.")
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
                self:AddError("Array at "+cNode+" does not allow additional items. Extra items found: "+hb_NToC(nAdditionalValues))
                if (self:lFastMode)
                    break
                endif
            elseif (cItemType=="H")
                //Additional Items
                aAdditionalValues:=aCopy(aValues,Array(nAdditionalValues),(nPrefixItems+1),nAdditionalValues)
                if (!self:CheckArrayItems(aAdditionalValues,hSchema,cNode))
                    if (self:lFastMode)
                        break
                    endif
                endif
            endif
        endif

        if (lHasContains)
            // Additional checks after iteration
            nContainsCount:=Max(nContainsCount-=Len(self:aOnlyCheck),0)
            aSize(self:aOnlyCheck,0)
            if ((hb_HHasKey(hSchema,"minContains").and.(nContainsCount<hSchema["minContains"])))
                lValid:=.F.
                self:AddError("Array at "+cNode+" has too few items satisfying 'contains'. Found: "+hb_NToC(nContainsCount))
                if (self:lFastMode)
                    break
                endif
            elseif (nContainsCount<1)  // Default: at least 1 item
                lValid:=.F.
                self:AddError("Array at "+cNode+" does not contain at least one item satisfying 'contains'.")
                if (self:lFastMode)
                    break
                endif
            endif
            if (hb_HHasKey(hSchema,"maxContains").and.(nContainsCount>hSchema["maxContains"]))
                lValid:=.F.
                self:AddError("Array at "+cNode+" has too many items satisfying 'contains'. Found: "+hb_NToC(nContainsCount))
                if (self:lFastMode)
                    break
                endif
            endif
        endif

        if (hb_HHasKey(hSchema,"minItems"))
            if (nItems<hSchema["minItems"])
                lValid:=.F.
                self:AddError("Array at "+cNode+" has too few items. Found: "+hb_NToC(nItems)+", Minimum: "+hb_NToC(hSchema["minItems"]))
                if (self:lFastMode)
                    break
                endif
            endif
        endif

        if (hb_HHasKey(hSchema,"maxItems"))
            if (nItems>hSchema["maxItems"])
                lValid:=.F.
                self:AddError("Array at "+cNode+" has too many items. Found: "+hb_NToC(nItems)+", Maximum: "+hb_NToC(hSchema["maxItems"]))
                if (self:lFastMode)
                    break
                endif
            endif
        endif

    end sequence

    return(lValid)

method CheckEnum(xValue as anytype,aEnum as array,cNode as character) class JSONSchemaValidator
    local cEnumType as character
    local cValueType as character:=valType(xValue)
    local lValid as logical:=.F.
    local lOnlyCheck:=self:lOnlyCheck
    local i as numeric
    for i:=1 to Len(aEnum)
        if ((hb_IsHash(aEnum[i])).and.(hb_HHasKey(aEnum[i],"pattern")))
            // Check pattern, if present
            self:lOnlyCheck:=.T.
                lValid:=self:CheckPattern(xValue,aEnum[i]["pattern"],cNode)
            self:lOnlyCheck:=lOnlyCheck
            if (lValid)
                exit
            endif
        else
            cEnumType:=ValType(aEnum[i])
            if (cValueType==cEnumType)
                lValid:=(xValue==aEnum[i])
                if (lValid)
                    exit
                endif
            endif
        endif
    next i
    if (!lValid)
        self:AddError("Invalid enum value at "+cNode+". Value: "+hb_JSONEncode(xValue)+", Allowed values: "+hb_JSONEncode(aEnum))
    endif
    return(lValid)

method CheckFormat(cValue as character,cFormat as character,cNode as character) class JSONSchemaValidator

    local cPattern as character

    local lValid as logical

    hb_Default(@cNode,"root")

    switch Lower(cFormat)
        case "date-time"//ISO 8601
            cPattern:="^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:Z|[+-]\d{2}:\d{2})$"
            exit
        case "date"//ISO 8601
            cPattern:="^\d{4}-\d{2}-\d{2}$"
            exit
        case "time"//ISO 8601
            cPattern:="^\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:Z|[+-]\d{2}:\d{2})?$"
            exit
        case "duration"//ISO 8601
            cPattern:="^P(?=\d|T\d)(\d+Y)?(\d+M)?(\d+W)?(\d+D)?(T(\d+H)?(\d+M)?(\d+S)?)?$"
            exit
        case "email"//RFC 5322
            cPattern:="^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
            exit
        case "idn-email"//RFC 5322
            cPattern:="^[\p{L}\p{N}._%+-]+@[\p{L}\p{N}.-]+\.[\p{L}]{2,}$"
            exit
        case "hostname"//RFC 1034
            cPattern:="^(?=.{1,253}$)(?!-)[a-zA-Z0-9-]{1,63}(?<!-)(\.[a-zA-Z0-9-]{1,63})*$"
            exit
        case "ipv4"
            cPattern:="^(?:\d{1,3}\.){3}\d{1,3}$"
            exit
        case "ipv6"
            cPattern:="^([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$"
            exit
        case "uuid" //RFC 4122
            cPattern:="^([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$"
            exit
        case "uri" //RFC 3986
            cPattern:="^[a-zA-Z][a-zA-Z0-9+.-]*:[^\s]*$"
            exit
        case "uri-reference" //RFC 3986
            cPattern:="^[a-zA-Z][a-zA-Z0-9+.-]*:[^\s]*|^[^\s]*$"
            exit
        otherwise
            if (self:RegexMatch("",cFormat,.T.))
                cPattern:=cFormat
            endif
    end switch

    if (!Empty(cPattern))
        lValid:=self:RegexMatch(cValue,cPattern,.F.)
        if (!lValid)
            self:AddError("Format mismatch at "+cNode+". Value: '"+cValue+"' does not match pattern: '"+cPattern+"'")
        endif
    else
        lValid:=.T.
    endif

    return(lValid)

method CheckNumber(nValue as numeric,hSchema as hash,cNode as character) class JSONSchemaValidator

    local cType as character:=hSchema["type"]

    local lValid as logical:=.T.

    local nTempN as numeric

    begin sequence

        // Check the basic type
        if (cType=="integer")
            nTempN:=Int(nValue)
            lValid:=((nValue-nTempN)==0)
            if (!lValid)
                self:AddError("Type mismatch at " + cNode + ". Expected: " + cType + ", Found: number")
                if (self:lFastMode)
                    break
                endif
            endif
        elseif ((cType!="number").and.(cType!="integer"))
            lValid:=.F.
            self:AddError("Type mismatch at "+cNode+". Expected: "+cType+", Found: number")
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
                self:AddError("Value "+hb_JSONEncode(nValue)+" at "+cNode+" is not a multiple of "+hb_JSONEncode(hSchema["multipleOf"]))
                if (self:lFastMode)
                    break
                endif
            endif
        endif

        // Check minimum, if present
        if (hb_HHasKey(hSchema,"minimum"))
            if (nValue<hSchema["minimum"])
                lValid:=.F.
                self:AddError("Value "+hb_JSONEncode(nValue)+" at "+cNode+" is smaller than minimum: "+hb_JSONEncode(hSchema["minimum"]))
                if (self:lFastMode)
                    break
                endif
            endif
        endif

        // Check maximum, if present
        if (hb_HHasKey(hSchema,"maximum"))
            if (nValue>hSchema["maximum"])
                lValid:=.F.
                self:AddError("Value "+hb_JSONEncode(nValue)+" at "+cNode+" is bigger than maximum: "+hb_JSONEncode(hSchema["maximum"]))
                if (self:lFastMode)
                    break
                endif
            endif
        endif

        // Check exclusiveMinimum, if present
        if (hb_HHasKey(hSchema,"exclusiveMinimum"))
            if (nValue<=hSchema["exclusiveMinimum"])
                lValid:=.F.
                self:AddError("Value "+hb_JSONEncode(nValue)+" at "+cNode+" is smaller than or equal to exclusiveMinimum: "+hb_JSONEncode(hSchema["exclusiveMinimum"]))
                if (self:lFastMode)
                    break
                endif
            endif
        endif

        // Check exclusiveMaximum, if present
        if (hb_HHasKey(hSchema,"exclusiveMaximum"))
            if (nValue>=hSchema["exclusiveMaximum"])
                lValid:=.F.
                self:AddError("Value "+hb_JSONEncode(nValue)+" at "+cNode+" is bigger than or equal to exclusiveMaximum: "+hb_JSONEncode(hSchema["exclusiveMaximum"]))
                if (self:lFastMode)
                    break
                endif
            endif
        endif

    end sequence

    return(lValid)

method CheckPattern(cValue as character,cPattern as character,cNode as character) class JSONSchemaValidator

    local lValid as logical

    hb_Default(@cNode,"root")

    lValid:=self:RegexMatch(cValue,cPattern,.F.)
    if (!lValid)
        self:AddError("Pattern mismatch at "+cNode+". Value: '"+cValue+"' does not match pattern: '"+cPattern+"'")
    endif

    return(lValid)

method CheckRequired(hData as hash,aRequired as array,cNode as character) class JSONSchemaValidator

    local cProperty as character

    local lValid as logical:=.T.

    local nProperty as numeric

    hb_Default(@cNode,"root")

    begin sequence

        if (!hb_IsHash(hData))
            lValid:=.F.
            self:AddError("Expected an object at "+cNode+" to check required properties")
            break
        endif

        for nProperty:=1 to Len(aRequired)
            cProperty:=aRequired[nProperty]
            if (!hb_HHasKey(hData,cProperty))
                lValid:=.F.
                self:AddError("Required property missing at "+cNode+"."+cProperty)
                if (self:lFastMode)
                    break
                endif
            endif
        next

    end sequence

    return(lValid)

method CheckString(cValue as numeric,hSchema as hash,cNode as character) class JSONSchemaValidator

    local lValid as logical:=.T.

    local nLen as numeric:=Len(cValue)

    begin sequence

        // Check minLength, if present
        if (hb_HHasKey(hSchema,"minLength"))
            if (nLen<hSchema["minLength"])
                lValid:=.F.
                self:AddError("Lenght ("+hb_NToC(nLen)+") of string "+hb_JSONEncode(cValue)+" at "+cNode+" is smaller than minLength: "+hb_JSONEncode(hSchema["minLength"]))
                if (self:lFastMode)
                    break
                endif
            endif
        endif

        // Check maxLength, if present
        if (hb_HHasKey(hSchema,"maxLength"))
            if (nLen>hSchema["maxLength"])
                lValid:=.F.
                self:AddError("Lenght ("+hb_NToC(nLen)+") of string "+hb_JSONEncode(cValue)+" at "+cNode+" is bigger than maxLength: "+hb_JSONEncode(hSchema["maxLength"]))
                if (self:lFastMode)
                    break
                endif
            endif
        endif

        // Check pattern, if present
        if (hb_HHasKey(hSchema,"pattern"))
            lValid:=self:CheckPattern(cValue,hSchema["pattern"],cNode)
        endif

    end sequence

    return(lValid)

method CheckType(xValue as anytype,xType as anytype,cNode as character) class JSONSchemaValidator

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
            self:AddError("Type mismatch at "+cNode+". Expected: "+cType+", Found: "+__HB2JSON(cValueType))
        endif
    elseif (cType=="A")
        // Array de tipos
        cType:=hb_JSONEncode(xType)
        cValueType:=__HB2JSON(cValueType)
        lResult:=(cValueType$cType)
        if (!lResult)
            self:AddError( "Type mismatch at "+cNode+". Expected: one of: "+cType+", Found: "+cValueType)
        endif
    else
        // Tipo inválido para cType
        self:AddError( "Invalid type specification at "+cNode+". Expected string or array of strings, Got "+__HB2JSON(cType))
        lResult:=.F.
    endif

    return(lResult)

method Reset(cSchema as character) class JSONSchemaValidator
    hb_default(@cSchema,self:cSchema)
    return(self:SetSchema(cSchema))

method SetSchema(cSchema as character) class JSONSchemaValidator
    local nLengthDecoded as numeric
    aSize(self:aErrors,0)
    aSize(self:aOnlyCheck,0)
    self:lOnlyCheck:=.F.
    if ((self:cSchema!=cSchema).or.(Empty(self:hSchema)))
        self:cSchema:=cSchema
        nLengthDecoded:=hb_JSONDecode(self:cSchema,@self:hSchema)
        self:lHasError:=((nLengthDecoded==0).or.(!hb_IsHash(self:hSchema)))
    else
        self:lHasError:=(!hb_IsHash(self:hSchema))
    endif
    if (self:lHasError)
        self:AddError("Invalid JSON Schema provided")
    endif
    return(!self:lHasError)

method SetFastMode(lFastMode as logical) class JSONSchemaValidator
    local lValue as logical:=self:lFastMode
    self:lFastMode:=lFastMode
    return(lValue)

method Validate(cJSONData as character) class JSONSchemaValidator
    local nLengthDecoded as numeric
    begin sequence
        nLengthDecoded:=hb_JSONDecode(cJSONData,@self:xJSONData)
        if (((nLengthDecoded==0).or.(!ValType(self:xJSONData)$"A|C|H|L|N|U")))
            self:AddError("Invalid JSON data provided")
            break
        endif
        self:ValidateObject(self:xJSONData,self:hSchema,"root")
    end sequence
    self:lHasError:=(!Empty(self:aErrors))
    return(!self:lHasError)

method ValidateObject(xData as anytype,hSchema as hash,cNode as character) class JSONSchemaValidator

    local aRequired as array

    local cType as character
    local cProperty as character
    local cPropertyPath as character

    local hProperties as hash

    local hItemsSchema as hash
    local hPropertySchema as hash
    local hPrefixItemsSchema as hash

    local lValid as logical
    local lHasRef as logical

    local xType as anytype

    hb_Default(@cNode,"root")

    begin sequence

        if (hb_HHasKey(hSchema,"type"))
            xType:=hSchema["type"]
            lValid:=self:CheckType(xData,xType,cNode)
            if (!lValid)
                break
            endif
        endif

        if (hb_HHasKey(hSchema,"format"))
            if (!self:CheckFormat(xData,hSchema["format"],cNode))
                if (self:lFastMode)
                    break
                endif
            endif
        endif

        if (hb_HHasKey(hSchema,"enum"))
            if (!self:CheckEnum(xData,hSchema["enum"],cNode))
                if (self:lFastMode)
                    break
                endif
            endif
        endif

        if (hb_IsString(xType))
            cType:=xType
            switch Lower(cType)
                case "array"
                    if (hb_HHasKey(hSchema,"prefixItems"))
                        if (!self:CheckArrayPrefixItems(xData,hSchema,cNode))
                            if (self:lFastMode)
                                break
                            endif
                        endif
                    elseif (hb_HHasKey(hSchema,"items"))
                        if (!self:CheckArrayItems(xData,hSchema,cNode))
                            if (self:lFastMode)
                                break
                            endif
                        endif
                    endif
                    exit
                case "string"
                    if (!self:CheckString(xData,hSchema,cNode))
                        if (self:lFastMode)
                            break
                        endif
                    endif
                    exit
                case "object"
                    exit
                case "integer"
                case "number"
                    if (!self:CheckNumber(xData,hSchema,cNode))
                        if (self:lFastMode)
                            break
                        endif
                    endif
                    exit
            end switch
        endif

        if (!hb_IsHash(xData))
            break
        endif

        if (hb_HHasKey(hSchema,"required"))
            aRequired:=hSchema["required"]
            if (!self:CheckRequired(xData,aRequired,cNode))
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
                cPropertyPath:=(cNode+"."+cProperty)
                lHasRef:=hb_HHasKey(hProperties[cProperty],"$ref")
                if (lHasRef)
                    hPropertySchema:=self:ResolveRef(hProperties[cProperty]["$ref"],cPropertyPath)
                else
                    hPropertySchema:=hProperties[cProperty]
                endif
                if (hb_HHasKey(hPropertySchema,"type"))
                    xType:=hPropertySchema["type"]
                    lValid:=self:CheckType(xData[cProperty],xType,cPropertyPath)
                    if (!lValid)
                        if (self:lFastMode)
                            break
                        endif
                        loop
                    endif
                    if (hb_HHasKey(hPropertySchema,"enum"))
                        if (!self:CheckEnum(xData[cProperty],hPropertySchema["enum"],cPropertyPath))
                            if (self:lFastMode)
                                break
                            endif
                        endif
                    endif
                    if (hb_IsString(xType))
                        cType:=xType
                        switch Lower(cType)
                            case "array"
                                if (hb_HHasKey(hPropertySchema,"prefixItems"))
                                    hPrefixItemsSchema:=hPropertySchema
                                elseif (hb_HHasKey(hProperties[cProperty],"prefixItems"))
                                    hPrefixItemsSchema:=hProperties[cProperty]
                                else
                                    hPrefixItemsSchema:={=>}
                                endif
                                if (hb_HHasKey(hPrefixItemsSchema,"prefixItems"))
                                    if (!self:CheckArrayPrefixItems(xData[cProperty],hPrefixItemsSchema,cPropertyPath))
                                        if (self:lFastMode)
                                            break
                                        endif
                                    endif
                                else
                                    if (hb_HHasKey(hPropertySchema,"items"))
                                        hItemsSchema:=hPropertySchema
                                    elseif (hb_HHasKey(hProperties[cProperty],"items"))
                                        hItemsSchema:=hProperties[cProperty]
                                    else
                                        hItemsSchema:={=>}
                                    endif
                                    if (hb_HHasKey(hItemsSchema,"items"))
                                        if (!self:CheckArrayItems(xData[cProperty],hItemsSchema,cPropertyPath))
                                            if (self:lFastMode)
                                                break
                                            endif
                                        endif
                                    endif
                                endif
                                exit
                            case "string"
                                if (!self:CheckString(xData[cProperty],hPropertySchema,cPropertyPath))
                                    if (self:lFastMode)
                                        break
                                    endif
                                endif
                                exit
                            case "object"
                                if (!self:ValidateObject(xData[cProperty],hPropertySchema,cPropertyPath))
                                    if (self:lFastMode)
                                        break
                                    endif
                                endif
                                exit
                            case "integer"
                            case "number"
                                if (!self:CheckNumber(xData[cProperty],hPropertySchema,cPropertyPath))
                                    if (self:lFastMode)
                                        break
                                    endif
                                endif
                                exit
                        end switch
                    endif
                endif
                if (hb_HHasKey(hPropertySchema,"format"))
                    if (!self:CheckFormat(xData[cProperty],hPropertySchema["format"],cPropertyPath))
                        if (self:lFastMode)
                            break
                        endif
                    endif
                endif
            endif
        next each //cProperty

    end sequence

    self:lHasError:=(!Empty(self:aErrors))

    return(!self:lHasError)

method RegexMatch(cString as character,cPattern as character,lOnlyCompile as logical) class JSONSchemaValidator

    local aMatch as array

    local lMatch as logical
    local lRegexComp as logical

    local pRegex as pointer

    if (hb_HHasKey(self:hRegexMatch,cPattern))
        pRegex:=self:hRegexMatch[cPattern]
        lRegexComp:=.T.
    else
        pRegex:=hb_regexComp(cPattern,.T./* case-sensitive */,.F./* no multiline */)
        lRegexComp:=(!Empty(pRegex))
        if (lRegexComp)
            self:hRegexMatch[cPattern]:=pRegex
        endif
    endif

    if (lRegexComp)
        aMatch:=hb_regex(pRegex,cString,.T./* case-sensitive */)
    endif

    lMatch:=if(lOnlyCompile,lRegexComp,(!Empty(aMatch)))

    return(lMatch)

method ResolveRef(cRef as character,cNode as character) class JSONSchemaValidator
    local hRefSchema as hash
    if (Left(cRef,1)=="#")
        hRefSchema:=self:ResolveInternalRef(cRef,cNode)
    else
        hRefSchema:=self:ResolveExternalRef(cRef,cNode)
    endif
    return(hRefSchema)

method ResolveInternalRef(cRef as character,cNode as character) class JSONSchemaValidator

    local aKeys as array

    local cKey as character
    local cFullKey as character

    local hRefSchema as hash

    if (hb_HHasKey(self:hRefSchema,cRef))
        hRefSchema:=self:hRefSchema[cRef]
    else
        if (cRef=="#")
            hRefSchema:=hb_HMerge({=>},self:hSchema)
        else
            aKeys:=hb_ATokens(cRef,"/")
            cFullKey:=""
            for each cKey in aKeys
                if (cKey:__enumIndex()==1)//#
                    loop
                endif
                cFullKey+="["
                cFullKey+=hb_JSONEncode(cKey)
                cFullKey+="]"
            next each
            begin sequence
                if (!Empty(cFullKey))
                    private m__hRefSchema as hash
                    M->m__hRefSchema:=hb_HMerge({=>},self:hSchema)
                    M->m__hRefSchema:=&("M->m__hRefSchema"+cFullKey)
                    hRefSchema:=hb_HMerge({=>},M->m__hRefSchema)
                else
                    hRefSchema:=hb_HMerge({=>},self:hSchema)
                endif
            recover
                hRefSchema:={=>}
                self:AddError("Invalid JSON $Ref Schema provided at "+cNode+". $Ref:"+cRef)
            end sequence
        endif
        self:hRefSchema[cRef]:=hRefSchema
    endif

    return(hRefSchema)

method ResolveExternalRef(cRef as character,cNode as character) class JSONSchemaValidator

    local cBaseURL as character
    local cErrorMsg as character
    local cJSONSchema as character

    local hRefSchema as hash := {=>}

    local oTURL as object

    if (hb_HHasKey(self:hSchema,"$id"))
        cBaseURL:=self:hSchema["$id"]
        cBaseURL+=cRef
    else
        cBaseURL:=cRef
    endif

    begin sequence

        if (hb_HHasKey(self:hRefSchema,cBaseURL))
            hRefSchema:=self:hRefSchema[cBaseURL]
            break
        endif

        oTURL:=TUrl():New(cBaseURL)

        switch Lower(oTURL:cProto)
            case "http"
            case "https"
                if (!__GetJSONSchemaByHTTP(oTURL,cNode,cRef,@cJSONSchema,@cErrorMsg))
                    self:AddError(cErrorMsg)
                    break
                endif
                exit
            otherwise
                if (!__GetJSONSchemaByFile(cBaseURL,cNode,cRef,@cJSONSchema,@cErrorMsg))
                    self:AddError(cErrorMsg)
                    break
                endif
        end switch

        if ((hb_JSONDecode(cJSONSchema,@hRefSchema)==0).or.(!hb_IsHash(hRefSchema)))
            self:AddError("Invalid JSON $Ref Schema provided at "+cNode+". $Ref:"+cRef+" Failed to fetch external schema from "+cRef)
            break
        endif

        self:hRefSchema[cBaseURL]:=hRefSchema

    end sequence

    return(hRefSchema)

static function __GetJSONSchemaByHTTP(oTURL as object,cNode,cRef,/*@*/cJSONSchema as character,/*@*/cErrorMsg)

    local cLastErrorMessage as character

    local lGetJSONSchemaByHTTP as logical

    begin sequence

        lGetJSONSchemaByHTTP:=__cURLGet(oTURL:cAddress,@cJSONSchema,@cLastErrorMessage)

        if (!lGetJSONSchemaByHTTP)
            cErrorMsg:="Invalid JSON $Ref Schema provided at "+cNode+". $Ref:"+cRef+" Failed to fetch external schema from " + cRef+" "+cLastErrorMessage
            break
        endif

        lGetJSONSchemaByHTTP:=(!Empty(cJSONSchema))
        if (!lGetJSONSchemaByHTTP)
            cErrorMsg:="Invalid JSON $Ref Schema provided at "+cNode+". $Ref:"+cRef+" Failed to fetch external schema from "+cRef
            break
        endif

    end sequence

    return(lGetJSONSchemaByHTTP)

static function __cURLGet(cURL as character,cJSONSchema as character,/*@*/cErrorMsg)

    local aHeader as array

    local lcURLGet as logical

    local nError as numeric
    local nHTTPCode as numeric

    local phcUrl as pointer

    curl_global_init()

        begin sequence

            lcURLGet:=(!Empty(phcUrl:=curl_easy_init()))
            if (!lcURLGet)
                cErrorMsg:="cURL Error"
                break
            endif

            begin sequence

                aHeader:=Array(0)
                aAdd(aHeader,"Content-Type: application/json;charset=utf-8")
                /*TODO
                aAdd(aHeader,"Accept-Encoding: gzip,deflate")
                aAdd(aHeader,"Content-Encoding: gzip")
                */

                curl_easy_setopt(phcUrl,HB_CURLOPT_HTTPHEADER,aHeader)
                curl_easy_setopt(phcUrl,HB_CURLOPT_URL,cURL)
                curl_easy_setopt(phcUrl,HB_CURLOPT_FOLLOWLOCATION,.T.)
                curl_easy_setopt(phcUrl,HB_CURLOPT_SSL_VERIFYPEER,.F.)
                curl_easy_setopt(phcUrl,HB_CURLOPT_SSL_VERIFYHOST,.F.)
                curl_easy_setopt(phcUrl,HB_CURLOPT_NOPROGRESS,.T.)
                curl_easy_setopt(phcUrl,HB_CURLOPT_VERBOSE,.F.)
                curl_easy_setopt(phcUrl,HB_CURLOPT_DL_BUFF_SETUP)

                //Sending the request and getting the response
                lcURLGet:=((nError:=curl_easy_perform(phcUrl))==HB_CURLE_OK)
                if (!lcURLGet)
                    cErrorMsg:="cURL Error code: "+hb_NToC(nError)
                    break
                endif

                nHTTPCode:=curl_easy_getinfo(phcUrl,HB_CURLINFO_RESPONSE_CODE,@nError)

                lcURLGet:=(nError==HB_CURLE_OK)
                if (!lcURLGet)
                    cErrorMsg:="cURL Error code: "+hb_NToC(nError)
                    break
                endif

                lcURLGet:=((nHTTPCode>=200).and.(nHTTPCode<=299))
                if (!lcURLGet)
                    cErrorMsg:="cURL HTTP Error code: "+hb_NToC(nHTTPCode)
                endif

                cJSONSchema:=hb_ZUncompress(curl_easy_dl_buff_get(phcUrl))
                if (empty(cJSONSchema))
                    cJSONSchema:=curl_easy_dl_buff_get(phcUrl)
                endif

            end sequence

            curl_easy_cleanup(phcUrl)

        end sequence

    curl_global_cleanup()

    return(lcURLGet)

static function __GetJSONSchemaByFile(cFilePath as character,cNode as character,cRef,/*@*/cJSONSchema,/*@*/cErrorMsg)

    local lGetJSONSchemaByFile as logical

    begin sequence
        lGetJSONSchemaByFile:=hb_FileExists(cFilePath)
        if (!lGetJSONSchemaByFile)
            cErrorMsg:="Invalid JSON $Ref Schema provided at "+cNode+". $Ref:"+cRef+". Schema file not found: "+cFilePath
            break
        endif
        cJSONSchema:=hb_MemoRead(cFilePath)
    end sequence

    return(lGetJSONSchemaByFile)

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

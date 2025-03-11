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
static function getTst13(cSchema as character)

    local aTests as array

    local cData as character

    local lExpected as logical

    cSchema:=getJSONSchemaTst13()

    cData:=getJSONDataTst13()

    lExpected:=((!Empty(cSchema)).and.(!Empty(cData)))

    // Array of test cases following the schema
    aTests:={;
         {if(lExpected,"Valid","Invalid")+" Case: External Full object schema with required and optional properties.",cData,lExpected};
    }

    return(aTests)

static function getJSONSchemaTst13(/*@*/cErrorMsg as character)

    local cURL as character:="http://json-schema.org/draft-04/schema#"
    local cPath as character,cName as character, cExt as character, cDrive as character
    local cHB_PS as character:=hb_ps()
    local cFilePath as character
    local cJSONSchema as character

    local hJSONSchema as hash

    local lIsDir as logical

    hb_FNameSplit(hb_DirBase(),@cPath,@cName,@cExt,@cDrive)

    cPath+=if(Right(cPath,1)==cHB_PS,"",cHB_PS)
    cPath+="json-schema"
    cPath+=cHB_PS

    cName:=hb_FNameName(hb_ProgName()+"_"+Lower(ProcName()))
    cName+="_schema"

    cExt:=".json"

    cFilePath:=hb_FNameMerge(cPath,cName,cExt)

    hb_FNameSplit(cPath,@cPath)

    lIsDir:=hb_DirExists(cPath)
    if (!lIsDir)
        lIsDir:=(hb_DirCreate(cPath)==0)
    endif

    if (!hb_FileExists(cFilePath))
        __cURLGetTst13(cURL,@cJSONSchema,@cErrorMsg)
        if (lIsDir)
            hb_JSONDecode(cJSONSchema,@hJSONSchema)
            if (hb_HHasKey(hJSONSchema,"definitions"))
                hb_MemoWrit(strTran(cFilePath,cName,cName+"_definitions"),hb_JSONEncode({"definitions" => hJSONSchema["definitions"]},.T.))
                hb_HDel(hJSONSchema,"definitions")
                cJSONSchema:=hb_JSONEncode(hJSONSchema,.T.)
            endif
            cJSONSchema:=hb_StrReplace(cJSONSchema,;
                {;
                     "http://json-schema.org/draft-04/schema#" => "json-schema";
                    ,"#/definitions/positiveIntegerDefault0" => cName+"_definitions.json#/definitions/positiveIntegerDefault0";
                    ,"#/definitions/positiveInteger" => cName+"_definitions.json#/definitions/positiveInteger";
                    ,"#/definitions/stringArray" => cName+"_definitions.json#/definitions/stringArray";
                    ,"#/definitions/schemaArray" => cName+"_definitions.json#/definitions/schemaArray";
                    ,"#/definitions/simpleTypes" => cName+"_definitions.json#/definitions/simpleTypes";
                };
            )
            cJSONSchema:=cJSONSchema:=hb_StrReplace(cJSONSchema,{'"id": "json-schema"' => '"$id": "json-schema"'})
            hb_MemoWrit(cFilePath,cJSONSchema)
        endif
    else
        cJSONSchema:=hb_MemoRead(cFilePath)
    endif

    return(cJSONSchema)

static function getJSONDataTst13(/*@*/cErrorMsg as character)

    local cURL as character:="https://standard.open-contracting.org/schema/1__1__5/release-schema.json"
    local cPath as character,cName as character, cExt as character, cDrive as character
    local cHB_PS as character:=hb_ps()
    local cFilePath as character
    local cJSONData as character

    local lIsDir as logical

    hb_FNameSplit(hb_DirBase(),@cPath,@cName,@cExt,@cDrive)

    cPath+=if(Right(cPath,1)==cHB_PS,"",cHB_PS)
    cPath+="json-data"
    cPath+=cHB_PS

    cName:=hb_FNameName(hb_ProgName()+"_"+ProcName())
    cName+="_data"

    cExt:=".json"

    cFilePath:=hb_FNameMerge(cPath,cName,cExt)

    lIsDir:=hb_DirExists(cPath)
    if (!lIsDir)
        lIsDir:=(hb_DirCreate(cPath)==0)
    endif

    if (!hb_FileExists(cFilePath))
        __cURLGetTst13(cURL,@cJSONData,@cErrorMsg)
        if (lIsDir)
            hb_MemoWrit(cFilePath,cJSONData)
        endif
    else
        cJSONData:=hb_MemoRead(cFilePath)
    endif

    return(cJSONData)

static function __cURLGetTst13(cURL as character,cResponse as character,/*@*/cErrorMsg)

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
                aAdd(aHeader,"Accept-Encoding: gzip,deflate")
                aAdd(aHeader,"Content-Encoding: gzip")

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

                cResponse:=hb_ZUncompress(curl_easy_dl_buff_get(phcUrl))
                if (empty(cResponse))
                    cResponse:=curl_easy_dl_buff_get(phcUrl)
                endif

            end sequence

            curl_easy_cleanup(phcUrl)

        end sequence

    curl_global_cleanup()

    return(lcURLGet)

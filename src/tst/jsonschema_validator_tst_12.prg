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
static function getTst12(cSchema as character)

    local aTests as array

    local cData as character

    local lExpected as logical

    cSchema:=getJSONSchemaTst12()

    cData:=getJSONDataTst12()

    lExpected:=((!Empty(cSchema)).and.(!Empty(cData)))

    // Array of test cases following the schema
    aTests:={;
         {if(lExpected,"Valid","Invalid")+" Case: Full object schema with required and optional properties.",cData,lExpected};
    }

    return(aTests)

static function getJSONSchemaTst12(/*@*/cErrorMsg as character)

    local cURL as character:="http://json-schema.org/draft-04/schema#"
    local cJSONSchema as character

    __cURLGetTst12(cURL,@cJSONSchema,@cErrorMsg)

    return(cJSONSchema)

static function getJSONDataTst12(/*@*/cErrorMsg as character)

    local cURL as character:="https://standard.open-contracting.org/schema/1__1__5/release-schema.json"
    local cJSONData as character

    __cURLGetTst12(cURL,@cJSONData,@cErrorMsg)

    return(cJSONData)

static function __cURLGetTst12(cURL as character,cResponse as character,/*@*/cErrorMsg)

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

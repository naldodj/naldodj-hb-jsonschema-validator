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
static function getTst01()

    local aTests as array

    cFunName:=ProcName()

    // JSON Schema example
    #pragma __cstream|M->cSchema:=%s
{
    "type": "object",
    "required": [
        "name",
        "age",
        "tags",
        "salary"
    ],
    "properties": {
        "name": {
            "type": "string",
            "minLength": 3,
            "maxLength": 80,
            "pattern": "^(?=.* )[A-Z]+(?: [A-Z]+)*$"
        },
        "age": {
            "type": "integer",
            "exclusiveMinimum": 0,
            "exclusiveMaximum": 150
        },
        "salary": {
            "type": "number",
            "minimum": 1500.00,
            "maximum": 120000.00,
            "multipleOf": 10
        },
        "address": {
            "type": "object",
            "properties": {
                "city": {
                    "type": "string"
                },
                "zip": {
                    "type": "string",
                    "pattern": "^[0-9]{5}-[0-9]{3}$"
                }
            }
        },
        "tags": {
            "description": "Tags for the product",
            "type": "array",
            "items": {
                "type": "string"
            },
            "minItems": 1,
            "maxItems": 10,
            "contains": {
                "type": "string",
                "pattern": "^product-"
            },
            "minContains": 1,
            "maxContains": 3,
            "uniqueItems": true
        },
        "email": {
            "type":"string",
            "format": "email"
        }
    }
}
    #pragma __endtext

    // Array of test cases: {description, JSON data, expected validity}
    aTests:={;
        {;//1
             "=> Valid case: All fields are correct";
            ,'{"name": "JOHN B","age": 30,"salary": 15000,"tags": ["product-123"],"address": {"city": "New York","zip": "12345-678"},"email":"teste@teste.com"}';
            ,.T.;
        };
       ,{;//2
             "=> Invalid case: Missing required fields: 'name' and 'salary'";
            ,'{"age": 25,"tags": ["test"]}';
            ,.F.;
        };
       ,{;//3
             "=> Invalid case: Incorrect type for 'age'";
            ,'{"name": "ALICE k","age": "thirty","salary": 1501.054,"tags": ["demo"]}';
            ,.F.;
        };
       ,{;//4
             "=> Invalid case: Incorrect item type in 'tags'";
            ,'{"name": "BOB D","age": 40,"salary": 15000,"tags": ["tag1",123]}';
            ,.F.;
        };
       ,{;//5
             "=> Invalid case: 'tags' contains fewer items than the minimum required";
            ,'{"name": "EVE T","age": 22,"salary": 15000,"tags": []}';
            ,.F.;
        };
       ,{;//6
             "=> Invalid case: 'tags' contains more items than the maximum allowed";
            ,'{"name": "FRANK M","age": 35,"salary": 15000,"tags": ["product-000","product-001","product-002","product-003","product-004","product-005","product-006","product-007","product-008","product-009","product-010"],"email":"@teste.com"}';
            ,.F.;
        };
       ,{;//7
             "=> Invalid case: 'zip' does not match the required pattern";
            ,'{"name": "GRACE K","age": 28,"salary": 15000,"tags": ["valid"],"address": {"city": "LA","zip": "1234-567"}}';
            ,.F.;
        };
       ,{;//8
             "=> Valid case: Minimal valid data";
            ,'{"name": "HANK D","age": 50,"salary": 15000,"tags": ["product-123"]}';
            ,.T.;
        };
       ,{;//9
             "=> Invalid case: 'address' has an incorrect type";
            ,'{"name": "IVY P","age": 33,"salary": 15000,"tags": ["test"],"address": "not an object"}';
            ,.F.;
        };
       ,{;//10
             "=> Valid case: At least one tag satisfies the 'contains' condition";
            ,'{"name": "JOHN W","age": 30,"salary": 15000,"tags": ["product-123","other"]}';
            ,.T.;
        };
       ,{;//11
             "=> Invalid case: No tag satisfies the 'contains' condition";
            ,'{"name": "ALICE S","age": 25,"salary": 15000,"tags": ["other","another"]}';
            ,.F.;
        };
       ,{;//12
             "=> Invalid case: Too many tags satisfy the 'contains' condition";
            ,'{"name": "BOB B","age": 40,"salary": 15000,"tags": ["product-1","product-2","product-3","product-4"]}';
            ,.F.;
        };
       ,{;//13
             "=> Valid case: Exactly two tags satisfy the 'contains' condition";
            ,'{"name": "EVE Z","age": 22,"salary": 15000,"tags": ["product-a","product-b","other"]}';
            ,.T.;
        };
       ,{;//14
             "=> Valid case: Unique tags";
            ,'{"name": "JOHN J","age": 30,"salary": 15000,"tags": ["product-123","other"]}';
            ,.T.;
        };
       ,{;//15
             "=> Invalid case: Duplicate tags found";
            ,'{"name": "ALICE A","age": 25,"salary": 15000,"tags": ["product-123","product-132","product-123","product-132","product-123"]}';
            ,.F.;
        };
       ,{;//16
             "=> Invalid case: 'salary' is below the minimum allowed";
            ,'{"name": "EVE K","age": 0,"salary": 0,"tags": ["product-000","product-001","product-002"]}';
            ,.F.;
        };
       ,{;//17
             "=> Invalid case: 'salary' is above the maximum allowed";
            ,'{"name": "FRANK T","age": 155,"salary": 999999,"tags": ["product-000","product-001","product-002"]}';
            ,.F.;
        };
       ,{;//18
             "=> Invalid case: 'name' exceeds the maximum length";
            ,'{"name": "PEDRO DE ALCÂNTARA JOÃO CARLOS LEOPOLDO SALVADOR BIBIANO FRANCISCO XAVIER DE PAULA LEOCÁDIO MIGUEL GABRIEL RAFAEL GONZAGA","age": '+hb_NToC(DateDiffYear(Date(),SToD("18251202")))+',"salary": 999999,"tags": ["product-000","product-001","product-002"],"email": "PEDRO DE ALCÂNTARA JOÃO CARLOS LEOPOLDO SALVADOR BIBIANO FRANCISCO XAVIER DE PAULA LEOCÁDIO MIGUEL GABRIEL RAFAEL GONZAGA"}';
            ,.F.;
        };
    }

    return(aTests)

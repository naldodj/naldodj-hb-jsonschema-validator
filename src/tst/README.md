# tests

### JSON Schema
```json
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
        }
    }
}
```
---
### Valid
[json_validator_tst](https://github.com/naldodj/naldodj-hb-json-validator/blob/main/src/tst/json_validator_tst.prg)
---
### Result
![image](https://github.com/user-attachments/assets/9643c30e-d585-45f7-bc4b-0a25d198a1f1)
---
### JSON Schema
```json
{
    "type": "object",
    "required": ["fruta", "numero", "opcao", "status"],
    "properties": {
        "fruta": {
            "type": "string",
            "enum": ["maçã", "banana", "cereja"]
        },
        "numero": {
            "type": "number",
            "enum": [1, 2, 3]
        },
        "opcao": {
            "type": "string",
            "enum": ["sim", "não"]
        },
        "status": {
            "type": ["string", "null"],
            "enum": [null, "ativo", "inativo"]
        }
    }
}
```
---
---
### Result
![image](https://github.com/user-attachments/assets/cb1c3d02-df28-4f05-979a-d1bf7094478b)

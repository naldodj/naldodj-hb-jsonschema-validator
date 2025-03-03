# TODO 📌

### Backlog 🕓

- [ ] Validações de Arrays: implementar as validações uniqueItems, contains, minContains, maxContains e prefixItems para alinhar o validador às especificações do JSON Schema.
- [x] Validações de Strings: Adicionar suporte para palavras-chave como pattern, minLength e maxLength para validar strings conforme os critérios definidos no schema.
- [x] Validações de Números: Implementar as palavras-chave minimum, maximum, exclusiveMinimum e exclusiveMaximum para assegurar que os valores numéricos estejam dentro dos limites especificados.
- [ ] Validações de Objetos: Incluir suporte para required, properties, patternProperties e additionalProperties para validar a estrutura e o conteúdo de objetos JSON.
- [ ] Suporte a Referências ($ref): Implementar a resolução de referências para permitir a reutilização de schemas e a validação de estruturas mais complexas.
- [ ] Mensagens de Erro Detalhadas: Melhorar as mensagens de erro para fornecer feedback mais claro e específico sobre falhas de validação.
- [ ] Testes Abrangentes: Desenvolver uma suíte de testes abrangente para garantir a precisão e a robustez do validador em diversos cenários
- [ ] **Suporte a Referências (`$ref`):** Implementar a resolução de referências para permitir a reutilização de schemas e a validação de estruturas mais complexas.
- [ ] **Validações de Objetos:** Incluir suporte para `patternProperties` e `additionalProperties` para validar a estrutura e o conteúdo de objetos JSON.
- [ ] **Combinações Lógicas:** Implementar as palavras-chave `allOf`, `anyOf` e `oneOf` para validações condicionais.
- [ ] **Suporte a Definições (`$defs`):** Adicionar suporte para o uso de definições reutilizáveis dentro dos schemas.

### In Progress ⏳

- [ ] "type": ["array"](https://json-schema.org/understanding-json-schema/reference/array)
    - [x] "items"
    - [x] "tupleValidation"
        - [x] "prefixItems"
        - [x] "items"
    - [ ] "unevaluatedItems"
        - [ ] "items"
        - [ ] "prefixItems"
        - [ ] "contains"
    - [x] "contains"
        - [x] "minContains"
        - [x] "maxContains"
    - [x] "length"
        - [x] "minItems"
        - [x] "maxItems"
    - [x] "uniqueItems"
    - [ ] "allOf"
    - [ ] "anyOf"
    - [ ] "oneOf" 
    - [x] "prefixItems"
- [ ] "type": ["object"](https://json-schema.org/understanding-json-schema/reference/object)
- [ ] "type": ["boolean"](https://json-schema.org/understanding-json-schema/reference/boolean)
- [ ] "$ref"
- [ ] "$defs"

### Done ✔

- [x] "type": ["number"](https://json-schema.org/understanding-json-schema/reference/numeric)
    - [x] "range"
        - [x] x ≥ "minimum"
        - [x] x ≤ "maximum"
        - [x] x > "exclusiveMinimum"
        - [x] x < "exclusiveMaximum"
    - [x] "Multiples"
        - [x] "multipleOf"
    - [x] "types"
        - [x] "integer"
        - [x] "number"
- [x] "type": ["string"](https://json-schema.org/understanding-json-schema/reference/string)
    - [x] "Length"
        - [x] "minLength"
        - [x] "maxLength"
        - [x] "pattern"

# TODO

### Pendências

- [ ] Validações de Arrays: implementar as validações uniqueItems, contains, minContains, maxContains e prefixItems para alinhar o validador às especificações do JSON Schema.
- [ ] Validações de Strings: Adicionar suporte para palavras-chave como pattern, format, minLength e maxLength para validar strings conforme os critérios definidos no schema.
- [ ] Validações de Números: Implementar as palavras-chave minimum, maximum, exclusiveMinimum e exclusiveMaximum para assegurar que os valores numéricos estejam dentro dos limites especificados.
- [ ] Validações de Objetos: Incluir suporte para required, properties, patternProperties e additionalProperties para validar a estrutura e o conteúdo de objetos JSON.
- [ ] Suporte a Referências ($ref): Implementar a resolução de referências para permitir a reutilização de schemas e a validação de estruturas mais complexas.
- [ ] Mensagens de Erro Detalhadas: Melhorar as mensagens de erro para fornecer feedback mais claro e específico sobre falhas de validação.
- [ ] Testes Abrangentes: Desenvolver uma suíte de testes abrangente para garantir a precisão e a robustez do validador em diversos cenários

### In Progress

- [ ] "type": ["array"](https://json-schema.org/understanding-json-schema/reference/array)
    - [x] "uniqueItems"
    - [x] "minContains"
    - [x] "maxContains"
    - [ ] "tupleValidation"
- [ ] "type": ["string"](https://json-schema.org/understanding-json-schema/reference/string)
    - [ ] "Length"
        - [ ] "minLength"
        - [ ] "maxLength"

- [ ] "type": ["object"](https://json-schema.org/understanding-json-schema/reference/object)
- [ ] "type": ["boolean"](https://json-schema.org/understanding-json-schema/reference/boolean)

### Done ✓

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

# Harbour JSON Schema Validator

Este projeto é um validador de JSON Schema para a linguagem Harbour, permitindo que desenvolvedores validem dados JSON conforme esquemas definidos, garantindo a integridade e conformidade dos dados em aplicações Harbour.

![image](https://github.com/user-attachments/assets/552c954c-8e9a-48e9-afeb-0fd806742de6)

## Funcionalidades Atuais

- **Validação de Tipos Básicos:** Suporte para `string`, `number`, `integer`, `boolean`, `object`, `array` e `null`.
- **Validação de Strings:** Implementação das palavras-chave `minLength`, `maxLength` e `pattern`.
- **Validação de Números:** Suporte para `minimum`, `maximum`, `exclusiveMinimum`, `exclusiveMaximum` e `multipleOf`.
- **Validação de Arrays:** Implementação das palavras-chave `minItems`, `maxItems`, `uniqueItems`, `contains`, `minContains`, `maxContains`, `items` e `prefixItems`.
- **Validação de Objetos:** Suporte para `required`, `properties`, `dependencies`, `propertyNames`, `minProperties`, `maxProperties`
- **Validação de Enumerações:** Implementação da palavra-chave `enum`.
- **Validação de Formatos:** Implementação da palavra-chave `format` para validar formatos específicos, como `email`, `date-time`, `ipv4`, entre outros.
- **Resolução de Referências (`$ref`):** Capacidade de resolver referências internas e externas dentro dos schemas.
- **Mensagens de Erro Detalhadas:** Fornecimento de mensagens de erro claras e específicas sobre falhas de validação, incluindo o caminho completo do nó onde ocorreu a inconsistência, como "root.pessoa.idade", facilitando a identificação de problemas em dados complexos.

## Funcionalidades Planejadas

- **Suporte Completo para Combinações Lógicas:** Implementar as palavras-chave `allOf`, `anyOf` e `oneOf` para validações condicionais.
- **Suporte para `if`, `then` e `else`:** Permitir validações condicionais baseadas na estrutura dos dados.
- **Suporte para `patternProperties`, `additionalProperties` e `dependentRequired` para validar a estrutura e o conteúdo de objetos JSON.

## Instalação e Uso

1. **Pré-requisitos:** Certifique-se de ter o [Harbour](https://harbour.github.io/) instalado.
2. **Clone o Repositório:** `git clone https://github.com/naldodj/naldodj-hb-jsonschema-validator.git`
3. **Compile o Código:** Navegue até o diretório `src/core` e compile o arquivo `jsonschema_validator.prg` usando o compilador Harbour.
4. **Execute os Testes:** No diretório `src/tests`, compile e execute `jsonschema_validator_test.prg` para validar a funcionalidade do validador.

## Exemplo de Uso

```harbour
#include "hbclass.ch"
#include "jsonschema_validator.prg"

FUNCTION Main()
    LOCAL oValidator := JSONSchemaValidator():New('{ "type": "object", "properties": { "name": { "type": "string" }, "age": { "type": "number" } }, "required": ["name", "age"] }')
    LOCAL cJSONData := '{ "name": "John", "age": 30 }'

    IF oValidator:Validate(cJSONData)
        ? "JSON válido!"
    ELSE
        ? "JSON inválido:"
        AEVAL(oValidator:GetErros(), {|e| ? e })
    ENDIF

    RETURN
```


Este exemplo cria um esquema que requer um objeto com propriedades `name` (string) e `age` (número), ambas obrigatórias. Em seguida, valida um JSON conforme esse esquema.

## Testes

Os testes estão localizados no diretório `src/tests` e cobrem diversos cenários de validação, garantindo a robustez e a precisão do validador.

## Contribuições

Contribuições são bem-vindas! Sinta-se à vontade para abrir issues ou pull requests no [repositório GitHub](https://github.com/naldodj/naldodj-hb-jsonschema-validator).

## Licença

Este projeto está licenciado sob a [Apache-2.0](LICENSE).

---

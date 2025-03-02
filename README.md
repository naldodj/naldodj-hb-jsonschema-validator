# Harbour JSON Schema Validator

Este projeto é um validador de JSON Schema para a linguagem Harbour, permitindo que desenvolvedores validem dados JSON conforme esquemas definidos, garantindo a integridade e conformidade dos dados em aplicações Harbour.

## Funcionalidades Atuais

- **Validação de Tipos Básicos:** Suporte para `string`, `number`, `integer`, `boolean`, `object`, `array` e `null`.
- **Validação de Strings:** Implementação das palavras-chave `minLength`, `maxLength` e `pattern`.
- **Validação de Números:** Suporte para `minimum`, `maximum`, `exclusiveMinimum`, `exclusiveMaximum` e `multipleOf`.
- **Validação de Arrays:** Implementação das palavras-chave `minItems`, `maxItems`, `uniqueItems`, `contains`, `minContains` e `maxContains`.
- **Validação de Objetos:** Suporte para `required` e `properties`.
- **Mensagens de Erro Detalhadas:** Fornecimento de mensagens de erro claras e específicas sobre falhas de validação, incluindo o caminho completo do nó onde ocorreu a inconsistência, como "root.pessoa.idade", facilitando a identificação de problemas em dados complexos.

## Funcionalidades Planejadas

- **Suporte a Referências (`$ref`):** Implementar a resolução de referências para permitir a reutilização de schemas e a validação de estruturas mais complexas.
- **Validações Adicionais de Objetos:** Incluir suporte para `patternProperties` e `additionalProperties` para validar a estrutura e o conteúdo de objetos JSON.
- **Suporte Completo para Combinações Lógicas:** Implementar as palavras-chave `allOf`, `anyOf` e `oneOf` para validações condicionais.

## Instalação e Uso

1. **Pré-requisitos:** Certifique-se de ter o [Harbour](https://harbour.github.io/) instalado.
2. **Clone o Repositório:** `git clone https://github.com/naldodj/naldodj-hb-json-validator.git`
3. **Compile o Código:** Navegue até o diretório `src/core` e compile o arquivo `json_validator.prg` usando o compilador Harbour.
4. **Execute os Testes:** No diretório `src/tst`, compile e execute `json_validator_tst.prg` para validar a funcionalidade do validador.

## Exemplo de Uso

```harbour
#include "hbclass.ch"
#include "json_validator.prg"

FUNCTION Main()
    LOCAL oValidator := JSONValidator():New('{ "type": "object", "properties": { "name": { "type": "string" }, "age": { "type": "number" } }, "required": ["name", "age"] }')
    LOCAL cJSONData := '{ "name": "John", "age": 30 }'

    IF oValidator:Validate(cJSONData)
        ? "JSON válido!"
    ELSE
        ? "JSON inválido:"
        AEVAL(oValidator:aErrors, {|e| ? e })
    ENDIF
RETURN
```


Este exemplo cria um esquema que requer um objeto com propriedades `name` (string) e `age` (número), ambas obrigatórias. Em seguida, valida um JSON conforme esse esquema.

## Testes

Os testes estão localizados no diretório `src/tst` e cobrem diversos cenários de validação, garantindo a robustez e a precisão do validador.

## Contribuições

Contribuições são bem-vindas! Sinta-se à vontade para abrir issues ou pull requests no [repositório GitHub](https://github.com/naldodj/naldodj-hb-json-validator).

## Licença

Este projeto está licenciado sob a [Licença MIT](LICENSE).

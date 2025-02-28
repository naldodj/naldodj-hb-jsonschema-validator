# naldodj-hb-json-validator

- Este é um projeto inicial de validador JSON Schema para Harbour, com muitas funcionalidades ainda não implementadas, mas planejadas para incluir todas as previstas no [JSON Schema Overview](https://json-schema.org/overview/what-is-jsonschema).
- O texto ajustado para o README.md reflete que é uma versão inicial, com suporte básico para tipos, propriedades obrigatórias e rastreamento de erros, mas sem recursos avançados como padrões ou enums, que serão adicionados futuramente.
- Uma característica inesperada é o rastreamento de caminho nos erros, facilitando a depuração em estruturas aninhadas.

#### Introdução
Este projeto, chamado "Harbour JSON Schema Validator", é uma ferramenta para validar dados JSON contra esquemas em Harbour, uma linguagem usada em sistemas legados, especialmente no Brasil. É uma implementação inicial, com planos de expandir para cobrir todas as funcionalidades do JSON Schema com o tempo.

#### Funcionalidades Atuais
Atualmente, suporta:
- Verificação de tipos básicos (strings, números, booleanos, objetos, arrays, nulos).
- Validação de propriedades obrigatórias.
- Validação recursiva para objetos aninhados.
- Rastreamento de caminho nos erros, como "root.property.subproperty", o que ajuda na depuração.

#### Limitações e Planos Futuros
Muitas funcionalidades avançadas, como padrões (regex), enums e validações detalhadas de arrays, ainda não estão implementadas. No entanto, a equipe planeja adicionar todas as capacidades descritas no [JSON Schema Overview](https://json-schema.org/overview/what-is-jsonschema) em versões futuras, tornando-o mais completo.

---

### Nota Detalhada

#### Contexto e Objetivo
O projeto "naldodj-hb json-validator" é uma implementação de um validador JSON Schema para a linguagem Harbour, uma derivação de xBase usada em sistemas legados, especialmente em ERP no Brasil. A validação JSON é essencial para garantir que dados trocados entre sistemas sigam um formato esperado, e este validador utiliza o conceito de JSON Schema, um padrão para definir a estrutura de dados JSON, conforme descrito em [JSON Schema Overview](https://json-schema.org/overview/what-is-jsonschema). O objetivo é fornecer uma ferramenta inicial para desenvolvedores Harbour verificarem a conformidade de dados JSON com esquemas, com foco em aplicações que requerem validação básica, mas com planos de expansão para cobrir todas as funcionalidades previstas no JSON Schema.

#### Análise do Código e Funcionalidades
O código principal, localizado em `json_validator.prg`, define a classe `JSONValidator` com métodos como `New`, `SetSchema`, `Validate`, `CheckType`, `CheckRequired` e `ValidateObject`. Ele suporta:

- **Verificação de tipos básicos:** Strings, números, booleanos, objetos, arrays e nulos, usando o método `CheckType`.
- **Propriedades obrigatórias:** Verifica se todas as propriedades listadas como "required" no esquema estão presentes, via `CheckRequired`.
- **Validação recursiva:** Para objetos aninhados, usando `ValidateObject`, permitindo navegar por estruturas hierárquicas.
- **Rastreamento de erros:** Inclui o caminho completo do nó onde ocorreu a inconsistência, como "root.pessoa.idade", o que facilita a identificação de problemas em dados complexos.

No entanto, há limitações significativas na versão atual:
- Não suporta recursos avançados do JSON Schema, como padrões (patterns), enums, ou validações de formato (ex.: data, email).
- Arrays são verificados apenas quanto ao tipo, sem validação dos elementos internos, mesmo que o esquema tenha uma definição "items".

Uma característica inesperada e útil é o rastreamento de caminho nos erros, que não é sempre encontrado em validadores básicos, facilitando a depuração, especialmente em esquemas aninhados.

#### Instalação e Configuração
Para utilizar o validador, é necessário ter o Harbour instalado, disponível em [Harbour Project Website with JSON Library Information](https://harbour.github.io/). O validador usa a função `hb_jsonDecode`, parte da biblioteca padrão do Harbour, então não há necessidade de instalar bibliotecas adicionais. Para compilar e executar, siga estas etapas:

1. Baixe e instale o Harbour.
2. Inclua `json_validator.prg` no seu projeto.
3. Compile com o comando, por exemplo:  
   ```
   harbour seu_programa.prg -o seu_programa.exe
   ```
4. Execute o programa gerado.

#### Uso Prático e Exemplos
O uso é direto: crie uma instância da classe `JSONValidator` passando o esquema como string JSON, valide os dados com `Validate`, e verifique os erros em `aErrors`. Aqui estão exemplos práticos:

##### Exemplo de JSON Válido
```harbour
#include "hbclass.ch"
#include "json_validator.prg"

FUNCTION Main()
    LOCAL oValidator := JSONValidator():New('{ "type": "object", "properties": { "name": { "type": "string" }, "age": { "type": "number" } }, "required": ["name", "age"] }')
    LOCAL cJSONData := '{ "name": "John", "age": 30 }'

    IF oValidator:Validate(cJSONData)
        ? "JSON válido"
    ELSE
        ? "JSON inválido"
        AEval(oValidator:aErrors, {|x| ? x })
    ENDIF

RETURN NIL
```
Resultado esperado: "JSON válido", sem erros.

##### Exemplo de JSON Inválido
```harbour
#include "hbclass.ch"
#include "json_validator.prg"

FUNCTION Main()
    LOCAL oValidator := JSONValidator():New('{ "type": "object", "properties": { "name": { "type": "string" }, "age": { "type": "number" } }, "required": ["name", "age"] }')
    LOCAL cJSONData := '{ "name": 123, "age": "thirty" }'

    IF oValidator:Validate(cJSONData)
        ? "JSON válido"
    ELSE
        ? "JSON inválido"
        AEval(oValidator:aErrors, {|x| ? x })
    ENDIF

RETURN NIL
```
Resultado esperado: "JSON inválido", com erros como:
- "Invalid type for property: root.name Expected: string Assigned: number"
- "Invalid type for property: root.age Expected: number Assigned: string"

Essa funcionalidade de incluir o caminho nos erros é particularmente útil para depuração, especialmente em esquemas aninhados, e pode ser considerada uma característica inesperada para um validador básico.

#### Limitações e Considerações
Embora funcional para validações simples, o validador não cobre todos os recursos do JSON Schema, como descrito em [JSON Schema Overview and Explanation](https://json-schema.org/overview/what-is-jsonschema). Por exemplo, não suporta:
- Validação de padrões (regex) para strings.
- Enums para valores fixos.
- Validação detalhada de arrays, como itens específicos ou tuplas.

Isso o torna adequado para cenários onde apenas tipos básicos e propriedades obrigatórias são necessários, mas insuficiente para esquemas complexos. No entanto, como mencionado, é um projeto inicial, e a equipe planeja expandir para incluir todas as funcionalidades previstas no JSON Schema, como descrito em [JSON Schema Overview](https://json-schema.org/overview/what-is-jsonschema), em versões futuras.

#### Contribuição e Suporte
Contribuições são bem-vindas, e os usuários podem submeter problemas ou pull requests no GitHub. Para suporte, entre em contato com [naldodj](https://github.com/naldodj) via GitHub. A licença do projeto é MIT, conforme indicado, permitindo uso e modificação livre, com a obrigação de manter os créditos.

#### Tabela de Comparação de Recursos

| **Recurso**                  | **Suportado** | **Observação**                              |
|------------------------------|---------------|---------------------------------------------|
| Verificação de tipo básico   | Sim           | Strings, números, booleanos, objetos, arrays, nulos |
| Propriedades obrigatórias    | Sim           | Verifica presença via "required"            |
| Validação recursiva          | Sim           | Para objetos aninhados                      |
| Caminho nos erros            | Sim           | Inclui "root.property.subproperty"          |
| Padrões (regex)              | Não           | Não suportado, planejado para o futuro      |
| Enums                        | Não           | Não suportado, planejado para o futuro      |
| Validação de arrays          | Parcial       | Apenas tipo, sem itens internos, expansão planejada |

#### Conclusão
O "Harbour JSON Schema Validator" é uma ferramenta útil para validações básicas em projetos Harbour, com uma implementação eficiente e amigável. No entanto, sua cobertura limitada do JSON Schema deve ser considerada para projetos mais complexos, onde outros validadores, como o Ajv para JavaScript ([Ajv JSON schema validator for Advanced Features](https://ajv.js.org/)), podem ser mais apropriados. Para desenvolvedores Harbour, é uma solução prática, especialmente com a inclusão de caminhos nos erros, facilitando a depuração. Com o tempo, espera-se que o validador evolua para incluir todas as funcionalidades previstas no [JSON Schema Overview](https://json-schema.org/overview/what-is-jsonschema), tornando-se uma opção mais robusta.

#### Citações Chave
- [Harbour Project Website with JSON Library Information](https://harbour.github.io/)
- [JSON Schema Overview and Explanation](https://json-schema.org/overview/what-is-jsonschema)
- [Ajv JSON schema validator for Advanced Features](https://ajv.js.org/)

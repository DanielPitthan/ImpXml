# Rotina para importação de Arquivos XML (Nf-e), paraTOTVS-Protheus.
Essa rotina tem por objetivo realizar a importação de uma nota fiscal de consumidor compras, gerando pre-nota ou documento de entrada. A rotina foi idealizada para realizar uma validação no portal da SEFAZ, antes de que o usuário final consiga realmente importar o arquivo. O que garante que apenas notas fiscais legítimas válidas sejam importadas.

Durante processo a rotina realiza a vinculação com o pedido de compras e testa em qual empresa/filial deve ser feito a importação do arquivo XML.
* [Vídeo da Rotina](https://www.youtube.com/watch?v=eXXCPgPJH3Y&feature=youtu.be)

### Correção de Bugs e novas features (03/06/18)

* Validação de existencia a de arquivo
* Tratativa em caso de erro não derrubar mais o sistemas - ErrorBlock
* Validação juntoa Sefaz da NF-e
* Auto preechimento da TES utilizando a TES inteligente
*  Seleção da NF de origem
*  Auto cadastro de Produto Vs Fornecedor

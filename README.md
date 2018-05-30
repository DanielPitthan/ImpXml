# Rotina para importação de Arquivos XML (Nf-e), paraTOTVS-Protheu.
Essa rotina tem por objetivo realizar a importação de uma nota fiscal de consumidor campras, gerando pre-nota ou documento de entrada.
A rotina foi idealizada para realizar uma validação no portal da SEFAZ, antes de que o usuário final consiga realmente importar o arquivo. O que garante que apenas notas fiscais legítimas válidas sejam impotadas.

Durante  processo a rotina realiza a viculação com o pedido de compras e testa em qual empresa/filial deve ser feito a importação do arquivo XML.

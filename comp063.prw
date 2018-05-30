#Include 'Protheus.ch'
#Include 'Topconn.ch'


//#####################################################################
//+-------------------------------------------------------------------+
//|    			>>> Sanchez Cano Ltda / xixi xuxoxexmxs <<<           | 
//+-------------------------------------------------------------------+
//| Autor | Daniel Pitthan Silveira                   | Data |10/2016 |
//+-------------------------------------------------------------------+
//| Sobre | Rotina para realizar a importação de arquivos XML         | 
//|       | Gera Nota ou Prénota                                      |
//+-------------------------------------------------------------------+
//| Frase | Todo cuidado é pouco!                                     |
//+-------------------------------------------------------------------+ 
//#####################################################################
user function COMP063()

	Private cDrive	:=""
	Private cDir	:=""
	Private cNome	:=""
	Private cext	:=""
	Private aNfOri:={} //Array com as notas fiscais de origem
	Private cPath	:="C:\IMPXML\"
	Private cPathproc:= "C:\IMPXML\PROCESSADO"

	If !ExistDir(cPath)
		makeDir(cPath)
		makeDir(cPathproc)
	EndIf

	Private afiles
	afiles:= Directory(cPath+"*.xml")


	Private nOpc1		:=0
	Private nOpc2		:=GD_INSERT+GD_UPDATE+GD_DELETE
	
	Private cLinhaOk	:='AllwaysTrue()'
	Private cTudoOk		:='AllwaysTrue()'
	Private cIniCpos	:=''				//Campos com incremento automatico
	Private aAlter     	:={}				//Vetor com os campos que poderão ser alterados.
	Private aAlter2    	:={}				//Vetor com os campos que poderão ser alterados.
	Private nFreeze		:=0
	Private nMax		:=999999999			//Numero maximos de registros a serem exibidos
	Private cFieldOk	:='AllwaysTrue()'	//Validacao de campo
	Private cSuperDel	:=''				//Super Del
	Private cDelOk		:='AllwaysTrue()'	//Validacao da Exclusão da Linha
	
	Private aHe1		:={}
	Private aCo1		:={}
	Private aHe2		:={}
	Private aCo2		:={}
	Private nRecSD2		:=0
	private nbox1:=0
	
	Private oxml		:=nil
	Private chaveNfe	:=""
	Private motivo		:=""
	Private status  	:=""
	Private cnpjEmitente :=""
	Private nomeEmitente :=""
	Private numeroNF	 :=""
	Private serieNF	 	 :=""
	Private emissaoNf    :=""
	Private emissaoNf	 :=""
	Private naturezaOp	 :=""
	Private cnpjDestino  :=""
	Private nomeDestiono :=""
	Private vNF			 :=0
	Private vProd		 :=0
	Private VBC			 :=0
	Private VICMS:=0
	Private nVol	:=0
	Private nPesoB	:=0
	Private nPesoL	:=0
				
		
	//Tipos de NF-e	
	aOpcoes:={}
	aadd(aOpcoes,{"1","Devolução"})
	aadd(aOpcoes,{"2","Complementar"})
	aadd(aOpcoes,{"3","NF-e de ajuste"})
	aadd(aOpcoes,{"4","Devolução de mercadoria"})

				
	
	//Arquivos para processar
	aAdd(aHe1, {"Emp"  				,"TR_EMP"		,"@!"				,2,0,'.t.',,"C","",,,})
	aAdd(aHe1, {""  				,"TR_MARK"		,"@BMP"				,1,0,'.t.',,"L","",,,})
	aAdd(aHe1, {"Arquivo"  			,"TR_ARQUIVO"	,"@!"				,50,0,'.t.',,"C","",,,})
	aAdd(aHe1, {"Cliente" 			,"TR_CLI"		,"@!"				,50,0,'.t.',,"C","",,,})
	aAdd(aHe1, {"CNPJ" 				,"TR_CNPJ"		,"@!"				,14,0,'.t.',,"C","",,,})
	aAdd(aHe1, {"Nota" 				,"TR_NOTA"		,"@!"				,9,0,'.t.',,"C","",,,})
	aAdd(aHe1, {"Serie" 			,"TR_SERIE"		,"@!"				,3,0,'.t.',,"C","",,,})
	aAdd(aHe1, {"Emissao" 			,"TR_EMISS"		,"@D"				,10,0,'.t.',,"D","",,,})
	aAdd(aHe1, {"Total" 			,"TR_TOTAL"		,"@E 999,999,999.99"				,10,2,'.t.',,"N","",,,})
	aAdd(aHe1, {"Motivo" 			,"TR_MOT"		,"@!"				,44,0,'.t.',,"C","",,,})
	aAdd(aHe1, {"Chave NF-e" 		,"TR_CHNFE"		,"@!"				,44,0,'.t.',,"C","",,,})
	
	
	nUsado := Len(aHe1)
	
	//Guarda a posção do aHeader
	n0:= aScan(aHe1,{|x|  ALLTRIM(X[2])=="TR_EMP"		}) 
	n1:= aScan(aHe1,{|x|  ALLTRIM(X[2])=="TR_MARK"		})
	n2:= aScan(aHe1,{|x|  ALLTRIM(X[2])=="TR_ARQUIVO"	})
	n3:= aScan(aHe1,{|x|  ALLTRIM(X[2])=="TR_CLI"		})
	n4:= aScan(aHe1,{|x|  ALLTRIM(X[2])=="TR_CNPJ"		})
	n5:= aScan(aHe1,{|x|  ALLTRIM(X[2])=="TR_NOTA"		})
	n6:= aScan(aHe1,{|x|  ALLTRIM(X[2])=="TR_SERIE"		})
	n7:= aScan(aHe1,{|x|  ALLTRIM(X[2])=="TR_TOTAL"		})
	n8:= aScan(aHe1,{|x|  ALLTRIM(X[2])=="TR_CHNFE"		})
	n9:= aScan(aHe1,{|x|  ALLTRIM(X[2])=="TR_MOT"		})
	n10:= aScan(aHe1,{|x| ALLTRIM(X[2])=="TR_EMISS"     })
	
	//Carrega o acols de arquivos 
	For i:=1 to Len(aFiles)
		
		//Pre lê os arquivos pegando algumas informações 
		SplitPath (cPath+afiles[i][1], @cDrive,@cDir,@cNome, @cExt)
		
		
		oxml:=OPENXML():New(alltrim(cNome+cExt),cPath)
		oxml:=oxml:oxml //Reduzindo o tamanho da chave
		AADD(aco1,array(nUsado+1))
		
		//Testa se é um XML válido 
		If Type("oxml:_nfeproc")=="U"
			aco1[i][n1] :="BR_AZUL_OCEAN"
			aco1[i][n2] :=afiles[i][1]
			aco1[i][n3] :="Inválido"
			aco1[i][n4] :=""
			aco1[i][n5] :=""
			aco1[i][n6] :=""
			aco1[i][n7] :=""
			aco1[i][n8] :=""
			aco1[i][n9] :=""
			aco1[i][n10]:= CTOD("//")
			aco1[i][nUsado+1] :=.f.
		Else
	
			chaveNfe:= oxml:_nfeproc:_protnfe:_infprot:_chnfe:text //chave da Nfe
			motivo	:= oxml:_nfeproc:_protnfe:_infprot:_xmotivo:text //motivo da NFe - deve sempre vir autorizado
			
			//Tipo de NF-e <finNFe> 
//			1=NF-e normal;
//			2=NF-e complementar;
//			3=NF-e de ajuste;
//			4=Devolução de mercadoria.
			
			finNFe:= oxml:_nfeproc:_nfe:_infnfe:_ide:_finNFe:text

	
			cnpjEmitente := oxml:_nfeproc:_nfe:_infnfe:_emit:_cnpj:text 		//cnpj emitente
			nomeEmitente := oxml:_nfeproc:_nfe:_infnfe:_emit:_xnome:text 		//nome do emitente
			numeroNF	 := oxml:_nfeproc:_nfe:_infnfe:_ide:_cnf:text    		//Número da NF
			serieNF	 	 := oxml:_nfeproc:_nfe:_infnfe:_ide:_serie:text    		//Série da NF
			
			//Emissao da NF	
			//Normaliza a emissao para o protheus
			emissaoNf    := oxml:_nfeproc:_nfe:_infnfe:_ide:_dhemi:text
			emissaoNf:=left(emissaoNf,4)+substring(emissaoNf,6,2)+substring(emissaoNf,9,2)
			naturezaOp	 := oxml:_nfeproc:_nfe:_infnfe:_ide:_natop:text
		
			cnpjDestino  := oxml:_nfeproc:_nfe:_infnfe:_dest:_cnpj:text
			nomeDestiono := oxml:_nfeproc:_nfe:_infnfe:_dest:_xnome:text
			vNF			 := Val(oxml:_nfeproc:_nfe:_infnfe:_total:_icmstot:_vNf:text)
			
			
				aSM0Area:= SM0->(GetArea())
		
				DbSelectArea("SM0")
				Dbgotop()
				While !Eof()
					if SM0->M0_CGC==cnpjDestino
						aco1[i][n0]:=SM0->M0_CODIGO
						exit
					EndIf
					DbSkip()
				End
			
			RestArea(aSM0Area)
			
			aco1[i][n1] :="LBNO" //"OK_15"
			aco1[i][n2] :=afiles[i][1]
			aco1[i][n3] :=nomeEmitente
			aco1[i][n4] :=cnpjEmitente
			aco1[i][n5] :=numeroNF
			aco1[i][n6] :=serieNF
			aco1[i][n7] :=vNF
			aco1[i][n8] :=chaveNfe
			aco1[i][n9] :=motivo
			aco1[i][n10]:=stod(emissaoNf)
			aco1[i][nUsado+1] :=.f.
			
		EndIf
		
				

	Next
	
	
	
	
	//Monta o aHeader do preprocessamento 
	aAdd(aHe2, {""  						,"ZZZ_OK"			,"@BMP"								,01,0,'AllwaysTrue()',,"L","",,,})
	aAdd(aHe2, {"Prod Fornecedor"  			,"ZZZ_PRODF"		,"@!"								,15,0,'AllwaysTrue()',,"C","SA7",,,})
	aAdd(aHe2, {"Descri Cli"  				,"ZZZ_DESC"			,"@!"								,40,0,'AllwaysTrue()',,"C","",,,})
	aAdd(aHe2, {"Prod Fini"  				,"ZZZ_PRODC"		,"@!"  								,15,0,'AllwaysTrue()',,"C","SB1",,,})
	aAdd(aHe2, {"Descri Fini"  				,"ZZZ_DESCF"		,"@!"								,40,0,'AllwaysTrue()',,"C","",,,})
	aAdd(aHe2, {"Item"  					,"ZZZ_ITEM"			,"@!" 								,04,0,'AllwaysTrue()',,"C","",,,})
	aAdd(aHe2, {"Local"  					,"ZZZ_LOCAL"		,"@!"								,02,0,'AllwaysTrue()',,"C","",,,})
	aAdd(aHe2, {"Quantidade"  				,"ZZZ_QUANT"		,"@E 999,999,999.99"				,10,2,'AllwaysTrue()',,"N","",,,})
	aAdd(aHe2, {"Valor Unit"  				,"ZZZ_VALUNI"		,"@E 999,999,999.99"				,10,2,'AllwaysTrue()',,"N","",,,})
	aAdd(aHe2, {"Total"  					,"ZZZ_TOTAL"		,"@E 999,999,999.99"				,10,2,'AllwaysTrue()',,"N","",,,})
	aAdd(aHe2, {"NF Origem"  				,"ZZZ_NFORIG"		,"@!"								,09,0,'AllwaysTrue()',,"C","SF2",,,})
	aAdd(aHe2, {"Serie Origem"  			,"ZZZ_SERIEO"		,"@!"								,03,0,'U_COMP63V("I")',,"C","",,,})
	aAdd(aHe2, {"Item Origem"  				,"ZZZ_ITEMO"		,"@!"								,03,0,'AllwaysTrue()',,"C","",,,})
	aAdd(aHe2, {"Operacao" 					,"ZZZ_OPER"			,"@!"								,02,0,'U_COMP63V("O")',,"C","SFM",,,})
	aAdd(aHe2, {"TES"  						,"ZZZ_TES"			,"@!"								,03,0,'AllwaysTrue()',,"C","SF4",,,})

	AADD(aAlter2,"ZZZ_PRODC")
	AADD(aAlter2,"ZZZ_NFORIG")
	AADD(aAlter2,"ZZZ_SERIEO")
	AADD(aAlter2,"ZZZ_TES")
	AADD(aAlter2,"ZZZ_OPER")
		
	nUsado2:=Len(aHe2)
	
	//Guarda a posição do array
	
	nn1:= aScan(aHe2,{|x|  ALLTRIM(X[2])=="ZZZ_PRODF"}) 	//PRODUTO CLIENTE
	nn2:= aScan(aHe2,{|x|  ALLTRIM(X[2])=="ZZZ_PRODC"}) 	//PRODUTO FINI
	nn3:= aScan(aHe2,{|x|  ALLTRIM(X[2])=="ZZZ_ITEM"}) 		//Item 
	nn4:= aScan(aHe2,{|x|  ALLTRIM(X[2])=="ZZZ_LOCAL"}) 	//almoxarifado
	nn5:= aScan(aHe2,{|x|  ALLTRIM(X[2])=="ZZZ_QUANT"}) 	//Quantidade
	nn6:= aScan(aHe2,{|x|  ALLTRIM(X[2])=="ZZZ_VALUNI"}) 	//Valor Unitário
	nn7:= aScan(aHe2,{|x|  ALLTRIM(X[2])=="ZZZ_TOTAL"}) 	//Total
	nn8:= aScan(aHe2,{|x|  ALLTRIM(X[2])=="ZZZ_NFORIG"}) 	//Nota de Origem 
	nn9:= aScan(aHe2,{|x|  ALLTRIM(X[2])=="ZZZ_SERIEO"}) 	//Serie de Origem 
	nn10:=aScan(aHe2,{|x|  ALLTRIM(X[2])=="ZZZ_TES"}) 		//TES
	nn11:=aScan(aHe2,{|x|  ALLTRIM(X[2])=="ZZZ_OPER"}) 		//OPeração
	nn12:=aScan(aHe2,{|x|  ALLTRIM(X[2])=="ZZZ_OK"}) 		//OK 
	nn13:=aScan(aHe2,{|x|  ALLTRIM(X[2])=="ZZZ_DESC"}) 		//Descrição 
	nn14:=aScan(aHe2,{|x|  ALLTRIM(X[2])=="ZZZ_ITEMO"})	 	//Item Origem 
	nn15:=aScan(aHe2,{|x|  ALLTRIM(X[2])=="ZZZ_DESC"}) 		//descrição cliente
	nn16:=aScan(aHe2,{|x|  ALLTRIM(X[2])=="ZZZ_DESCF"}) 	//descrição Fini  

	AADD(aco2,array(nUsado2+1))
	aco2[1][nn12]:="BR_VERMELHO"
	aco2[1][nUsado2+1]:=.F.


	oDlg1      := MSDialog():New(174,273,811,1396,"XML para Pre-Nota",,,.F.,,,,,,.T.,,,.T. )
	oSay1      := TSay():New( 008,004,{||"Arquivos"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_HRED,CLR_WHITE,032,008)
	oBrw1      := MsNewGetDados():New(020,004,092,552,nOpc1,cLinhaOk,cTudoOk,cIniCpos,aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oDlg1,aHe1,aCo1 )
	//Ativa o duplo clique
	oBrw1:oBrowse:bLDblClick   :={|| ConsultaXml(oBrw1, oBrw1:nat) }

	oGrp1      := TGroup():New(100,004,300,552,"Arquivo XML selecionado",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	
	oSay2      := TSay():New( 112,008,{||"Fornecedor:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	//oCBox1     := TComboBox():New( 108,480,,aOpcoes,056,010,oGrp1,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,, )
	
	
	oSay2t      := TSay():New( 108,480,{|| "" },oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	
	
	oSay2      := TSay():New( 112,008,{||"Fornecedor:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oSay3      := TSay():New( 112,368,{||"CNPJ:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oSay4      := TSay():New( 112,184,{||"Nota Fiscal:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oSay5      := TSay():New( 112,280,{||"Serie:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)

	oSay6      := TSay():New( 112,040,{||""},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,150,008) //Nome For
	oSay7      := TSay():New( 112,216,{||""},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,150,008) //nota
	oSay8      := TSay():New( 112,312,{||""},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,150,008) //serie
	oSay9      := TSay():New( 112,400,{||""},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,150,008) //cnpj

	oSay10     := TSay():New( 128,008,{||"Total:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oSay11     := TSay():New( 128,040,{||""},oGrp1,"@E 999,999,999.99",,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008) //total Vnf
	
	oSay12     := TSay():New( 128,280,{||"B. ICMS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oSay13     := TSay():New( 128,312,{||""},oGrp1,"@E 999,999,999.99",,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008) //B Icms
	
	oSay14     := TSay():New( 128,368,{||"Val. ICMS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oSay15     := TSay():New( 128,400,{||""},oGrp1,"@E 999,999,999.99",,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008) //Valor CIMS
	
	oSay16     := TSay():New( 128,184,{||"Total Prod.:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oSay17     := TSay():New( 128,216,{||""},oGrp1,"@E 999,999,999.99",,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008) //Total produto Vprod

	
	oBrw2      := MsNewGetDados():New(144,008,276,548,nOpc2,cLinhaOk,cTudoOk,cIniCpos,aAlter2,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oDlg1,aHe2,aCo2 )
	
	oSay1      := TSay():New( 280,008,{||"Peso Líquido:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oSay2      := TSay():New( 280,104,{||"Peso Bruto:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oSay3      := TSay():New( 280,188,{||"Volumes:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oSay4b      := TSay():New( 280,048,{||""},oGrp1,"@E 999,999,999.99",,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oSay5b      := TSay():New( 280,136,{||""},oGrp1,"@E 999,999,999.99",,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oSay6b      := TSay():New( 280,216,{||""},oGrp1,"@E 999,999,999.99",,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	
	
	
	oBtn1R      := TButton():New( 300,482,"Ações Relacionadas",oDlg1,{||},70,012,,,,.T.,,"",,,,.F. )
	
	//--
	//--  Cria o menu de Ações Relacionadas
	//--
	oMenuRelac :=TMenu():New(0,0,0,0,.T.)
	
	oPrenota 	:= TMenuItem():New(oDlg1,"Gerar Pre-Nota",,,,		{|| ImportaNF("PRE") },,,,,,,,,.T.) //Gerar Pre Nota Fiscal
	oNota		:= TMenuItem():New(oDlg1,"Gerar Nota",,,,			{|| ImportaNF("NF") },,,,,,,,,.T.) //Gerar Nota Fiscal
	oTES		:= TMenuItem():New(oDlg1,"Preenche TES" ,,,,			{|| GetTES()	  },,,,,,,,,.T.) //Preenche com Operação e TES 
	oSair		:= TMenuItem():New(oDlg1,"Sair",,,,					{|| oDlg1:End()   },,,,,,,,,.T.) //Sair
	
		
	
	oMenuRelac:Add(oPrenota)	//Gera Pre Nota Fiscal 
	oMenuRelac:Add(oNota)		//Gera Nota Fiscal
	oMenuRelac:Add(oTES)		//Preenche com Operação e TES 
	oMenuRelac:Add(oSair)	    //Sair 
	oBtn1R:SetPopupMenu(oMenuRelac)	

	
	
	oDlg1:Activate(,,,.T.)

Return



///#################################################
// Preenche a TES com base na operação 
///#################################################
Static Function GetTES()

	Private aOption	:= {}
	Private cPerg	:= "XMLtoPRE1"
	Private aret1	:= {}
	Private cTesInt := nil
	
	AADD(aOption,{1,"Código de Operação",Space(02),"@!",".T.","SFM",".T.",30,.T.})
	AADD(aOption,{9,"         OU         ",200,20,.T.})
	AADD(aOption,{1,"TES",Space(03),"@!",".T.","SF4",".T.",30,.T.})
						
	If !ParamBox(aOption,cPerg,@aRet1,,,.t.,,,,cPerg,.t.,.t.)
		return
	EndIf


	If !empty(aRet[1])	
		For i:=1 To Len(obrw2:acols)
			If !Empty(obrw2:acols[i][nn2])
			
			//+---------------------------------------------+
			//| Obtem a TES Inteligente                     | 
			//+---------------------------------------------+
				cTesInt := MaTesInt( 2,aRet1[1],SA1->A1_COD,SA1->A1_LOJA,"C",obrw2:acols[i][nn2],NIL)
			
				obrw2:acols[i][nn10]:=cTesInt
			
			EndIF
		Next
	EndIf
	
	If !empty(aRet[3])
		For i:=1 To Len(obrw2:acols)
			If !Empty(obrw2:acols[i][nn2])			
			
				obrw2:acols[i][nn10]:=aRet[3]
			
			EndIF
		Next
	EndIf
	
	obrw2:refresh()
Return

//########################################################
// Validacoes da Rotina
//########################################################
USER FUNCTION COMP63V(OP)

	If OP =="O" //TES Inteligente
		If Empty(obrw2:acols[obrw2:nat][nn2])
			Alert("Código do Produto não informado")
		EndIF
		
		
		Private op:= M->ZZZ_OPER//obrw2:acols[obrw2:nat][obrw2:obrowse:colpos]
		
		
		//+---------------------------------------------+
		//| Obtem a TES Inteligente                     | 
		//+---------------------------------------------+
		Private cTesInt := MaTesInt( 2,op,SA1->A1_COD,SA1->A1_LOJA,"C",obrw2:acols[obrw2:nat][nn2],NIL)
		
		obrw2:acols[obrw2:nat][nn10]:=cTesInt
		obrw2:refresh()
	EndIf
	
	If OP=='I' //NF DE oRIGEM
	
		DbSelectArea("SD2")
		DBSETORDER(3) //SD20103		D2_FILIAL, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_COD, D2_ITEM, R_E_C_N_O_, D_E_L_E_T_
		If DbSeek(xFilial("SD2")+oBrw2:acols[obrw2:nat][nn8]+M->ZZZ_SERIEO+SA1->A1_COD+SA1->A1_LOJA+oBrw2:acols[obrw2:nat][nn2])
			oBrw2:acols[obrw2:nat][nn14]:=SD2->D2_ITEM
		Else			
			Alert("NF de origem não encontrada")
			return(.T.)
		EndIf
		obrw2:Refresh()
	eNDiF
	
	

RETURN(.T.)


//#######################################################
//Atualiza getdados inferior 
//#######################################################
Static function ConsultaXml(obj,nAt)
	
	If obj:acols[nat][n0]<>cEmpant
		alert("Essa nota fiscal pertence a outra empresa >>> "+obj:acols[nat][n0])
		Return
	EndIf
	
	If obj:acols[nat][n1]=="BR_AZUL_OCEAN"
		Alert("XML com a estrutura inválida, não será possível processar.")
		Return
	EndIf
	
	For i:=1 to Len(obj:acols)
		obj:acols[i][n1]:="LBNO"
	Next
	
	obj:acols[nat][n1]:="OK_15"
	obj:Refresh()
	
	SplitPath (cpath+obj:acols[nat][n2], @cDrive,@cDir,@cNome, @cExt)
	
	Processa( {|| PreProcess(alltrim(cNome+cExt),cpath,obrw2)})
	
	
Return

//#######################################################
//Pre processa o arquivo 
//#######################################################
Static Function PreProcess(arquivo,caminho,obj)

Private aOrigens:={}


	If ApMsgYesNo("Tenta localizar a NF de Origem dos produtos?"+CRLF+"Essa operação poderá ser mais demorada","Atenção")
		lfazOrig:=.T.
	Else
		lfazOrig:=.F.
	Endif

	oxml:=OPENXML():New(arquivo,caminho)
	oxml:=oxml:oxml //Reduzindo o tamanho da chave

	chaveNfe:= oxml:_nfeproc:_protnfe:_infprot:_chnfe:text //chave da Nfe
	motivo	:= oxml:_nfeproc:_protnfe:_infprot:_xmotivo:text //motivo da NFe - deve sempre vir autorizado
	status  := oxml:_nfeproc:_protnfe:_infprot:_cstat:text //status do Motivo - deve sempre vir 100

	cnpjEmitente := oxml:_nfeproc:_nfe:_infnfe:_emit:_cnpj:text 		//cnpj emitente
	nomeEmitente := oxml:_nfeproc:_nfe:_infnfe:_emit:_xnome:text 	//nome do emitente
	numeroNF	 := oxml:_nfeproc:_nfe:_infnfe:_ide:_cnf:text    //Número da NF
	serieNF	 	 := oxml:_nfeproc:_nfe:_infnfe:_ide:_serie:text    //Série da NF
	emissaoNf    := oxml:_nfeproc:_nfe:_infnfe:_ide:_dhemi:text   //Emissao da NF
//Normaliza a emissao para o protheus
	emissaoNf:=left(emissaoNf,4)+substring(emissaoNf,6,2)+substring(emissaoNf,9,2)
	naturezaOp	 := oxml:_nfeproc:_nfe:_infnfe:_ide:_natop:text

	cnpjDestino  := oxml:_nfeproc:_nfe:_infnfe:_dest:_cnpj:text
	nomeDestiono := oxml:_nfeproc:_nfe:_infnfe:_dest:_xnome:text

	vNF			 := Val(oxml:_nfeproc:_nfe:_infnfe:_total:_icmstot:_vNf:text)
	vProd		 := Val(oxml:_nfeproc:_nfe:_infnfe:_total:_icmstot:_vProd:text)
	VBC			 := Val(oxml:_nfeproc:_nfe:_infnfe:_total:_icmstot:_VBc:text)
	VICMS		 := Val(oxml:_nfeproc:_nfe:_infnfe:_total:_icmstot:_VICMS:text)
	
	oSay2t:SetText(aScan(aOpcoes,{|x| x[1]==finNFe}))
	oSay2t:Refresh()
	
	
	If Type("oxml:_nfeproc:_nfe:_infnfe:_transp:_vol")<>"U"		
		If Type("oxml:_nfeproc:_nfe:_infnfe:_transp:_vol:_nvol:text")<>"U"
			nVol	:= Val(oxml:_nfeproc:_nfe:_infnfe:_transp:_vol:_nvol:text)
		Else
			If Type("oxml:_nfeproc:_nfe:_infnfe:_transp:_vol:_qVol:text")<>"U"
				nVol	:= Val(oxml:_nfeproc:_nfe:_infnfe:_transp:_vol:_qVol:text)
			EndIf		
		EndIf
		
		nPesoB	:= Val(oxml:_nfeproc:_nfe:_infnfe:_transp:_vol:_PESOB:text)
		nPesoL	:= Val(oxml:_nfeproc:_nfe:_infnfe:_transp:_vol:_PESOL:text)
	EndIf
	
	//itens da NFe
	itensNFE     := oxml:_nfeproc:_nfe:_infnfe:_det
	
	
	
	//Chaves das Notas fiscais de origem
	If Type("OXML:_NFEPROC:_NFE:_INFNFE:_IDE:_NFREF")<>"U"
		If Type("OXML:_NFEPROC:_NFE:_INFNFE:_IDE:_NFREF")=="A"  
			For i:=1 to len(OXML:_NFEPROC:_NFE:_INFNFE:_IDE:_NFREF)
				AADD(aOrigens,OXML:_NFEPROC:_NFE:_INFNFE:_IDE:_NFREF[i]:_refnfe:text) //Chaves das Notas fiscais de Origem 
			Next
		Else
			If Type("OXML:_NFEPROC:_NFE:_INFNFE:_IDE:_NFREF")=="O"
				AADD(aOrigens,OXML:_NFEPROC:_NFE:_INFNFE:_IDE:_NFREF:_refnfe:text)
			EndIf 
		EndIf
	EndIf
		
		
		
	If status<>"100"
		Alert("XMl inválido: "+motivo)
		Return
	EndIf



//--------------------PRIMEIRA PARTE ------------------------------//
//verificação de Integridade - Cadastro de Produtos Vs Cliente     //
//-----------------------------------------------------------------//

	//Posiciona no Cadastro do Cliente  
	DbSelectArea("SA1")
	DbSetOrder(3) //A2_FILIAL, A2_CGC, R_E_C_N_O_, D_E_L_E_T_
	If !DbSeek(xFilial("SA1")+cnpjEmitente)
		alert("CNPJ/Cliente não cadastrado "+cnpjEmitente+"/"+nomeEmitente)
		return
	EndIf
	
	oSay11:SetText((vNF))
	oSay17:SetText((vProd))
	oSay13:SetText((VBC))
	oSay15:SetText((VICMS))
	
	oSay11:CtrlRefresh()
	oSay17:CtrlRefresh()
	oSay13:CtrlRefresh()
	oSay15:CtrlRefresh()
	

	oSay6:SetText(SA1->A1_NOME)
	oSay9:SetText(SA1->A1_CGC)
	oSay7:SetText(numeroNF)
	oSay8:SetText(serieNF)
	
	oSay6:CtrlRefresh()
	oSay7:CtrlRefresh()
	oSay8:CtrlRefresh()
	oSay9:CtrlRefresh()

	oSay4b:SetText(nVol)
	oSay5b:SetText(nPesoB)
	oSay6b:SetText(nPesoL)


	Private labort:=.F.
	Private cPerg	:="XMLTOPREF"
	Private aOption	:={}
	Private cQuery3	:=""
	Private cCadastro  		:= "Cadastro de produto Vs fornecedor"
	Private aRet1		:={}

	aco2:={}
	
	zn:=Len(itensNFE)* Len(aOrigens)
	Reccount(Len(itensNFE)* Len(aOrigens))
	
	For i:=1 to Len(itensNFE)
		
		IncProc(strzero(i,8)+"/"+ strzero(zn,8))
		
		AADD(aco2,array(nUsado2+1))
		
				
		//PROCURA O CÓDIGO DO PRODUTO EM FORNECEDOR VS PRODUTO 
		//CODIGO DO PRODUTO DO FORNECER
		ProdutoFor  := itensNFE[i]:_prod:_cprod:text
		Descricao	:= itensNFE[i]:_prod:_XPROD:Text
		Quantidade  := Val(itensNFE[i]:_prod:_qcom:text)
		ValorUnit   := Val(itensNFE[i]:_prod:_vuncom:text)
		ValorTotal  := Val(itensNFE[i]:_prod:_vProd:text)
		
		cEan		:= itensNFE[i]:_prod:_cean:text
		cProdOur	:= ReadBar(cEan)
		
		aCo2[i][nn2]:=  cProdOur   //Produto Fini			
		aCo2[i][nn1]:=	ProdutoFor //produto Fornecedor
		aCo2[i][nn16]:= Posicione("SB1",1,xFilial("SB1")+cProdOur,"B1_DESC") //descrição produto Fini
				
		If Empty(cProdOur)			
			aCo2[i][nn12]:="BR_VERMELHO"
		Else
			aCo2[i][nn2]:=SA7->A7_PRODUTO
			aCo2[i][nn12]:="BR_VERDE"
		EndIf
		
		
		aCo2[i][nn13]:= Descricao
		aCo2[i][nn3]:= StrZero(i,tamSX3('D1_ITEM')[1]) //Item
		aCo2[i][nn4]:= GetMv("MV_CQ")
		aco2[i][nn5]:= Quantidade
		aco2[i][nn6]:= ValorUnit
		aco2[i][nn7]:= ValorTotal
		
		If lfazOrig
		
			 For nn:=1 to Len(aOrigens)
			 	
			 	IncProc(strzero(i+nn,8)+"/"+ strzero(zn,8))
			 
				 cquery:= ""
				 cQuery+=" SELECT DISTINCT D2_DOC,D2_SERIE,D2_ITEM " 
				 cQuery+=" FROM "+rETsQLNAME("SD2")+" "
				 cQuery+=" JOIN "+Retsqlname("SF2")+" ON F2_DOC=D2_DOC AND F2_SERIE=D2_SERIE AND F2_FILIAL=D2_FILIAL AND F2_CLIENT=D2_CLIENTE AND F2_LOJA=D2_LOJA "
				 cQuery+=" WHERE F2_CHVNFE='"+aOrigens[nn]+"' "
				 cQuery+=" AND D2_COD='"+cProdOur+"' "
				 IF SELECT("TORIG")>0
				 	TORIG->(DBCLOSEAREA())
				 ENDIF
				 
				 TCQUERY CQUERY NEW ALIAS "TORIG"
				 DBSELECTAREA("TORIG")
				 DBGOTOP()
				 
				 If !Eof()
					aco2[i][nn8]:= TORIG->D2_DOC    //NF Origem
					aco2[i][nn9]:= TORIG->D2_SERIE	//Serie Origem
					aco2[i][nn14]:= TORIG->D2_ITEM	//ITEM ORIGEM
					exit
				EndIf
				 
			 Next
		Else
			aco2[i][nn8]:= Space(09)  //NF Origem
			aco2[i][nn9]:= Space(03)	//Serie Origem
			aco2[i][nn14]:= Space(04)	//ITEM ORIGEM
		
		EndIf
		aco2[i][nn10]:= Space(03)	//TES
		aco2[i][nn11]:= Space(02)	//Operação
		
		aco2[i][nUsado2+1]:=.F.

	Next
	obj:acols:=aco2
	obj:Refresh()
Return



//##############################################################
//+------------------------------------------------------------+
//|                 >>> Sanchez Cano Ltda <<<                  |
//+------------------------------------------------------------+
//| data | 26/07/2016 | Autor | Daniel Pitthan Silveira        |
//+------------------------------------------------------------+
//| Le o código de barras e busca no cadastro de produto       |
//+------------------------------------------------------------+
//##############################################################
Static function ReadBar(cText)
local n:=0
Local aProds:={} 



 cText:= Alltrim(cText)

 cQuery:=" SELECT B1_COD FROM "+Retsqlname("SB1")+" WHERE  B1_COD='"+cText+"' OR  B1_CODBAR='"+cText+"' or B1_EAN13A='"+cText+"' or B1_EAN13B='"+cText+"' or B1_EAN13C='"+cText+"' AND LEFT(B1_COD,1)='1' "
 
 IF SELECT("TSB1")>0
 	TSB1->(DbCloseArea())
 EndIf
 
 TcQuery cQuery new Alias "TSB1"
 DbSelectArea("TSB1")
 DbGotop()
 
  If Eof() 	 
 	Return("")	
  EndIf
 
 While !Eof()
  	AADD(aProds,B1_COD)
 	DbSkip() 	
 End
 
 If Len(aProds)>1 
 	Return("")
 EndIf
 
Return(aProds[1])


//#######################################################
//     REALIZA A IMPORTACAO DOS XMLS 
//#######################################################
Static Function ImportaNF(cOP)


//-------------------------------------------------------
//-- Monta o cabeçalho
//-------------------------------------------------------
	private cTipo:=""
	If oCBox1:nat==1 //Devolução 
		cTipo:="D"
	EndIf
	If oCBox1:nat==2 //Normal 
		cTipo:="N"
	EndIf
	

	Private	aCab := {{"F1_FILIAL" , xFilial("SF1") 			,NIL},;
		{"F1_TIPO"   , cTipo                  				,NIL},;
		{"F1_FORMUL" , "N"                  				,NIL},;
		{"F1_DOC"    , PADL(ALLTRIM(numeroNF),9, "0")  		,NIL},;
		{"F1_SERIE"  , serieNF			       				,NIL},;
		{"F1_EMISSAO", STOD(emissaoNf)		    			,NIL},;
		{"F1_DTDIGIT", DATE()	          					,NIL},;
		{"F1_FORNECE", SA2->A2_COD          				,NIL},;
		{"F1_LOJA"   , SA2->A2_LOJA			 				,Nil},;
		{"F1_CHVNFE" , chaveNfe       						,NIL},;
		{"F1_ESPECIE", "SPED"               				,NIL},;
		{"F1_VOLUME1", nVol		               				,NIL},;
		{"F1_PESOL"	 , nPesoL               				,NIL},;
		{"F1_PBRUTO",  nPesoB               				,NIL}}

	Private aItem :={}

	For i:=1 to Len(obrw2:acols)
				
		If obrw2:acols[i][nUsado2+1]
			loop
		EndIf
				
				
		DbSelectArea("SA7")
		DbSetOrder(3)//A7_FILIAL, A7_CLIENTE, A7_LOJA, A7_CODCLI, R_E_C_N_O_, D_E_L_E_T_
		If !Empty(obrw2:acols[i][nn2])
			If !DbSeek(xFilial("SA7")+SA1->A1_COD+SA1->A1_LOJA+obrw2:acols[i][nn1])
				Begin Transaction
					RecLock("SA7",.T.)
					SA7->A7_PRODUTO		:=obrw2:acols[i][nn2]
					SA7->A7_CODCLI		:=obrw2:acols[i][nn1]
					SA7->A7_DESCCLI		:=obrw2:acols[i][nn15]
					SA7->A7_CLIENTE		:=SA1->A1_COD
					SA7->A7_LOJA		:=SA1->A1_LOJA
					MsUnlock()
				End Transaction
			EndIf
		EndIf
			
				//Posiciona no cadastro do produto 
		DbSelectArea("SB1")
		DbSetOrder(1) //Filial+Cod
		DbSeek(xFilial("SB1")+obrw2:acols[i][nn2])
		
		
		nItem := PADL(ALLTRIM(STR(I)),4,"0")		
	
		
		AAdd(aItem,{{"D1_FILIAL" ,xFilial("SD1")	       		,Nil},;
			{"D1_COD"    ,SB1->B1_COD       	           		,Nil},;
			{"D1_ITEM"   ,nItem						          	,Nil},;
			{"D1_QUANT"  ,obrw2:acols[i][nn5]                  	,Nil},;
			{"D1_LOCAL"  ,obrw2:acols[i][nn4]		           	,Nil},;
			{"D1_VUNIT"  ,obrw2:acols[i][nn6]                  	,Nil},;
			{"D1_TOTAL"  ,Round((obrw2:acols[i][nn7]),2)  		,Nil},;
			{"D1_NFORI"  ,obrw2:acols[i][nn8]					,Nil},;
			{"D1_SERIORI",obrw2:acols[i][nn9]					,Nil},;
			{"D1_ITEMORI",obrw2:acols[i][nn14]					,Nil}})
		
	Next


	lMsErroAuto := .F.
	If cOP=="PRE" //Pre nota	
		MATA140(aCab,aItem,3)
	EndIf

	If cOP=="NF" //Nota		
		MATA103(aCab,aItem,3)
	EndIf	
	
	If lMsErroAuto
		Mostraerro()		
	EndIf
	
Return


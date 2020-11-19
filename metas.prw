#Include 'Protheus.ch'
#include 'parmtype.ch'
#Include 'FWMVCDef.ch'
#INCLUDE "XMLXFUN.CH"
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'



user function META003()

	Local oBrowse := FwMBrowse():New()
	Local cFunBkp := FunName()
	Local cSql
	Local aFields
	Local dDataDe  := FirstDate(Date())
	Local dDataAt  := LastDate(Date())
	Local cLoja := '01'
	Local aPergs := {}
	Local aBrowse := {}
	Local aIndex := {}
	lOCAL oTable
	Private cTableNome
	Private cTableFilho
	Private cAlias := GetNextAlias()
	Private cFilho := GetNextAlias()
	Public dDataInicial
	Public dDataFinial
	Public CtipoV
	Public  nLoja1

	oTable:=FWTemporaryTable():New( cAlias, /*aFields*/)
	aFields := {}

	aAdd(aFields, {"TMP_LOJA", "C", 36, 0})
	aAdd(aFields, {"TMP_TIPO", "C", 10, 0})
	aAdd(aFields, {"TMP_DATA1", "D", 8, 0})
	aAdd(aFields, {"TMP_DATA2", "D", 8, 0})
	aAdd(aFields, {"TMP_VALOR", "N", 36, 0})
	//aAdd(aFields, {"TMP_CODIGO", "N", 36, 0})
	oTable:SetFields(aFields)


	oTable:AddIndex("01", {"TMP_DATA1","TMP_DATA2","TMP_LOJA"})
	oTable:Create()
	cTableNome := oTable:GetRealName()

	aAdd(aPergs, {1, "Data Inicial",  dDataDe,  "", ".T.", "", ".T.", 80,  .T.})
	aAdd(aPergs, {1, "Data Final", dDataAt,  "", ".T.", "", ".T.", 80,  .T.})
	//aAdd(aPergs, {2, "Loja", cLoja, {"01","02","03","04","05","06","07","15","19","20","21","22","23","24","29","30","33","34","36","45","48","98","49","99"},122, ".T.", .T.})
	aAdd(aPergs, {2, "Tipo", cLoja, {"Valor","Margem","Frete","Seguro","Garantia",DecodeUtf8("Serviço Express")},122, ".T.", .T.})

	If ParamBox(aPergs, "Informe os parâmetros")

		DO CASE
			CASE UPPER(MV_PAR03) = UPPER("Valor")
				cTipo :='V'
			CASE UPPER(MV_PAR03) =  UPPER("Margem")
				cTipo :='M'
			CASE UPPER(MV_PAR03) = UPPER("Frete")
				cTipo :='F'
			CASE UPPER(MV_PAR03) = UPPER("Seguro")'
				cTipo :='S'
			CASE UPPER(MV_PAR03) = UPPER("Garantia")
				cTipo :='G'
			CASE UPPER(MV_PAR03) = UPPER("Serviços Express")
				cTipo :='E'
			OTHERWISE
				cTipo := nil

		ENDCASE

		cSql:=  "SELECT min(ZZE_DATA) AS DATA_INICIAL, MAX(ZZE_DATA) AS DATA_FINAL ,SUM(ZZE_VALOR) as ZZE_VALOR  , ZZE_LOJA "
		cSql+=  "FROM ZZE030                                                      "
		cSql+=  " WHERE ZZE_TIPO ='"+cvaltochar(cTipo)+"'"
		cSql+=  " AND D_E_L_E_T_ <> '*'                                            "
		cSql+=  " AND ZZE_DATA BETWEEN " + DTOS(MV_PAR01) + " AND " + DTOS(MV_PAR02)
		cSql+= " group by ZZE_LOJA, ZZE_TIPO"
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cSql),'X98',.F.,.T.)


		DbGotop()
		while !Eof()
			RecLock( oTable:oStruct:cAlias, .T. )
			(oTable:oStruct:cAlias)->TMP_LOJA := X98->ZZE_LOJA
			(oTable:oStruct:cAlias)->TMP_TIPO := cvaltochar(cTipo)
			(oTable:oStruct:cAlias)->TMP_DATA1 :=STOD(X98->DATA_INICIAL)
			(oTable:oStruct:cAlias)->TMP_DATA2 :=STOD(X98->DATA_FINAL)
			(oTable:oStruct:cAlias)->TMP_VALOR :=X98->ZZE_VALOR
			//(oTable:oStruct:cAlias)->TMP_CODIGO :=
			(oTable:oStruct:cAlias)->(msUnlock())
			DbSelectArea('X98')
			dbSkip()
		enddo


		aAdd(aBrowse, {"Loja ", "TMP_LOJA", "C", 04,0,"@!"})
		aAdd(aBrowse, {"Valor ", "TMP_VALOR", "N", 10,0,"@E 9,999,999.99"})
		aAdd(aBrowse, {"Tipo ", "TMP_TIPO", "C", 50,0,"@!"})
		aAdd(aBrowse, {"Data Inicial ", "TMP_DATA1", "D", 08,0,"@D"})
		aAdd(aBrowse, {"Data Final ", "TMP_DATA2", "D", 08,0,"@D"})


		aAdd(aIndex,"TMP_LOJA")

		dDataInicial := MV_PAR01
		dDataFinial := MV_PAR02
		nLoja1 := MV_PAR03

	EndIf
	SetFunName("META003")
	SetFunName(cFunBkp)
	oBrowse:SetAlias(cAlias) //Selecionando o banco
	oBrowse:SetTemporary(.T.)
	oBrowse:SetQueryIndex(aIndex)
	oBrowse:SetFields(aBrowse)
	oBrowse:DisableDetails()
	oBrowse:SetDescription("Metas")
	oBrowse:SetCacheView(.F.)
	oBrowse:Activate()
	


return


Static Function MenuDef()
	Local aRot := {}
	//Local aRotina := FwMvcMenu("META003")

	//Adicionando opções
	ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.META003' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.META003' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'    ACTION  'VIEWDEF.META003'  OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.META003' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5

Return aRot



Static Function ModelDef()
	Local oModel := MPFormModel():New("XMVC02",,,,)
	Local oStTmp   := FWFormModelStruct():New()
	Local oStZZEFILHO := FWFormStruct(1, 'ZZE')
	//Local bVldPre  := {|| u_TesteMetaC()}
	Local bVldCom  := {|| u_adcPeriodo()(.F., .F., 'ZZE_DATA', 'ZZE_DATA_F', 'ZZE->ZZE_LOJA', 'ZZE_TIPO' , 'ZZE_VALOR')}





	oStTmp:AddTable(cAlias, {'TMP_LOJA', 'TMP_TIPO', 'TMP_DATA1', 'TMP_DATA2', 'TMP_VALOR'}, "Cabecalho ZZE")
	//oStZZEFILHO:AddTable(cFilho, {'TMF_LOJA', 'TMF_TIPO', 'TMF_DATA',  'TMF_VALOR'}, "Grid ZZE")
	oStTmp:AddField(;
		"Loja",;                                                                                  // [01]  C   Titulo do campo
		"Loja",;                                                                                  // [02]  C   ToolTip do campo
		"TMP_LOJA",;                                                                               // [03]  C   Id do Field
		"C",;                                                                                       // [04]  C   Tipo do campo
		2,;                                                                    // [05]  N   Tamanho do campo
		0,;                                                                                         // [06]  N   Decimal do campo
		Nil,;                                                                                       // [07]  B   Code-block de validação do campo
		Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
		{"01","02","03","04","05","06","07","15","19","20","21","22","23","24","29","30","33","34","36","45","48","98","49","99"},;                                                                                        // [09]  A   Lista de valores permitido do campo
		.T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
		nil,;   // [11]  B   Code-block de inicializacao do campo
		.T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
		.F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.F.)                                                                                        // [14]  L   Indica se o campo é virtual
	oStTmp:AddField(;
		"Data",;                                                                    // [01]  C   Titulo do campo
		"Data",;                                                                    // [02]  C   ToolTip do campo
		"TMP_DATA1",;                                                                  // [03]  C   Id do Field
		"D",;                                                                         // [04]  C   Tipo do campo
		8,;                                                      // [05]  N   Tamanho do campo
		Nil,;                                                                           // [06]  N   Decimal do campo
		Nil,;                                                                         // [07]  B   Code-block de validação do campo
		Nil,;                                                                         // [08]  B   Code-block de validação When do campo
		{},;                                                                          // [09]  A   Lista de valores permitido do campo
		.T.,;                                                                         // [10]  L   Indica se o campo tem preenchimento obrigatório
		nil,;    // [11]  B   Code-block de inicializacao do campo
		.T.,;                                                                         // [12]  L   Indica se trata-se de um campo chave
		.F.,;                                                                         // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.F.)                                                                          // [14]  L   Indica se o campo é virtual
	oStTmp:AddField(;
		"Tipo",;                                                                    // [01]  C   Titulo do campo
		"Tipo",;                                                                    // [02]  C   ToolTip do campo
		"TMP_TIPO",;                                                                  // [03]  C   Id do Field
		"C",;                                                                         // [04]  C   Tipo do campo
		25,;                                                      // [05]  N   Tamanho do campo
		Nil,;                                                                           // [06]  N   Decimal do campo
		Nil,;                                                                         // [07]  B   Code-block de validação do campo
		Nil,;                                                                         // [08]  B   Code-block de validação When do campo
		{"Valor","Margem","Frete","Seguro","Garantia",DecodeUtf8("Serviço Express")},;                                                                          // [09]  A   Lista de valores permitido do campo
		.T.,;                                                                         // [10]  L   Indica se o campo tem preenchimento obrigatório
		nil,;    // [11]  B   Code-block de inicializacao do campo
		.T.,;                                                                         // [12]  L   Indica se trata-se de um campo chave
		.F.,;                                                                         // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.F.)
	oStTmp:AddField(;
		"Valor",;                                                                    // [01]  C   Titulo do campo
		"Valor",;                                                                    // [02]  C   ToolTip do campo
		"TMP_VALOR",;                                                                  // [03]  C   Id do Field
		"N",;                                                                         // [04]  C   Tipo do campo
		100,;                                                      // [05]  N   Tamanho do campo
		Nil,;                                                                           // [06]  N   Decimal do campo
		Nil,;                                                                         // [07]  B   Code-block de validação do campo
		Nil,;                                                                         // [08]  B   Code-block de validação When do campo
		{},;                                                                          // [09]  A   Lista de valores permitido do campo
		.T.,;                                                                         // [10]  L   Indica se o campo tem preenchimento obrigatório
		nil,;    // [11]  B   Code-block de inicializacao do campo
		.F.,;                                                                         // [12]  L   Indica se trata-se de um campo chave
		.F.,;                                                                         // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.F.)
	oStTmp:AddField(;
		"Data Final ",;                                                                    // [01]  C   Titulo do campo
		"Data Final",;                                                                    // [02]  C   ToolTip do campo
		"TMP_DATA2",;                                                                  // [03]  C   Id do Field
		"D",;                                                                         // [04]  C   Tipo do campo
		8,;                                                      // [05]  N   Tamanho do campo
		Nil,;                                                                           // [06]  N   Decimal do campo
		Nil,;                                                                         // [07]  B   Code-block de validação do campo
		Nil,;                                                                         // [08]  B   Code-block de validação When do campo
		{},;                                                                          // [09]  A   Lista de valores permitido do campo
		.T.,;                                                                         // [10]  L   Indica se o campo tem preenchimento obrigatório
		nil,;    // [11]  B   Code-block de inicializacao do campo
		.T.,;                                                                         // [12]  L   Indica se trata-se de um campo chave
		.F.,;                                                                         // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.F.)

	oStTmp:SetProperty('TMP_TIPO', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, "'Valor'"))
	oModel := MPFormModel():New("zModel2M", , , bVldCom)
	oModel:AddFields("FORMCAB",/*cOwner*/,oStTmp)
	oModel:AddGrid('ZZEDETAIL','FORMCAB',oStZZEFILHO)
	oModel:SetRelation('ZZEDETAIL', {{'ZZE_LOJA', ALLTRIM(TMP_LOJA)},{"ZZE_TIPO", "'"+TMP_TIPO+"'"}}, ZZE->(IndexKey(1)))
	///setando filtro no grid
	oModel:GetModel('ZZEDETAIL'):SetLoadFilter(, "ZZE_DATA BETWEEN '"+DtoS(dDataInicial)+"' AND '" +DtoS(dDataFinial)+"' " )
	//ativando o filtro
	oModel:Activate()
	FWSaveRows(oModel)
	FWRestRows()
	///desativando para não ocorrer erro
	oModel:DeActivate()



	oModel:GetModel( 'ZZEDETAIL' ):SetNoInsertLine(.T.)
	oModel:GetModel( 'ZZEDETAIL' ):SetNoUpdateLine(.T.)

	oModel:GetModel('ZZEDETAIL'):SetOptional(.T.)
	oModel:SetDescription("Modelo de Dados do ZZE ")
	oModel:SetPrimaryKey({})
	oModel:GetModel("FORMCAB"):SetDescription("Formulário do Cadastro ZZE ")


return oModel


Static Function ViewDef()


	Local oView := Nil
	Local aStructTMP := (cAlias)->(DbStruct())

	Local oModel     := FWLoadModel("META003")
	Local oStTmp     := FWFormViewStruct():New()
	Local oStZZEFILHO   := FWFormStruct(2, 'ZZE')
	Private nCombo    := {"01","02","03","04","05","06","07","15","19","20","21","22","23","24","29","30","33","34","36","45","48","98","49","99"}


	oStTmp:AddField(;
		"TMP_LOJA",;               // [01]  C   Nome do Campo
		"01",;                      // [02]  C   Ordem
		"Loja 	",;               // [03]  C   Titulo do campo
		"Loja 	",;    // [04]  C   Descricao do campo
		Nil,;                       // [05]  A   Array com Help
		"A",;                       // [06]  C   Tipo do campo
		"@!",;    // [07]  C   Picture
		Nil,;                       // [08]  B   Bloco de PictTre Var
		Nil,;                       // [09]  C   Consulta F3
		.T.,;                       // [10]  L   Indica se o campo é alteravel
		Nil,;                       // [11]  C   Pasta do campo
		Nil,;                       // [12]  C   Agrupamento do campo
		nCombo,;                       // [13]  A   Lista de valores permitido do campo (Combo)
		Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
		Nil,;                       // [15]  C   Inicializador de Browse
		Nil,;                       // [16]  L   Indica se o campo é virtual
		Nil,;                       // [17]  C   Picture Variavel
		Nil)                        // [18]  L   Indica pulo de linha após o campo

	oStTmp:AddField(;
		"TMP_DATA1",;                 // [01]  C   Nome do Campo
		"02",;                      // [02]  C   Ordem
		"Data Inicial",;                    // [03]  C   Titulo do campo
		"Data Inicial",;                    // [04]  C   Descricao do campo
		Nil,;                       // [05]  A   Array com Help
		"D",;                       // [06]  C   Tipo do campo
		"@D",;                      // [07]  C   Picture
		Nil,;                       // [08]  B   Bloco de PictTre Var
		Nil,;                       // [09]  C   Consulta F3
		.T.,;                       // [10]  L   Indica se o campo é alteravel
		Nil,;                       // [11]  C   Pasta do campo
		Nil,;                       // [12]  C   Agrupamento do campo
		Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
		Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
		Nil,;                       // [15]  C   Inicializador de Browse
		Nil,;                       // [16]  L   Indica se o campo é virtual
		Nil,;                       // [17]  C   Picture Variavel
		Nil)                        // [18]  L   Indica pulo de linha após o campo
	oStTmp:AddField(;
		"TMP_TIPO",;               	// [01]  C   Nome do Campo
		"04",;                      // [02]  C   Ordem
		"Tipo 	",;               	// [03]  C   Titulo do campo
		"Tipo 	",;    				// [04]  C   Descricao do campo
		Nil,;                       // [05]  A   Array com Help
		"A",;                       // [06]  C   Tipo do campo
		"@!",;    					// [07]  C   Picture
		Nil,;                       // [08]  B   Bloco de PictTre Var
		Nil,;                       // [09]  C   Consulta F3
		.T.,;                       // [10]  L   Indica se o campo é alteravel
		Nil,;                       // [11]  C   Pasta do campo
		Nil,;                       // [12]  C   Agrupamento do campo
		{"Valor","Margem","Frete","Seguro","Garantia",DecodeUtf8("Serviço Express")},;                       // [13]  A   Lista de valores permitido do campo (Combo)
		Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
		Nil,;                       // [15]  C   Inicializador de Browse
		Nil,;                       // [16]  L   Indica se o campo é virtual
		Nil,;                       // [17]  C   Picture Variavel
		Nil)                        // [18]  L   Indica pulo de linha após o campo


	oStTmp:AddField(;
		"TMP_VALOR",;              	 // [01]  C   Nome do Campo
		"05",;                      // [02]  C   Ordem
		"Valor 	",;               	// [03]  C   Titulo do campo
		"Valor 	",;    				// [04]  C   Descricao do campo
		Nil,;                       // [05]  A   Array com Help
		"N",;                       // [06]  C   Tipo do campo
		"@E 9,999,999.99",;    					// [07]  C   Picture
		Nil,;                       // [08]  B   Bloco de PictTre Var
		Nil,;                       // [09]  C   Consulta F3
		.T.,;                       // [10]  L   Indica se o campo é alteravel
		Nil,;                       // [11]  C   Pasta do campo
		Nil,;                       // [12]  C   Agrupamento do campo
		Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
		Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
		Nil,;                       // [15]  C   Inicializador de Browse
		Nil,;                       // [16]  L   Indica se o campo é virtual
		Nil,;                       // [17]  C   Picture Variavel
		Nil)                        // [18]  L   Indica pulo de linha após o campo
	oStTmp:AddField(;
		"TMP_DATA2",;                 // [01]  C   Nome do Campo
		"03",;                      // [02]  C   Ordem
		"Data Final",;                    // [03]  C   Titulo do campo
		"Data Final",;                    // [04]  C   Descricao do campo
		Nil,;                       // [05]  A   Array com Help
		"D",;                       // [06]  C   Tipo do campo
		"@D",;                      // [07]  C   Picture
		Nil,;                       // [08]  B   Bloco de PictTre Var
		Nil,;                       // [09]  C   Consulta F3
		.T.,;                       // [10]  L   Indica se o campo é alteravel
		Nil,;                       // [11]  C   Pasta do campo
		Nil,;                       // [12]  C   Agrupamento do campo
		Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
		Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
		Nil,;                       // [15]  C   Inicializador de Browse
		Nil,;                       // [16]  L   Indica se o campo é virtual
		Nil,;                       // [17]  C   Picture Variavel
		Nil)                        // [18]  L   Indica pulo de linha após o campo



	oView := FWFormView():New()

	oView:SetModel(oModel)
	oView:AddField("VIEW_CAB", oStTmp, "FORMCAB")
	oView:AddGrid('VIEW_ZZE',oStZZEFILHO,'ZZEDETAIL')

	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('CABEC',30)
	oView:CreateHorizontalBox('GRID',70)


	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_CAB','CABEC')
	oView:SetOwnerView('VIEW_ZZE','GRID')

	//Habilitando título
	oView:EnableTitleView('VIEW_CAB','Cadastro de Metas')
	oView:EnableTitleView('VIEW_ZZE','Metas')


	//Tratativa padrão para fechar a tela
	oView:SetCloseOnOk({||.T.})


return oView


user function adcPeriodo(lFeriado, lDomingo, dDataIni, dDataFinish, nLoja, cTipo , nValor)
	Local aArray := {}
	Local x
	Local nCount := 0
	Local aFeriado := {}
	Local xF
	Local aArea := ZZE->(GetArea())
	Local cSql
	Local cSqlT
	Local aDados := {}
	Local lRet       := .T.
	Local dDataTIni
	Local dDataTFin
	Local nTot := 0
	Local nValorAtual
	Local oModel     := FWModelActive()
	Local aPergs := {}

	oModel:Activate()
	nLoja := oModel:GetValue("FORMCAB","TMP_LOJA")
	dDataIni := oModel:GetValue("FORMCAB","TMP_DATA1")
	dDataFinish :=oModel:GetValue("FORMCAB","TMP_DATA2")
	cTipo := oModel:GetValue("FORMCAB","TMP_TIPO")
	nValor := oModel:GetValue("FORMCAB","TMP_VALOR")
	dDataTIni := dDataIni
	dDataTFin := dDataFinish

	DO CASE
		CASE UPPER(cTipo) = UPPER("Valor")
			cTipo :='V'
		CASE UPPER(cTipo) =  UPPER("Margem")
			cTipo :='M'
		CASE UPPER(cTipo) = UPPER("Frete")
			cTipo :='F'
		CASE UPPER(cTipo) = UPPER("Seguro")'
			cTipo :='S'
		CASE UPPER(cTipo) = UPPER("Garantia")
			cTipo :='G'
		CASE UPPER(cTipo) = UPPER("Serviços Express")
			cTipo :='E'
		OTHERWISE
			cTipo := nil

	ENDCASE
	aAdd(aPergs,{5, "Incluir Feriados ?", .T., 50, "", .T.})
	aAdd(aPergs,{5, "Incluir Domingos ?", .T., 50, "", .T.})
	if inclui .or. altera
		If ParamBox(aPergs, DecodeUtf8("Informe os parâmetros"))
			lFeriado:= MV_PAR01
			lDomingo := MV_PAR02

			aFeriado := u_veriFeriado(dDataIni,dDataFinish, nLoja)

			cSql:=  "SELECT R_E_C_N_O_ as id, ZZE_VALOR , ZZE_DATA "
			cSql+=  " FROM ZZE030                                                      "
			cSql+=  "WHERE ZZE_LOJA = '"+nLoja+"'"
			cSql+=  " AND ZZE_TIPO = 'V'                                               "
			cSql+=  " AND D_E_L_E_T_ <> '*'                                            "
			cSql+=  " AND ZZE_DATA BETWEEN " + DTOS(dDataIni) + "AND " + DTOS(dDataFinish)

			while dDataIni <= dDataFinish
				If dDataIni == Date()
					aAdd (aArray,Date())
					dDataIni := DaySum(dDataIni, 1)
				Endif


				If lDomingo == .T. .And. Dow(dDataIni) == 1
					aAdd (aArray, dDataIni)
					dDataIni := DaySum(dDataIni, 1)
				elseif lDomingo == .F. .And. Dow(dDataIni) == 1
					dDataIni := DaySum(dDataIni, 1)
				elseif lDomingo == .T. .And. Dow(dDataIni) != 1
					aAdd (aArray, dDataIni)
					dDataIni := DaySum(dDataIni, 1)
				elseif 	lDomingo == .F. .and. Dow(dDataIni) != 1
					aAdd (aArray, dDataIni)
					dDataIni := DaySum(dDataIni, 1)
				Endif
				if lFeriado == .F.
					For xF := 1 to len (aFeriado)
						If aFeriado[xF] ==  dDataIni
							dDataIni := DaySum(dDataIni, 1)
						endif
					next
				endif

				if   Dow(dDataIni) != 1 .And. dDataIni != Date() .And. lFeriado == .F.
					aAdd (aArray,dDataIni)
					dDataIni := DaySum(dDataIni, 1)
				elseif lFeriado == .T.
					For xF := 1 to len (aFeriado)
						If aFeriado[xF] ==  dDataIni
							aADD(aArray,aFeriado[xF])
							dDataIni := DaySum(dDataIni, 1)
						else
							aAdd (aArray,dDataIni)
							dDataIni := DaySum(dDataIni, 1)
						EndIF
					Next
				endif


				nCount ++
				if ASCAN(aArray, dDataIni) == 0 .and. Dow(dDataIni) != 1 .and. ASCAN(aFeriado,dDataIni,1) == 0 .and. (dDataIni = dDataFinish)
					aAdd (aArray,dDataIni)
					dDataIni := DaySum(dDataIni, 1)
					end if
					EndDo
					nValorAtual := round((nValor / len(aArray)),2)

					dbUseArea(.T.,"TOPCONN",TCGenQry(,,cSql),'XS9',.F.,.T.)
					DbSelectArea('XS9')
					DbGotop()
					while !Eof()
					
				
						aADD(aDados,stod(XS9->ZZE_DATA))
						dbSkip()
					enddo

					RestArea(aArea)

					DbSelectArea('XS9')
					USE
					for x:=1 to len(aArray)
						if x == len(aArray)
							nValorAtual -= nValorAtual + (nTot - nValor)
						endif
						n1 := ascan(aDados,aArray[x])
						if n1 == 0
							DbSelectArea('ZZE')

							DbSetOrder(2)
							DbGotop()
							RecLock("ZZE", .T.)
							ZZE -> ZZE_FILIAL := xFilial("ZZE")
							ZZE -> ZZE_LOJA := cvaltochar(nLoja)
							ZZE -> ZZE_DATA :=aArray[x]
							ZZE -> ZZE_TIPO := alltrim(cValToChar(cTipo))
							ZZE -> ZZE_VALOR := nValorAtual
							MsUnLock()

							RestArea(aArea)


						else
						
							DbSelectArea('ZZE')

							DbSetOrder(2)
							if  !Dbseek(alltrim(cvaltochar(nLoja))+DTOS(aArray[n1])+alltrim(cValToChar(cTipo)))
								msginfo('nao encontrado')
							endif
							RecLock("ZZE", .F.)
							ZZE->ZZE_VALOR := nValorAtual
							MsUnLock()
							DbSelectArea(cAlias)
							 DbSetOrder(1)
							 dbGotop()
							 
						if msSeek(dtos(dDataTIni)+dtos(dDataTFin)+ALLTRIM(nLoja))
							RecLock( cAlias, .F. )
								TMP_VALOR :=nValor
							msUnlock()
							EndIf

							RestArea(aArea)
						endif
						nTot += nValorAtual
					next
				EndIF
				If inclui .and. n1 == 0
					DbSelectArea(cAlias)
					DbSetOrder(1)
					RecLock( cAlias, .T. )
					TMP_LOJA := nLoja
					TMP_TIPO := cvaltochar(cTipo)
					TMP_DATA1 :=dDataTIni
					TMP_DATA2 :=dDataTFin
					TMP_VALOR :=nValor
					msUnlock()
				ElseIF altera
					RecLock( cAlias, .F. )
					TMP_VALOR :=nValor
					msUnlock()
				EndIF
			else
				u_deletePeriodo(dDataTIni,dDataTFin,nloja,cTipo)
				RecLock( cAlias, .F. )
				 DBDelete()
				msUnlock()
		    Endif
return(lRet)






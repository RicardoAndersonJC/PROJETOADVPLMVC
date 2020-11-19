#include "protheus.ch"

user function AddPeriodo(lFeriado, lDomingo, dDataIni, dDataFinish, nLoja, cTipo , nValor)
	Local aArray := {}
	Local x
	Local nCount := 0
	Local aFeriado := {}
	Local xF
	Local aArea := ZZE->(GetArea())
	Local cSql
	Local aDados := {}
	Local nTot := 0
	Local nValorAtual

	dDataIni :=  CTOD(dDataIni)
	dDataFinish := CTOD(dDataFinish)
	aFeriado := u_veriFeriado(dDataIni,dDataFinish, nLoja)

	cSql:=  "SELECT R_E_C_N_O_ as id, ZZE_VALOR , ZZE_DATA "
	cSql+=  "FROM ZZE030                                                      "
	cSql+=  "WHERE ZZE_LOJA = " + nLoja
	cSql+=  "AND ZZE_TIPO = 'V'                                               "
	cSql+=  "AND D_E_L_E_T_ <> '*'                                            "
	cSql+=  "AND ZZE_DATA BETWEEN " + DTOS(dDataIni) + "AND " + DTOS(dDataFinish)

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
		if ASCAN(aArray, dDataIni, 1) == 0 .and. Dow(dDataIni) != 1 .and. ASCAN(aFeriado,dDataIni,1) == 0
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
			ZZE -> ZZE_TIPO := 'V'
			ZZE -> ZZE_VALOR := nValorAtual
			MsUnLock()

			RestArea(aArea)


		else
			DbSelectArea('ZZE')

			DbSetOrder(2)
			if  !Dbseek(cvaltochar(nLoja)+DTOS(aArray[n1])+'V')
				msginfo('nao encontrado')
			endif
			RecLock("ZZE", .F.)
			ZZE->ZZE_VALOR := nValorAtual
			MsUnLock()

			RestArea(aArea)
		endif
		nTot += nValorAtual


	next


return





user function veriFeriado(dDataIni, dDataFinish, cloja)
	local aFeriado :={}
	Local cSql
	Local lbusca
	Local aRetorno := {}



	If ( cloja $ GETMV("MV_FILSATU"))
		cSql := "SELECT LEFT(X5_DESCRI, 8) AS feriado "
		cSql += " FROM SX5010                         "
		cSql += "WHERE X5_CHAVE = 'ZG1'              "
		cSql += "  AND X5_FILIAL IN('02',            "
		cSql += "                   '04',            "
		cSql += "                   '05',            "
		cSql += "                   '06',            "
		cSql += "                   '07',            "
		cSql += "                   '19',            "
		cSql += "                   '20',            "
		cSql += "                   '22',            "
		cSql += "                   '23',            "
		cSql += "                   '29',            "
		cSql += "                   '33',            "
		cSql += "                   '34',            "
		cSql += "                   '45',            "
		cSql += "                   '48',            "
		cSql += "                   '49')            "
		cSql += "  AND D_E_L_E_T_ <> '*'             "
		cSql += "and LEFT(X5_DESCRI, 4) = CONVERT(varchar,YEAR(convert(date, '26/10/2019',103)),103)"
		cSql += "GROUP BY LEFT(X5_DESCRI, 8)         "



		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cSql),'XR5',.F.,.T.)
		DbSelectArea('XR5')
		DbGotop()

		While !Eof()
			aADD(aFeriado,XR5->feriado)
			DBSkip()
		Enddo
		DbSelectArea('XR5')
		use
	ElseIf( cloja $ GETMV("MV_FILSANT"))
		cSql := "SELECT LEFT(X5_DESCRI, 8) AS feriado  "
		cSql += " FROM SX5030                          "
		cSql += "WHERE X5_CHAVE = 'ZG1'               "
		cSql += "AND X5_FILIAL IN('01',               "
		cSql += "'03',                                "
		cSql += "'15',                                "
		cSql += "'21',                                "
		cSql += "'24',                                "
		cSql += "'30',                                "
		cSql += "'36')                                "
		cSql += "AND D_E_L_E_T_ <> '*'                "
		cSql += "and LEFT(X5_DESCRI, 4) = CONVERT(varchar,YEAR(convert(date, '26/10/2019',103)),103)"
		cSql += "GROUP BY LEFT(X5_DESCRI, 8);         "

		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cSql),'XR6',.F.,.T.)
		DbSelectArea('XR6')
		DbGotop()

		While !Eof()
			aADD(aFeriado,XR6->feriado)
			DBSkip()
		Enddo
		DbSelectArea('XR6')
		use
	EndIf

	While dDataIni <= dDataFinish

		dDataIni := DTOS(dDataIni)
		lBusca := ASCAN(aFeriado,dDataIni,1)

		If lBusca != 0
			aADD(aRetorno,STOD(dDataIni))
		EndIf

		dDataIni := STOD(dDataIni)
		dDataIni := DaySum(dDataIni, 1)

	EndDo



return aRetorno

user function addDias(dDia , dDataIni, dDataFinish, nLoja,nValorT)
	Local ncCount := 0
	Local nValor := 0
	Local aArray := {}
	Local nValorAtt := 0
	Local nStatus
	Local i
	Local cSql
	Local aData := {}

	Local aArea := ZZE->(GetArea())

	Local nStatusEx
	cSql:=  "SELECT R_E_C_N_O_ as id, ZZE_VALOR , ZZE_DATA "
	cSql+=  "FROM ZZE030                                                      "
	cSql+=  "WHERE ZZE_LOJA = " + nLoja
	cSql+=  "AND ZZE_TIPO = 'V'                                               "
	cSql+=  "AND D_E_L_E_T_ <> '*'                                            "
	cSql+=  "AND ZZE_DATA BETWEEN " + DTOS(CTOD(dDataIni)) + "AND " + DTOS(CTOD(dDataFinish))


	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cSql),'XR7',.F.,.T.)
	DbSelectArea('XR7')
	DbGotop()
	If DTOS(CTOD(dDataIni))  ==  DTOS(CTOD(dDataFinish))

		If DTOS(CTOD(dDataIni))	== XR7->ZZE_DATA
			TCSqlExec("update ZZE030  set ZZE_VALOR = " + nValorT + "where ZZE_DATA = " + DTOS(CTOD(dDataIni)) +  "and ZZE_LOJA = " + cvaltochar(nLoja ))
		else
			DbSelectArea('ZZE')
			Dbseek(xFilial('ZZE') +  ZZE->ZZE_LOJA+DTOS(ZZE->ZZE_DATA))

			DbSetOrder(1)
			DbGotop()

			nStatusEx := 0

			RecLock("ZZE", .T.)
			ZZE -> ZZE_FILIAL := xFilial("ZZE")
			ZZE -> ZZE_LOJA := cvaltochar(nLoja)
			ZZE -> ZZE_DATA :=CTOD(dDia)
			ZZE -> ZZE_TIPO := 'V'
			ZZE -> ZZE_VALOR := nValorT
			MsUnLock()

			RestArea(aArea)

			DbSelectArea('ZZE')
			USE
		EndIF


	else

		While !Eof()
			nValor += XR7->ZZE_VALOR
			aAdd(aArray,XR7->id )
			ncCount ++
			DBSkip()
		EndDo

		if empty(nValorT)
			nValorAtt := round(nValor / ncCount,2)
		else
			nValorAtt := round(nValorT / ncCount,2)
		endif
		For i := 1 to len(aArray)
			nStatus := TCSqlExec("update ZZE030  set ZZE_VALOR = " + cvaltochar(nValorAtt) + "where R_E_C_N_O_ = " + cvaltochar(aArray[i]))
			If (nStatus < 0)
				conout("Ocorreu erro no update do arquivo de id "+  cvaltochar(aArray[i])  +  TCSQLError())
			EndIf
		Next

		DbSelectArea('XR7')
		USE



		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cSql),'XR7',.F.,.T.)
		DbSelectArea('XR7')
		DbGotop()
		while !Eof()
			aADD(aData, XR7->ZZE_DATA)
			DBSkip()
		EndDo
		DbSelectArea('XR7')
		USE
		If ASCAN(aData,dDia,1) == 0
			DbSelectArea('ZZE')
			Dbseek( xFilial('ZZE') +  ZZE->ZZE_LOJA+DTOS(ZZE->ZZE_DATA))

			DbSetOrder(1)
			DbGotop()
			RecLock("ZZE", .F.)
			ZZE -> ZZE_VALOR := nValorAtt
			MsUnLock()
			DbSelectArea('ZZE')
			USE


		else
			DbSelectArea('ZZE')
			Dbseek( xFilial('ZZE') +  ZZE->ZZE_LOJA+DTOS(ZZE->ZZE_DATA))

			DbSetOrder(1)
			DbGotop()
			RecLock("ZZE", .T.)
			ZZE -> ZZE_FILIAL := xFilial("ZZE")
			ZZE -> ZZE_LOJA := cvaltochar(nLoja)
			ZZE -> ZZE_DATA :=CTOD(dDia)
			ZZE -> ZZE_TIPO := 'V'
			ZZE -> ZZE_VALOR := nValorAtt
			MsUnLock()
			DbSelectArea('ZZE')
			USE
			RestArea(aArea)


		EndIF




	endif

return
user function deleteDia(dDia, dDataFinish,nLoja)
	Local nCount := 0
	Local cSql
	Local nValor := 0
	Local aArray := {}
	Local nValorAtt := 0
	Local nStatus
	Local i

	cSql:=  "SELECT R_E_C_N_O_ as id, ZZE_VALOR ,ZZE_DATA "
	cSql+=  "FROM ZZE030                                                      "
	cSql+=  "WHERE ZZE_LOJA = " + nLoja
	cSql+=  "AND ZZE_TIPO = 'V'                                               "
	cSql+=  "AND D_E_L_E_T_ <> '*'                                            "
	cSql+=  "AND ZZE_DATA BETWEEN " + DTOS(CTOD(dDia)) + "AND " + DTOS(CTOD(dDataFinish))
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cSql),'XR9',.F.,.T.)
	DbSelectArea('XR9')
	DbGotop()
	While !Eof()
		nValor += XR9->ZZE_VALOR
		if XR9->ZZE_DATA !=  DTOS(CTOD(dDia))
			aAdd(aArray,XR9->id )
			nCount ++
		endif
		DBSkip()
	EndDo
	nValorAtt := round(nValor / nCount,2)
	TCSqlExec("delete ZZE030  where ZZE_DATA = " + DTOS(CTOD(dDia)) +  "and ZZE_LOJA = " + nLoja )
	For i := 1 to len(aArray)
		nStatus := TCSqlExec("update ZZE030  set ZZE_VALOR = " + cvaltochar(nValorAtt) + "where R_E_C_N_O_ = " + cvaltochar(aArray[i]))
		If (nStatus < 0)
			conout("Ocorreu erro no update do arquivo de id "+  cvaltochar(aArray[i])  +  TCSQLError())
		EndIf
	Next



return

user function deletePeriodo(dDataIni, dDataFinish, nLoja, cTipo )
	
	Local cSql
	

	cSql:=  "SELECT R_E_C_N_O_ , ZZE_VALOR , ZZE_DATA "
	cSql+=  "FROM ZZE030                                                      "
	cSql+=  "WHERE ZZE_LOJA = '"+alltrim(nLoja)+"'"
	cSql+=  "AND ZZE_TIPO = '"+alltrim(cvaltochar(cTipo))+"'"
	cSql+=  "AND D_E_L_E_T_ <> '*'                                            "
	cSql+=  "AND ZZE_DATA BETWEEN " + DTOS(dDataIni) + "AND " + DTOS(dDataFinish)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cSql),'XD9',.F.,.T.)
	DbSelectArea('XD9')
	DbGotop()
	while !Eof()
		nStatus := TCSqlExec("delete ZZE030 where R_E_C_N_O_ = " +  XD9->R_E_C_N_O_)
		If (nStatus < 0)
			conout("Ocorreu erro na exclusão do arquivo" +  TCSQLError())
		EndIf
		DBSkip()
	enddo


	return 

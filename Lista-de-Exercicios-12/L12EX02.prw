#INCLUDE 'TOTVS.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'TOPCONN.CH'

#DEFINE ESQUERDA  1
#DEFINE CENTRO    2
#DEFINE DIREITA   3

#DEFINE GERAL       1
#DEFINE NUMERICO    2
#DEFINE MONETARIO   3
#DEFINE DATETIME    4

/*/{Protheus.doc} User Function L12EX02
    Gerador de Planilhas com todos os Registros de Produtos
    @type  Function
    @author Jo�o Pedro Fazoli de Souza
    @since 19/04/2023
    /*/
User Function L12EX02()
    local cPath       := 'C:\Users\Jo�o Pedro Fazoli\Desktop\'
    local cArq        := 'L12EX02.xls'
    local cAlias      := GetNextAlias()
    local cQuery      := GeraQuery()
    Private cPasta    := 'Produtos'
    Private cTable    := 'Dados dos Produtos'
    Private oExcel    := FwMsExcelEx():New()

    PREPARE ENVIRONMENT EMPRESA '99' FILIAL '01' TABLES 'SA2' MODULO 'COM'

    TCQUERY cQuery ALIAS &(cAlias) NEW
    
    oExcel:AddWorkSheet(cPasta)

    oExcel:AddTable(cPasta, cTable)

    //! Colunas a serem usadas
    oExcel:AddColumn(cPasta, cTable, 'C�digo'           , CENTRO    , 1)
    oExcel:AddColumn(cPasta, cTable, 'Descri��o'        , ESQUERDA  , 1)
    oExcel:AddColumn(cPasta, cTable, 'Tipo'             , CENTRO    , 1)
    oExcel:AddColumn(cPasta, cTable, 'Unidade de Medida', CENTRO    , 1)
    oExcel:AddColumn(cPasta, cTable, 'Pre�o de Venda'   , ESQUERDA  , 3)

    //!Estilo Titulo
    oExcel:SetTitleFont('Arial')
    oExcel:SetTitleSizeFont(14)
    oExcel:SetTitleBold(.T.)
    oExcel:SetTitleBgColor('#2F4F4F')
    oExcel:SetTitleFrColor('#FFFFFF')

    //!Estilo Cabe�alho
    oExcel:SetHeaderFont('Arial')
    oExcel:SetHeaderSizeFont(12)
    oExcel:SetHeaderBold(.T.)
    oExcel:SetBgColorHeader('#228B22')
    oExcel:SetFrColorHeader('#FFFFFF')
    //!Estilo Linha 1
    oExcel:SetLineFont('Arial')
    oExcel:SetLineSizeFont(10)
    oExcel:SetLineBgColor('#98FB98')
    oExcel:SetLineFrColor('#000000')
    //!Estilo Linha 2
    oExcel:Set2LineFont('Arial')
    oExcel:Set2LineSizeFont(10)
    oExcel:Set2LineBgColor('#90EE90')
    oExcel:Set2LineFrColor('#000000')


    oExcel:SetCelBgColor("#FF0000")
    oExcel:SetCelFrColor("#ffffff")

    if !Empty(cAlias)
        ImpDados(cAlias)

        oExcel:ACTIVATE()
        oExcel:GetXMLFile(cPath + cArq)

        if ApOleClient('MsExcel')
            oExec := MsExcel():New()
            oExec:WorkBooks:Open(cPath + cArq)
            oExec:SetVisible(.T.)
        else
            FwAlertError('Excel n�o encontrado no Windows', 'Excel n�o Encontrado')
        endif

        FwAlertSuccess('Arquivo Gerado com Sucesso', 'Concluido')
        oExcel:DeActivate()
    else
        FwAlertError('N�o foram encontrados Resultados')
    endif

Return 

Static Function GeraQuery()
    local cQuery := ''

    cQuery := 'SELECT SB1.B1_COD, SB1.B1_DESC, SB1.B1_TIPO, SB1.B1_UM, SB1.B1_PRV1, SB1.R_E_C_D_E_L_ FROM SB1990 SB1' + CRLF
    cQuery += 'ORDER BY SB1.B1_COD'

Return cQuery

Static Function ImpDados(cAlias)
    local cCodigo
    local cDesc
    local cTipo
    local cUnid
    local cPreco

    while (cAlias)->(!EOF())
        cCodigo   := Alltrim((cAlias)->(B1_COD))
        cDesc     := Alltrim((cAlias)->(B1_DESC))
        cTipo     := Alltrim((cAlias)->(B1_TIPO))
        cUnid     := Alltrim((cAlias)->(B1_UM))
        cPreco    := (cAlias)->(B1_PRV1)


        if (cAlias)->(R_E_C_D_E_L_ ) <> 0
            oExcel:AddRow(cPasta, cTable,{cCodigo,cDesc,cTipo,cUnid,cPreco},{1,2,3,4,5})
        else
            oExcel:AddRow(cPasta, cTable,{cCodigo,cDesc,cTipo,cUnid,cPreco})
        endif
        (cAlias)->(DbSkip())
    enddo
Return

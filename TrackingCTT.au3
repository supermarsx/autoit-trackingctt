#include-once
#include <Array.au3>
#include <Inet.au3>
#include <String.au3>
#include "HTML.au3"

; #INDEX# =======================================================================================================================
; Title .........: Tracking CTT
; Version .......: 1.0
; AutoIt Version : 3.3.14.2
; Language ......: Português (pt_PT)
; Description ...: UDF para obter informações de tracking CTT
; Author(s) .....: Eduardo Mota
; Dll ...........: -
; Dependencies ..: HTML UDF from Dhilip89
; ===============================================================================================================================

; #VARS/CONSTANTS# ==============================================================================================================
; $ctt_url_prefix 		= Prefixo do URL (antes dos parâmetros)
; $ctt_url_sufix 		= Sufixo do URL (depois dos parâmetros)
; $ctt_tracking_regex	= Padrão Regex comparativo de tracking (XX012345678XX)
; ===============================================================================================================================
Global Const $ctt_url_prefix = "https://www.ctt.pt/feapl_2/app/open/objectSearch/objectSearch.jspx?objects=", _
	$ctt_url_sufix = "" , _
	$ctt_tracking_regex = "[A-z]{2}\d{9}[A-z]{2}"

; #CURRENT# =====================================================================================================================
;_trackingctt_obterultimoestado
; ===============================================================================================================================

;===============================================================================
;
; Function Name:   	_trackingctt_obterultimoestado()
; Description:      Obter o último estado sobre um determinado tracking number
; Parameter(s):     $sTrackingnumber     - O número tracking sobre o qual se
;										  se pretende mais informações
;					$bClearentities		- [optional] Se Verdadeiro limpar
;										  e retornar valores em formato
;										  legível invés de html
;
; Return Value(s):  On Success  - Retorna um array com as informações de estado
;                  				  'Array'[0] = Tracking Number
;                  				  'Array'[1] = Data
;								  'Array'[2] = Hora
;								  'Array'[3] = Estado
;								  'Array'[4] = Local
;								  'Array'[5] = Motivo
;								  'Array'[6] = Receptor
;					On Failure  - Retorna variável da falha correspondente o set error
;                                 1 = Erro na Ligação/Obter dados
;								  2 = Código Inválido (XX012345678XX)
;								  3 = Erro a processar informação
;								  4 = Número não encontrado
;								  5 = Erro ao obter página
;								  6 = Erro ao descodificar HTML Entities
;
; Author(s):        Eduardo Mota
;
;===============================================================================

Func _trackingctt_obterultimoestado(ByRef $sTrackingnumber, $bClearentities = 1)
	Local $sTrackinginfo[7], _	; Localização final das informações de Tracking.
		  $ctt_url_final, _	; URL Final para tracking
		  $ctt_trkbuffer	; Localização intermédia da informação obtida

	If Not StringRegExp($sTrackingnumber,$ctt_tracking_regex) Then
		SetError(2)
		Return 2
	EndIf

	$ctt_url_final = $ctt_url_prefix & $sTrackingnumber & $ctt_url_sufix
	$ctt_trkbuffer = _INetGetSource($ctt_url_final)
	If @error Then
		SetError(1)
		Return 1		; Terminar se ocorrer erro a obter dados
	EndIf

	If Not StringInStr($ctt_trkbuffer,$sTrackingnumber) Then
		SetError(5)
		Return 5
	EndIf

	$ctt_trkbuffer = _StringBetween($ctt_trkbuffer, "<td>", "</td>")
	If @error Then
		SetError(3)
		Return 3
	EndIf

	If UBound($ctt_trkbuffer) < 10 Then
		SetError(4)
		Return 4 ; Se o array for menor que 10 é provável que o número não tenha sido encontrado
	EndIf

	; Atribuir informações de tracking existentes
	$sTrackinginfo[0] = $sTrackingnumber	; Tracking Number (XX012345678XX)
	$sTrackinginfo[1] = $ctt_trkbuffer[2]	; Data (AAAA/MM/DD)
	$sTrackinginfo[2] = $ctt_trkbuffer[3]	; Hora (HH:MM)
	$sTrackinginfo[3] = $ctt_trkbuffer[6]	; Estado
	$sTrackinginfo[4] = $ctt_trkbuffer[8]	; Local
	$sTrackinginfo[5] = $ctt_trkbuffer[7]	; Motivo
	$sTrackinginfo[6] = $ctt_trkbuffer[9]	; Receptor

	; Limpar HTML Entities
	If $bClearentities Then
		For $i = 3 To 6
			$sTrackinginfo[$i] = _HTMLDecode($sTrackinginfo[$i])
			If @error Then
				SetError(6)
				Return 6
			EndIf
		Next
	Endif

	Return $sTrackinginfo

EndFunc
#include "TrackingCTT.au3"


$trackingnumber = "XX012345678XX"

$trackinginfo = _trackingctt_obterultimoestado($trackingnumber)
IF Not IsArray($trackinginfo) Then
	MsgBox(0,"Ocorreu um erro","Ocorreu o erro " & $trackinginfo & ". Consulte o UDF para mais informações")
Else
	MsgBox(0,"Tracking Number --> "& $trackinginfo[0], _
	"Data: " & $trackinginfo[1] & @CRLF & _
	"Hora: " & $trackinginfo[2] & @CRLF & _
	"Estado: " & $trackinginfo[3] & @CRLF & _
	"Local: " & $trackinginfo[4] & @CRLF & _
	"Motivo: " & $trackinginfo[5] & @CRLF & _
	"Receptor: " & $trackinginfo[6])
EndIf
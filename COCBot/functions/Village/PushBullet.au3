; #FUNCTION# ====================================================================================================================
; Name ..........: PushBulle
; Description ...: This function will report to your mobile phone your values and last attack
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: Antidote (2015-03)
; Modified ......:
; Remarks .......: This file is part of ClashGameBot. Copyright 2015
;                  ClashGameBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================


#include <Array.au3>
#include <String.au3>

Func _PushBullet($pTitle = "", $pMessage = "")
    $oHTTP = ObjCreate("WinHTTP.WinHTTPRequest.5.1")
    $access_token = $PushToken
    ;$device_iden = ""

    $oHTTP.Open("Get", "https://api.pushbullet.com/v2/devices", False)
    $oHTTP.SetCredentials($access_token, "", 0)
    $oHTTP.Send()
    $Result = $oHTTP.ResponseText
    Local $device_iden = _StringBetween($Result, 'iden":"', '"')
    Local $device_name = _StringBetween($Result, 'nickname":"', '"')
    Local $device = ""
    Local $pDevice = 1
    $oHTTP.Open("Post", "https://api.pushbullet.com/v2/pushes", False)
    $oHTTP.SetCredentials($access_token, "", 0)
    $oHTTP.SetRequestHeader("Content-Type", "application/json")
    Local $pPush = '{"type": "note", "title": "' & $pTitle & '", "body": "' & $pMessage & '"}'
    $oHTTP.Send($pPush)
EndFunc   ;==>_PushBullet

Func _Push($pTitle, $pMessage)
    $oHTTP = ObjCreate("WinHTTP.WinHTTPRequest.5.1")
    $access_token = $PushToken
    ;$device_iden = ""

    $oHTTP.Open("Post", "https://api.pushbullet.com/v2/pushes", False)
    $oHTTP.SetCredentials($access_token, "", 0)
    $oHTTP.SetRequestHeader("Content-Type", "application/json")
    Local $pPush = '{"type": "note", "title": "' & $pTitle & '", "body": "' & $pMessage & '"}'
    ;Local $pPush = '{"type": "note", "title": "' & $pTitle & '", "body": "' & $pMessage & '","device_iden": "' & $device_iden[$pDevice - 1] & '"}'
    $oHTTP.Send($pPush)
EndFunc   ;==>_Push

; _PushBullet()
;_Push("CGB Notifications", "Message")

Func _DeleteMessage($iden)
	$oHTTP = ObjCreate("WinHTTP.WinHTTPRequest.5.1")
	$access_token = $PushToken
	$oHTTP.Open("Delete", "https://api.pushbullet.com/v2/pushes/" & $iden, False)
	$oHTTP.SetCredentials($access_token, "", 0)
	$oHTTP.SetRequestHeader("Content-Type", "application/json")
	$oHTTP.Send()
EndFunc   ;==>_DeleteMessage

Func _RemoteControl()
	$oHTTP = ObjCreate("WinHTTP.WinHTTPRequest.5.1")
	$access_token = $PushToken
	$oHTTP.Open("Get", "https://api.pushbullet.com/v2/pushes?active=true", False)
	$oHTTP.SetCredentials($access_token, "", 0)
	$oHTTP.SetRequestHeader("Content-Type", "application/json")
	$oHTTP.Send()
	$Result = $oHTTP.ResponseText

	Local $findstr = StringRegExp($Result, '(?i)"title":"bot')
	If $findstr = 1 Then
		Local $title = _StringBetween($Result, '"title":"', '"', "", False)
		Local $iden = _StringBetween($Result, '"iden":"', '"', "", False)

		For $x = 0 To UBound($title) - 1
			If $title <> "" Or $iden <> "" Then
				$title[$x] = StringLower(StringStripWS($title[$x], $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES))
				$iden[$x] = StringStripWS($iden[$x], $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES)

				Switch $title[$x]
					Case "bot help"
						SetLog("CGB PB remote requested. Help menu is now sent")
						_Push("CGB remote request: help", "You can remotely control your bot using the following command format\n\nBot <command> where <command> is:\n\nPause - pause the bot\nResume - resume the bot\nStats - send bot current statistics\nLogs - send the current log file\nHelp - send this help message\n\nEnter the command in the title of the message")
						_DeleteMessage($iden[$x])
					Case "bot pause"
						If $TPaused = False Then
							SetLog("CGB PB remote request. Bot is now paused")
							_Push("CGB remote request: Pause", "CGB is paused")
							_DeleteMessage($iden[$x])
							$TPaused = NOT $TPaused
						Else
							SetLog("Your bot is currently paused, no action was taken")
							_Push("Request to Pause", "Your bot is currently paused, no action was taken")
						EndIf
					Case "bot resume"
						If $TPaused = True Then
							SetLog("CGB PB remote requested. Bot is now resumed")
							_Push("CGB remote request: resume", "CGB is resumed")
							_DeleteMessage($iden[$x])
							$TPaused = NOT $TPaused
						Else
							SetLog("Your bot is currently running, no action was taken")
							_Push("Request to Resume", "Your bot is currently running, no action was taken")
						EndIf
						_DeleteMessage($iden[$x])
					Case "bot stats"
						SetLog("Your request has been received. Statistics sent")
						;_Push("Request for Stats", "Resources at Start\n-Gold:  " & GUICtrlRead($lblresultgoldtstart) & "\n-Elixir:  " & GUICtrlRead($lblresultelixirstart) & "\n-DE:  " & GUICtrlRead($lblresultdestart) & "\n-Trophies:  " & GUICtrlRead($lblresulttrophystart) & "\n\nCurrent Resources \n-Gold:  " & GUICtrlRead($lblresultgoldnow) & "\n-Elixir:  " & GUICtrlRead($lblresultelixirnow) & "\n-DE:  " & GUICtrlRead($lblresultdenow) & "\n-Trophies:  " & GUICtrlRead($lblresulttrophynow) & "\n\nBuildings/Walls Upgrade " & "\n-Wall Upgrade:  " & GUICtrlRead($lblwallupgradecount) & "\n\nTotal Gain\n-Gold Gain:  " & GUICtrlRead($lblresultgoldgain) & "\n-Elixir Gain:  " & GUICtrlRead($lblresultelixirgain) & "\n-DE Gain:  " & GUICtrlRead($lblresultdegain) & "\n-Trophies Gain:  " & GUICtrlRead($lblresulttrophygain) & "\n\nOther Stats\n-Attacked:  " & GUICtrlRead($lblresultvillagesattacked) & "\n-Skipped:  " & GUICtrlRead($lblresultvillagesskipped) & "\n-Search Cost:  " & GUICtrlRead($lblresultsearchcost) & "\n-Bot Run Time:  " & StringFormat("%02i:%02i:%02i", $hour, $min, $sec))
						_DeleteMessage($iden[$x])
					Case "bot logs"
						SetLog("CGB PB remote requested. Log file is now sent")
						_DeleteMessage($iden[$x])
				EndSwitch
				$title[$x] = ""
				$iden[$x] = ""
			EndIf
		Next
	EndIf
EndFunc   ;==>_RemoteControl

Func _PushBulletRemote()
	_RemoteControl()
	While $TPaused ; Actual Pause loop
		If _Sleep(4000) Then ExitLoop
		_RemoteControl()
	WEnd

	ZoomOut()
	If _Sleep(250) Then Return
EndFunc


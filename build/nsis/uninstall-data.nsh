!include "nsDialogs.nsh"
!include "LogicLib.nsh"

; 卸载页面：是否删除 ClickClaw 本地目录（默认不勾选）
Var unDeleteClickClawDataCheckbox
Var unDeleteClickClawData

!macro customUnWelcomePage
  !insertmacro MUI_UNPAGE_WELCOME
  UninstPage custom un.ClickClawDataPageCreate un.ClickClawDataPageLeave
!macroend

Function un.ClickClawDataPageCreate
  nsDialogs::Create 1018
  Pop $0

  ${If} $0 == error
    Abort
  ${EndIf}

  ${NSD_CreateLabel} 0 0 100% 18u "卸载选项"
  Pop $1

  ${NSD_CreateLabel} 0 18u 100% 26u "默认仅卸载程序本体并保留用户数据。若需同时清理 ClickClaw 本地数据，请勾选下方选项。"
  Pop $2

  ${NSD_CreateCheckbox} 0 52u 100% 12u "删除 ClickClaw 本地数据 (~/.clickclaw)"
  Pop $unDeleteClickClawDataCheckbox
  ${NSD_SetState} $unDeleteClickClawDataCheckbox ${BST_UNCHECKED}

  nsDialogs::Show
FunctionEnd

Function un.ClickClawDataPageLeave
  ${NSD_GetState} $unDeleteClickClawDataCheckbox $unDeleteClickClawData
FunctionEnd

!macro customUnInstall
  ; 默认不删除，只有用户勾选时才清理 ~/.clickclaw
  StrCmp $unDeleteClickClawData ${BST_CHECKED} 0 done

  ; 保护：仅允许基于当前用户目录拼接目标路径，且拒绝明显异常值
  StrCpy $0 "$PROFILE"
  ${If} $0 == ""
    DetailPrint "Skip deleting ~/.clickclaw: empty user profile path"
    Goto done
  ${EndIf}
  ${If} $0 == "\\"
    DetailPrint "Skip deleting ~/.clickclaw: invalid user profile path ($PROFILE=$0)"
    Goto done
  ${EndIf}
  ${If} $0 == "/"
    DetailPrint "Skip deleting ~/.clickclaw: invalid user profile path ($PROFILE=$0)"
    Goto done
  ${EndIf}

  StrCpy $1 "$0\.clickclaw"

  DetailPrint "Deleting ClickClaw local data: $1"
  RMDir /r "$1"

done:
  ; 设计约束：绝不删除 ~/.openclaw
  DetailPrint "Keeping OpenClaw data (~/.openclaw) untouched"
!macroend

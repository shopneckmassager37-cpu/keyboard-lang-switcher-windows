#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%
SendMode Input

; --- Configuration ---
; Hotkey: ALT+SHIFT+J
!+j::
    ; 1. Handle CapsLock
    if GetKeyState("CapsLock", "T")
    {
        SetCapsLockState, Off
    }

    ; 2. Switch Keyboard Language
    ; PostMessage, 0x50, 0, 0,, A ; WM_INPUTLANGCHANGEREQUEST - Simple toggle
    ; To explicitly switch to the other language, we can use the following:
    ; Get current layout
    WinGet, active_id, ID, A
    ThreadID := DllCall("GetWindowThreadProcessId", "UInt", active_id, "UInt", 0)
    InputLocaleID := DllCall("GetKeyboardLayout", "UInt", ThreadID, "UInt")
    
    ; HE: 0x040D, EN: 0x0409
    ; If it's English (0x0409), switch to Hebrew (0x040D) and vice-versa
    if (InputLocaleID = 0x04090409 or InputLocaleID = 67699721) ; English US
    {
        PostMessage, 0x50, 0, 0x040D040D,, A ; Switch to Hebrew
    }
    else
    {
        PostMessage, 0x50, 0, 0x04090409,, A ; Switch to English
    }

    ; 3. Get Selected Text
    ClipboardOld := ClipboardAll
    Clipboard := ""
    Send, ^c
    ClipWait, 0.5
    if (ErrorLevel)
    {
        Clipboard := ClipboardOld
        return
    }
    
    SelectedText := Clipboard
    ConvertedText := ConvertText(SelectedText)
    
    ; 4. Paste Converted Text
    Clipboard := ConvertedText
    Send, ^v
    Sleep, 100
    
    ; Restore Clipboard
    Clipboard := ClipboardOld
return

; --- Conversion Logic ---
ConvertText(text) {
    static EN_TO_HE := {"q":"/", "w":"'", "e":"ק", "r":"ר", "t":"א", "y":"ט", "u":"ו", "i":"ן", "o":"ם", "p":"פ", "[":"]", "]":"[", "a":"ש", "s":"ד", "d":"ג", "f":"כ", "g":"ע", "h":"י", "j":"ח", "k":"ל", "l":"ך", ";":"ף", "'":",", "z":"ז", "x":"ס", "c":"ב", "v":"ה", "b":"נ", "n":"מ", "m":"צ", ",":"ת", ".":"ץ", "/":"."}
    
    static HE_TO_EN := {"/":"q", "'":"w", "ק":"e", "ר":"r", "א":"t", "ט":"y", "ו":"u", "ן":"i", "ם":"o", "פ":"p", "]":"[", "[":"]", "ש":"a", "ד":"s", "ג":"d", "כ":"f", "ע":"g", "י":"h", "ח":"j", "ל":"k", "ך":"l", "ף":";", ",":"'", "ז":"z", "ס":"x", "ב":"c", "ה":"v", "נ":"b", "מ":"n", "צ":"m", "ת":",", "ץ":".", ".":"/"}

    ; Simplified conversion logic for AHK
    result := ""
    Loop, Parse, text
    {
        char := A_LoopField
        if (EN_TO_HE.HasKey(char))
            result .= EN_TO_HE[char]
        else if (HE_TO_EN.HasKey(char))
            result .= HE_TO_EN[char]
        else
        {
            ; Check uppercase EN
            StringLower, lowerChar, char
            if (EN_TO_HE.HasKey(lowerChar))
                result .= EN_TO_HE[lowerChar]
            else
                result .= char
        }
    }
    return result
}

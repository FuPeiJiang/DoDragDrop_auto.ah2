#SingleInstance force
ListLines 0
KeyHistory 0
SendMode "Input" ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir A_ScriptDir ; Ensures a consistent starting directory.

SetWinDelay -1

f1::{
	parentDir:="C:\"
	namesArr:=["example.txt","example2.txt"]

	hWnd:=0
	locked:=false
	okNowWhat() {
		MyWndProc(hWnd, uMsg, wParam, lParam) {
			switch (uMsg) {

				case 0x0200: ;WM_MOUSEMOVE
					if (locked) {
						return DllCall("DefWindowProc","Ptr",hWnd,"Uint",uMsg,"UInt64",wParam,"Int64",lParam)
					}
					locked:=true
					DllCall("shell32\SHParseDisplayName","Str",parentDir,"Uint",0,"Ptr*",&pidl:=0,"Uint",0,"Uint",0)
					DllCall("ole32\IIDFromString","Str","{000214E6-0000-0000-C000-000000000046}","Ptr",IID_IShellFolder:=Buffer(16))
					DllCall("shell32\SHBindToObject","Ptr",0,"Ptr",pidl,"Ptr",0,"Ptr",IID_IShellFolder,"Ptr*",&pIShellFolder:=0)
					apidl:=Buffer(namesArr.Length * A_PtrSize)
					for k, v in namesArr {
						;IShellFolder:ParseDisplayName
						ComCall(3,pIShellFolder,"Ptr",0,"Ptr",0,"Wstr",v,"Ptr",0,"Ptr*",&tmpPIDL:=0,"Ptr",0) ;IShellFolder:ParseDisplayName
						NumPut("Ptr",tmpPIDL,apidl,(k - 1)*A_PtrSize)
					}
					DllCall("ole32\IIDFromString","Str","{0000010e-0000-0000-c000-000000000046}","Ptr",IID_IDataObject:=Buffer(16))
					DllCall("shell32\SHCreateDataObject","Ptr",pidl,"Uint",namesArr.Length,"Ptr",apidl,"Ptr",0,"Ptr",IID_IDataObject,"Ptr*",&pDataObject:=0)
					Send "{Lbutton down}"
					DllCall("shell32\SHDoDragDrop","Ptr",0,"Ptr",pDataObject,"Ptr",0,"UInt",7,"Ptr*",&Effect:=0,"Ptr") ; 7=DROPEFFECT_COPY | DROPEFFECT_MOVE | DROPEFFECT_LINK
					DllCall("DestroyWindow","Ptr",hWnd) ; 7=DROPEFFECT_COPY | DROPEFFECT_MOVE | DROPEFFECT_LINK
			}
			return DllCall("DefWindowProc","Ptr",hWnd,"Uint",uMsg,"UInt64",wParam,"Int64",lParam)
		}
		if (!okNowWhat.HasOwnProp("hihi")) {
			DllCall("ole32\OleInitialize","Ptr",0)
			okNowWhat.hihi:=1
			WNDCLASSEXW := Buffer(0x50)
			NumPut("Uint", 0x50, WNDCLASSEXW, 0x0) ;cbSize
			NumPut("Uint", 3, WNDCLASSEXW, 0x4) ;Style
			; hmodule:=DllCall("GetModuleHandleA","AStr","user32","Ptr")
			; proc_adddress:=DllCall("GetProcAddress","Ptr",hmodule,"AStr","DefWindowProcW","Ptr")
			; NumPut("Ptr",proc_adddress, WNDCLASSEXW, 0x8) ;lpfnWndProc
			NumPut("Ptr",CallbackCreate(MyWndProc), WNDCLASSEXW, 0x8) ;lpfnWndProc
			NumPut("Int", 0, WNDCLASSEXW, 0x10) ;cbClsExtra
			NumPut("Int", 0, WNDCLASSEXW, 0x1C) ;cbWndExtra
			NumPut("Ptr", 0, WNDCLASSEXW, 0x18) ;hInstance
			NumPut("Ptr", 0, WNDCLASSEXW, 0x20) ;hIcon
			NumPut("Ptr", DllCall("LoadCursorA","Ptr",0,"Ptr",32512,"Ptr"), WNDCLASSEXW, 0x28) ;hCursor
			NumPut("Ptr", DllCall("CreateSolidBrush", "Uint", 0x000000, "Ptr"), WNDCLASSEXW, 0x30) ;hbrBackground
			NumPut("Ptr", 0, WNDCLASSEXW, 0x38) ;lpszMenuName
			class_name := Buffer(StrPut("ResizableWindow", "UTF-16"))
			StrPut("ResizableWindow", class_name.Ptr, "UTF-16")
			NumPut("Ptr", class_name.Ptr, WNDCLASSEXW, 0x40)
			NumPut("Ptr", 0, WNDCLASSEXW, 0x48)
			ret:=DllCall("RegisterClassExW", "Ptr", WNDCLASSEXW, "Ptr")
		}
		MouseGetPos &OutputVarX, &OutputVarY
		hWnd:=DllCall("CreateWindowExW","Uint",0,"Str","ResizableWindow","Str","My Resizable Window","Uint",0x80000000,"Int",(OutputVarX - 200),"Int",(OutputVarY - 200),"Int",400,"Int",400,"Ptr",0,"Ptr",0,"Ptr",0,"Ptr",0,"Ptr")
		DllCall("SetWindowLongPtrW","Ptr",hWnd,"Int",-4,"Ptr",CallbackCreate(MyWndProc))
		DllCall("ShowWindow","Ptr",hWnd,"Int",1)
		WinActivate hWnd

		msg:=Buffer(0x30)
		while (DllCall("GetMessage","Ptr",msg,"Ptr",hWnd,"Uint",0,"Uint",0))
		{
			if (locked) {
				break
			}
			DllCall("TranslateMessage","Ptr",msg)
			DllCall("DispatchMessage","Ptr",msg)
		}
	}
	ok:=DllCall("CreateThread","Ptr",0,"Ptr",0,"Ptr",CallbackCreate(okNowWhat),"Ptr",0,"Uint",0,"Ptr",0,"Ptr")

	DllCall("Sleep","Uint",100) ;increasing this "could" help
	WinHide hWnd
	DllCall("Sleep","Uint",300) ;uncommenting this "could" help
	Send "{Lbutton up}"
}

return

f3::Exitapp
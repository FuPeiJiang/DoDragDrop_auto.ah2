#SingleInstance force
ListLines 0
KeyHistory 0
SendMode "Input" ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir A_ScriptDir ; Ensures a consistent starting directory.

f1::{
	parentDir:="C:\"
	namesArr:=["example.txt","example2.txt"]

	myGui:=Gui()
	DllCall("SetWindowLongPtrW","Ptr",myGui.Hwnd,"Int",-16,"Ptr",0x80000000)

	MouseGetPos &OutputVarX, &OutputVarY
	myGui.Show("w400 h400 x" (OutputVarX - 200) " y" (OutputVarY - 200))
	Send "{Lbutton down}"
	okNowWhat() {
		DllCall("Sleep","Uint",100) ;uncommenting this "could" help
		myGui.Destroy()
		DllCall("Sleep","Uint",300) ;increasing this "could" help
		Send "{Lbutton up}"
	}
	ok:=DllCall("CreateThread","Ptr",0,"Ptr",0,"Ptr",CallbackCreate(okNowWhat),"Ptr",0,"Uint",0,"Ptr",0,"Ptr")

	DllCall("shell32\SHParseDisplayName","Str",parentDir,"Uint",0,"Ptr*",&pidl:=0,"Uint",0,"Uint",0)
	DllCall('ole32\IIDFromString','Str',"{000214E6-0000-0000-C000-000000000046}",'Ptr',IID_IShellFolder:=Buffer(16))
	DllCall("shell32\SHBindToObject","Ptr",0,"Ptr",pidl,"Ptr",0,"Ptr",IID_IShellFolder,"Ptr*",&pIShellFolder:=0)
	apidl:=Buffer(namesArr.Length * A_PtrSize)
	for k, v in namesArr {
		;IShellFolder:ParseDisplayName
		ComCall(3,pIShellFolder,"Ptr",0,"Ptr",0,"Wstr",v,"Ptr",0,"Ptr*",&tmpPIDL:=0,"Ptr",0) ;IShellFolder:ParseDisplayName
		NumPut("Ptr",tmpPIDL,apidl,(k - 1)*A_PtrSize)
	}
	DllCall("ole32\IIDFromString","Str","{0000010e-0000-0000-c000-000000000046}","Ptr",IID_IDataObject:=Buffer(16))
	DllCall("shell32\SHCreateDataObject","Ptr",pidl,"Uint",namesArr.Length,"Ptr",apidl,"Ptr",0,"Ptr",IID_IDataObject,"Ptr*",&pDataObject:=0)
	DllCall("shell32\SHDoDragDrop","Ptr",0,"Ptr",pDataObject,"Ptr",0,"UInt",7,"Ptr*",&Effect:=0,"Ptr") ; 7=DROPEFFECT_COPY | DROPEFFECT_MOVE | DROPEFFECT_LINK
}

return

f3::Exitapp
drop files programmatically to area under mouse

```ahk
parentDir:="C:\"
namesArr:=["example.txt","example2.txt"]
```

a sleep delay of 300 makes it work for discord, for windows apps, 50 is enough:
```ahk
DllCall("Sleep","Uint",300) ;increasing this "could" help
```
\_\_\_<br>
you may ignore "DoDragDrop_auto2.ah2", it's more of a showcase of creating the gui on a new thread
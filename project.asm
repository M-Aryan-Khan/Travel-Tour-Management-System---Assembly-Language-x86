INCLUDE Irvine32.inc
INCLUDE macros.inc 

BUFFER_SIZE = 200
BUFFER_SIZE2 = 5000

.data
    
    filehandle HANDLE ?
    filehandle2 HANDLE ?

    filename BYTE "admin.txt", 0
    TPackagesFile BYTE "totalPackages.txt", 0
    TCustomerFile BYTE "totalCustomers.txt", 0
    PackagesFile BYTE "packages.txt",0
    CustomersFile BYTE "customers.txt",0

    buffer BYTE BUFFER_SIZE DUP (?)
    buffer2 BYTE BUFFER_SIZE2 DUP (?)

    username BYTE 10 DUP(?)
    cusername BYTE 10 DUP(?)
    password byte 10 dup (?)
    cpassword byte 10 dup (?)
    Tcustomer BYTE 10 DUP(?)
    Tpackage BYTE 10 DUP(?)
    packageName BYTE 30 DUP(?)
    destination BYTE 15 DUP(?)
    tripTimePeriod BYTE 10 DUP(?)
    departureDate BYTE 10 DUP(?)
    price BYTE 10 DUP(?)
    customerName BYTE 20 DUP(?)
    packageSelected BYTE 30 DUP(?)
    contact BYTE 12 DUP(?)
    address BYTE 20 DUP(?)
    dob BYTE 12 DUP(?)
    passport BYTE 12 DUP(?)

    newline BYTE "," ,0dh, 0ah
    collonNewLine BYTE 0dh, 0ah, ";"
    commaSpace BYTE ","
    nline BYTE 0dh,0ah
    tabspace BYTE "     ", 0
    backspace BYTE 08h

    len dword 0
    row byte ?
    row2 byte ?
    count byte 0
    countT dword 0
    countTP dword 0

;-------------------------------------------Main PROC------------------------------------------

.code
Main PROC
    mov eax, 0 + (7 * 16)
    call settextcolor
    call waitmsg
    call Clrscr
    mov edx, offset filename
    call openinputfile
    mov filehandle, eax
    call closefile
    mov eax, filehandle
    cmp eax, INVALID_HANDLE_VALUE
    je cAdminFile
    jmp saveUP

cAdminFile:
    call createAdminFile

saveUP:
    call saveUserPass
compareUP:
    call compareUserPass
    mGotoxy 0, 30
exit
Main ENDP

;-------------------------------------------MY Delay PROC----------------------------------------

delayy proc
    mov eax, 2000
    call delay
ret
delayy endp

;---------------------------------------Compare user and pass------------------------------------

compareUserPass PROC
    call Clrscr
    user:
        mGotoxy 95, 10
        mov eax, 5 + (7 * 16)
        call settextcolor
        mwrite "Admin Login"
        call Crlf
        mov eax, blue + (7 * 16)
        call settextcolor
        mGotoxy 93, 12
        mwrite "username: "
        mov eax, black + (7 * 16)
        call settextcolor
        mov edx, offset cuserName
        mov ecx, sizeof cuserName
        call readstring
        INVOKE Str_compare, ADDR username, ADDR cusername
        je pass
        jmp userFail

    pass:
        mov eax, blue + (7 * 16)
        call settextcolor
        mGotoxy 93, 14
        mwrite "password: "
        mov eax, 103
        mov row, al
        mov eax, black + (7 * 16)
        call settextcolor
        mov ecx, lengthof cpassword
        mov esi, offset cpassword
        mGotoxy 103, 14
        mov ecx, 10
        mov eax, 0
        mov bl, nline

    l3:
        call ReadChar
        cmp al, bl
        je passReadEnd
        cmp al, backspace
        jne contPassRead
        dec dh
        call Gotoxy
        mov al, backspace
        call writechar
        mov al, " "
        call writechar
        mov al, backspace
        call writechar
        dec dh
        call Gotoxy
        dec esi
    jmp l3
    contPassRead:
        mov [esi], eax
        mov al, '*'
        call writechar
        inc esi
    jmp l3

    passReadEnd:
        mov byte ptr [esi], 0
        INVOKE Str_compare, ADDR password, ADDR cpassword
        je equal
        jmp passFail
    
    equal:
        call Crlf
        mov eax, green + (7 * 16)
        call settextcolor
        mGotoxy 94, 16
        mwrite "Logging in..."
        call delayy
        call Clrscr
        mov eax, 0 + (7 * 16)
        call settextcolor
        call DashboardDisplay
        ret
    userFail:
        mov eax, red + (7 * 16)
        call settextcolor
        mGotoxy 92, 14
        mwrite "Username Incorrect"
        mov eax, cyan + (7 * 16)
        call settextcolor

        mGotoxy 78, 15
        mwrite "->Login Again<-, "
        mov eax, 0 + (7 * 16)
        call settextcolor
        call WaitMsg
        call Clrscr
        call compareUserPass
    passFail:
        call Crlf
        mov eax, red + (7 * 16)
        call settextcolor
        mGotoxy 92, 16
        mwrite "Password Incorrect"
        mov eax, 0 + (7 * 16)
        call settextcolor
        mGotoxy 83, 17
        mwrite "Enter any key to "
        mov eax, cyan + (7 * 16)
        call settextcolor
        mwrite "->Login Again<-...."
        call ReadChar
        mov eax, 0
        call Clrscr
        call compareUserPass

compareUserPass ENDP

;---------------------------------------save user and pass------------------------------------

saveUserPass PROC

    mov edx, offset filename
    call openinputfile
    mov filehandle, eax
    mov edx, offset buffer
    mov ecx, buffer_size
    call readfromfile
    mov eax, filehandle
    call closefile
    mov esi, offset buffer
    mov edi, offset username
    mov bl, newline
    l1:
        mov dl, byte ptr [esi]
        cmp dl, bl
        je lab
        mov byte ptr [edi], dl
        inc esi
        inc edi
        jmp l1

        lab:
        inc edi
        mov byte ptr [edi], 0
        add esi, 3
        mov edi, offset password
        
    l2:
        mov dl, byte ptr [esi]
        cmp dl, bl
        je here
        mov byte ptr [edi], dl
        inc esi
        inc edi
        jmp l2

    here:
        inc edi
        mov byte ptr [edi], 0

ret
saveUserPass ENDP

;---------------------------------------create Admin File---------------------------------------

createAdminFile PROC
    call gotoxy
    mov row, dh
    mov edx, OFFSET filename
    call CreateOutputFile
    mov filehandle, eax
    mGotoxy 90, 10
    mov eax, 5 + (7 * 16)
    call settextcolor
    mwrite "Create Admin Profile"
    mov eax, blue + (7 * 16)
    call settextcolor
    mGotoxy 92, 12
    mwrite "username: "
    mov eax, Gray + (7 * 16)
    call settextcolor
    mov edx, OFFSET buffer
    mov ecx, BUFFER_SIZE
    mov eax, black + (7 * 16)
    call settextcolor
    mov eax,0
    call ReadString
    mov len, eax
    mov eax, filehandle
    mov edx, OFFSET buffer
    mov ecx, len
    call WriteToFile
    mov eax, filehandle
    mov edx, offset newline
    mov ecx, sizeof newline
    call WriteToFile

    mov dh, row
    add dh, 2
    call gotoxy
    mov ebx, 0
    mov eax, blue + (7 * 16)
    call settextcolor
    mGotoxy 92, 14
    mwrite "password: "
    mov eax, black + (7 * 16)
    call settextcolor
    mov ecx, lengthof password
    mov esi, offset password
    mGotoxy 102, 14
    mov ecx, 10
    mov eax, 0
    mov bl, nline
    l4:
        call ReadChar
        cmp al, bl
        je passReadEndd
        cmp al, 08h
        jne contPassReadd
        dec dh
        call Gotoxy
        mov al, backspace
        call writechar
        mov al, " "
        call writechar
        mov al, backspace
        call writechar
        dec dh
        call Gotoxy
        dec esi
    jmp l4
    contPassReadd:
        mov [esi], eax
        mov al, '*'
        call writechar
        inc esi
    jmp l4

    passReadEndd:
        mov byte ptr [esi], 0
    next:
        mov eax, filehandle
        mov edx, OFFSET password
        mov ecx, ebx
        call WriteToFile
        mov eax, filehandle
        mov edx, offset newline
        mov ecx, sizeof newline
        call WriteToFile
        mov eax, filehandle
        call CloseFile
        call Crlf
        mov eax, green + (7 * 16)
        call settextcolor
        mGotoxy 86, 16
        mwrite "->Account Created Succesfuly<-, "
        call Crlf
        mGotoxy 76, 17
        mov eax, 12 + (7 * 16)
        call settextcolor
        mwrite "Now Login To Account, "
        mov eax, 0 + (7 * 16)
        call settextcolor
        call WaitMsg
        call Clrscr
    ret
createAdminFile ENDP

;---------------------------------------Dashboard Display---------------------------------------

DashboardDisplay PROC
    call Clrscr
    mGotoxy 60, 7
    mwrite "_____________________________________________________________________________________"
    mGotoxy 60, 8
    mwrite "|                        |                                 |                        |"
    mGotoxy 60, 9
    mwrite "|                        |                                 |                        |"
    mov eax, blue + (7 * 16)
    call settextcolor
    mGotoxy 65, 9
    mwrite "LIFETIME TOTAL"
    mov eax, 5 + (7 * 16)
    call settextcolor
    mGotoxy 98, 9
    mwrite "DASHBOARD"
    mov eax, red + (7 * 16)
    call settextcolor
    mGotoxy 124, 9
    mwrite "CURRENT ACTIVE"
    mov eax, 0 + (7 * 16)
    call settextcolor
    mGotoxy 60, 10
    mwrite "|                        |_________________________________|                        |"
    mov eax, blue + (7 * 16)
    call settextcolor
    mGotoxy 67, 10
    mwrite "CUSTOMERS"
    mov eax, red + (7 * 16)
    call settextcolor
    mGotoxy 128, 10
    mwrite "PACKAGES"
     mov eax, 0 + (7 * 16)
    call settextcolor
    mGotoxy 60, 11
    mwrite "|________________________|                                 |________________________|"
    mGotoxy 60, 12
    mwrite "|                        | 1. Add New Customer             |                        |"
    mGotoxy 60, 13
    mwrite "|                        |                                 |                        |"
    mGotoxy 60, 14
    mwrite "|________________________| 2. Display Customers            |________________________|"
    mGotoxy 60, 15
    mwrite "                         |                                 |"
    mGotoxy 60, 16
    mwrite "                         | 3. Add New Package              |"
    mGotoxy 60, 17
    mwrite "                         |                                 |"
    mGotoxy 60, 18
    mwrite "                         | 4. Display Packages             |"
    mGotoxy 60, 19
    mwrite "                         |                                 |"
    mGotoxy 60, 20
    mwrite "                         | 5. Exit                         |"
    mGotoxy 60, 21
    mwrite "                         |_________________________________|"
    mov eax, green + (7 * 16)
    call settextcolor
    call TPackageDisplay
    call TCustomerDisplay
    mov eax, 0 + (7 * 16)
    call settextcolor
    mGotoxy 90, 24
    mwrite "Choose the Operation: "
    call ReadDec
    call WriteDec
    cmp eax, 1
    je addCus
    cmp eax, 2
    je viewCus
    cmp eax, 3
    je addPac
    cmp eax, 4
    je viewPac
    cmp eax, 5
    jne again
    ret
    addCus:
        call AddCustomer
        jmp callagain
    viewCus:
        call StructDisplayCustomer
        jmp callagain
    addPac:
        call AddPackage
        jmp callagain
    viewPac:
        call StructDisplayPackage
        jmp callagain
    again:
        mGotoxy 95, 26
        mov eax, red + (7 * 16)
        call settextcolor
        mwrite "Invalid Choice"
        mGotoxy 88, 27
        mov eax, 0 + (7 * 16)
        call settextcolor
        call waitmsg
    callagain:
        call DashboardDisplay

DashboardDisplay ENDP

;-------------------------------------- T. Package Display---------------------------------------

TPackageDisplay PROC
    push ebp
    mov ebp, esp
    sub esp, 4
    mov edx, offset packagesFile
    call openInputFile
    mov filehandle, eax
    mov edx, offset buffer2
    mov ecx, buffer_size2
    call ReadFromFile
    mov len, eax
    mov eax, 0
    mov countTP, eax
    mov eax, filehandle
    call closefile
    mov esi, offset buffer2
    mov ecx, len
    count_loop:
        mov  al, [esi]  
        cmp  al, ';'
        je   increment_count              
        jmp  continue_loop  

    increment_count:
        mov ebx, countTP
        inc ebx
        mov countTP, ebx

    continue_loop:
        inc  esi        
    loop count_loop
    outttt:
    mgotoxy 132, 13
    mov eax, countTP
    call writedec
    lea  edi, buffer2
    mov  ecx, len
    mov  eax, 0
    rep  stosb
    mov esp, ebp
    pop ebp
ret
TPackageDisplay ENDP

;---------------------------------------T. Customer Display---------------------------------------

TCustomerDisplay PROC
    push ebp
    mov ebp, esp
    sub esp, 4
    mov edx, offset CustomersFile
    call openInputFile
    mov filehandle, eax
    mov edx, offset buffer2
    mov ecx, buffer_size2
    call ReadFromFile
    mov len, eax
    mov eax, 0
    mov countT, eax
    mov eax, filehandle
    call closefile
    mov esi, offset buffer2
    mov ecx, len
    count_loop:
        mov  al, [esi]  
        cmp  al, ';'
        je   increment_count              
        jmp  continue_loop  

    increment_count:
        mov ebx, countT
        inc ebx
        mov countT, ebx

    continue_loop:
        inc  esi        
    loop count_loop
    outttt:
    mgotoxy 71, 13
    mov eax, countT
    call writedec
    lea  edi, buffer2
    mov  ecx, len
    mov  eax, 0
    rep  stosb
    mov esp, ebp
    pop ebp
ret
TCustomerDisplay ENDP

;------------------------------------create Package File-----------------------------------

CreatePackageFile PROC
    mov edx, offset PackagesFile
    call createOutputFile
    mov filehandle, eax
    call closeFile

ret
CreatePackageFile ENDP

;---------------------------------------Add Packages---------------------------------------

AddPackage PROC
    call clrscr
    mov edx, offset PackagesFile
    call openinputfile
    mov filehandle, eax
    call closefile
    mov eax, filehandle
    cmp eax, INVALID_HANDLE_VALUE
    jne pckgNext
    call CreatePackageFile

    pckgNext:
        invoke createFile, ADDR PackagesFile, GENERIC_WRITE, 0, NULL, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
        mov fileHandle,eax
        invoke SetFilePointer, fileHandle, 0, 0, FILE_END
        mGotoxy 90, 8
        mov eax, 0 + (7 * 16)
        call settextcolor
        mwrite "_________________________"
        mGotoxy 90, 9
        mwrite "|                       |"
        mgotoxy 90, 10
        mwrite "|                       |"
        mgotoxy 94, 10
        mov eax, 5 + (7*16)
        call settextcolor
        mwrite "ADD A NEW PACKAGE"
        mov eax, 0 + (7 * 16)
        call settextcolor
        mGotoxy 90, 11
        mwrite "|_______________________|"

        mov eax, blue + (7 * 16)
        call settextcolor
        mgotoxy 85, 15
        mwrite "Package Name:"
        mov edx, offset packageName
        mov ecx, lengthof packagename
        mov eax, 0 + (7 * 16)
        call settextcolor
        mgotoxy 102, 15
        call ReadString
        mov len, eax
        mov eax, filehandle
        mov edx, offset packageName
        mov ecx, len
        call writeToFile

        call Crlf

        mov eax, filehandle
        mov edx, offset commaSpace
        mov ecx, lengthof commaSpace
        call writeToFile

        mov eax, blue + (7 * 16)
        call settextcolor
        mgotoxy 85, 17
        mwrite "Price:"
        mov edx, offset price
        mov ecx, lengthof price
        mov eax, 0 + (7 * 16)
        call settextcolor
        mgotoxy 102, 23
        call ReadString
        mov len, eax
        mov eax, filehandle
        mov edx, offset price
        mov ecx, len
        call writeToFile

        call Crlf

        mov eax, filehandle
        mov edx, offset commaSpace
        mov ecx, lengthof commaSpace
        call writeToFile

        call Crlf

        mov eax, blue + (7 * 16)
        call settextcolor
        mgotoxy 85, 19
        mwrite "Destination(s):"
        mov edx, offset destination
        mov ecx, lengthof destination
        mov eax, 0 + (7 * 16)
        call settextcolor
        mgotoxy 102, 17
        call ReadString
        mov len, eax
        mov eax, filehandle
        mov edx, offset destination
        mov ecx, len
        call writeToFile

        call Crlf

        mov eax, filehandle
        mov edx, offset commaSpace
        mov ecx, lengthof commaSpace
        call writeToFile

        mov eax, blue + (7 * 16)
        call settextcolor
        mgotoxy 85, 21
        mwrite "Time Period:"
        mov edx, offset tripTimePeriod
        mov ecx, lengthof tripTimePeriod
        mov eax, 0 + (7 * 16)
        call settextcolor
        mgotoxy 102, 19
        call ReadString
        mov len, eax
        mov eax, filehandle
        mov edx, offset tripTimePeriod
        mov ecx, len
        call writeToFile

        call Crlf

        mov eax, filehandle
        mov edx, offset commaSpace
        mov ecx, lengthof commaSpace
        call writeToFile

        mov eax, blue + (7 * 16)
        call settextcolor
        mgotoxy 85, 23
        mwrite "Departure Date:"
        mov edx, offset departureDate
        mov ecx, lengthof departureDate
        mov eax, 0 + (7 * 16)
        call settextcolor
        mgotoxy 102, 21
        call ReadString
        mov len, eax
        mov eax, filehandle
        mov edx, offset departureDate
        mov ecx, len
        call writeToFile

        call Crlf

        mov eax, filehandle
        mov edx, offset collonNewLine
        mov ecx, lengthof collonNewLine
        call writeToFile
    
        mov eax, filehandle
        call closeFile
        ret
AddPackage ENDP

;---------------------------------------Display Packages---------------------------------------

DisplayPackage PROC
    push ebp
    mov ebp, esp
    sub esp, 4
    mov edx, offset PackagesFile
    call openInputFile
    mov filehandle, eax
    mov edx, offset buffer2
    mov ecx, buffer_size2
    call ReadFromFile
    mov len, eax
    mov eax, filehandle
    call closefile
    mov esi, offset buffer2
    mov ecx, len
    mov dh, 12
    mov dl, 57
    mov row,57
    mainDisplay:
        mGotoxy dl, dh
        push ecx
        mov bl, 0
        cmp bl, [esi]
        je outt
        mov bl, collonNewLine
        cmp bl, [esi]
        jne nextD
        add esi, 3
        add dh, 1
        mov dl, 57
        mov row, dl
        mGotoxy dl, dh
        call Crlf
        jmp mainDisplay
        nextD:
            mov bl, commaSpace
            cmp bl, [esi]
            jne nextD2
            inc esi
            mov dl, row
            inc dl
            add dl, 18
            mov row, dl
            mGotoxy dl, dh
            jmp mainDisplay
        nextD2:
            mov al, [esi]
            call WriteChar
            inc dl
            inc esi
        pop ecx
    loop mainDisplay
    outt:
    mov esp, ebp
    pop ebp
ret
DisplayPackage ENDP

;-----------------------------------Struct Display Packages---------------------------------------

StructDisplayPackage PROC
    call Clrscr
    mov eax, 0 + (7 * 16)
    call settextcolor
    mGotoxy 55, 7
    mwrite "________________________________________________________________________________________________"
    mGotoxy 55, 8
    mwrite "|                  |                  |                  |                  |                  |"
    mGotoxy 55, 9
    mwrite "|                  |                  |                  |                  |                  |"
    mov eax, 5 + (7 * 16)
    call settextcolor
    mGotoxy 57, 9
    mwrite "Package"
    mov eax, 13 + (7 * 16)
    call settextcolor
    mGotoxy 76, 9
    mwrite "Price Per Person"
    mov eax, blue + (7 * 16)
    call settextcolor
    mGotoxy 95, 9
    mwrite "Trip Period"
    mov eax, red + (7 * 16)
    call settextcolor
    mGotoxy 114, 9
    mwrite "Departure Date"
    mov eax, green + (7 * 16)
    call settextcolor
    mGotoxy 133, 9
    mwrite "Destination(s)"
    mov eax, 0 + (7 * 16)
    call settextcolor
    mGotoxy 55, 10
    mwrite "|__________________|__________________|__________________|__________________|__________________|"
    mov ecx, countTP
    inc ecx
    mov dh, 11
    mov dl, 55
    call Gotoxy
    l2:
        mwrite "|                  |                  |                  |                  |                  |"
        inc dh
        call Gotoxy
    loop l2
    mwrite "|__________________|__________________|__________________|__________________|__________________|"
    mov dl, 112
    add dh, 2
    mov row2, dh
    call gotoxy
    mwrite "Press Any Key To Go Back To Dashboard..."
    call DisplayPackage
    mov dl, 152
    mov dh, row2
    call gotoxy
    call readchar
ret
StructDisplayPackage ENDP

;---------------------------------------Display Package Customer---------------------------------------

DisplayPackageForCustomer PROC
    push ebp
    mov ebp, esp
    sub esp, 4
    mov edx, offset PackagesFile
    call openInputFile
    mov filehandle2, eax
    mov edx, offset buffer2
    mov ecx, buffer_size2
    call ReadFromFile
    mov len, eax
    mov eax, filehandle2
    call closefile
    mov esi, offset buffer2
    mov ecx, len
    mov dh, 17
    mov dl, 97
    mov row,97
    mov eax, 0
    mov len, eax
    mGotoxy dl, dh
    mainDisplay:
        mGotoxy dl, dh
        push ecx
        mov bl, 0
        cmp bl, [esi]
        je outt
        mov bl, collonNewLine
        cmp bl, [esi]
        jne nextD
        add esi, 3
        add dh, 1
        mov dl, 97
        mov row, dl
        mGotoxy dl, dh
        mov eax, len
        inc eax
        mov len, eax
        call Crlf
        jmp mainDisplay
        nextD:
            mov bl, commaSpace
            cmp bl, [esi]
            jne nextD2
            l1:
                inc esi
                mov bl, collonNewLine
                cmp bl, [esi]
                je mainDisplay
                jmp l1
        nextD2:
            mov al, [esi]
            call WriteChar
            inc dl
            inc esi
        pop ecx
    loop mainDisplay
    outt:
    mov ecx, len
    mov ebx, 0
    mov row, bl
    mov row, cl
    mov dh, 17
    mov dl, 95
    call Gotoxy
    l2:
        mov al, count
        inc al
        mov count, al
        call WriteDec
        mov al, '.'
        call writechar
        inc dh
        mov dl, 95
        call gotoxy
    loop l2
    mov esp, ebp
    pop ebp
ret
DisplayPackageForCustomer ENDP

;------------------------------------create Customers File-----------------------------------

CreateCustomerFile PROC
    mov edx, offset CustomersFile
    call createOutputFile
    mov filehandle, eax
    call closeFile

ret
CreateCustomerFile ENDP

;---------------------------------------Add Customers---------------------------------------

AddCustomer PROC
    call clrscr
    mov edx, offset CustomersFile
    call openinputfile
    mov filehandle, eax
    call closefile
    mov eax, filehandle
    cmp eax, INVALID_HANDLE_VALUE
    jne cusNext
    call CreateCustomerFile

    cusNext:
        invoke createFile, ADDR CustomersFile, GENERIC_WRITE, 0, NULL, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
        mov fileHandle,eax
        invoke SetFilePointer, fileHandle, 0, 0, FILE_END
        mGotoxy 90, 8
        mov eax, 0 + (7 * 16)
        call settextcolor
        mwrite "__________________________"
        mGotoxy 90, 9
        mwrite "|                        |"
        mgotoxy 90, 10
        mwrite "|                        |"
        mgotoxy 94, 10
        mov eax, 5 + (7*16)
        call settextcolor
        mwrite "ADD A NEW CUSTOMER"
        mov eax, 0 + (7 * 16)
        call settextcolor
        mGotoxy 90, 11
        mwrite "|________________________|"

        mov eax, blue + (7 * 16)
        call settextcolor
        mgotoxy 85, 15
        mwrite "Customer Name:"
        mov edx, offset customerName
        mov ecx, lengthof customerName
        mov eax, 0 + (7 * 16)
        call settextcolor
        mgotoxy 104, 15
        call ReadString
        mov len, eax
        mov eax, filehandle
        mov edx, offset customerName
        mov ecx, len
        call writeToFile

        call Crlf

        mov eax, filehandle
        mov edx, offset commaSpace
        mov ecx, lengthof commaSpace
        call writeToFile

        call DisplayPackageForCustomer
        mov eax, blue + (7 * 16)
        call settextcolor
        mgotoxy 85, 17
        mwrite "Packages:"
        mov bl, row
        inc bl
        add bl, 17
        mgotoxy 85, bl
        mwrite "Select: "
        mov eax, 0 + (7 * 16)
        call settextcolor
        mgotoxy 104, bl
        mov edx, offset packageSelected
        mov ecx, lengthof packageSelected
        call ReadString
        mov len, eax
        mov eax, filehandle
        mov edx, offset packageSelected
        mov ecx, len
        call writeToFile

        call Crlf

        mov eax, filehandle
        mov edx, offset commaSpace
        mov ecx, lengthof commaSpace
        call writeToFile

        mov eax, blue + (7 * 16)
        call settextcolor
        add bl, 2
        mgotoxy 85, bl
        mwrite "Contact (4-7):"
        mov edx, offset contact
        mov ecx, lengthof contact
        mov eax, 0 + (7 * 16)
        call settextcolor
        mgotoxy 104, bl
        call ReadString
        mov len, eax
        mov eax, filehandle
        mov edx, offset contact
        mov ecx, len
        call writeToFile

        call Crlf

        mov eax, filehandle
        mov edx, offset commaSpace
        mov ecx, lengthof commaSpace
        call writeToFile

        mov eax, blue + (7 * 16)
        call settextcolor
        add bl, 2
        mgotoxy 85, bl
        mwrite "Address: "
        mov edx, offset address
        mov ecx, lengthof address
        mov eax, 0 + (7 * 16)
        call settextcolor
        mgotoxy 104, bl
        call ReadString
        mov len, eax
        mov eax, filehandle
        mov edx, offset address
        mov ecx, len
        call writeToFile

        call Crlf

        mov eax, filehandle
        mov edx, offset commaSpace
        mov ecx, lengthof commaSpace
        call writeToFile

        mov eax, blue + (7 * 16)
        call settextcolor
        add bl, 2
        mgotoxy 85, bl
        mwrite "DOB (mm/dd/yyyy):"
        mov edx, offset dob
        mov ecx, lengthof dob
        mov eax, 0 + (7 * 16)
        call settextcolor
        mgotoxy 104, bl
        call ReadString
        mov len, eax
        mov eax, filehandle
        mov edx, offset dob
        mov ecx, len
        call writeToFile

        call Crlf

        mov eax, filehandle
        mov edx, offset commaSpace
        mov ecx, lengthof commaSpace
        call writeToFile

        mov eax, blue + (7 * 16)
        call settextcolor
        add bl, 2
        mgotoxy 85, bl
        mwrite "Passport (Max 12):"
        mov edx, offset passport
        mov ecx, lengthof passport
        mov eax, 0 + (7 * 16)
        call settextcolor
        mgotoxy 104, bl
        call ReadString
        mov len, eax
        mov eax, filehandle
        mov edx, offset passport
        mov ecx, len
        call writeToFile

        call Crlf

        mov eax, filehandle
        mov edx, offset collonNewLine
        mov ecx, lengthof collonNewLine
        call writeToFile
    
        mov eax, filehandle
        call closeFile
        mov eax, green + (7 * 16)
        call settextcolor
        add bl, 2
        mgotoxy 90, bl
        mwrite "Customer Added Successfuly.."
        call delayy
        mov eax, 0 + (7 * 16)
        call settextcolor
        ret
AddCustomer ENDP

;-----------------------------------Struct Display Customer---------------------------------------

StructDisplayCustomer PROC
    call Clrscr
    mGotoxy 47, 7
    mwrite "___________________________________________________________________________________________________________________"
    mGotoxy 47, 8
    mwrite "|                  |                  |                  |                  |                  |                  |"
    mGotoxy 47, 9
    mwrite "|                  |                  |                  |                  |                  |                  |"
    mov eax, 5 + (7 * 16)
    call settextcolor
    mGotoxy 49, 9
    mwrite "FULL NAME"
    mov eax, 13 + (7 * 16)
    call settextcolor
    mGotoxy 68, 9
    mwrite "PACKAGE SELECTED"
    mov eax, blue + (7 * 16)
    call settextcolor
    mGotoxy 87, 9
    mwrite "CONTACT INFO"
    mov eax, red + (7 * 16)
    call settextcolor
    mGotoxy 106, 9
    mwrite "FULL ADDRESS"
    mov eax, green + (7 * 16)
    call settextcolor
    mGotoxy 125, 9
    mwrite "DATE OF BIRTH"
    mov eax, cyan + (7 * 16)
    call settextcolor
    mGotoxy 144, 9
    mwrite "PASSPORT NO."
    mov eax, 0 + (7 * 16)
    call settextcolor
    mGotoxy 47, 10
    mwrite "|__________________|__________________|__________________|__________________|__________________|__________________|"

    
    mov ecx, counTT
    inc ecx
    mov dh, 11
    mov dl, 47
    call Gotoxy
    l2:
        mwrite "|                  |                  |                  |                  |                  |                  |"
        inc dh
        call Gotoxy
    loop l2
    mwrite "|__________________|__________________|__________________|__________________|__________________|__________________|"
    call DisplayCustomer
    add dh,2
    mov dl, 123
    call Gotoxy
    mwrite "Press Any Key To Go Back To Dashboard..."
    call readchar
ret
StructDisplayCustomer ENDP

;---------------------------------------Display Customers---------------------------------------

DisplayCustomer PROC
    push ebp
    mov ebp, esp
    sub esp, 4
    mov edx, offset CustomersFile
    call openInputFile
    mov filehandle, eax
    mov edx, offset buffer2
    mov ecx, buffer_size2
    call ReadFromFile
    mov len, eax
    mov eax, filehandle
    call closefile
    mov esi, offset buffer2
    mov ecx, len
    mov dh, 12
    mov dl, 49 
    mov row,49
    mainDisplayC:
        mGotoxy dl, dh
        push ecx
        mov bl, 0
        cmp bl, [esi]
        je outtt
        mov bl, collonNewLine
        cmp bl, [esi]
        jne nextD3
        add esi, 3
        add dh, 1
        mov dl, 49
        mov row, dl
        mGotoxy dl, dh
        call Crlf
        jmp mainDisplayC
        nextD3:
            mov bl, commaSpace
            cmp bl, [esi]
            jne nextD4
            inc esi
            mov dl, row
            inc dl
            add dl, 18
            mov row, dl
            mGotoxy dl, dh
            jmp mainDisplayC
        nextD4:
            mov al, [esi]
            call WriteChar
            inc dl
            inc esi
        pop ecx
    loop mainDisplayC
    outtt:
    mov esp, ebp
    pop ebp
ret
DisplayCustomer ENDP

END Main

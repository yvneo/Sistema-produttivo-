.section .data
    fd: .int 0                          # File descriptor
    testo_errore: .ascii "Ops! Qualcosa non ha funzionato nella lettura del file\n\n"
    testo_errore_lunghezza: .long .- testo_errore
    numero_elementi: .int 0
    value: .int 0
    value_section: .int 0

    carattere_nuova_linea: .ascii "\n"
    cr: .ascii "\r"
    carattere_virgola: .ascii ","
    buffer: .string ""                  # Spazio per il buffer di input (salvo l'input temporaneamente)
    
    EOR: .int 1

    status: .int 200

.section .text
    .global read_file
    .type read_file, @function

read_file:
    popl %esi                           # salvo l'indirizzo della prox istruzione in ESI

    movl %eax, fd                       # Salva il file descriptor in fd (il file descriptor viene salvato di default in eax con la syscall open)
    cmpl $0, %eax
    je errore

# Utilizziamo la syscall read per leggere dati dal file aperto (fd) nel buffer.
read_loop:
    movl $3, %eax                       # syscall read
    movl fd, %ebx                       # file descriptor
    movl $buffer, %ecx                  # Buffer di input
    movl $1, %edx                       # Lunghezza massima
    int $0x80                           # interruzione del kernel

    cmpl $0, %eax                       # controlla se EOF
    je push_last_value                  # Se EOF inserisce ultimo valore

    cmpl $0, %eax                       # controlla se errore
    jl end_read

    # Controlla se ho una nuova linea
    movb buffer, %al                    # copia il carattere dal buffer
    cmpb carattere_nuova_linea, %al     # confronta con il carattere "\n"  
    je check_value
    
    cmpb carattere_virgola, %al         # confronta con il carattere "," 
    je check_value                      # se è una "," salto per controllare se il valore in value rispetta i parametri richiesti

    cmpb cr, %al                        # confronta con il carattere "\r" (Solo per Windows)
    je read_loop                        # se è a fine linea salto per incrementare il numero del prodotti

    movb %al, %bl                       # trasferisci cifra ascii da AL in BL per poter usare imul
    xorl %eax, %eax                     # azzera registro EAX
    movb value, %al                     # copia il valore precedente

    subb $48, %bl                       # converti la cifra ascii in intero
    movb $10, %dl                       # metti 10 in DL per usare mul
    mulb %dl                            # moltiplica il contenuto di AL x 10 e salva in AX
    addb %al, %bl                       # somma valore prec con la nuova cifra
    movb %bl, value                     # salva il nuovo valore in "value"
    xorl %eax, %eax                     # azzera registro EAX

    jmp read_loop                       # leggi nuovo char


check_value:
    cmpl $0, value_section              # Colonna 1:
    je check_more_or_equal_one

    cmpl $1, value_section              # Colonna 2:
    je check_more_or_equal_one

    cmpl $2, value_section              # Colonna 3:
    je check_more_or_equal_one
    
    cmpl $3, value_section              # Colonna 4
    je check_more_or_equal_one

    jmp errore                          # Non una colonna valida

check_value_max:
    cmpl $0, value_section
    je check_less_or_equal_max_ID

    cmpl $1, value_section
    je check_less_or_equal_max_durata

    cmpl $2, value_section
    je check_less_or_equal_max_scadenza
    
    cmpl $3, value_section
    je check_less_or_equal_max_priorità

check_more_or_equal_one:
    cmpl $1, value
    jge check_value_max 


check_less_or_equal_max_ID:
    incl value_section
    cmpl $127, value
    jle add_value
    jmp errore

check_less_or_equal_max_durata:
    incl value_section
    cmpl $10, value
    jle add_value
    jmp errore

check_less_or_equal_max_scadenza:
    incl value_section
    cmpl $100, value
    jle add_value
    jmp errore

check_less_or_equal_max_priorità:
    movl $0, value_section              # azzera il contatore della riga
    cmpl $5, value
    jle add_value
    jmp errore

add_value:
    xorl %eax, %eax                     # azzera il registro EAX         
    movl value, %eax                    # copia il valore convertito in eax              
    pushl %eax                          # inserisci il valore nello stack               
    movl $0, value                      # resetta il valore temporaneo                    
    incl numero_elementi                # incrementa il numero di elementi inseriti nello stack
    
    cmpl $0, EOR                        # check se sono a fine file 
    je end_read             

    jmp read_loop                       # altrimenti ritorna al ciclo di lettura 

push_last_value:
    movl $0, EOR                        # fine file quindi abbassa il flag EOF 
    jmp check_value                     # check ultimo valore

end_read:
    movb numero_elementi, %al
    pushl %esi                          # ESP punta all'indirizzo della prox istruzione
    ret

errore: 
    # Stampo il messaggio di errore
    movl $4, %eax                       # syscall write
    movl $2, %ebx                       # file descriptor (stderr)
    leal testo_errore, %ecx             # messaggio di errore
    movl testo_errore_lunghezza, %edx   # lunghezza messaggio
    int $0x80                           # interruzione del kernel

    movl $1, %eax                       # custom return value to indicate an error
    movl $500, status
    
esci:  
    movl status, %eax
    ret

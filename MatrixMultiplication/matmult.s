.global matMult
.equ ws, 4
.text

makeMat:
    # prologue:
        push %ebp
        movl %esp, %ebp
        subl $ws, %esp

        # ebp + 12: num_cols_b
        # ebp + 8: num_rows_a
        # ebp + 4: ret add
        # ebp: old ebp
        # ebp - 4: c

        .equ num_cols_b, 3*ws
        .equ num_rows_a, 2*ws
        .equ c, -1*ws

    # EAX: temp
    # EBX: temp
    # ECX: c
    # EDX: temp
    # ESI: i
    # EDI: j

    movl num_rows_a(%ebp), %edx     # EDX = num_rows_a
    shll $2, %edx                   # EDX = num_rows_a * sizeof(int*)
    push %edx
    call malloc
    addl $1*ws, %esp                # Remove added argument "EDX" from stack
    movl %eax, c(%ebp)              # EDI: c = (int**)malloc(num_rows_a * sizeof(int*))

    movl $0, %esi
    for_start:
        cmpl num_rows_a(%ebp), %esi
        jge for_end

        movl num_cols_b(%ebp), %edx     # EDX = num_cols_b
        shll $2, %edx                   # EDX = num_cols_b * sizeof(int*)
        push %edx
        call malloc                     # EAX = (int*)malloc(num_cols_b * sizeof(int))
        addl $1*ws, %esp                # Remove added argument "EDX" from stack

        movl c(%ebp), %ecx              # ECX = c
        movl %eax, (%ecx, %esi, ws)     # c[i] = (int*) malloc(num_cols_b * sizeof(int));

        movl $0, %edi
        inner_for_start:
            cmpl num_cols_b(%ebp), %edi
            jge inner_for_end

            movl $0, (%eax, %edi, ws)           # ECX: c[i][j] = 0

            incl %edi
            jmp inner_for_start
        inner_for_end:

        incl %esi
        jmp for_start
    for_end:

    # epilogue:
        movl c(%ebp), %eax
        addl $ws, %esp      # Remove local variable c
        movl %ebp, %esp
        pop %ebp
        ret

matMult:
    # prologue:
        push %ebp
        movl %esp, %ebp

        # ebp + 28: num_cols_b
        # ebp + 24: num_rows_b
        # ebp + 20: b
        # ebp + 16: num_cols_a
        # ebp + 12: num_rows_a
        # ebp + 8: a
        # ebp + 4: ret add
        # ebp: old ebp
        # ebp - 4: c
        # ebp - 8: i
        # ebp - 12: j
        # ebp - 16: k

        .equ num_cols_b, 7*ws
        .equ num_rows_b, 6*ws
        .equ b, 5*ws
        .equ num_cols_a, 4*ws
        .equ num_rows_a, 3*ws
        .equ a, 2*ws
        .equ c, -1*ws
        .equ i, -2*ws
        .equ j, -3*ws
        .equ k, -4*ws

        subl $4*ws, %esp

    # EAX: temp
    # EBX: i
    # ECX: temp
    # EDX: temp
    # ESI: j
    # EDI: k

    movl num_cols_b(%ebp), %edx
    push %edx
    movl num_rows_a(%ebp), %edx
    push %edx
    call makeMat                # EAX = c
    movl %eax, c(%ebp)
    addl $2*ws, %esp

    movl $0, %ebx
    row_for_start:
        cmpl num_rows_a(%ebp), %ebx
        jge row_for_end

            movl $0, %esi
            col_for_start:
                cmpl num_cols_b(%ebp), %esi
                jge col_for_end

                movl $0, %edi
                index_for_start:
                    cmpl num_cols_a(%ebp), %edi
                    jge index_for_end

                    movl a(%ebp), %eax              # EAX = a
                    movl (%eax, %ebx, ws), %eax     # EAX = a[i]
                    movl (%eax, %edi, ws), %eax     # EAX = a[i][k]

                    movl b(%ebp), %edx              # EDX = b
                    movl (%edx, %edi, ws), %edx     # EDX = b[k]
                    movl (%edx, %esi, ws), %edx     # EDX = b[k][j]

                    imull %edx   # Multiplication is implicit; It multiplies EAX by register provided (i.e. %edx)
                                 # EAX *= EDX;   EAX = a[i][k] * b[k][j]


                    movl c(%ebp), %edx                 
                    movl (%edx, %ebx, ws), %edx     # c[i]
                    addl %eax, (%edx, %esi, ws)     # c[i][j] += a[i][k] * b[k][j]

                    incl %edi
                    jmp index_for_start
                index_for_end:

                incl %esi
                jmp col_for_start
            col_for_end:

        incl %ebx
        jmp row_for_start
    row_for_end:

    movl c(%ebp), %eax

    # epilogue:
        addl $4*ws, %esp
        movl %ebp, %esp
        pop %ebp
        ret

.global knapsack
.equ ws, 4
.text

max:
    # prologue:
        push %ebp
        movl %esp, %ebp

        # ebp + 12: b
        # ebp + 8: a
        # ebp + 4: ret add
        # ebp: old ebp

        .equ b, 3*ws
        .equ a, 2*ws

    movl a(%ebp), %eax

    if_start:
        movl b(%ebp), %ecx
        cmpl %ecx, %eax
        jbe else
        jmp end_ifs
    else:
        movl b(%ebp), %eax
    end_ifs:

    # epilogue:
        movl %ebp, %esp
        pop %ebp
        ret

/*  File is structured as:
    capacity
    num_items
    weight1 value1
    weight2 value2... */

knapsack:   # int* weights, unsigned int* values, unsigned int num_items, int capacity, unsigned int cur_value

    prologue:
        push %ebp
        movl %esp, %ebp

        # ebp + 24: cur_value
        # ebp + 20: capacity
        # ebp + 16: num_items
        # ebp + 12: values
        # ebp + 8:  weights
        # ebp + 4:  ret add
        # ebp:      old ebp     <-- ESP
        # ebp - 4: i
        # ebp - 8: best_value

        .equ cur_value, 6*ws
        .equ capacity, 5*ws
        .equ num_items, 4*ws
        .equ values, 3*ws
        .equ weights, 2*ws
        .equ i, -1*ws
        .equ best_value, -2*ws

        subl $2*ws, %esp

    # Calling convention: you can overwrite EAX, ECX, EDX
    movl cur_value(%ebp), %ecx      # best_value = cur_value
    movl %ecx, best_value(%ebp)

    movl $0, %edi                   # EDI: i = 0
    for_start:
        cmpl num_items(%ebp), %edi  # i >= num_items
        jae for_end

        if:     # if (capacity - weights[i] >= 0)
            movl weights(%ebp), %ecx            # ECX = weights
            movl (%ecx, %edi, ws), %ecx
            movl capacity(%ebp), %edx           # EDX = capacity
            subl %ecx, %edx                     # EDX = capacity - weights[i]
            cmpl $0, %edx
            jl end_if

            movl values(%ebp), %ecx
            movl (%ecx, %edi, ws), %ecx
            addl cur_value(%ebp), %ecx
            push %ecx                           # ECX = cur_value + values[i]

            push %edx                           # EDX = capacity - weights[i]

            movl num_items(%ebp), %eax
            subl %edi, %eax
            decl %eax
            push %eax                           # num_items - i - 1

            movl values(%ebp), %ecx             # ECX = values
            leal ws(%ecx, %edi, ws), %ecx       # ECX = values + i + 1
            push %ecx

            movl weights(%ebp), %edx            # edx = weights + i
            leal ws(%edx, %edi, ws), %edx       # edx = weights + i + 1
            push %edx

            movl %edi, i(%ebp)      # Save value of i
            call knapsack           # EAX = knapsack(weights + i + 1, values + i + 1, .... )
            movl i(%ebp), %edi      # Retrieve value of i

            push %eax
            push best_value(%ebp)

            call max
            movl %eax, best_value(%ebp)

            addl $7*ws, %esp        # Remove all push arguments from stack

        end_if:

        incl %edi
        jmp for_start
    for_end:

    epilogue:
        movl best_value(%ebp), %eax
        movl %ebp, %esp
        pop %ebp
        ret

/* Translating weights[i] -> *(weights + i)
WRONG!
movl weights(%ebp, %edi, ws), %ecx
//  (&weights)[i]   ->    *(&weights + i)
//  *(weights + ebp + i * ws)
//  *(8 + ebp + i * ws)

RIGHT!
movl weights(%ebp), %ecx
movl (%ecx, %edi, ws), %ecx
// *(*(weights + ebp) + i * ws)
   *(*(8 + ebp) + i * ws)
*/

.global get_combs

#.global num_combs
.equ ws, 4

get_combs: #int** get_combs(int* items, int k, int len)

  #prologue
  pushl %ebp
  movl %esp, %ebp
  subl $(5*ws), %esp

  #args
  .equ items, (2*ws) #%ebp
  .equ k,     (3*ws) #%ebp
  .equ len,   (4*ws) #%ebp

  #locals
  .equ nc,         (-1*ws) #%ebp
  .equ cur_comb,   (-2*ws) #%ebp
  .equ combs,      (-3*ws) #%ebp
  .equ comb_count, (-4*ws) #%ebp
  .equ i,          (-5*ws) #%ebp

  #nc = num_combs(len, k);
  pushl k(%ebp)
  pushl len(%ebp)
  call num_combs
  #clear args
  addl $(2*ws), %esp

  #save nc
  movl %eax, nc(%ebp)

  #int** combs = (int**)malloc(nc*sizeof(int*));
  shll $2, %eax #nc*sizeof(int*)
  push %eax
  call malloc
  #clear args
  addl $(1*ws), %esp

  #save combs
  movl %eax, combs(%ebp)

  #int* cur_comb = (int*)malloc(k *sizeof(int));
  movl k(%ebp), %eax
  shll $2, %eax #k *sizeof(int)
  push %eax
  call malloc
  #don't clear argument because it will be needed in next call

  #save cur_comb
  movl %eax, cur_comb(%ebp)

  #comb_count = 0;
  movl $0, comb_count(%ebp)


  #eax is temp
  #i is ecx
  #edx is combs


  #for(i = 0; i < nc; i++){
  #  combs[i] = (int*)malloc(k * sizeof(int));
  #}

  movl $0, %ecx #i = 0
  init_combs_loop:
    #i < nc
    #i - nc < 0
    #negation: i - nc >= 0
    cmpl nc(%ebp), %ecx
    jge end_init_combs_loop
    movl %ecx, i(%ebp) #save ecx before call
    call malloc #argumets set previously on lines 49 - 51
    movl i(%ebp), %ecx #restore ecx
    movl combs(%ebp), %edx #edx = combs
    movl %eax, (%edx, %ecx, ws) #combs[i] = (int*)malloc(k * sizeof(int));

    incl %ecx #i++
    jmp init_combs_loop
  end_init_combs_loop:

  #clear k * sizeof(int) from stack
  addl $(1*ws), %esp

  #_get_combs(items, k, len, combs, k, cur_comb,  &comb_count);
  leal comb_count(%ebp), %eax
  pushl %eax
  pushl cur_comb(%ebp)
  pushl k(%ebp)
  pushl combs(%ebp)
  pushl len(%ebp)
  pushl k(%ebp)
  pushl items(%ebp)
  call _get_combs
  #clear args
  addl $(7*ws), %esp

  #free(cur_comb);
  pushl cur_comb(%ebp)
  call free
  #clear args
  addl $(1*ws), %esp

  #set return value
  movl combs(%ebp), %eax

  #epilogue
  #restore regs
  movl %ebp, %esp
  pop %ebp
  ret


_get_combs: #void _get_combs(int* items, int k, int len,
            #int** combs, int comb_per_row, int* cur_comb, int* comb_count)

  #prologue
  pushl %ebp
  movl %esp, %ebp
  subl $(1*ws), %esp

  #args
  .equ items,        (2*ws) #%ebp
  .equ k,            (3*ws) #%ebp
  .equ len,          (4*ws) #%ebp
  .equ combs,        (5*ws) #%ebp
  .equ comb_per_row, (6*ws) #%ebp
  .equ cur_comb,     (7*ws) #%ebp
  .equ comb_count,   (8*ws) #%ebp

  #locals
  .equ i, (-1*ws) #%ebp

  /*if(k == 0){ //completed a combination
    memcpy(combs[*comb_count], cur_comb, comb_per_row*sizeof(int));
    (*comb_count)++;
    return;
  }*/

  cmpl $0, k(%ebp)
  jnz k_not_0
  k_is_0:
    #memcpy(combs[*comb_count], cur_comb, comb_per_row*sizeof(int));
    movl comb_per_row(%ebp), %eax #eax = comb_per_row
    shll $2, %eax #eax = comb_per_row*sizeof(int)
    pushl %eax
    pushl cur_comb(%ebp)
    movl comb_count(%ebp), %eax #eax = comb_count
    movl (%eax), %ecx #ecx = *comb_count
    movl combs(%ebp), %edx #edx = combs
    movl (%edx, %ecx, ws), %edx #edx = combs[*comb_count]
    pushl %edx
    call memcpy #do the call

    movl comb_count(%ebp), %eax #eax = comb_count
    incl (%eax) #(*comb_count)++;
    jmp end_get_combs
  k_not_0:

  /*
  else if(k > len){ //not enough elements to complete a combination
    return;
  }*/
  movl len(%ebp), %eax
  cmpl %eax, k(%ebp)
  jle more_elements
  not_enough_elements:
    jmp end_get_combs
  more_elements:
  /*
  else{
    for(i = 0; i < len; i++){
      cur_comb[comb_per_row - k] = items[i];
      _get_combs(items + i + 1, k - 1, len - i - 1, combs, comb_per_row, cur_comb, comb_count);
    }
  */

  #ecx = i
  movl $0, %ecx
  for_remain_elems:
    cmpl len(%ebp), %ecx
    jge end_for_remain_elems

    #cur_comb[comb_per_row - k] = items[i];
    movl items(%ebp), %eax #eax = items
    movl (%eax, %ecx, ws), %eax #eax = items[i]

    movl %ecx, i(%ebp) #save i

    movl comb_per_row(%ebp), %edx
    subl k(%ebp), %edx
    movl cur_comb(%ebp), %ecx #ecx = cur_comb
    movl %eax, (%ecx, %edx, ws) #cur_comb[comb_per_row - k] = items[i];

    #_get_combs(items + i + 1, k - 1, len - i - 1, combs, comb_per_row, cur_comb, comb_count);
    pushl comb_count(%ebp)
    pushl cur_comb(%ebp)
    pushl comb_per_row(%ebp)
    pushl combs(%ebp)
    movl len(%ebp), %eax
    movl i(%ebp), %ecx
    subl %ecx, %eax
    subl $1, %eax
    pushl %eax
    movl k(%ebp), %eax
    subl $1, %eax
    pushl %eax
    movl items(%ebp), %eax
    leal ws(%eax, %ecx, ws), %eax
    pushl %eax
    call _get_combs
    #clear arguments
    addl $(7*ws), %esp

    #restore %ecx
    movl i(%ebp), %ecx

    incl %ecx #i++
    jmp for_remain_elems
  end_for_remain_elems:
  end_get_combs:

  #epilogue
  movl %ebp, %esp
  pop %ebp
  ret

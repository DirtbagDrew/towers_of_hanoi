# CECS 341 Computer Architecture
# Lab Project 3
# Tower of Hanoi
# Andrew Myer
# Jacob Parcell
# 11/30/17
#
# convert the following c code to mips *update* pretty different than C code
# C Code
# void towerOfHanoi(int n, char from_rod, char to_rod, char aux_rod)
# {
#     if (n == 1)
#     {
#         printf("n Move disk 1 from rod %c to rod %c", from_rod, to_rod);
#         return;
#     }
#     towerOfHanoi(n-1, from_rod, aux_rod, to_rod);
#     printf("n Move disk %d from rod %c to rod %c", n, from_rod, to_rod);
#     towerOfHanoi(n-1, aux_rod, to_rod, from_rod);
# }
#  
# int main()
# {
#     int n = 4; // Number of disks
#     towerOfHanoi(n, 'A', 'C', 'B');  // A, B and C are names of rods
#     return 0;
# }
.data
askForDiskCount: .asciiz "\nEnter the number of disks: "
newLine: .asciiz "\n"
blank: .asciiz "|"
blank_space: .asciiz " "
ex: .asciiz "x"
numberOfSteps: .asciiz "\nTotal steps "
steps: .asciiz " steps"

.text

la $s0, 0x100100c0 	# s0 = address of first column array

main:
li  $v0, 4
la  $a0, askForDiskCount	# prompts user to enter disk count they want
syscall

li $v0, 5		# gets disk count from user 
syscall

add  $a0, $v0, $zero 	# load user identified disk count into n 
addi $s3, $a0, 0	# set s3 to n
addi $t9, $a0, 0

sll  $t0, $a0, 2	# multiply n by 4

add $s1, $s0, $t0	# allocate n bytes for column 1
add $s2, $s1, $t0	# allocate n bytes for column 2

addi $t7, $0, -1	# set step counter to -1 to account for the printing of the original state

# load discs into initial position

addi $t0, $0, 1		# t0 = 1
addi $t4, $0, 0		# t4 = 0

addi $t1, $s0, 0	# save initial value of s0 which is address of A
addi $t2, $s1, 0	# save initial value of s1 which is address of B
addi $t3, $s2, 0	# save initial value of s2 which is address of C

loop:			# adds initial values to the corresponding arrays
blt  $a0, $t0, endLoop	# end loop if a0 < t0
sw $t0, 0($s0)		# save t0 into s0
sw $t4, 0($s1)		# save 0 into s1
sw $t4, 0($s2)		# save 0 into s2

addi $t0, $t0, 1	# increment t0 by 1
addi $s0, $s0, 4	# increment s0 by 4 to go to next address
addi $s1, $s1, 4	# increment s1 by 4 to go to next address
addi $s2, $s2, 4	# increment s2 by 4 to go to next address

j loop

endLoop:

addi $s0, $t1, 0	#reset s0 to be the initial address of column 1
addi $s1, $t2, 0	#reset s0 to be the initial address of column 2
addi $s2, $t3, 0	#reset s0 to be the initial address of column 3

addi $a1, $0, 1		# set from_rod
addi $a2, $0, 3		# set to_rod
addi $a3, $0, 2		# set aux_rod

addi $t8, $a0, 0	# hold original value of a0
addi $t6, $v0, 0	# hold original value of v0
jal print
addi $v0, $t6, 0	# restore value of v0
addi $a0, $t8, 0	# restore value of a0

jal towerOfHanoi

j exit

towerOfHanoi:
addi $sp, $sp, -20	# adjust stack for 5 items: 4 arguments and 1 address

sw $ra, 16($sp)		# save address
sw $a3, 12($sp)		# save aux_rod
sw $a2, 8($sp)		# save to_rod
sw $a1, 4($sp)		# save from_rod
sw $a0, 0($sp)		# save n

slti $t0, $a0, 2 	# if n < 2, then t0 = 1

beq $t0, $0, continue   # branch if n >= 2

addi $sp, $sp, 20 	# pop 5 items from the stack

addi $s4, $ra, 0	# store ra
jal moveDisc		#moves disc in stack using current argument values	

addi $t8, $a0, 0	# hold original value of a0
addi $t6, $v0, 0	# hold original value of v0
jal print
addi $v0, $t6, 0	# restore value of v0
addi $a0, $t8, 0	# restore value of a0

addi $ra, $s4, 0	# reset ra

jr $ra			# return after printing

continue: 
addi $a0, $a0, -1 	# n - 1
addi $t0, $a2, 0	# create temp for to_rod
addi $a2, $a3, 0	# set to_rod to value of aux_rod
addi $a3, $t0, 0	# set aux_rod to value of to_rod

jal towerOfHanoi

lw $a0, 0($sp)		# load values from the stack
lw $a1, 4($sp)
lw $a2, 8($sp)
lw $a3, 12($sp)
lw $ra, 16($sp)

addi $s4, $ra, 0	# store ra
jal moveDisc		#moves disc in stack using current argument values
	
addi $t8, $a0, 0	# hold original value of a0
addi $t6, $v0, 0	# hold original value of v0
jal print
addi $v0, $t6, 0	# restore value of v0
addi $a0, $t8, 0	# restore value of a0

addi $ra, $s4, 0	# reset ra

addi $a0, $a0, -1 	# n - 1
addi $t0, $a1, 0	# create temp for from_rod
addi $a1, $a3, 0	# set from_rod to value of aux+rod
addi $a3, $t0, 0	# set aux_rod to value of from_rod

jal towerOfHanoi

lw $ra, 16($sp)
addi $sp, $sp, 20 	# pop 5 items from the stack

lw $a0, 0($sp)

jr $ra

moveDisc:
addi $t2, $ra, 0	# save return address
jal findFromRodValue	# finds value of top disc of from_rod and stores it in $v0
jal findToRod		# finds which rod the to_rod is and stores address in v1

addi $t1, $0, 1		# incrementer to check if whole array is 0

	findAddressLoop:
	lw  $t0, 0($v1)			# load value of index of to_rod into t0
	bne $t0, $0, addressFound	# if value at index of to_rod != 0, then the first disc is found
	beq $t1, $s3, rodEmpty		# leaves loop if all indexes of rod are 0
	addi $v1, $v1, 4		# increment address of to_rod if value not found yet
	addi $t1, $t1, 1		# increment t1
	j findAddressLoop
	
	addressFound:
	addi $v1, $v1, -4	# go back to first empty space before top disc
	sw $v0, 0($v1)
	
	rodEmpty:
	sw $v0, 0($v1)
	
addi $ra, $t2, 0		# reset ra

jr $ra

findFromRodValue:
	
	findFromRod:			# returns address of from_rod in v0
	addi $t0, $0, 1			# set incrementer to 0
	beq  $t0, $a1, from_rodIs1	# branch if the from_rod = 1

	addi $t0, $t0, 1		# increment t0 by 1
	beq  $t0, $a1, from_rodIs2	# branch if the from_rod = 2

	addi $t0, $t0, 1		# increment t0 by 1
	beq  $t0, $a1, from_rodIs3	# branch if the from_rod = 3

	from_rodIs1:
	addi $v0, $s0, 0	# set address of rod 1 to v0 and return
	j fromRodFound
	
	from_rodIs2:
	addi $v0, $s1, 0	# set address of rod 2 to v0 and return
	j fromRodFound
	
	from_rodIs3:
	addi $v0, $s2, 0	# set address of rod 3 to v0 and return
	j fromRodFound
	
	fromRodFound:
	
		addi $t1, $0, 1		# incrementer to check if whole array is 0
		findValueLoop:
		lw  $t0, 0($v0)		# load value of top index of from_rod
		bne $t0, $0, valueFound	# if value at index of from_rod != 0, then the first disc is found
		addi $v0, $v0, 4	# increment address of from_rod if value not found yet
		addi $t1, $t1, 1		# increment t1
		j findValueLoop	
		
	valueFound:
	addi $t1, $0, 0
	sw   $t1, 0($v0)	# save 0 to former index of top disc
	addi $v0, $t0, 0	# set v0 to top disc index
	jr $ra			# return to moveDisc
	

findToRod:			# returns address of to_rod in v1
addi $t0, $0, 1			# set incrementer to 0
beq  $t0, $a2, to_rodIs1	# branch if the to_rod = 1

addi $t0, $t0, 1		# increment t0 by 1
beq  $t0, $a2, to_rodIs2	# branch if the to_rod = 2

addi $t0, $t0, 1		# increment t0 by 1
beq  $t0, $a2, to_rodIs3	# branch if the to_rod = 3

	to_rodIs1:
	addi $v1, $s0, 0	# set address of rod 1 to v1 and return
	jr $ra
	
	to_rodIs2:
	addi $v1, $s1, 0	# set address of rod 2 to v1 and return
	jr $ra
	
	to_rodIs3:
	addi $v1, $s2, 0	# set address of rod 3 to v1 and return
	jr $ra

#--------------------------------------------------------------print function------------------------------------------------------------

print:

addi $t7, $t7, 1		# increment step counter

addi $t0, $t9, 0		# t0 is a constant n.
li $t1, 0 			# t1 is our counter (i)

# starts the loop to print the array
print_loop:
beq $t1, $t0, endPrint 		# if t1 == 10 we are done

sll $t2, $t1, 2			# $t2 = multply t1 by 4

add $t3,$t2,$s0			# $t3 = $tower1[i]
add $t4,$t2,$s1			# $t4 = $tower2[i]
add $t5,$t2,$s2			# $t5 = $tower3[i]

lw $s5, 0($t3)			# $s5 = tower1[i]
lw $s6, 0($t4)			# $s6 = tower2[i]
lw $s7, 0($t5)			# $s7 = tower3[i]

beq $s5, $0, tower_1_num0	# if tower1[i] = 0, branch to tower_1_num0
j tower_1_numgreater0		# else jump to tower_1_numgreater0


#----------------------------------------------
# prints tower 1
#----------------------------------------------
# prints the "|" if the number is 0 for tower 1
tower_1_num0:
li $v0, 4 				# sets system service mode to print string
la $a0, blank				# load argument to print "|"
syscall					# call system services to print string
j tower_1_blank_spaces			# jumping to tower_1_blank_spaces 

tower_1_numgreater0:
add $t2,$s5,$0 				# t2 = tower1[i]
li $t3, 0 				# t1 is our counter (j)
xloop:
beq $t3, $t2, tower_1_blank_spaces	# if t3 == tower1[i] we are done

li $v0, 4 
la $a0, ex				# prints the x
syscall

addi $t3, $t3, 1 			# add 1 to t1
j xloop 				# jump back to the top


# prints the blank space for tower 1
tower_1_blank_spaces:
beq $s5, $0,isZero1			# if tower1[i] = 0 branch to isZero1
subi $t2,$s5,1
sub $t2,$t0,$t2
j is_zero_1_done

# tower1[i] = 0
isZero1:
add $t2,$t0,$s5				# $t2 is number of spaces required

# done allocating how many spaces needed
is_zero_1_done:
li $t3, 0 				# t3 is our counter

# loop inside of tower_1_num_0_blank_spaces
tower_1_blank_spaces_loop:
beq $t3, $t2, tower_2_decide 		# if t3 = blank spaces required 
					# branch to tower_2_decide
li $v0, 4 
la $a0, blank_space
syscall

addi $t3, $t3, 1 			# add 1 to t3
j tower_1_blank_spaces_loop 		# jump back to the top
#--------------------------------------------------


#----------------------------------------------
# prints tower 2
#----------------------------------------------
#decides whether 0 or not
tower_2_decide:
beq $s6, $0, tower_2_num0		# if tower2[i] = 0 branch to tower_2_num0
j tower_2_numgreater0			# else jump to tower_2_numgreater0

#prints the "|" if the number is 0 for tower 2
tower_2_num0:
li $v0, 4 
la $a0, blank				# call to print "|"
syscall
j tower_2_blank_spaces

tower_2_numgreater0:
add $t2,$s6,$0 				# t2 is a constant tower2[i]
li $t3, 0 				# t3 is our counter (i)
xxloop:
beq $t3, $t2, tower_2_blank_spaces 	# if t3 == tower2[i] jump to tower_2_blank_spaces

li $v0, 4 
la $a0, ex				# print x
syscall

addi $t3, $t3, 1 			# add 1 to t1
j xxloop 				# jump back to the top


# prints the blank space for tower 1
tower_2_blank_spaces:
beq $s6, $0,isZero2			# if $s6 = 0, branch to isZero2
subi $t2, $s6,1				# set $t2 to tower2[i] - 1 to subtract from n
sub $t2,$t0,$t2				# n-$t2 = required blank space
j is_zero_2_done

# if tower2[i]=0
isZero2:
add $t2,$t0,$s6				# sets blank space if tower2[i]=0

# after blank space length has been determined
is_zero_2_done:

li $t3, 0 				# t3 is our counter (i)

# loop inside of tower_1_num_0_blank_spaces
tower_2_blank_spaces_loop:
beq $t3, $t2, tower_3_decide 		# if t3 == blank space required, jump to
					#tower 3 decide
li $v0, 4 
la $a0, blank_space			# print blank space
syscall

addi $t3, $t3, 1 			# add 1 to t3
j tower_2_blank_spaces_loop 		# jump back to the top
#--------------------------------------------------


#---------------------------------------------------
# prints tower 3
#----------------------------------------------
#prints the "|" if the number is 0 for tower 2
tower_3_decide:
beq $s7, 0, tower_3_num0		# if tower3[i] = 0 branch to tower_3_num0
j tower_3_numgreater0			# else jump to tower_3_numgreater0

#decides whether 0 or not
tower_3_num0:
li $v0, 4 
la $a0, blank				# call to print "|"
syscall
j endOfLine

tower_3_numgreater0:
add $t2,$s7,$0 				# t2 is a constant tower3[i]
li $t3, 0 				# t3 is our counter
xxxloop:
beq $t3, $t2, endOfLine	# if t3 == tower3[i] jump to tower_3_blank_spaces

li $v0, 4 
la $a0, ex				# print "x"
syscall

addi $t3, $t3, 1 			# add 1 to t3
j xxxloop 				# jump back to the top

#--------------------------------------------------


#---------------------------------------------------
# ends the line and starts on the next one
#---------------------------------------------------
endOfLine:
li $v0, 4 
la $a0, newLine	# prints out \n
syscall

j increment
#-----------------------------------------------------


#-----------------------------------------------------
# increments the counter in the print loop
#-----------------------------------------------------
increment:
addi $t1, $t1, 1	# add 1 to t1
j print_loop 		# jump back to the top
#-----------------------------------------------------


#-----------------------------------------------------
# end of loop
#-----------------------------------------------------
endPrint:
li $v0, 4 
la $a0, newLine		#add space for next screenshot
syscall

jr $ra

exit:

li  $v0, 4
la  $a0, numberOfSteps	# prints total amount of steps
syscall

li  $v0, 1
addi $a0, $t7, 0	# prints step counter
syscall

li  $v0, 4
la  $a0, steps	# prints total amount of steps
syscall
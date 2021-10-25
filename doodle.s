#####################################################################
#
# CSC258H5S Fall 2020 Assembly Final Project
# University of Toronto, St. George
#
# Bitmap Display Configuration:
# - Unit width in pixels: 16
# - Unit height in pixels: 16
# - Display width in pixels: 256
# - Display height in pixels: 512
# - Base Address for Display: 0x10008000 ($gp)
#
# t0 = display address
# t1 = doodler
# t2 = platform
# t3 = background
# t4 = counter
# t5 = func use
# t6 = func use
# t7 = platform counter
# t8 = jump value 4 3 2 1 0 -1 -2 -3 
# t9 = doodler position
# s0 = game over value 1 = NO | 0 = YES
# s1 = key checker
# s2 = key value

#####################################################################
.data

displayAddress: .word 0x10008000    #display  address location
doodlerColor: .word 0xcdc615    #color of doodler
platformColor: .word 0xdf4925    #color of platform
backgroundColor: .word 0x25ebce    #color of background
platformCounter: 
jumpValue:
gameOver:
platformlocation: .word 1940, 1636, 1232, 844, 528, 360, 80


.text
main:
	restartgamenow:
	lw $t0, displayAddress    #stores the base address for display
	lw $t1, doodlerColor    #stores the doodler color 
	lw $t2, platformColor    #stores platform color
	lw $t3, backgroundColor    #stores background color
	lw $t7, platformCounter
	lw $t8, jumpValue
	lw $s0, gameOver
	addi $s0, $s0, 1
	
	# draw platforms for restart
	la $s3, platformlocation
	li $t5, 1940
	sw $t5, 0($s3)
	addi $s3, $s3, 4
	li $t5, 1636
	sw $t5, 0($s3)
	addi $s3, $s3, 4
	li $t5, 1232
	sw $t5, 0($s3)
	addi $s3, $s3, 4
	li $t5, 844
	sw $t5, 0($s3)
	addi $s3, $s3, 4
	li $t5, 528
	sw $t5, 0($s3)
	addi $s3, $s3, 4
	li $t5, 360
	sw $t5, 0($s3)
	addi $s3, $s3, 4
	li $t5, 80
	sw $t5, 0($s3)
	addi $s3, $s3, 4
	
	addi $sp, $sp, -4
	sw $t0, 0($sp)
	jal drawBackground
	
	#initial platform loads to bypass BAD RNG
	
	sw $t2, 1940($t0)
	sw $t2, 1944($t0)
	sw $t2, 1948($t0)
	sw $t2, 1952($t0)
	sw $t2, 1956($t0)
	
	sw $t2, 1636($t0)
	sw $t2, 1640($t0)
	sw $t2, 1644($t0)
	sw $t2, 1648($t0)
	sw $t2, 1652($t0)
	
	sw $t2, 1232($t0)
	sw $t2, 1236($t0)
	sw $t2, 1240($t0)
	sw $t2, 1244($t0)
	sw $t2, 1248($t0)
	
	sw $t2, 844($t0)
	sw $t2, 848($t0)
	sw $t2, 852($t0)
	sw $t2, 856($t0)
	sw $t2, 860($t0)
	
	sw $t2, 528($t0)
	sw $t2, 532($t0)
	sw $t2, 536($t0)
	sw $t2, 540($t0)
	sw $t2, 544($t0)
	
	sw $t2, 360($t0)
	sw $t2, 364($t0)
	sw $t2, 368($t0)
	sw $t2, 372($t0)
	sw $t2, 376($t0)
	
	sw $t2, 80($t0)
	sw $t2, 84($t0)
	sw $t2, 88($t0)
	sw $t2, 92($t0)
	sw $t2, 96($t0)
	addi $t7, $t7, 7
	
	lw $t5, displayAddress
	addi $t5, $t5, 1760
	li $t9, 0
	add $t9, $t9, $t5
	addi $sp, $sp, -4
	sw $t5, 0($sp)
	jal drawDoodler
	
	
	centralLOOP:    #CENTRAL PROCESSING LOOP
		li $v0, 32
		li $a0, 60
		syscall 
		
		beq $s0, $zero, gameEND
		
		lw $s1, 0xffff0000
		bne $s1, 1, nokeyINPUT
		lw $s2, 0xffff0004
		bne $s2, 0x6A, noJ
		addi $sp, $sp, -4
		sw $t9, 0($sp)
		jal undrawDoodler
		addi $t9, $t9, -4
		addi $sp, $sp, -4
		sw $t9, 0($sp)
		jal drawDoodler
	noJ:
		bne $s2, 0x6B, noK
		addi $sp, $sp, -4
		sw $t9, 0($sp)
		jal undrawDoodler
		addi $t9, $t9, 4
		addi $sp, $sp, -4
		sw $t9, 0($sp)
		jal drawDoodler
	noK:
		bne $s2, 115, noS
		beq $s0, 1, gameovernow
		li $s0, 1
		gameovernow:
		li $s0, 0
		j gameEND
	noS:
	nokeyINPUT:
		addi $sp, $sp, -4
		sw $t9, 0($sp)
		jal doodplatCollision
		lw $t4, 0($sp)
		addi $sp, $sp, 4
		bne $t4, 1, collcheckEND
		li $t8, 4
		li $v0, 31
		li $a0, 72
		li $a1, 500
		li $a2, 127
		li $a3, 30
		syscall
	collcheckEND:
		addi $sp, $sp, -4
		sw $t9, 0($sp)
		jal undrawDoodler
		jal moveDoodler
		jal platformsUpdate
		li $s7, 0
		addi $s7, $t0, 768
		bge $t9, $s7, skipthis
		jal movedownPlatforms
		skipthis:
		jal checkgameEnd
		j centralLOOP	
	gameEND:
	j restartgamenow
	
Exit:
	li $v0, 10 # terminate the program gracefully
	syscall
	
#FUNC: background drawer	
drawBackground: 
	lw $t5, 0($sp)
	addi $sp, $sp, 4
	li $t4, 0
backgroundLOOP:    #LOOP: background drawing loop
	beq $t4, 2048, backgroundEND
	sw $t3, 0($t5)
	addi $t5, $t5, 4
	addi $t4, $t4, 4
	j backgroundLOOP
backgroundEND:
	jr $ra	

#FUNC: platform drawer	
drawPlatform:
	lw $t5, 0($sp)
	addi $sp, $sp, 4
	li $t4, 0
platformLOOP:
	beq $t4, 5, platformEND
	sw $t2, 0($t5)
	addi $t5, $t5, 4
	addi $t4, $t4, 1
	j platformLOOP
platformEND:
	jr $ra
	
#FUNC: doodler drawer
drawDoodler:
	lw $t5, 0($sp)
	addi $sp, $sp, 4	
	li $t6, 3947012
	li $t4, 8947564
	sw $t4, 0($t5)
	sw $t4, 4($t5)
	sw $t6, 60($t5)
	sw $t1, 64($t5)
	sw $t4, 120($t5)
	sw $t1, 124($t5)
	sw $t1, 128($t5)
	sw $t4, 132($t5)
	jr $ra

#FUNC: undraw the doodler
undrawDoodler:
	lw $t5, 0($sp)
	addi $sp, $sp, 4	
	sw $t3, 0($t5)
	sw $t3, 4($t5)
	sw $t3, 60($t5)
	sw $t3, 64($t5)
	sw $t3, 120($t5)
	sw $t3, 124($t5)
	sw $t3, 128($t5)
	sw $t3, 132($t5)
	jr $ra

#FUNC: collision detection between doodler and platform
doodplatCollision:
	lw $t5, 0($sp)
	addi $sp, $sp, 4
	addi $t5, $t5, 188
	li $t4, 0
	
	lw $t6, 0($t5)
	bne $t6, $t2, e1
	addi $sp, $sp, -4
	addi $t4, $t4, 1
	sw $t4, 0($sp)
	jr $ra
	e1:
	addi $t6, $t6, 4
	bne $t6, $t2, e2
	addi $sp, $sp, -4
	addi $t4, $t4, 1
	sw $t4, 0($sp)
	jr $ra
	e2:
	addi $t6, $t6, 4
	bne $t6, $t2, e3
	addi $sp, $sp, -4
	addi $t4, $t4, 1
	sw $t4, 0($sp)
	jr $ra
	e3:
	addi $t6, $t6, 4
	bne $t6, $t2, e4
	addi $sp, $sp, -4
	addi $t4, $t4, 1
	sw $t4, 0($sp)
	jr $ra
	e4:
	jr $ra
	
#FUNC: move doodler based on the jump value
moveDoodler:
	bne, $t8, 4, else1
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	addi, $t9, $t9, -256
	addi $sp, $sp, -4
	sw $t9, 0($sp)
	jal drawDoodler
	addi $t8, $t8, -1
	lw $ra, 0($sp)
	addi, $sp, $sp, 4
	jr $ra
	else1:
	bne $t8, 3, else2
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	addi, $t9, $t9, -192
	addi $sp, $sp, -4
	sw $t9, 0($sp)
	jal drawDoodler
	addi $t8, $t8, -1
	lw $ra, 0($sp)
	addi, $sp, $sp, 4
	jr $ra
	else2:
	bne $t8, 2, else3
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	addi, $t9, $t9, -128
	addi $sp, $sp, -4
	sw $t9, 0($sp)
	jal drawDoodler
	addi $t8, $t8, -1
	lw $ra, 0($sp)
	addi, $sp, $sp, 4
	jr $ra
	else3:
	bne $t8, 1, else4
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	addi, $t9, $t9, -64
	addi $sp, $sp, -4
	sw $t9, 0($sp)
	jal drawDoodler
	addi $t8, $t8, -1
	lw $ra, 0($sp)
	addi, $sp, $sp, 4
	jr $ra
	else4:
	bne $t8, 0, else5
	addi $t8, $t8, -1
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	addi $sp, $sp, -4
	sw $t9, 0($sp)
	jal drawDoodler
	lw $ra, 0($sp)
	addi, $sp, $sp, 4
	jr $ra
	else5:
	bne $t8, -1, else6
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	addi, $t9, $t9, 64
	addi $sp, $sp, -4
	sw $t9, 0($sp)
	jal drawDoodler
	lw $ra, 0($sp)
	addi, $sp, $sp, 4
	jr $ra
	else6:
	jr $ra

#FUNC: check if the game is over
checkgameEnd:
	lw $t4, displayAddress
	addi $t4, $t4, 1856
	blt $t9, $t4, gameendFALSE
	li $s0, 0
	jr $ra
	gameendFALSE:
	jr $ra

#FUNC: update platforms accordingly
platformsUpdate:
	la $t6, platformlocation
	li $s3, 0
	addi $sp, $sp, -4
	sw $ra 0($sp)
pfinitLOOP:    #loop and draw NEW platforms
	beq $s3, 7, pfinitEND
	li $t5, 0
	lw $t5, 0($t6)
	blt $t5, 2048, keepPLATFORM
	li $v0, 42
	li $a0, 0
	li $a1, 64
	syscall
	li $t4, 4
	mult  $a0, $t4
	mflo $t4
	sw $t4, 0($t6)
	add $t4, $t0, $t4
	addi $sp, $sp, -4
	sw $t4, 0($sp)
	jal drawPlatform
	addi $t6, $t6, 4
	addi $s3, $s3, 1
	j pfinitLOOP
keepPLATFORM:
	addi $sp, $sp, -4
	add $t5, $t5, $t0
	sw $t5, 0($sp)
	jal drawPlatform
	addi $t6, $t6, 4
	addi $s3, $s3, 1
	j pfinitLOOP
pfinitEND:
	lw $ra 0($sp)
	addi $sp, $sp, 4
	jr $ra

#FUNC: move down platforms with camera movement
movedownPlatforms:
	lw $t5, displayAddress
	addi $t5, $t5, 768
	bge $t9, $t5, noMOVEDOWN
	
	la $t6, platformlocation
	li $s3, 0
	addi $sp, $sp, -4
	sw $ra 0($sp)
	movedownLOOP:
		beq $s3, 7, movedownloopEND
		lw $t4, 0($t6)
		li $t5, 0
		add $t5, $t4, $t0
		addi $sp, $sp, -4
		sw $t5, 0($sp)
		jal undrawPlatform
		addi $t4, $t4, 64
		sw $t4, 0($t6)
		addi $s3, $s3, 1
		addi $t6, $t6, 4
		j movedownLOOP
	movedownloopEND:
		lw $ra 0($sp)
		addi $sp, $sp, 4	
		jr $ra
noMOVEDOWN:
	jr $ra

#FUNC: undraw the platform
undrawPlatform:
	lw $t5, 0($sp)
	addi $sp, $sp, 4
	li $s4, 0
unplatformLOOP:
	beq $s4, 5, unplatformEND
	sw $t3, 0($t5)
	sw $t2, 64($t5)
	addi $t5, $t5, 4
	addi $s4, $s4, 1
	j unplatformLOOP
unplatformEND:
	jr $ra

	


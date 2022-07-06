#####################################################################
#
# CSC258H5S Winter 2022 Assembly Final Project
# University of Toronto, St. George
#
# Student: Zhichao (Jimmy) Hao, 1007320588
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
#
# Which milestone is reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# 	- Milestone 1
# 	- Milestone 2
# 	- Milestone 3
# 	- Milestone 4
#	- Milestone 5
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. Display the number of lives remaining. 
# 2. Have objects in different rows move at different speeds.
# 3. Add a third row in each of the water and road sections.
# 4. Display a death/respawn animation each time the player loses a frog.
# 5. Add sound effects for movement, losing lives, collisions, and reaching the goal
# 6. Make a second level that starts after the player completes the first level.
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################


.data
	displayAddress: .word 	0x10008000


#-----------------------------------------------------Raw Data-----------------------------------------------------------
	lives:		.word   3
	game_on:	.word	1 			# start game when game_on == 1
	level2:		.word   0			# start level2 if level2 = 1
	
	#goal_filled == 1 indicate that goal is empty
	goal1_filled: 	.word	1			# cover goal1 when goal1_filled == 0
	goal2_filled:	.word	1			# cover goal2 when goal2_filled == 0
	goal3_filled:	.word	1			# cover goal3 when goal3_filled == 0
	
	
	frog_x: 	.word 	16
	frog_y: 	.word 	29
	frog_start_x: 	.word 	16
	frog_start_y: 	.word 	29

	car_height:	.word	3
	car_width:	.word	6
	car1: 		.word	2560
	car2: 		.word	2608
	car3: 		.word	2956
	car4: 		.word	3012
	car5: 		.word	3368
	car6: 		.word	3428
	car_row1_speed: .word	0
	car_row2_speed: .word	0
	car_row3_speed: .word	4
		
	log_height:	.word	3
	log_width:	.word	8
	log1: 		.word	1040
	log2: 		.word	1096
	log3: 		.word	1412
	log4: 		.word	1492
	log5: 		.word	1804
	log6: 		.word	1868
	log_row1_speed: .word	4
	log_row2_speed: .word	0
	log_row3_speed: .word	0

#------------------------------------------------------Colors------------------------------------------------------------
	outerColor: 	.word 		0xA5DF35
	middleColor: 	.word 		0x525BE6
	riverColor: 	.word 		0x45B3CC
	roadColor: 	.word 		0xCFE1E5
	logColor: 	.word 		0x794E2E
	carColor: 	.word 		0xE65059
	goalColor:	.word		0x45B3CC			#0xE4E02A
	goalColorFilled:	.word	0xF79B14
	livesColor:	.word		0xFFFFFF
	
	frogBody: 	.word 		0x56CC98
	frogEye: 	.word 		0x003525
	frogTail:	.word		0x2D6C59
	
	
#------------------------------------------------------Sound Effects---------------------------------------------------------
	duration1:	.word		150
	duration2:	.word		400
	volume:		.word		100
	pitch:		.word		75
	instrument1:	.word		128			# sound effect for collision
	instrument2:	.word		11			# sound effect for move

	
	
.text
lw $t0, displayAddress # $t0 stores the base address for display



#----------------------------------------------------start game--------------------------------------------------------
#######################################################################################################################
#----------------------------------------------------------------------------------------------------------------------
game_start:

la $s0, level2
lw $s0, 0($s0)					# s0 = level2
addi $t1, $zero, 1				# t1 = 1
beq $s0, $t1, if_level2				# if s0 == 1, jump to if_end

#check if game win
addi $sp, $sp, -4				#Move stack pointer to empty location
sw $ra, 0($sp)					#push ra onto the stack
add $t1, $zero, $zero	
jal get_score					#get_score
lw $ra, 0($sp)					#pop ra off the stack
addi $sp, $sp, 4				#Move stack pointer to top element

addi $s3, $zero, 3				# s3 stores the value 3
beq $v1, $s3, second_level			# if v1 == 3, second level!
j if_end

if_level2:
la $t3, goal1_filled
sw $t1, 0($t3)						# set goal1_filled to 1
la $t4, goal2_filled
sw $t1, 0($t4)						# set goal2_filled to 1
la $t5, goal3_filled
sw $t1, 0($t5)						# set goal3_filled to 1


#check if game ends
if_end:
addi $s1, $zero, 1				# s1 store the value 1
la $s2, game_on					
lw $s2, 0($s2)					# Fetch game_on value to s2
bne $s2, $s1, Exit				# if game_on != 1, end


j map_loop

end_game_start:
j Exit


#----------------------------------------------------end game----------------------------------------------------------
#######################################################################################################################
#----------------------------------------------------------------------------------------------------------------------
end_game:

la $s1, game_on					# s1 has the address of game_on
sw $zero, 0($s1)				# store 0 to game_on

end_end_game:
jr $ra



#----------------------------------------------------map loop----------------------------------------------------------
########################################################################################################################
#------------------------------------------------------------------------------------------------------------------------
map_loop:
addi $sp, $sp, -4			#Move stack pointer to empty location
sw $ra, 0($sp)				#push ra onto the stack
jal draw_background
lw $ra, 0($sp)				#pop ra off the stack
addi $sp, $sp, 4			#Move stack pointer to top element


addi $sp, $sp, -4			#Move stack pointer to empty location
sw $ra, 0($sp)				#push ra onto the stack
add $t1, $zero, $zero
jal draw_car_row			#draw car row
lw $ra, 0($sp)				#pop ra off the stack
addi $sp, $sp, 4			#Move stack pointer to top element

addi $sp, $sp, -4			#Move stack pointer to empty location
sw $ra, 0($sp)				#push ra onto the stack
add $t1, $zero, $zero
jal draw_log_row			#draw log row
lw $ra, 0($sp)				#pop ra off the stack
addi $sp, $sp, 4			#Move stack pointer to top element

addi $sp, $sp, -4			#Move stack pointer to empty location
sw $ra, 0($sp)				#push ra onto the stack
add $t1, $zero, $zero
jal draw_frog				#draw frog
lw $ra, 0($sp)				#pop ra off the stack
addi $sp, $sp, 4			#Move stack pointer to top element


addi $sp, $sp, -4			#Move stack pointer to empty location
sw $ra, 0($sp)				#push ra onto the stack
add $t1, $zero, $zero
jal update_car_row			#update_car_row
lw $ra, 0($sp)				#pop ra off the stack
addi $sp, $sp, 4			#Move stack pointer to top element

addi $sp, $sp, -4			#Move stack pointer to empty location
sw $ra, 0($sp)				#push ra onto the stack
add $t1, $zero, $zero
jal update_log_row			#update_car_row
lw $ra, 0($sp)				#pop ra off the stack
addi $sp, $sp, 4			#Move stack pointer to top element

#sleep for 1 second
li $v0, 32
li $a0, 80
syscall

j game_start
end_map_loop:
j Exit





#----------------------------------------------------get score----------------------------------------------------------
#######################################################################################################################
#----------------------------------------------------------------------------------------------------------------------
get_score:
la $s3	goal1_filled
lw $s3  0($s3)					# s3 = goal1_filled
la $s4	goal2_filled
lw $s4  0($s4)					# s4 = goal2_filled
la $s5	goal3_filled
lw $s5  0($s5)					# s5 = goal3_filled

# v1 stores the score for this game
add $v1, $zero, $zero				# v1 = 0
goal1:
bne $s3, $zero, goal2				# if s3 != 0, goal1 is empty, jump to goal2 
addi $v1, $v1, 1				# v1 ++
goal2:
bne $s4, $zero, goal3				# if s4 != 0, goal2 is empty, jump to goal3 
addi $v1, $v1, 1				# v1 ++
goal3:
bne $s5, $zero, end_get_score			# if s5 != 0, goal3 is empty, jump to end_get_score
addi $v1, $v1, 1				# v1 ++

end_get_score:
jr $ra


#----------------------------------------------------second level----------------------------------------------------------
#######################################################################################################################
#----------------------------------------------------------------------------------------------------------------------
second_level:
addi $t1, $zero, 1					# t1 = 1
la $t2, game_on
sw $t1, 0($t2)						# set game_on to 1

la $s3, lives						# s3 = adress of lives
addi $s4, $zero, 3					# s4 = 3			
sw $s4, 0($s3)						# reset lives to 3

la $s5, level2						# s5 = level2
addi $s6, $zero, 1					# s6 = 1			
sw $s6, 0($s5)						# set level2 to 1


addi $s0, $zero, 8					# s0 stores the value 8
la $s1, car_row2_speed
sw $s0, 0($s1)						# set car_row2_speed to 8 
la $s2, log_row1_speed
sw $s0, 0($s2)						# set log_row1_speed to 8 

la $t3, frog_x					# t3 has the address of frog_x								
la $t4, frog_y					# t4 has the address of frog_y				
la $t5, frog_start_x
lw $t5, 0($t5)					# t5 =  value of frog_start_x
la $t6, frog_start_y	
lw $t6, 0($t6)					# t6 =  value of frog_start_y

sw $t5, 0($t3)					# Set frog_x to start
sw $t6, 0($t4)					# Set frog_y to start

end_second_level:
j game_start




#----------------------------------------------------Move----------------------------------------------------------
###################################################################################################################
#------------------------------------------------------------------------------------------------------------------
Move:
lw $t8, 0xffff0000					# t8 stores the value of memory address 0xffff0000
beq $t8, 1, keyboard_input				# check if a key is pressed 
j end_move						# if no key is pressed, end move

keyboard_input:
	lw $t2, 0xffff0004				# t2 stores the next integer in memory, what key is pressed	
	beq $t2, 0x77, respond_to_W			# check if pressed W
	beq $t2, 0x61, respond_to_A			# check if pressed A
	beq $t2, 0x73, respond_to_S			# check if pressed S
	beq $t2, 0x64, respond_to_D			# check if pressed D
end_keyboard_input:
j end_move

#-------------------------responds---------------------------
respond_to_W:				# Move up
#sound effect
addi $sp, $sp, -4				#Move stack pointer to empty location
sw $ra, 0($sp)					#push ra onto the stack
jal move_sound
lw $ra, 0($sp)					#pop ra off the stack
addi $sp, $sp, 4				#Move stack pointer to top element

la $t4, frog_y				# t4 has the address of frog_y
lw $t6, 0($t4)				# Fetch y position of frog
subi $t6, $t6, 3			# frog_y+3
sw $t6, 0($t4)				# store new y coordinate of the frog	
end_respond_to_W:
j check_edge

respond_to_S:				# Move down
#sound effect
addi $sp, $sp, -4				#Move stack pointer to empty location
sw $ra, 0($sp)					#push ra onto the stack
jal move_sound
lw $ra, 0($sp)					#pop ra off the stack
addi $sp, $sp, 4				#Move stack pointer to top element

la $t4, frog_y				# t4 has the address of frog_y
lw $t6, 0($t4)				# Fetch y position of frog
addi $t6, $t6, 3			# frog_y-3
sw $t6, 0($t4)				# store new y coordinate of the frog
end_respond_to_S:
j check_edge

respond_to_D:				# Move right
#sound effect
addi $sp, $sp, -4				#Move stack pointer to empty location
sw $ra, 0($sp)					#push ra onto the stack
jal move_sound
lw $ra, 0($sp)					#pop ra off the stack
addi $sp, $sp, 4				#Move stack pointer to top element

la $t3, frog_x				# t3 has the address of frog_x
lw $t5, 0($t3)				# Fetch x position of frog
addi $t5, $t5, 3			# frog_x+3
sw $t5, 0($t3)				# store new x coordinate of the frog
end_respond_to_D:
j check_edge

respond_to_A:				# Move left
#sound effect
addi $sp, $sp, -4				#Move stack pointer to empty location
sw $ra, 0($sp)					#push ra onto the stack
jal move_sound
lw $ra, 0($sp)					#pop ra off the stack
addi $sp, $sp, 4				#Move stack pointer to top element

la $t3, frog_x				# t3 has the address of frog_x
lw $t5, 0($t3)				# Fetch x position of frog
subi $t5, $t5, 3			# frog_x-3
sw $t5, 0($t3)				# store new x coordinate of the frog
end_respond_to_A:
j check_edge


#------------------------------------------edge----------------------------------------------------
check_edge:
addi $a1, $zero, 1			# a1 stores the value 1
check_y:	
# check if y exceed the edge
la $t4, frog_y				# t4 has the address of frog_y
lw $t6, 0($t4)				# Fetch y position of frog
	
	check_bot:
	slti $a0, $t6, 29			# a0 stores whether t4 < 29, 
						# t4 < 29: a0 = 1,    t5 >= 29: a0 = 0
	beq $a0, $a1, check_x			# if a0 = 1, jump
		addi $t8, $zero, 29		# t8 stores the value of the edge
		sw $t8, 0($t4)			# store new y coordinate of the frog

# check if x exceed the edge
check_x:
la $t3, frog_x				# t3 has the address of frog_x
lw $t5, 0($t3)				# Fetch x position of frog

	check_left:
	slt $a0, $t5, $zero			# a0 stores whether t5 < 0, 
						# t5 < 0: a0 = 1,    t5 >= 0: a0 = 0
	bne $a0, $a1, check_right		# if a0 = 0, jump			
		add $t8, $zero, $zero		# t8 stores the value of the edge
		sw $t8, 0($t3)			# store new y coordinate of the frog	

	check_right:
	slti $a0, $t5, 29			# a0 stores whether t5 < 29, 
						# t5 < 29: a0 = 1,    t5 >= 29: a0 =0
	beq $a0, $a1, end_check_edge		# if a0 = 1, jump			
		addi $t8, $zero, 29		# t8 stores the value of the edge
		sw $t8, 0($t3)			# store new y coordinate of the frog	

end_check_edge:
jr $ra


end_move:
jr $ra




#----------------------------------------------------collision-----------------------------------------------------
###################################################################################################################
#------------------------------------------------------------------------------------------------------------------


# collide cars if   -3 < frog_x - car_x < 6 		and 	car_y = frog_y, collide
# check_collide_cars: (a1: car_x, a2: car_y)
check_collide_cars:	
addi $a0, $zero, 1				# a0 stores the value 1
						
la $t3, frog_x					# t3 has the address of frog_x
lw $t5, 0($t3)					# Fetch x position of frog
la $t4, frog_y					# t4 has the address of frog_y
lw $t6, 0($t4)					# Fetch y position of frog
bne $t6, $a2, end_check_collide_cars		# if t6 != a2, no collide

sub $s1, $t5, $a1				# s1 = t5 - a1
addi $s2, $zero, -3				# s2 stores the value -3 
addi $s3, $zero, 6				# s2 stores the value 6 
beq $s1, $s2, end_check_collide_cars 		# if s1 == -3, no collide
beq $s1, $s3, end_check_collide_cars 		# if s1 == 6, no collide

slti $s4, $s1, -3				# s4 stores whether s1 < -3, 
						# s1 < -3: s4 = 1,    s1 >= -3: s4 = 0 (s1 > -3 since checked s1 != -3 above)
slti $s5, $s1, 6				# s5 stores whether s1 < 6, 
						# s1 < 6: s5 = 1,    s1 >= 6: s5 = 0

beq $s4, $zero, check_6				# if s4 = 0: s1 > -6, check if s1 < 6
j end_check_collide_cars

check_6:
beq $s5, $a0, collide_response			# if s5 = 1: s1 < 6, collide	

end_check_collide_cars:
jr $ra



# on logs if  -1 < frog_x - car_x  < 6 	and 		car_y = frog_y, on log, st v0 to 1
# check_collide_logs: (a1: log_x, a2: log_y, v0: is_on_log)
check_collide_logs:	
addi $a0, $zero, 1				# a0 stores the value 1
beq $v0, $a0, end_check_collide_logs		# if v0 == 1, on log and safe, don't need to check this log then
						# if v0 == 0, keep check
						
# add $v0, $zero, $zero				# v0 stores is_on_log, would be change to 1 if a						
la $t3, frog_x					# t3 has the address of frog_x
lw $t5, 0($t3)					# Fetch x position of frog
la $t4, frog_y					# t4 has the address of frog_y
lw $t6, 0($t4)					# Fetch y position of frog
bne $t6, $a2, end_check_collide_logs		# if t6 != a2, not on the log

sub $s1, $t5, $a1				# s1 = t5 - a1
addi $s2, $zero, -1				# s2 stores the value -1 
addi $s3, $zero, 6				# s2 stores the value 6 
beq $s1, $s2, end_check_collide_logs 		# if s1 == -1, not on the log
beq $s1, $s3, end_check_collide_logs 		# if s1 == 5, not on the log

slti $s4, $s1, -1				# s4 stores whether s1 < -1, 
						# s1 < -1: s4 = 1,    s1 >= -1: s4 = 0 (s1 > -1 since checked s1 != -1 above)
slti $s5, $s1, 6				# s5 stores whether s1 < 6, 
						# s1 < 6: s5 = 1,    s1 >= 6: s5 = 0

beq $s4, $a0, end_check_collide_logs		# if s4 = 1: s1 < -1, not on the log
beq $s5, $zero, end_check_collide_logs		# if s5 = 0: s1 >= 6, not on the log	

addi $v0, $zero, 1				# v0 stores is_on_log, would be change to 1 if a

end_check_collide_logs:
jr $ra



# if collide, call the following functions to response
collide_response:
#sound effect
addi $sp, $sp, -4				#Move stack pointer to empty location
sw $ra, 0($sp)					#push ra onto the stack
jal collide_sound
lw $ra, 0($sp)					#pop ra off the stack
addi $sp, $sp, 4				#Move stack pointer to top element


# respawn animation
addi $sp, $sp, -4				#Move stack pointer to empty location
sw $ra, 0($sp)					#push ra onto the stack
jal respawn_animation				#respawn_animation
lw $ra, 0($sp)					#pop ra off the stack
addi $sp, $sp, 4				#Move stack pointer to top element

# reset frog to starting possion
la $t3, frog_x					# t3 has the address of frog_x								
la $t4, frog_y					# t4 has the address of frog_y				
la $t5, frog_start_x
lw $t5, 0($t5)					# t5 =  value of frog_start_x
la $t6, frog_start_y	
lw $t6, 0($t6)					# t6 =  value of frog_start_y

sw $t5, 0($t3)					# Set frog_x to start
sw $t6, 0($t4)					# Set frog_y to start
													
# lives - 1					
la $t7, lives					# t7 has the address of lives
lw $t8, 0($t7)					# t8 =  value of lives
subi $t8, $t8, 1				# t8 --
sw $t8, 0($t7)					# lives - 1 			
											
# if lives == 0, end game
beq $t8, $zero, end_game					
					
end_collide_response:
jr $ra



# if (frog_x, frog_y) == 
#	(4,5) (5,5) (14,5) (15,5) (24,5) (25,5)
check_collide_goals:
la $t3, frog_x					
lw $t3, 0($t3)					# t3 stores frog_x
la $t4, frog_y					
lw $t4, 0($t4)					# t4 stores frog_y

addi $s0, $zero, 5				# s0 stores the value of 5

bne $t6, $s0, end_check_collide_goals		# if 74 != 5, end_check_collide_goals


addi $s1, $zero, 4				# s1 stores the value of 4
addi $s2, $zero, 14				# s2 stores the value of 14
addi $s3, $zero, 15				# s3 stores the value of 15
addi $s4, $zero, 24				# s4 stores the value of 24
addi $s5, $zero, 25				# s5 stores the value of 25
addi $s6, $zero, 1				# s5 stores the value of 1

check_g1:
la $a1	goal1_filled				# a1 = goal1_filled address
lw $s7 0($a1)					# s7 = goal1_filled
bne $s7, $s6, check_goal1_filled		# if s7 != 1, goal1 is filled, check_goal1_filled
j check_goal1

check_goal1_filled:
	check_4_5_filled:				# (4,5)
	bne $t3, $s1, check_5_5_filled			# if t3 != s1, check_5_5_filled
	addi $sp, $sp, -4				#Move stack pointer to empty location
	sw $ra, 0($sp)					#push ra onto the stack
	add $t1, $zero, $zero
	jal collide_response				#collide_response
	lw $ra, 0($sp)					#pop ra off the stack
	addi $sp, $sp, 4				#Move stack pointer to top element
	j end_check_collide_goals			# if t3 == s1, collide with goal1, no need to check other goals
	check_5_5_filled:				# (5,5)
	bne $t3, $s0, check_goal1			# if t3 != s0, check_goal1
	addi $sp, $sp, -4				#Move stack pointer to empty location
	sw $ra, 0($sp)					#push ra onto the stack
	add $t1, $zero, $zero
	jal collide_response				#collide_response
	lw $ra, 0($sp)					#pop ra off the stack
	addi $sp, $sp, 4				#Move stack pointer to top element
	j end_check_collide_goals			# if t3 == s1, collide with goal1, no need to check other goals
end_check_goal1_filled:

check_goal1:
	check_4_5:					# (4,5)
	bne $t3, $s1, check_5_5				# if t3 != s1, check_5_5
	la $a1	goal1_filled	
	sw $zero 0($a1)	 				# set goal1_filled to 0
	j end_check_collide_goals			# if t3 == s1, collide with goal1, no need to check other goals
	check_5_5:					# (5,5)
	bne $t3, $s0, check_g2				# if t3 != s0, check_g2
	la $a1	goal1_filled
	sw $zero 0($a1)	 				# set goal1_filled to 0
	j end_check_collide_goals			# if t3 == s1, collide with goal1, no need to check other goals


check_g2:
la $a1	goal2_filled					# a1 = goal2_filled address
lw $s7 0($a1)						# s7 = goal2_filled
bne $s7, $s6, check_goal2_filled			# if s7 != 1, goal2 is filled, check_goal2_filled
j check_goal2

check_goal2_filled:
	check_14_5_filled:				# (14,5)
	bne $t3, $s2, check_15_5_filled			# if t3 != s2, check_15_5_filled
	addi $sp, $sp, -4				#Move stack pointer to empty location
	sw $ra, 0($sp)					#push ra onto the stack
	add $t1, $zero, $zero
	jal collide_response				#collide_response
	lw $ra, 0($sp)					#pop ra off the stack
	addi $sp, $sp, 4				#Move stack pointer to top element
	j end_check_collide_goals			# if t3 == s2, collide with goal2, no need to check other goals
	check_15_5_filled:				# (15,5)
	bne $t3, $s3, check_goal2			# if t3 != s3, check_goal2
	addi $sp, $sp, -4				#Move stack pointer to empty location
	sw $ra, 0($sp)					#push ra onto the stack
	add $t1, $zero, $zero
	jal collide_response				#collide_response
	lw $ra, 0($sp)					#pop ra off the stack
	addi $sp, $sp, 4				#Move stack pointer to top element
	j end_check_collide_goals			# if t3 == s2, collide with goal2, no need to check other goals
end_check_goal2_filled:

check_goal2:
check_14_5:					# (14,5)
bne $t3, $s2, check_15_5			# if t3 != s2, check_15_5
la $a1	goal2_filled
sw $zero 0($a1)	 				# set goal2_filled to 0
j end_check_collide_goals			# if t3 == s2, collide with goal2, no need to check other goals
check_15_5:					# (15,5)
bne $t3, $s3, check_g3				# if t3 != s3, check_g3
la $a1	goal2_filled
sw $zero 0($a1)	 				# set goal2_filled to 0
j end_check_collide_goals			# if t3 == s2, collide with goal2, no need to check other goals


check_g3:
la $a1	goal3_filled				# a1 = goal3_filled address
lw $s7 0($a1)					# s7 = goal3_filled
bne $s7, $s6, check_goal3_filled		# if s7 != 1, goal3 is filled, check_goal3_filled
j check_goal3

check_goal3_filled:
	check_24_5_filled:				# (24,5)
	bne $t3, $s4, check_25_5_filled			# if t3 != s4, check_25_5_filled
	addi $sp, $sp, -4				#Move stack pointer to empty location
	sw $ra, 0($sp)					#push ra onto the stack
	add $t1, $zero, $zero
	jal collide_response				#collide_response
	lw $ra, 0($sp)					#pop ra off the stack
	addi $sp, $sp, 4				#Move stack pointer to top element
	j end_check_collide_goals			# if t3 == s3, collide with goal3, no need to check other goals
	check_25_5_filled:				# (25,5)
	bne $t3, $s5, check_goal3			# if t3 != s5, check_goal3
	addi $sp, $sp, -4				#Move stack pointer to empty location
	sw $ra, 0($sp)					#push ra onto the stack
	add $t1, $zero, $zero
	jal collide_response				#collide_response
	lw $ra, 0($sp)					#pop ra off the stack
	addi $sp, $sp, 4				#Move stack pointer to top element
	j end_check_collide_goals			# if t3 == s3, collide with goal3, no need to check other goals
end_check_goal3_filled:

check_goal3:
check_24_5:					# (24,5)
bne $t3, $s4, check_25_5			# if t3 != s4, check_25_5
la $a1	goal3_filled
sw $zero 0($a1)	 				# set goal3_filled to 0
j end_check_collide_goals			# if t3 == s3, collide with goal3, no need to check other goals
check_25_5:					# (25,5)
bne $t3, $s5, collide_response			# if t3 != s5, collide_response
la $a1	goal3_filled
sw $zero 0($a1)	 				# set goal3_filled to 0

end_check_collide_goals:
jr $ra

#-------------------------------------------------------------







#---------------------------------------------------Background-----------------------------------------------------
###################################################################################################################
#------------------------------------------------------------------------------------------------------------------
#Draw the background of the game
draw_background:
lw $t0, displayAddress # $t0 stores the base address for display

#Fetch colors
la $s2, logColor			#s2 has the address of the logColor 
la $s3, carColor			#s3 has the address of the carColor 
la $s4, roadColor			#s4 has the address of the roadColor 
la $s5, riverColor			#s5 has the address of the riverColor 
la $s6, middleColor			#s6 has the address of the middleColor 
la $s7, outerColor			#s7 has the address of the outerColor 

lw $s2, 0($s2)				
lw $s3, 0($s3)				
lw $s4, 0($s4)				
lw $s5, 0($s5)				
lw $s6, 0($s6)				
lw $s7, 0($s7)	
		

#-----------------------------------------------
#draw the top outer region
addi $a2, $zero, 256
add $a3, $zero, $s7

addi $sp, $sp, -4			#Move stack pointer to empty location
sw $ra, 0($sp)				#push ra onto the stack
add $t1, $zero, $zero
jal paint_row				#draw a row
lw $ra, 0($sp)				#pop ra off the stack
addi $sp, $sp, 4			#Move stack pointer to top element

#-----------------------------------------------
#draw river
addi $a2, $zero, 288
add $a3, $zero, $s5

addi $sp, $sp, -4			#Move stack pointer to empty location
sw $ra, 0($sp)				#push ra onto the stack
add $t1, $zero, $zero
jal paint_row				#draw a row
lw $ra, 0($sp)				#pop ra off the stack
addi $sp, $sp, 4			#Move stack pointer to top element

#-----------------------------------------------
#draw middle
addi $a2, $zero, 96
add $a3, $zero, $s6

addi $sp, $sp, -4			#Move stack pointer to empty location
sw $ra, 0($sp)				#push ra onto the stack
add $t1, $zero, $zero
jal paint_row				#draw a row
lw $ra, 0($sp)				#pop ra off the stack
addi $sp, $sp, 4			#Move stack pointer to top element

#-----------------------------------------------
#draw road
addi $a2, $zero, 288
add $a3, $zero, $s4

addi $sp, $sp, -4			#Move stack pointer to empty location
sw $ra, 0($sp)				#push ra onto the stack
add $t1, $zero, $zero
jal paint_row				#draw a row
lw $ra, 0($sp)				#pop ra off the stack
addi $sp, $sp, 4			#Move stack pointer to top element

#-----------------------------------------------
# draw the bottom outer region
addi $a2, $zero, 96
add $a3, $zero, $s7

addi $sp, $sp, -4			#Move stack pointer to empty location
sw $ra, 0($sp)				#push ra onto the stack
add $t1, $zero, $zero
jal paint_row				#draw a row
lw $ra, 0($sp)				#pop ra off the stack
addi $sp, $sp, 4			#Move stack pointer to top element


#-----------------------------------------------
#draw the goal region
la $s1, goalColor			#s1 has the address of the goalColor color
lw $s1, 0($s1)				# s1 = goalColor
la $s0, goalColorFilled		
lw $s0, 0($s0)				# s0 = goalColorFilled

add $t1, $zero, $zero			#set t1 to 0
add $t2, $zero, $zero 			#set t2 to 0

add $t3, $zero, 656			#t3 = 4 * 4 + 5 * 128 = 656
add $t4, $zero, 696			#t4 = 14 * 4 + 5 * 128 = 696
add $t5, $zero, 736			#t5 = 24 * 4 + 5 * 128 = 736

addi $a1, $zero, 3			#height a1 = 3
addi $a2, $zero, 4			#width a2 = 4
	#Draw goal 1
	add $a3, $zero, $s1			#color a3 = goalColor  
	la $t6, goal1_filled
	lw $t6, 0($t6)				# t6 = goal1_filled
	bne $t6, $zero, draw_goal_1		# if t6 != 0, t6 == 1, draw goal1 directly
		add $a3, $zero, $s0		#color a3 = goalColorFilled  
	draw_goal_1:
	lw $t0, displayAddress 			# $t0 stores the base address for display
	add $t0, $t0, $t3
	addi $sp, $sp, -4			#Move stack pointer to empty location
	sw $ra, 0($sp)				#push ra onto the stack
	add $t1, $zero, $zero
	jal paint_rect				#draw a rectangle
	lw $ra, 0($sp)				#pop ra off the stack
	addi $sp, $sp, 4			#Move stack pointer to top element
	
	#Draw goal 2
	add $a3, $zero, $s1			#color a3 = goalColor  
	la $t6, goal2_filled
	lw $t6, 0($t6)				# t6 = goal2_filled
	bne $t6, $zero, draw_goal_2		# if t6 != 0, t6 == 1, draw goal2 directly
		add $a3, $zero, $s0		#color a3 = goalColorFilled  
	draw_goal_2:
	lw $t0, displayAddress 			# $t0 stores the base address for display
	add $t0, $t0, $t4
	addi $sp, $sp, -4			#Move stack pointer to empty location
	sw $ra, 0($sp)				#push ra onto the stack
	add $t1, $zero, $zero
	jal paint_rect				#draw a rectangle
	lw $ra, 0($sp)				#pop ra off the stack
	addi $sp, $sp, 4			#Move stack pointer to top element
	
	#Draw goal 3
	add $a3, $zero, $s1			#color a3 = goalColor  
	la $t6, goal3_filled
	lw $t6, 0($t6)				# t6 = goal3_filled
	bne $t6, $zero, draw_goal_3		# if t6 != 0, t6 == 1, draw goal3 directly
		add $a3, $zero, $s0		#color a3 = goalColorFilled  
	draw_goal_3:
	lw $t0, displayAddress 			# $t0 stores the base address for display
	add $t0, $t0, $t5
	addi $sp, $sp, -4			#Move stack pointer to empty location
	sw $ra, 0($sp)				#push ra onto the stack
	add $t1, $zero, $zero
	jal paint_rect				#draw a rectangle
	lw $ra, 0($sp)				#pop ra off the stack
	addi $sp, $sp, 4			#Move stack pointer to top element

#-----------------------------------------------
draw_lives:
lw $t0, displayAddress 			# $t0 stores the base address for display
la $t8, livesColor			#t8 has the address of the livesColor 
lw $t8, 0($t8)	

la $t9, lives				
lw $t9, 0($t9)				# t9 = lives

addi $t1, $zero, 1			# t1 = 1
addi $t2, $zero, 2			# t2 = 2
addi $t3, $zero, 3			# t3 = 3

draw_live3:
bne $t9, $t3, draw_live2		# if t9 != 3, draw_live2
sw $t8, 152($t0) 
subi $t9, $t9, 1			# t9 --
draw_live2:
bne $t9, $t2, draw_live1		# if t9 != 2, draw_live1
sw $t8, 144($t0)
subi $t9, $t9, 1			# t9 --
draw_live1:
bne $t9, $t1, end_draw_lives		# if t9 != 1, end_draw_lives
sw $t8, 136($t0) 

end_draw_lives:
add $t1, $zero, $zero
add $t2, $zero, $zero
add $t3, $zero, $zero
add $t8, $zero, $zero
add $t9, $zero, $zero

end_draw_background:
jr $ra





#----------------------------------------------Frog-----------------------------------------------------------------
draw_frog:
lw $t0, displayAddress 			# $t0 stores the base address for display


#-----------------------check collision--------------------------
check_collide:

check_cars:
# check_collide_cars: (a1: car_x, a2: car_y)
#check car_row 1
	#check car1
	addi $a2, $zero, 20			# set a2 to 20, the height of car row 1
	la $s1, car1 
	lw $s1, 0($s1)				# s1 stores the position for car1
	addi $s2, $zero, 2560			# s2 stores the value 2560, starting position of car row 1
	sub $s3, $s1, $s2			# s3 = s1 - s2
	addi $s4, $zero, 4			# s4 stores the value 4
	div $s3, $s4
	mflo $a1				# s5 = s3 / s4


	addi $sp, $sp, -4			#Move stack pointer to empty location
	sw $ra, 0($sp)				#push ra onto the stack
	add $t1, $zero, $zero
	jal check_collide_cars			#check_collide_cars
	lw $ra, 0($sp)				#pop ra off the stack
	addi $sp, $sp, 4			#Move stack pointer to top element

	#check car2
	addi $a2, $zero, 20			# set a2 to 20, the height of car row 1
	la $s1, car2 
	lw $s1, 0($s1)				# s1 stores the position for car2
	addi $s2, $zero, 2560			# s2 stores the value 2560, starting position of car row 1
	sub $s3, $s1, $s2			# s3 = s1 - s2
	addi $s4, $zero, 4			# s4 stores the value 4
	div $s3, $s4
	mflo $a1				# s5 = s3 / s4


	addi $sp, $sp, -4			#Move stack pointer to empty location
	sw $ra, 0($sp)				#push ra onto the stack
	add $t1, $zero, $zero
	jal check_collide_cars			#check_collide_cars
	lw $ra, 0($sp)				#pop ra off the stack
	addi $sp, $sp, 4			#Move stack pointer to top element
	
#check car_row 2
	#check car3
	addi $a2, $zero, 23			# set a2 to 23, the height of car row 2
	la $s1, car3 
	lw $s1, 0($s1)				# s1 stores the position for car3
	addi $s2, $zero, 2944			# s2 stores the value 2944, starting position of car row 2
	sub $s3, $s1, $s2			# s3 = s1 - s2
	addi $s4, $zero, 4			# s4 stores the value 4
	div $s3, $s4
	mflo $a1				# s5 = s3 / s4


	addi $sp, $sp, -4			#Move stack pointer to empty location
	sw $ra, 0($sp)				#push ra onto the stack
	add $t1, $zero, $zero
	jal check_collide_cars			#check_collide_cars
	lw $ra, 0($sp)				#pop ra off the stack
	addi $sp, $sp, 4			#Move stack pointer to top element

	#check car4
	addi $a2, $zero, 23			# set a2 to 23, the height of car row 2
	la $s1, car4 
	lw $s1, 0($s1)				# s1 stores the position for car4
	addi $s2, $zero, 2944			# s2 stores the value s944, starting position of car row 2
	sub $s3, $s1, $s2			# s3 = s1 - s2
	addi $s4, $zero, 4			# s4 stores the value 4
	div $s3, $s4
	mflo $a1				# s5 = s3 / s4


	addi $sp, $sp, -4			#Move stack pointer to empty location
	sw $ra, 0($sp)				#push ra onto the stack
	add $t1, $zero, $zero
	jal check_collide_cars			#check_collide_cars
	lw $ra, 0($sp)				#pop ra off the stack
	addi $sp, $sp, 4			#Move stack pointer to top element
	
#check car_row 3
	#check car5
	addi $a2, $zero, 26			# set a2 to 26, the height of car row 3
	la $s1, car5 
	lw $s1, 0($s1)				# s1 stores the position for car5
	addi $s2, $zero, 3328			# s2 stores the value 3328, starting position of car row 3
	sub $s3, $s1, $s2			# s3 = s1 - s2
	addi $s4, $zero, 4			# s4 stores the value 4
	div $s3, $s4
	mflo $a1				# s5 = s3 / s4


	addi $sp, $sp, -4			#Move stack pointer to empty location
	sw $ra, 0($sp)				#push ra onto the stack
	add $t1, $zero, $zero
	jal check_collide_cars			#check_collide_cars
	lw $ra, 0($sp)				#pop ra off the stack
	addi $sp, $sp, 4			#Move stack pointer to top element

	#check car6
	addi $a2, $zero, 26			# set a2 to 26, the height of car row 2
	la $s1, car6 
	lw $s1, 0($s1)				# s1 stores the position for car6
	addi $s2, $zero, 3328			# s2 stores the value 3328, starting position of car row 3
	sub $s3, $s1, $s2			# s3 = s1 - s2
	addi $s4, $zero, 4			# s4 stores the value 4
	div $s3, $s4
	mflo $a1				# s5 = s3 / s4


	addi $sp, $sp, -4			#Move stack pointer to empty location
	sw $ra, 0($sp)				#push ra onto the stack
	add $t1, $zero, $zero
	jal check_collide_cars			#check_collide_cars
	lw $ra, 0($sp)				#pop ra off the stack
	addi $sp, $sp, 4			#Move stack pointer to top element
end_check_cars:


# check if the frog is on log rows, if not skip check_logs
# if 8 <= log_y < 17, check_logs, otherwise skip check_logs
la $t4, frog_y					
lw $t4, 0($t4)					# t4 has the value of frog_y

addi $s0, $zero, 17				# s0 stores the value 8

slti $s1, $t4, 8				# s1 = 1 if t4 < 8,   s1 = 0 if t4 >= 8
beq $s1, $zero, check_leq_17			# if s1 == 0, check_leq_17
j check_goals

check_leq_17:
slt $s2, $t4, $s0				# s2 = 1 if t4 < 17,	s2 = 0 if t4 >= 17
bne $s2, $zero, check_logs			# if s2 != 0,  s2 == 1, check_logs
j check_goals
						

		
																			
# check_collide_logs: (a1: log_x, a2: log_y, v0: is_on_log)
check_logs:
add $v0, $zero, $zero				# set v0 to 0
addi $v1, $zero, 1				# set v1 to 1
#check log_row 1
	#check log1
	addi $a2, $zero, 8			# set a2 to 8, the height of log row 1
	la $s1, log1 
	lw $s1, 0($s1)				# s1 stores the position for log1
	addi $s2, $zero, 1024			# s2 stores the value 1024, starting position of log row 1
	sub $s3, $s1, $s2			# s3 = s1 - s2
	addi $s4, $zero, 4			# s4 stores the value 4
	div $s3, $s4
	mflo $a1				# s5 = s3 / s4


	addi $sp, $sp, -4			#Move stack pointer to empty location
	sw $ra, 0($sp)				#push ra onto the stack
	add $t1, $zero, $zero
	jal check_collide_logs			#check_collide_logs
	lw $ra, 0($sp)				#pop ra off the stack
	addi $sp, $sp, 4			#Move stack pointer to top element
	beq $v0, $v1, check_goals		# if v0 == v1 == 1, on_log, no need to check other logs
	
	#check log2
	addi $a2, $zero, 8			# set a2 to 8, the height of log row 1
	la $s1, log2 
	lw $s1, 0($s1)				# s1 stores the position for log2
	addi $s2, $zero, 1024			# s2 stores the value 1024, starting position of log row 1
	sub $s3, $s1, $s2			# s3 = s1 - s2
	addi $s4, $zero, 4			# s4 stores the value 4
	div $s3, $s4
	mflo $a1				# s5 = s3 / s4


	addi $sp, $sp, -4			#Move stack pointer to empty location
	sw $ra, 0($sp)				#push ra onto the stack
	add $t1, $zero, $zero
	jal check_collide_logs			#check_collide_logs
	lw $ra, 0($sp)				#pop ra off the stack
	addi $sp, $sp, 4			#Move stack pointer to top element
	beq $v0, $v1, check_goals		# if v0 == v1 == 1, on_log, no need to check other logs
	
#check log_row 2
	#check log3
	addi $a2, $zero, 11			# set a2 to 11, the height of log row 2
	la $s1, log3 
	lw $s1, 0($s1)				# s1 stores the position for log3
	addi $s2, $zero, 1408			# s2 stores the value 1408, starting position of log row 2
	sub $s3, $s1, $s2			# s3 = s1 - s2
	addi $s4, $zero, 4			# s4 stores the value 4
	div $s3, $s4
	mflo $a1				# s5 = s3 / s4

	addi $sp, $sp, -4			#Move stack pointer to empty location
	sw $ra, 0($sp)				#push ra onto the stack
	add $t1, $zero, $zero
	jal check_collide_logs			#check_collide_logs
	lw $ra, 0($sp)				#pop ra off the stack
	addi $sp, $sp, 4			#Move stack pointer to top element
	beq $v0, $v1, check_goals		# if v0 == v1 == 1, on_log, no need to check other logs

	#check log4
	addi $a2, $zero, 11			# set a2 to 11, the height of log row 2
	la $s1, log4 
	lw $s1, 0($s1)				# s1 stores the position for log4
	addi $s2, $zero, 1408			# s2 stores the value 1408, starting position of log row 2
	sub $s3, $s1, $s2			# s3 = s1 - s2
	addi $s4, $zero, 4			# s4 stores the value 4
	div $s3, $s4
	mflo $a1				# s5 = s3 / s4

	addi $sp, $sp, -4			#Move stack pointer to empty location
	sw $ra, 0($sp)				#push ra onto the stack
	add $t1, $zero, $zero
	jal check_collide_logs			#check_collide_logs
	lw $ra, 0($sp)				#pop ra off the stack
	addi $sp, $sp, 4			#Move stack pointer to top element
	beq $v0, $v1, check_goals		# if v0 == v1 == 1, on_log, no need to check other logs
	
#check log_row 3
	#check log5
	addi $a2, $zero, 14			# set a2 to 14, the height of log row 3
	la $s1, log5 
	lw $s1, 0($s1)				# s1 stores the position for log5
	addi $s2, $zero, 1792			# s2 stores the value 1792, starting position of log row 3
	sub $s3, $s1, $s2			# s3 = s1 - s2
	addi $s4, $zero, 4			# s4 stores the value 4
	div $s3, $s4
	mflo $a1				# s5 = s3 / s4


	addi $sp, $sp, -4			#Move stack pointer to empty location
	sw $ra, 0($sp)				#push ra onto the stack
	add $t1, $zero, $zero
	jal check_collide_logs			#check_collide_logs
	lw $ra, 0($sp)				#pop ra off the stack
	addi $sp, $sp, 4			#Move stack pointer to top element
	beq $v0, $v1, check_goals		# if v0 == v1 == 1, on_log, no need to check other logs

	#check log6
	addi $a2, $zero, 14			# set a2 to 14, the height of log row 3
	la $s1, log6 
	lw $s1, 0($s1)				# s1 stores the position for log6
	addi $s2, $zero, 1792			# s2 stores the value 1792, starting position of log row 3
	sub $s3, $s1, $s2			# s3 = s1 - s2
	addi $s4, $zero, 4			# s4 stores the value 4
	div $s3, $s4
	mflo $a1				# s5 = s3 / s4

	addi $sp, $sp, -4			#Move stack pointer to empty location
	sw $ra, 0($sp)				#push ra onto the stack
	add $t1, $zero, $zero
	jal check_collide_logs			#check_collide_logs
	lw $ra, 0($sp)				#pop ra off the stack
	addi $sp, $sp, 4			#Move stack pointer to top element
	beq $v0, $v1, check_goals 		# if v0 == v1 == 1, on_log, no need to check other logs	
	
	sw $ra, 0($sp)				#push ra onto the stack
	add $t1, $zero, $zero
	jal collide_response			#collide_response
	lw $ra, 0($sp)				#pop ra off the stack
	addi $sp, $sp, 4			#Move stack pointer to top element
	
end_check_logs:


# check_collide_goals: (a1: goal_x, a2: goal_y)
check_goals:
addi $sp, $sp, -4				#Move stack pointer to empty location
sw $ra, 0($sp)					#push ra onto the stack
add $t1, $zero, $zero
jal check_collide_goals				#check_collide_goals	
lw $ra, 0($sp)					#pop ra off the stack
addi $sp, $sp, 4				#Move stack pointer to top element

end_check_collide:


#------------------------------------------------------------------


#start draw the frog
#Move t0 to (frog_x, frog_y)
add $t1, $zero, $zero 			#set t1 to 0
add $t2, $zero, $zero 			#set t2 to 0


addi $sp, $sp, -4			#Move stack pointer to empty location
sw $ra, 0($sp)				#push ra onto the stack
add $t1, $zero, $zero
jal Move				#check if moved, do responses if moved
lw $ra, 0($sp)				#pop ra off the stack
addi $sp, $sp, 4			#Move stack pointer to top element


la $t3, frog_x				#t3 has the address of frog_x
la $t4, frog_y				#t4 has the address of frog_y
lw $t5, 0($t3)				#Fetch x position of frog
lw $t6, 0($t4)				#Fetch y position of frog
sll $t5, $t5, 2				#Multiply t5 by 4
sll $t6, $t6, 7				#Multiply t6 by 128
add $t0, $t0, $t5			#Add x offset to t0
add $t0, $t0, $t6			#Add y offset to t0

#Fetch frog colors
la $s1, frogBody			#t7 has the address of the frogBody color
la $s2, frogEye				#t8 has the address of the frogEye color
la $s3, frogTail			#t9 has the address of the frogTail color
lw $s1, 0($s1)				#Fetch frogBody color of frog
lw $s2, 0($s2)				#Fetch frogEye color of frog
lw $s3, 0($s3)				#Fetch frogTail color of frog

#draw first row
sw $s2, 0($t0) 
addi $t0, $t0, 4
sw $s1, 0($t0) 
addi $t0, $t0, 4
sw $s2, 0($t0) 

#draw the second row
addi $t0, $t0, 120
addi $a1, $zero, 1			
addi $a2, $zero, 3
add $a3, $zero, $s1			#set color to frogBody
addi $sp, $sp, -4			#Move stack pointer to empty location
sw $ra, 0($sp)				#push ra onto the stack
add $t1, $zero, $zero
add $t2, $zero, $zero
jal paint_rect				#draw a rect
lw $ra, 0($sp)				#pop ra off the stack
addi $sp, $sp, 4			#Move stack pointer to top element

#draw the third row
sw $s1, 0($t0) 
sw $s3, 4($t0) 
sw $s1, 8($t0) 

end_draw_frog:
jr $ra



#-------------------------------------------Car Row------------------------------------------------------------------
#Draw a car: (s1 is the address of the car, a0 is the max of the row)
draw_car:
lw $t0, displayAddress # $t0 stores the base address for display

la $a3, carColor			#a3 has the address of the carColor color
lw $a3, 0($a3)		
		
lw $s0, 0($s1)				#s0 stores the top-left coordinate of this car

add $t0, $t0, $s0			#Move t0 to s0

la $a1, car_height
lw $a1, 0($a1)				#a1 stores the height
la $a2, car_width
lw $a2, 0($a2)				#a2 stores the width

	
exceed_car_row:
addi $t9, $zero, 1			#Using t9 to store value 1
sub $t6, $a0, $s0 			#t6 = a0 - s0
slti $t7, $t6, 24			#t7 stores whether t6 = a0 - s0 < 24, 
#s0 exceed if: a0 - s0 < 24, t7 == 1 
bne $t7, $t9, not_exceed_car		#if t7 != 1, jump to not_exceed
	slt $t4, $t6, $zero		#t4 stores whether t6 = a0 - s0 < 0, 
					#s0 rare if: a0 - s0 < 0, t4 == 1 
	bne $t4, $t9, check0_car	#if t6 = a0 - s0 >= 0, jump to check0
	subi $s0, $a0, 128		#set the position to the top-left of the row, s0 = a0 - 128
	sub $s0, $s0, $t6		#s0 = s0 + (-t6) = s0 + (- (a0 - s0) )
	sw $s0, 0($s1)			#store new location of the car		
	lw $t0, displayAddress # $t0 stores the base address for display
	add $t0, $t0, $s0			#set t0 to s0
	addi $sp, $sp, -4			#Move stack pointer to empty location
	sw $ra, 0($sp)				#push ra onto the stack
	add $t1, $zero, $zero
	jal paint_rect				#Draw a rectangle: (s0 is the top-left coordinate. a1 is the height, a2 is the width, a3 is the color)
	lw $ra, 0($sp)				#pop ra off the stack
	addi $sp, $sp, 4			#Move stack pointer to top element
	j end_draw_car
		
	check0_car:
	bne $t6, $zero, keep_car	#if t6 = a0 - s0 != 0, jump to keep
	subi $s0, $a0, 128		#set the position to the top-left of the row, s0 = a0 - 128
	sw $s0, 0($s1)			#store new location of the car
	lw $t0, displayAddress # $t0 stores the base address for display
	add $t0, $t0, $s0			#set t0 to s0
	addi $sp, $sp, -4			#Move stack pointer to empty location
	sw $ra, 0($sp)				#push ra onto the stack
	add $t1, $zero, $zero
	jal paint_rect				#Draw a rectangle: (s0 is the top-left coordinate. a1 is the height, a2 is the width, a3 is the color)
	lw $ra, 0($sp)				#pop ra off the stack
	addi $sp, $sp, 4			#Move stack pointer to top element
	j end_draw_car
	
	keep_car:
	addi $t8, $zero, 4		# s8 stores value 4
	div $t6, $t8			# t6 / t8
	mflo $s3			# s3 = t6 / 4, how long does it overlap
	
	#draw the non exceed half part 
	add $a2, $zero, $s3			#a2 = s3, sets a2 to the length of the non exceeded part
	addi $sp, $sp, -4			#Move stack pointer to empty location
	sw $ra, 0($sp)				#push ra onto the stack
	add $t1, $zero, $zero
	jal paint_rect				#draw rect
	lw $ra, 0($sp)				#pop ra off the stack
	addi $sp, $sp, 4			#Move stack pointer to top element
	
	#draw the exceed half part 
	la $a2, car_width
	lw $a2, 0($a2)				#a2 stores the original width
	sub $a2, $a2, $s3			#a2 = a2 - s3, the length of the exceeded part
	subi $s0, $a0, 128			#Move t0 to the top-left of the row, s0 = a0 - 128
	lw $t0, displayAddress # $t0 stores the base address for display
	add $t0, $t0, $s0			#set t0 to s0
	addi $sp, $sp, -4			#Move stack pointer to empty location
	sw $ra, 0($sp)				#push ra onto the stack
	add $t1, $zero, $zero
	jal paint_rect				#Draw a rectangle: (s0 is the top-left coordinate. a1 is the height, a2 is the width, a3 is the color)
	lw $ra, 0($sp)				#pop ra off the stack
	addi $sp, $sp, 4			#Move stack pointer to top element
	j end_draw_car
	
not_exceed_car:	
	addi $sp, $sp, -4			#Move stack pointer to empty location
	sw $ra, 0($sp)				#push ra onto the stack
	add $t1, $zero, $zero
	jal paint_rect				#Draw a rectangle
	lw $ra, 0($sp)				#pop ra off the stack
	addi $sp, $sp, 4			#Move stack pointer to top element

end_draw_car:
jr $ra




draw_car_row:
lw $t0, displayAddress # $t0 stores the base address for display

#first row
addi $a0, $zero, 2688			#set the max of this row, a0 to 2688
la $s1, car1				#s1 stores the address of car1
addi $sp, $sp, -4			#Move stack pointer to empty location
sw $ra, 0($sp)				#push ra onto the stack
add $t1, $zero, $zero
jal draw_car				#draw car
lw $ra, 0($sp)				#pop ra off the stack
addi $sp, $sp, 4			#Move stack pointer to top element

la $s1, car2				#s1 stores the address of car2
addi $sp, $sp, -4			#Move stack pointer to empty location
sw $ra, 0($sp)				#push ra onto the stack
add $t1, $zero, $zero
jal draw_car				#draw car
lw $ra, 0($sp)				#pop ra off the stack
addi $sp, $sp, 4			#Move stack pointer to top element

#second row
addi $a0, $zero, 3072			#set the max of this row, a0 to 3072
la $s1, car3				#s1 stores the address of car3
addi $sp, $sp, -4			#Move stack pointer to empty location
sw $ra, 0($sp)				#push ra onto the stack
add $t1, $zero, $zero
jal draw_car				#draw car
lw $ra, 0($sp)				#pop ra off the stack
addi $sp, $sp, 4			#Move stack pointer to top element

la $s1, car4				#s1 stores the address of car4
addi $sp, $sp, -4			#Move stack pointer to empty location
sw $ra, 0($sp)				#push ra onto the stack
add $t1, $zero, $zero
jal draw_car				#draw car
lw $ra, 0($sp)				#pop ra off the stack
addi $sp, $sp, 4			#Move stack pointer to top element

#third row
addi $a0, $zero, 3456			#set the max of this row, a0 to 3456
la $s1, car5				#s1 stores the address of car5
addi $sp, $sp, -4			#Move stack pointer to empty location
sw $ra, 0($sp)				#push ra onto the stack
add $t1, $zero, $zero
jal draw_car				#draw car
lw $ra, 0($sp)				#pop ra off the stack
addi $sp, $sp, 4			#Move stack pointer to top element

la $s1, car6				#s1 stores the address of car6
addi $sp, $sp, -4			#Move stack pointer to empty location
sw $ra, 0($sp)				#push ra onto the stack
add $t1, $zero, $zero
jal draw_car				#draw car
lw $ra, 0($sp)				#pop ra off the stack
addi $sp, $sp, 4			#Move stack pointer to top element

end_draw_car_row:
jr $ra





#Update the position of each cars according to the speed of the rows 
update_car_row:
la $t1, car_row1_speed
lw $t1, 0($t1)				#t1 stores the car_row1_speed
la $t2, car_row2_speed
lw $t2, 0($t2)				#t2 stores the car_row2_speed
la $t3, car_row3_speed
lw $t3, 0($t3)				#t3 stores the car_row3_speed

la $t4, car1				#t4 stores address for car1
lw $s1, 0($t4)				#t1 stores car1
la $t5, car2				#t5 stores address for car2
lw $s2, 0($t5)				#t2 stores car2
add $s1, $s1, $t1 			#increment car1 by car_row1_speed
sw $s1, 0($t4)				#store new location of car1 back to car1
add $s2, $s2, $t1 			#increment car2 by car_row1_speed
sw $s2, 0($t5)				#store new location of car2 back to car2

la $t4, car3
lw $s3, 0($t4)	
la $t5, car4
lw $s4, 0($t5)
add $s3, $s3, $t2 			#increment car3 by car_row2_speed
sw $s3, 0($t4)				#store new location of car3 back to car3
add $s4, $s4, $t2			#increment car4 by car_row2_speed
sw $s4, 0($t5)				#store new location of car4 back to car4

la $t4, car5
lw $s5, 0($t4)	
la $t5, car6
lw $s6, 0($t5)
add $s5, $s5, $t3			#increment car5 by car_row3_speed
sw $s5, 0($t4)				#store new location of car5 back to car5
add $s6, $s6, $t3			#increment car6 by car_row3_speed
sw $s6, 0($t5)				#store new location of car6 back to car6
end_update_car_row:
jr $ra


#-------------------------------------------------Log Row----------------------------------------------------------------
#Draw a log: (s1 is the address of the log, a0 is the min of the row)
draw_log:
lw $t0, displayAddress # $t0 stores the base address for display

la $a3, logColor			#a3 has the address of the logColor color
lw $a3, 0($a3)		
		
lw $s0, 0($s1)				#s0 stores the top-left coordinate of this log

add $t0, $t0, $s0			#Move t0 to s0

la $a1, log_height
lw $a1, 0($a1)				#a1 stores the height
la $a2, log_width
lw $a2, 0($a2)				#a2 stores the width

	
exceed_log_row:
addi $t9, $zero, 1			#Using t9 to store value 1
sub $t6, $a0, $s0  			#t6 = a0 - s0, how far away from the left bound
slt $t7, $t6, $zero			#t7 stores whether t6 = a0 - s0 < 0, 
					#t7==1: a0 - s0 < 0, t7==0: a0 - s0 >= 0

#s0 exceed if: a0 - s0 > 0. t7 == 0 and t6 != 0	
beq $t6, $zero not_exceed_log		#if t6 == 0, jump to not_exceed
beq $t7, $t9, not_exceed_log		#if t7 == 1, jump to not_exceed
	sll $s6, $a2, 2			#s6 = a2 * 4 = 32
	slt $t4, $t6, $s6		#t4 stores whether t6 = a0 - s0 < 32, 
					#s0 rare if: a0 - s0 > 32, t4 == 0 and t6 != 32 
	beq $t6, $s6, check0_log	#if t6 == 32, jump to check0
	beq $t4, $t9, check0_log	#if t4 = a0 - s0 >= 0, jump to check0
	addi $s0, $a0, 128		#s0 = a0 + 128
	sub $s0, $s0, $t6		
	add $s0, $s0, $s6		#s0 = s0 - (t6 - 32) = s0 - ((a0 - s0) - 32)
	sw $s0, 0($s1)			#store new location of the car		
	lw $t0, displayAddress # $t0 stores the base address for display
	add $t0, $t0, $s0			#set t0 to s0
	addi $sp, $sp, -4			#Move stack pointer to empty location
	sw $ra, 0($sp)				#push ra onto the stack
	add $t1, $zero, $zero
	jal paint_rect				#Draw a rectangle: (s0 is the top-left coordinate. a1 is the height, a2 is the width, a3 is the color)
	lw $ra, 0($sp)				#pop ra off the stack
	addi $sp, $sp, 4			#Move stack pointer to top element
	j end_draw_log
	
	check0_log:
	bne $t6, $s6, keep_log			#if t6 != 32, jump to keep 
	addi $s0, $a0, 128			#s0 = a0 + 128
	sub $s0, $s0, $s6			#s0 = s0 - 32
	sw $s0, 0($s1)				#store new location of the car		
	lw $t0, displayAddress # $t0 stores the base address for display
	add $t0, $t0, $s0			#set t0 to s0
	addi $sp, $sp, -4			#Move stack pointer to empty location
	sw $ra, 0($sp)				#push ra onto the stack
	add $t1, $zero, $zero
	jal paint_rect				#Draw a rectangle: (s0 is the top-left coordinate. a1 is the height, a2 is the width, a3 is the color)
	lw $ra, 0($sp)				#pop ra off the stack
	addi $sp, $sp, 4			#Move stack pointer to top element
	j end_draw_log
	
	keep_log:	
	addi $t8, $zero, 4			# s8 stores value 4
	div $t6, $t8				# t6 / t8
	mflo $s3				# s3 = t6 / 4, how long does it exceed
	
	#draw the non exceed half part 
	la $a2, log_width
	lw $a2, 0($a2)				#a2 stores the width
	sub $a2, $a2, $s3			#a2 = a2 - s3, sets a2 to the length of the non exceeded part
	
	addi $sp, $sp, -4			#Move stack pointer to empty location
	lw $t0, displayAddress # $t0 stores the base address for display
	add $t0, $t0, $a0			#set t0 to a0
	sw $ra, 0($sp)				#push ra onto the stack
	add $t1, $zero, $zero
	jal paint_rect				#draw rect
	lw $ra, 0($sp)				#pop ra off the stack
	addi $sp, $sp, 4			#Move stack pointer to top element
	
	#draw the exceed half part 
	add $a2, $zero, $s3			#a2 = s3, the length of the exceeded part			
	addi $s0, $a0, 128			
	sll $t7, $a2, 2				#t7 = a2 * 4
	sub $s0, $s0, $t7			#Move t0 to the top-left of the exceed part, s0 = a0 + 128 - a2 * 4
	lw $t0, displayAddress # $t0 stores the base address for display
	add $t0, $t0, $s0			#set t0 to s0
	addi $sp, $sp, -4			#Move stack pointer to empty location
	sw $ra, 0($sp)				#push ra onto the stack
	add $t1, $zero, $zero
	jal paint_rect				#Draw a rectangle: (s0 is the top-left coordinate. a1 is the height, a2 is the width, a3 is the color)
	lw $ra, 0($sp)				#pop ra off the stack
	addi $sp, $sp, 4			#Move stack pointer to top element
	j end_draw_car
	
not_exceed_log:	
	addi $sp, $sp, -4			#Move stack pointer to empty location
	sw $ra, 0($sp)				#push ra onto the stack
	add $t1, $zero, $zero
	jal paint_rect				#Draw a rectangle
	lw $ra, 0($sp)				#pop ra off the stack
	addi $sp, $sp, 4			#Move stack pointer to top element

end_draw_log:
jr $ra




draw_log_row:
lw $t0, displayAddress # $t0 stores the base address for display

#first row
addi $a0, $zero, 1024			#set the min of this row, a0 to 1024
la $s1, log1				#s1 stores the address of car1
addi $sp, $sp, -4			#Move stack pointer to empty location
sw $ra, 0($sp)				#push ra onto the stack
add $t1, $zero, $zero
jal draw_log				#draw log
lw $ra, 0($sp)				#pop ra off the stack
addi $sp, $sp, 4			#Move stack pointer to top element

la $s1, log2				#s1 stores the address of car2
addi $sp, $sp, -4			#Move stack pointer to empty location
sw $ra, 0($sp)				#push ra onto the stack
add $t1, $zero, $zero
jal draw_log				#draw log
lw $ra, 0($sp)				#pop ra off the stack
addi $sp, $sp, 4			#Move stack pointer to top element

#second row
addi $a0, $zero, 1408			#set the min of this row, a0 to 1408
la $s1, log3				#s1 stores the address of car3
addi $sp, $sp, -4			#Move stack pointer to empty location
sw $ra, 0($sp)				#push ra onto the stack
add $t1, $zero, $zero
jal draw_log				#draw log
lw $ra, 0($sp)				#pop ra off the stack
addi $sp, $sp, 4			#Move stack pointer to top element

la $s1, log4				#s1 stores the address of car4
addi $sp, $sp, -4			#Move stack pointer to empty location
sw $ra, 0($sp)				#push ra onto the stack
add $t1, $zero, $zero
jal draw_log				#draw log
lw $ra, 0($sp)				#pop ra off the stack
addi $sp, $sp, 4			#Move stack pointer to top element

#third row
addi $a0, $zero, 1792			#set the min of this row, a0 to 1792
la $s1, log5				#s1 stores the address of car5
addi $sp, $sp, -4			#Move stack pointer to empty location
sw $ra, 0($sp)				#push ra onto the stack
add $t1, $zero, $zero
jal draw_log				#draw log
lw $ra, 0($sp)				#pop ra off the stack
addi $sp, $sp, 4			#Move stack pointer to top element

la $s1, log6				#s1 stores the address of car6
addi $sp, $sp, -4			#Move stack pointer to empty location
sw $ra, 0($sp)				#push ra onto the stack
add $t1, $zero, $zero
jal draw_log				#draw log
lw $ra, 0($sp)				#pop ra off the stack
addi $sp, $sp, 4			#Move stack pointer to top element

end_draw_log_row:
jr $ra





#Update the position of each logs according to the speed of the rows 
update_log_row:
la $t1, log_row1_speed
lw $t1, 0($t1)				#t1 stores the log_row1_speed
la $t2, log_row2_speed
lw $t2, 0($t2)				#t2 stores the log_row2_speed
la $t3, log_row3_speed
lw $t3, 0($t3)				#t3 stores the log_row3_speed

la $t4, log1				#t4 stores address for log1
lw $s1, 0($t4)				#t1 stores log1
la $t5, log2				#t5 stores address for log2
lw $s2, 0($t5)				#t2 stores log2
sub $s1, $s1, $t1 			#decrease car1 by log_row1_speed
sw $s1, 0($t4)				#store new location of log1 back to log1
sub $s2, $s2, $t1 			#decrease car2 by log_row1_speed
sw $s2, 0($t5)				#store new location of log2 back to log2

la $t4, log3
lw $s3, 0($t4)	
la $t5, log4
lw $s4, 0($t5)
sub $s3, $s3, $t2 			#decrease log3 by log_row2_speed
sw $s3, 0($t4)				#store new location of log3 back to log3
sub $s4, $s4, $t2			#decrease log4 by log_row2_speed
sw $s4, 0($t5)				#store new location of log4 back to log4

la $t4, log5
lw $s5, 0($t4)	
la $t5, log6
lw $s6, 0($t5)
sub $s5, $s5, $t3			#decrease log5 by log_row3_speed
sw $s5, 0($t4)				#store new location of log5 back to log5
sub $s6, $s6, $t3			#decrease log6 by log_row3_speed
sw $s6, 0($t5)				#store new location of log6 back to log6
end_update_log_row:
jr $ra



#-------------------------------------------------------Helper Functions--------------------------------------------------------
#Draw a row: (t1 is the index, a2 is the length of the row, a3 is the color)
paint_row:
beq $t1, $a2, end_paint_row 

sw $a3, 0($t0) # paint the first (top-left) unit.
addi $t0, $t0, 4
addi $t1, $t1, 1

j paint_row
end_paint_row:
jr $ra



#Draw a rectangle: (t1 is the inner index, t2 is the outer index, a1 is the height, a2 is the width, a3 is the color)
paint_rect:
beq $t2, $a1, end_paint_rect

addi $sp, $sp, -4			#Move stack pointer to empty location
sw $ra, 0($sp)				#push ra onto the stack
add $t1, $zero, $zero
jal paint_row				#draw a line with width of a5
lw $ra, 0($sp)				#pop ra off the stack
addi $sp, $sp, 4			#Move stack pointer to top element

sll $t9, $a2, 2				#Calculate how much do we need to shift back: width * 4
sub $t0, $t0, $t9			#shift back to the left boundary
addi $t0, $t0, 128			#move to next line

addi $t2, $t2, 1
j paint_rect
end_paint_rect:
add $t1, $zero, $zero
add $t2, $zero, $zero
jr $ra

# respawn animation
respawn_animation:
#white
lw $t0 displayAddress
addi $a1, $zero, 32
addi $a2, $zero, 1
li $a3, 0xFFFFFF
addi $sp, $sp, -4			#Move stack pointer to empty location
sw $ra, 0($sp)				#push ra onto the stack
add $t1, $zero, $zero
add $t2, $zero, $zero
jal paint_rect				#draw a rect
lw $ra, 0($sp)				#pop ra off the stack
addi $sp, $sp, 4			#Move stack pointer to top element
#red
lw $t0 displayAddress
addi $t0, $t0, 4
addi $a1, $zero, 32
addi $a2, $zero, 5
li $a3, 0xFE0000
addi $sp, $sp, -4			#Move stack pointer to empty location
sw $ra, 0($sp)				#push ra onto the stack
add $t1, $zero, $zero
add $t2, $zero, $zero
jal paint_rect				#draw a rect
lw $ra, 0($sp)				#pop ra off the stack
addi $sp, $sp, 4			#Move stack pointer to top element
#orange
lw $t0 displayAddress
addi $t0, $t0, 24
addi $a1, $zero, 32
addi $a2, $zero, 5
li $a3, 0xFD9604
addi $sp, $sp, -4			#Move stack pointer to empty location
sw $ra, 0($sp)				#push ra onto the stack
add $t1, $zero, $zero
add $t2, $zero, $zero
jal paint_rect				#draw a rect
lw $ra, 0($sp)				#pop ra off the stack
addi $sp, $sp, 4			#Move stack pointer to top element
#yellow
lw $t0 displayAddress
addi $t0, $t0, 44
addi $a1, $zero, 32
addi $a2, $zero, 5
li $a3, 0xFFFF01
addi $sp, $sp, -4			#Move stack pointer to empty location
sw $ra, 0($sp)				#push ra onto the stack
add $t1, $zero, $zero
add $t2, $zero, $zero
jal paint_rect				#draw a rect
lw $ra, 0($sp)				#pop ra off the stack
addi $sp, $sp, 4			#Move stack pointer to top element
#green
lw $t0 displayAddress
addi $t0, $t0, 64
addi $a1, $zero, 32
addi $a2, $zero, 5
li $a3, 0x33FF00
addi $sp, $sp, -4			#Move stack pointer to empty location
sw $ra, 0($sp)				#push ra onto the stack
add $t1, $zero, $zero
add $t2, $zero, $zero
jal paint_rect				#draw a rect
lw $ra, 0($sp)				#pop ra off the stack
addi $sp, $sp, 4			#Move stack pointer to top element
#blue
lw $t0 displayAddress
addi $t0, $t0, 84
addi $a1, $zero, 32
addi $a2, $zero, 5
li $a3, 0x0198FF
addi $sp, $sp, -4			#Move stack pointer to empty location
sw $ra, 0($sp)				#push ra onto the stack
add $t1, $zero, $zero
add $t2, $zero, $zero
jal paint_rect				#draw a rect
lw $ra, 0($sp)				#pop ra off the stack
addi $sp, $sp, 4			#Move stack pointer to top element
#purple
lw $t0 displayAddress
addi $t0, $t0, 104
addi $a1, $zero, 32
addi $a2, $zero, 5
li $a3, 0x6734FF
addi $sp, $sp, -4			#Move stack pointer to empty location
sw $ra, 0($sp)				#push ra onto the stack
add $t1, $zero, $zero
add $t2, $zero, $zero
jal paint_rect				#draw a rect
lw $ra, 0($sp)				#pop ra off the stack
addi $sp, $sp, 4			#Move stack pointer to top element
#white
lw $t0 displayAddress
addi $t0, $t0, 124
addi $a1, $zero, 32
addi $a2, $zero, 1
li $a3, 0xffffff
addi $sp, $sp, -4			#Move stack pointer to empty location
sw $ra, 0($sp)				#push ra onto the stack
add $t1, $zero, $zero
add $t2, $zero, $zero
jal paint_rect				#draw a rect
lw $ra, 0($sp)				#pop ra off the stack
addi $sp, $sp, 4			#Move stack pointer to top element

li $v0, 32
li $a0, 300
syscall
end_respawn_animation:
jr $ra

#sound_effect for moving
move_sound:
li $v0, 31
la $a0, pitch
lw $a0 0($a0)				# a0 = pitch 
la $a1, duration1			
lw $a1, 0($a1)				# a1 = duration1
la $a2, instrument2			
lw $a2, 0($a2)				# a1 = instrument 
la $a3, volume			
lw $a3, 0($a3)				# a1 = volume
syscall
end_move_sound:
jr $ra


#sound_effect for collision
collide_sound:
li $v0, 31
la $a0, pitch
lw $a0 0($a0)				# a0 = pitch 
la $a1, duration2			
lw $a1, 0($a1)				# a1 = duration2
la $a2, instrument1 			
lw $a2, 0($a2)				# a1 = instrument 
la $a3, volume			
lw $a3, 0($a3)				# a1 = volume
syscall
end_collide_sound:
jr $ra




Exit:
li $v0, 10 # terminate the program gracefully
syscall

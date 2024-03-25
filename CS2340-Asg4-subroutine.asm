#	Description: This file aids the CS2340-Asg4.asm file by providing subroutines for the file. This file has 3 different 
#	main programs which are: makeAlphanumeric, convertCase, and isPalindrome. makeAlphanumeric is a series of functions which
#	make the user's input into a string with no non-alphanumeric characters. convertCase converts the string into the same
#	string but with all uppercase characters. isPalindrome recursively checks whether the input is a palindrome or not and
#	returns false (disregarding the recursive calls) if the characters at the end of the string do not match at any point.


	.eqv	LowerSubUpper	32	#ascii difference between upper and lowercase letters
	.eqv	charLimit		201	#max number of characters is 200 + '\n' character

.data
nonAlphaNumeric: 	.asciiz "!\"#$%&'()*+,-./:;<=>?@ [\\]^_`{|}~"
outputString:   	.space charLimit  


.text
.globl	makeAlphanumeric
.globl	palindrome
.globl 	clearOutput

#	sets up the function for removing alphanumeric characters by loading the addresses of the user input and the 
#	string which will hold the output string
makeAlphanumeric:
	la 	$t0, userInput   		#load address of input string
   	la 	$t5, outputString  		#load address of output string
	j 	removeNonAlphaNumeric	#jumps to remove nonalphanumeric once $t0 and $t5 are set up

#	sets up register values for clearOutputLoop in order to clear the garbage values in outputString from the previous
#	user input
clearOutput:
	la 	$t5, outputString		#loads $t5 with outputString
	li 	$t3, 0			#loads starting loop index into $t3

#	loops through every index of outputString and sets it to $zero (default value) in order to clear out all the garbage
#	values from the previous palindrome 
clearOutputLoop:
	sb 	$zero, 0($t5)		#stores $zero into the current index of $t5
	addi 	$t5, $t5, 1		#goes to the next index of outputString in $t5
	addi 	$t3, $t3, 1		#adds 1 to the current loop counter in $t3
	blt 	$t3,charLimit,clearOutputLoop	#if $t3 is less than total # of characters in input, loop back to clearOutputloop
	jr 	$ra			#goes back to original program to get userInput once again

#	loads the current character to be checked and resets the index used to iterate through the string of non alphanumeric
#	characters, will go to exit the function if the character is the null terminator
removeNonAlphaNumeric:
    	lb 	$t2, 0($t0)         	#load byte from input string
   	beqz 	$t2, exitAlphaNumeric 	#if null terminator go to exit
   	li 	$t3, 0               	#reset index for non-alphanumeric characters

#	loads the current character from the non-alphanumeric string and copies the current user input character if the character
#	is not anywhere in the non alphanumeric string otherwise goes to the next character if the character is found in the 
#	non alphanumeric string
checkNonAlphaNumeric:
    	lb 	$t4, nonAlphaNumeric($t3)   	#load byte from nonAlphaNumeric string
    	beqz 	$t4, copyCharacter       	#if end of nonAlphaNumeric string, copy character
    	bne 	$t2, $t4, incrementIndex  	#if not equal, check next non-alphanumeric character
    	j 	nextCharacter               	#if equal, skip copying and get next input character

#	increments the index for the non alphanumeric string and then goes to check the current alphanumeric character with the
#	current userinput character
incrementIndex:
    	addi 	$t3, $t3, 1              	#increment index to check next non-alphanumeric character
    	j 	checkNonAlphaNumeric        	#jump to next character in checkNonAlphaNumeric

#	stores the current character in userInput into outputString and then goes to the next index value in outputString to
#	load any future characters
copyCharacter:
    	sb 	$t2, 0($t5)         	#copy alphanumeric character to output string
    	addi 	$t5, $t5, 1       		#increment output string pointer

#	goes to the next character in userInput and then jumps back to check if that character is a non alpha numeric character
nextCharacter:
    	addi 	$t0, $t0, 1       		#move to next character in input string
    	j 	removeNonAlphaNumeric 	#jump to continue removing non-alphanumeric characters

#	resets $t0 to zero for the convertCase function and goes to convert case once done
exitAlphaNumeric:
	add 	$t0, $zero, $zero		#resets $t0 to zero

#	loads the current character from the outPut string, if the character is a lowercase letter, subtracts the ascii
#	difference between uppercase and lowercase to convert to uppercase and then stores the character into outputstring
convertCase:
    	lb 	$t1, outputString($t0)	#loads the character from outputString
   	beq 	$t1, '\0', exitCase		#if at the last character (null terminator), exit the function
   	blt 	$t1, 'a', getNextChar	#if character is not between a and z, get next character
   	bgt 	$t1, 'z', getNextChar	#if character is not between a and z, get next character
   	sub 	$t1, $t1, LowerSubUpper	#subtract the ascii difference between lower and capital to convert case
   	sb 	$t1, outputString($t0)	#update the character in the string to change the case

#	gets the next character index by adding 1 to $t0 and jumps back to the convertCase loop
getNextChar: 
   	addi 	$t0, $t0, 1		#add 1 to $t0 to get the next index in the character array
   	j 	convertCase		#jump back to convert case for next character

#	exits the current file by returning to the address in $ra, which leads to the main file
exitCase:
	jr 	$ra			#jump back to the original program to continue palindromes

#	sets up all the registers for the palindrome recursive function. Also goes to another function to get the input's length
#	and accounts for inputs of length 0 and 1 which are not palindrome and palindrome respectively. After calling the function
#	gets the return address and goes back to the main file
palindrome:
	subi	$sp, $sp, 8		#stores 2 words of space onto the stack 
	sw	$ra, 0($sp)		#stores the return address of the main file into stack
	la	$a0, outputString		#loads outputString into $a0
    	move 	$t0, $a0       		#save address of the string into $t0
    	li 	$t1, 0           		#set index to the beginning of the string in $t1
    	jal 	getStrLength       		#get the length of the string by going to getStrLength and returning afterwards
	beq 	$a1, 0, printFalse		#prints not palindrome if length is 0 
	beq 	$a1, 1, printTrue		#prints palindrome if length is 1
	subi 	$a1, $a1, 1		#subtract 1 from length to avoid setting $t2 to null terminator at end of input
    	add 	$t2, $t0, $a1   		#move to the end of the string
	jal	isPalindrome		#jumps to isPalindrome to recursively calculate if input is palindrome
	lw	$ra, 0($sp)		#after returning, loads address into $ra to return to main file
	addi	$sp, $sp, 8		#updates stack pointer by removing 2 words
	jr	$ra			#jumps back to the main file to print palindrome

#	recursively goes through the characters of the input and checks whether the string is a palindrome. Starts from the 
#	outside characters and then goes towards the middle of the string to check each set of characters. Prints false at
#	any moment if the characters are not matching
isPalindrome:
	bge	$a0, $t2, returnCalls	#if the start counter > end counter then go to returnCalls for recursive call
	subi	$sp, $sp, 8		#loads 2 words of space onto the stack
	sw	$ra, 0($sp)		#stores the address of $ra into $sp
	sw	$a0, 4($sp)		#stores $a0 into the second word of $sp
    	lb 	$t3, 0($a0)      		#load character from start position
    	lb 	$t4, 0($t2)      		#load character from end position
    	bne 	$t3, $t4, printFalse 	#if characters don't match go to print false
    	addi 	$a0, $a0, 1    		#move to the next character
    	subi 	$t2, $t2, 1    		#move to the previous character
    	jal 	isPalindrome		#recursive call to check next characters (characters match = true)

#	loads the previous address from the previous recursive call into $ra and $sp in order to make palindrome function
#	recursvie
returnCalls:
	lw	$ra, 0($sp)		#loads the previous call's address into $ra
	lw	$a0, 4($sp)		#loads the previous call's current string into $a0
	addi	$sp, $sp, 8		#points $sp to next stack item
	jr	$ra			#jumps back to ispalindrome for recursive call

#	sets up register values in order to get the count for the outputString and then goes to getStrLengthCount after 
#	setting everything up
getStrLength:
    	li 	$t6, 0           		#initialize current index to 0 in $t6
	li 	$t5, 0			#initialize length to 0 in %t5

#	loops through every value of outputString to find the length of the string and exits the loop once the null terminator
#	has been loaded into $t1
getStrLengthCount:
	add 	$t6, $t0, $t5		#gets the next index for the array
    	lb 	$t1, 0($t6)      		#load byte from index found in $t6 and store in $t1
    	beqz 	$t1, endStrLength  		#if null terminator go to endStrLength
    	addi 	$t5, $t5, 1    		#add 1 to the length counter found in $t5
    	j 	getStrLengthCount		#jumps back to the top of this label

#	sets up $t5 to account for an extra count added due to null terminator and then sets $a1 as the length of the 
#	palindrome and then returns back to the address from which the getStrLength was called from
endStrLength:
	subi 	$t5, $t5, 1		#subtracts 1 to account for null terminator
	add 	$a1, $zero, $t5		#sets $a1 to the length of the input entered
    	jr 	$ra              		#returns back to address found in $ra
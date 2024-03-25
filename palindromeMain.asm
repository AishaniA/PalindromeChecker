#	Written by Aishani Arunganesh, starting March 11, 2024.
#	Description: This program allows for users to enter a string of characters to test whether the entered input is a 
#	palindrome or not. The program ignores punctuation, case, and any character which is not a number or a letter. In this 
#	file, the program takes in the user's input and then makes calls to the subroutine file in order to remove special 
#	characters, convert to uppercase, and run the palindrome identifying functions. The subroutine file then returns and prints
#	out whether the input is a palindrome

	.include	"SysCalls.asm"
	.eqv	charLimit	201	#max number of characters is 200 + '\n' character

.data
.globl	userInput
userInput:	.space 	charLimit
promptInput: 	.asciiz 	"Enter a string of characters: \n"
Palindrome:	.asciiz	"Palindrome \n"
notPalindrome:	.asciiz	"Not Palindrome \n"

.text
.globl	printFalse
.globl	printTrue
.globl	main

#	main prompting label which prompts for a string and then calls a syscall to read a string from the user before
#	continuing to the rest of the program
main: 
	la	$a0, promptInput		#loads $a0 with the text found in the promptInput label
	li 	$v0, SysPrintString		#loads $v0 with the printing string syscall
	syscall			
	li	$a1, charLimit		#puts the 200 char limit into $a1 to limit user input
	la	$a0, userInput		#holds the userInput into $a0 after the syscall
	li	$v0, SysReadString		#loads $v0 with the string reading syscall
	syscall

# 	this label checks whether the entered input is a newline charcter or contains more than 1 character in the entered string
# 	it branches to the exit label if the entered input is "\n", otherwise it continues the rest of the program
checkEmpty:
	lb	$t0, 0($a0)		#loads the first character of input into $t0
	beq	$t0, '\n', exitPrgm		#goes to exitPrgm if the user enters a empty string

# 	goes to the subroutine calls to convert the user input into a string with no non-alphanumeric characters and converts each 
# 	letter into the same letter in uppercase. These two function calls make use of the subroutine file and come back to the 
#	current file when done
convertValues:
	jal	makeAlphanumeric		#goes to makeAlphanumeric found in the subroutine files
	jal	palindrome
#	la 	$a0, outputString		#loads the filtered string into $a0 for the palindrome algorithm


# 	prints out true once the entire palindrome function has been completed and then goes to clearOutput to clear 
#	outputString and then back to main for another user input
printTrue:
	la	$a0, Palindrome		#loads the isPalindrome text into $a0
	li	$v0, SysPrintString		#loads the string printing syscall into $v0
	syscall
	jal	clearOutput		#jumps to subroutine file to clear outputString and returns once done
	j 	main			#jumps back to main for another user input


# 	prints out false at any time in the palindrome checked (assuming the end of the function has not been reached) and then goes
# 	to clearOutput to clear outputString and then back to main for another user input
printFalse:
	la	$a0, notPalindrome		#loads the notPalindrome text into $a0
	li	$v0, SysPrintString		#loads the string printing syscall into $v0
	syscall
	jal	clearOutput		#jumps to subroutine file to clear outputString and returns once done
	j 	main			#jumps to main to obtain another user input

# 	if the user enters a newline character, the program exits using the syscall
exitPrgm:
	li 	$v0, SysExit		#loads the exit syscall into $v0
	syscall
	
		

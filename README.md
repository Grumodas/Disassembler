A brief guide regarding how to use this Disasembler

<h1>
What is a Disassembler?
</h1>	
		Computers operate in bits (also known as machine code). We, humans, prefer to use more understandable code thus we use programming languages which are then converted to machine code for machines to understand (i.e. ‘assembling’). Disassembler is a program which does the opposite – as an argument it takes 	in already compiled machine code and tried to reverse-engineer as much code to the original programming language as possible.


<h1>
Technical Information
</h1>
	This disassembler was written using TASM (Turbo Assembler) compiler for Intel 8086 architecture microprocessor (commonly known as x86). A program “Dosbox” was 	used for the emulation of such processor.	
	“Dosbox” can be downloaded from https://w	ww.dosbox.com/	
	TASM.zip package is included together with the software files.	
	Disassembler as an argument accepts a COM file, which can be created using most hex editors or can be obtained from an existing assembly program using tlink. 	This process is explained later in the documentation.


<h1>
Compilation and Running
</h1>
	It is not expected from an average used to possess information which could be used to run Disassembler, thus we provide the following instructions about how to compile and run the program.
	NOTE: There are many other ways to run x86 architecture code, but this one was used by the author and therefore is given as an example here.
	1.	Github.com/Grumodas, download the software files i.e. “dis.asm” and “example.com”. If using Windows, download “run.bat” as well.
	2.	Install Dosbox and unzip TASM.zip. Make sure the software files and the unzipped TASM files are in the same directory.
	3.	Open Dosbox and mount the directory where you downloaded and extracted files are using these commands:
	>> Mount c „C:\Users\Username\Desktop\TASM“
	>> C:\
	Here C:\Users\Username\Desktop\TASM is given as an example path to your files.
	4.	Once the directory is successfully mounted, it becomes possible to run the disassembler using “run.bat“. On windows, simply write to the consile:
	>> run dis.asm

	However, if the user is not running Windows, they will need to compile and execute the code themselves:

	>> tasm dis.asm
	>> tlink dis.obj
	>> dis
	
<h1>	
Obtaining the .COM File
</h1>
	It is quite likely that the user will want to disassemble a program of their own. Hence, if the user already has a finished assembly program, it’s possible to convert that program into a .COM file and pass it to the Disassembler to attempt and rebuild it.
	Say there is a file foo.asm which the user has themselves written. To obtain the .COM file (that is, the file with the machine code of that particular assembly program), the user needs to proceed in the following way:
	1.	Apply steps 1-3 from the “Compilation and Running” section above.
	2.	Type to the command line:
	>> tasm foo.asm 
	>> tlink /t foo.obj
	The obtained .COM file can now be passed to the Disassembler for disassembling.
	
	NOTE: a .com file can be obtained only if the program is "compressed" into one single segment. Thus, in foo.asm, all of the information which does not belong 	to the code segment (particularly data segment) should be moved to the end of the code segment. See example.asm as an example.

<h1>
Output File
</h1>
	The output file has 3 columns:
	1. The offset counting from the beginning of the code segment
	2. The bytes which are being disassembed
	3. The disasembled instruction (if instruction was not recognised, that will be visible in this column as well).
	
<h1>
Example
</h1>
	An example assembly program, .COM file of that program and a result file of disassembling the .COM file are provided by the author (example.asm, example.com and example.txt respectively). 

	example.asm is an assembly program which accepts symbol sequences seperated by spaces and prints the lengths of those symbol lines.

	example.com file was obtained using the steps described in the "Obtaining the .COM File" section above.
	NOTE: a .com file can be obtained only if the program is "compressed" into one single segment. Thus, in example.asm, all of the information which does not belong to the code segment (particularly data segment) was moved to the end of the code segment.

	after running example.com through disassembler, a example.txt file was obtained, which can be compared to the original example.asm file (ideally, they would look identical).

<h1>
Choosing an Input and Output Files
</h1>
	To choose an input file, open “dis.asm” and find a variable called “inputFile”. Change the variable’s value in accordance to the file which contains the machine code which is to be disassembled.
	IMPORTANT: the name of the input file should ALWAYS be followed by a “0”:
		inputFile db "input.com", 0
	A similar procedure should be followed to choose an output file. In “dis.asm” find a variable named outputFile and change the value of this variable accordingly.
	IMPORTANT: the name of the input file should ALWAYS be followed by a “0”:
		outputFile db "output.com", 0

<h1>
Recognisable Commands
</h1>
	There is a vast number of assembly commands, thus it’s exponentially difficult to recognise them all. The current version of this Disassembler recognises ALL existing types of the following commands:

	-	Mov
	-	Push
	-	Pop
	-	Add
	-	Inc
	-	Sub
	-	Dec
	-	Cmp
	-	Mul
	-	Div
	-	Call
	-	Ret
	-	Jmp
	-	Conditional Jmp(s)
	-	Loop
	-	Int



We hope you will find our disassembler simple to use and bug free.

Created by Kęstutis Grumodas (github.com/Grumodas)

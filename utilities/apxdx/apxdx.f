C$$$  MAIN PROGRAM DOCUMENTATION BLOCK
C
C MAIN PROGRAM:  APXDX
C   PRGMMR: J. ATOR          ORG: NP12        DATE: 2009-??-??
C
C ABSTRACT:  THIS PROGRAM GENERATES BUFR MESSAGES CORRESPONDING TO A
C   GIVEN USER DX TABLE AND APPENDS THEM TO A GIVEN BUFR DATA FILE.
C   IT IS PRIMARILY INTENDED FOR USE WHEN IMPLEMENTING BUFR DX TABLE
C   CHANGES TO ONE OR MORE BUFR TANKFILES IN THE NCEP OBSERVATIONAL
C   DATABASE.
C
C PROGRAM HISTORY LOG:
C 2009-07-01  J. ATOR     ORIGINAL VERSION FOR IMPLEMENTATION
C
C USAGE:
C   ./APXDX  CBFFIL  CDXTBL
C
C   INPUT FILES:
C       CBFFIL = BUFR DATA FILE
C       CDXTBL = BUFR DX TABLE
C
C   OUTPUT FILES:
C       CBFFIL = BUFR DATA FILE WITH DX TABLE MESSAGES APPENDED
C
C     FORTRAN LOGICAL UNIT 05 IS USED TO READ IN CBFFIL AND CDXTBL,
C     AS FULL SYSTEM PATH/FILENAMES UP TO 120 CHARACTERS EACH.
C
C     FORTRAN LOGICAL UNITS 10, 11 AND 12 ARE ALSO USED AS SCRATCH
C     WORKSPACE BY THIS PROGRAM.
C
C   SUBPROGRAMS CALLED:
C     LIBRARY:
C       BUFRLIB  - CLOSBF   OPENBF   WRDXTB
C
C   EXIT STATES:
C     COND =   0 - SUCCESSFUL RUN
C
C ATTRIBUTES:
C   LANGUAGE: FORTRAN 77
C
C$$$
	PROGRAM APXDX

	CHARACTER*120	cdxtbl, cbffil

C*----------------------------------------------------------------------

	lunin = 10
	lundx = 11
	lunot = 12

C*	Read the input arguments.

	READ ( 5, '(A)' ) cbffil
	READ ( 5, '(A)' ) cdxtbl

C*	Read the user DX table into the BUFRLIB.

	OPEN ( UNIT = lunin, FILE = '/dev/null' )
	OPEN ( UNIT = lundx, FILE = cdxtbl )

	CALL OPENBF ( lunin, 'IN', lundx )

C*	Open the BUFR file for append.

	OPEN ( UNIT = lunot, FILE = cbffil, FORM = 'UNFORMATTED' )

	CALL OPENBF ( lunot, 'APX', lunot )

C*	Generate DX messages from the table and append them to the
C*	BUFR file.

	CALL WRDXTB ( lunin, lunot )

C*	Close the BUFR file.

	CALL CLOSBF ( lunot )

	STOP
	END

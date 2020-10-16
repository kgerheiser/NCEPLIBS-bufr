C> @file
C> @author ATOR @date 2005-11-29
	
C> THIS SUBROUTINE PADS A BUFR MESSAGE WITH ZEROED-OUT BYTES
C>  FROM THE END OF THE MESSAGE UP TO THE NEXT 8-BYTE BOUNDARY.
C>
C> PROGRAM HISTORY LOG:
C> 2005-11-29  J. ATOR    -- ORIGINAL AUTHOR
C>
C> USAGE:    CALL PADMSG (MESG, LMESG, NPBYT )
C>   INPUT ARGUMENT LIST:
C>     MESG     - INTEGER: *-WORD PACKED BINARY ARRAY CONTAINING BUFR
C>                MESSAGE 
C>     LMESG    - INTEGER: DIMENSIONED SIZE (IN INTEGER WORDS) OF MESG;
C>                USED BY THE SUBROUTINE TO ENSURE THAT IT DOES NOT
C>                OVERFLOW THE MESG ARRAY
C>
C>   OUTPUT ARGUMENT LIST:
C>     MESG     - INTEGER: *-WORD PACKED BINARY ARRAY CONTAINING BUFR
C>                MESSAGE WITH NPBYT ZEROED-OUT BYTES APPENDED TO THE END
C>     NPBYT    - INTEGER: NUMBER OF ZEROED-OUT BYTES APPENDED TO MESG
C>
C> REMARKS:
C>    THIS ROUTINE CALLS:        BORT     IUPBS01  NMWRD    PKB
C>    THIS ROUTINE IS CALLED BY: MSGWRT
C>                               Also called by application programs.
C>
	SUBROUTINE PADMSG(MESG,LMESG,NPBYT)



	COMMON /HRDWRD/ NBYTW,NBITW,IORD(8)

	DIMENSION MESG(*)

C-----------------------------------------------------------------------
C-----------------------------------------------------------------------

C	Make sure that the array is big enough to hold the additional
C	byte padding that will be appended to the end of the message.

	NMW = NMWRD(MESG)
	IF(NMW.GT.LMESG) GOTO 900

C	Pad from the end of the message up to the next 8-byte boundary.

	NMB = IUPBS01(MESG,'LENM')
	IBIT = NMB*8
	NPBYT = ( NMW * NBYTW ) - NMB
	DO I = 1, NPBYT
	    CALL PKB(0,8,MESG,IBIT)
	ENDDO

	RETURN
900     CALL BORT('BUFRLIB: PADMSG - CANNOT ADD PADDING TO MESSAGE '//
     .    'ARRAY; TRY A LARGER DIMENSION FOR THIS ARRAY')
	END

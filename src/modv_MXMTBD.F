C> @file
C> @brief Declare and initialize MXMTBD variable.

C> This module declares and initializes the MXMTBD variable.
C>
C> <p>For dynamic allocation builds, this variable is initialized
C> to a default value which can be overridden by a subsequent call
C> to function isetprm() within the application program.
C> For static allocation builds, this variable is set as a
C> parameter at compile time and cannot be changed within the
C> application program.
C>
C> @author J. Ator
C> @date 2014-12-10

	MODULE MODV_MXMTBD

C>        @var mxmtbd
C>        Maximum number of entries in a master BUFR Table D.

#ifdef STATIC_ALLOCATION
	  INTEGER, PARAMETER :: MXMTBD = 1000
#else
	  INTEGER :: MXMTBD = 800
#endif

	END MODULE

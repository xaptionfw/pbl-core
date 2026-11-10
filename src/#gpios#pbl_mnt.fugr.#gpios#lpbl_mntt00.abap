*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /GPIOS/PBL_ACT..................................*
DATA:  BEGIN OF STATUS_/GPIOS/PBL_ACT                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/GPIOS/PBL_ACT                .
CONTROLS: TCTRL_/GPIOS/PBL_ACT
            TYPE TABLEVIEW USING SCREEN '0003'.
*...processing: /GPIOS/PBL_CB...................................*
DATA:  BEGIN OF STATUS_/GPIOS/PBL_CB                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/GPIOS/PBL_CB                 .
CONTROLS: TCTRL_/GPIOS/PBL_CB
            TYPE TABLEVIEW USING SCREEN '0004'.
*...processing: /GPIOS/PBL_COM..................................*
DATA:  BEGIN OF STATUS_/GPIOS/PBL_COM                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/GPIOS/PBL_COM                .
CONTROLS: TCTRL_/GPIOS/PBL_COM
            TYPE TABLEVIEW USING SCREEN '0005'.
*...processing: /GPIOS/PBL_RT...................................*
DATA:  BEGIN OF STATUS_/GPIOS/PBL_RT                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/GPIOS/PBL_RT                 .
CONTROLS: TCTRL_/GPIOS/PBL_RT
            TYPE TABLEVIEW USING SCREEN '0006'.
*...processing: /GPIOS/PBL_SET..................................*
DATA:  BEGIN OF STATUS_/GPIOS/PBL_SET                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/GPIOS/PBL_SET                .
*...processing: /GPIOS/PBL_VCT..................................*
TABLES: /GPIOS/PBL_VCT, */GPIOS/PBL_VCT. "view work areas
CONTROLS: TCTRL_/GPIOS/PBL_VCT
TYPE TABLEVIEW USING SCREEN '0007'.
DATA: BEGIN OF STATUS_/GPIOS/PBL_VCT. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/GPIOS/PBL_VCT.
* Table for entries selected to show on screen
DATA: BEGIN OF /GPIOS/PBL_VCT_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /GPIOS/PBL_VCT.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /GPIOS/PBL_VCT_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /GPIOS/PBL_VCT_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /GPIOS/PBL_VCT.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /GPIOS/PBL_VCT_TOTAL.

*.........table declarations:.................................*
TABLES: */GPIOS/PBL_ACT                .
TABLES: */GPIOS/PBL_CB                 .
TABLES: */GPIOS/PBL_COM                .
TABLES: */GPIOS/PBL_RT                 .
TABLES: */GPIOS/PBL_SET                .
TABLES: /GPIOS/PBL_ACT                 .
TABLES: /GPIOS/PBL_CB                  .
TABLES: /GPIOS/PBL_COM                 .
TABLES: /GPIOS/PBL_CTL                 .
TABLES: /GPIOS/PBL_CTT                 .
TABLES: /GPIOS/PBL_RT                  .
TABLES: /GPIOS/PBL_SET                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .

interface /GPIOS/IF_PBL_TYPES
  public .


  types:
    ty_t_controller TYPE STANDARD TABLE OF REF TO /gpios/if_pbl_controller WITH NON-UNIQUE KEY table_line .
  types:
    ty_t_cb_types TYPE STANDARD TABLE OF /gpios/pbl_cb_type WITH NON-UNIQUE DEFAULT KEY .
  types:
    ty_t_io_units TYPE STANDARD TABLE OF REF TO /gpios/if_pbl_io_unit WITH NON-UNIQUE KEY table_line .
  types:
    ty_t_pbl_com TYPE HASHED TABLE OF /gpios/pbl_com WITH UNIQUE KEY data_type comm_action .
  types:
    ty_t_pbl_cb TYPE STANDARD TABLE OF /gpios/pbl_cb WITH NON-UNIQUE KEY cb_type .
  types:
    ty_t_pbl_rt TYPE HASHED TABLE OF /gpios/pbl_rt WITH UNIQUE KEY rt_type .
  types:
    ty_t_pbl_act TYPE HASHED TABLE OF /gpios/pbl_act WITH UNIQUE KEY action_type .
  types:
    ty_t_dev TYPE STANDARD TABLE OF /gpios/pbl_dev WITH NON-UNIQUE KEY id .
  types:
    ty_t_usr TYPE STANDARD TABLE OF /gpios/pbl_usr WITH NON-UNIQUE KEY id .
  types:
    ty_t_bh TYPE STANDARD TABLE OF /gpios/pbl_bh WITH NON-UNIQUE KEY baugr .
  types:
    ty_t_bi TYPE STANDARD TABLE OF /gpios/pbl_bi WITH NON-UNIQUE KEY baugr idnrk .
  types:
    ty_t_bom_items TYPE STANDARD TABLE OF REF TO /gpios/if_pbl_bom_item WITH NON-UNIQUE DEFAULT KEY .
  types:
    ty_t_cpn TYPE STANDARD TABLE OF /gpios/pbl_cpn WITH NON-UNIQUE KEY idnrk .
  types:
    BEGIN OF ty_cpn_key,
            mandt TYPE mandt,
            sernr TYPE /gpios/pbl_sernr,
            idnrk TYPE idnrk,
         END OF   ty_cpn_key .
  types:
    ty_t_cpn_key TYPE STANDARD TABLE OF ty_cpn_key WITH NON-UNIQUE KEY idnrk .
  types:
    BEGIN OF ty_bh_key,
            mandt TYPE mandt,
            sernr TYPE /gpios/pbl_sernr,
            baugr TYPE baugr,
         END OF   ty_bh_key .
  types:
    ty_t_bh_key TYPE STANDARD TABLE OF ty_bh_key WITH NON-UNIQUE KEY baugr .
  types:
    BEGIN OF ty_bi_key,
            mandt TYPE mandt,
            sernr TYPE /gpios/pbl_sernr,
            baugr TYPE baugr,
            idnrk TYPE idnrk,
         END OF   ty_bi_key .
  types:
    ty_t_bi_key TYPE STANDARD TABLE OF ty_bi_key WITH NON-UNIQUE KEY baugr idnrk .
  types:
    ty_t_io_unit_data TYPE STANDARD TABLE OF /gpios/pbl_cb_io WITH NON-UNIQUE KEY io_uid .
  types:
    ty_r_data_types TYPE RANGE OF /gpios/pbl_data_type .
endinterface.

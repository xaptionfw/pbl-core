*"* use this source file for any macro definitions you need
*"* in the implementation part of the class

    DEFINE set_remote_data_types.
      ls_r_data_type = 'IEQ'.
      ls_r_data_type-low = &1.
      append ls_r_data_type to /gpios/if_pbl_ctrl_manager~gt_r_remote_data_types.
*      ls_r_data_type-sign = 'E'.
*      append ls_r_data_type to /gpios/if_pbl_ctrl_manager~gt_r_local_data_types.
    END-OF-DEFINITION.

*    DEFINE set_local_data_types.
*      ls_r_data_type = 'IEQ'.
*      ls_r_data_type-low = &1.
*      append ls_r_data_type to /gpios/if_pbl_ctrl_manager~gt_r_local_data_types.
*    END-OF-DEFINITION.
*
*    DEFINE disable_data_type.
*      ls_r_data_type = 'EEQ'.
*      ls_r_data_type-low = &1.
*      append ls_r_data_type to /gpios/if_pbl_ctrl_manager~gt_r_allowed_data_Types.
*    END-OF-DEFINITION.

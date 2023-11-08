*&---------------------------------------------------------------------*
*& Include          ZTC_STUDENT_INFO_PBO
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  go_main->status_0100( ).
  go_main->screen_process( ).
ENDMODULE.

MODULE tabcntrl_active_tab_set OUTPUT.
  tabcntrl-activetab = g_tabcntrl-pressed_tab.
  CASE g_tabcntrl-pressed_tab.
    WHEN c_tabcntrl-tab1.
      g_tabcntrl-subscreen = '0101'.
    WHEN c_tabcntrl-tab2.
      g_tabcntrl-subscreen = '0102'.
    WHEN c_tabcntrl-tab3.
      g_tabcntrl-subscreen = '0103'.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.

MODULE status_0101 OUTPUT.
  IF gs_screenstat-edit EQ abap_true.
    LOOP AT tbcntrl-cols INTO gv_tbc_cols WHERE screen-name EQ 'GS_SCORE-SCORE'.
      gv_tbc_cols-screen-input = '1'.
      MODIFY tbcntrl-cols FROM gv_tbc_cols INDEX sy-tabix.

    ENDLOOP.
  ENDIF.
ENDMODULE.

MODULE status_0102 OUTPUT.
* SET PF-STATUS 'xxxxxxxx'.
* SET TITLEBAR 'xxx'.
ENDMODULE.

MODULE status_0103 OUTPUT.
* SET PF-STATUS 'xxxxxxxx'.
* SET TITLEBAR 'xxx'.
  go_main->text_editor( ).
  go_main->screen_process( ).
ENDMODULE.

MODULE status_0200 OUTPUT.
* SET PF-STATUS 'xxxxxxxx'.
* SET TITLEBAR 'xxx'.
ENDMODULE.

MODULE status_0300 OUTPUT.
  SET PF-STATUS 'SC300'.
* SET TITLEBAR 'xxx'.
  go_main->screen_process( ).
  go_main->add_department_alv( ).
ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TC 'TBCNTRL'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE tbcntrl_change_tc_attr OUTPUT.
  DESCRIBE TABLE gt_score LINES tbcntrl-lines.
ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TC 'TBCNTRL'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: GET LINES OF TABLECONTROL
MODULE tbcntrl_get_lines OUTPUT.
  g_tbcntrl_lines = sy-loopc.
ENDMODULE.

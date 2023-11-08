*&---------------------------------------------------------------------*
*& Include          ZTC_STUDENT_INFO_PAI
*&---------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  IF ( sy-ucomm EQ '&DISP' OR gs_screenstat-display EQ abap_true
                         OR gs_screenstat-edit EQ abap_true )
                         AND ( sy-ucomm NE '&CLR' ).
    IF zka_14_s_student_info-student_id IS INITIAL.
      MESSAGE i005.
    ELSE.

      IF gs_selected_student IS NOT INITIAL.
        IF gt_values IS INITIAL.
          go_main->dropdown_department( ).
          go_main->display_pic( ).
          gv_studdoc = 1. " For Display Student Document Button
        ENDIF.
      ELSE.
        MESSAGE i002 WITH zka_14_s_student_info-student_id.
        go_main->refresh_screen( ).
      ENDIF.
    ENDIF.

    IF zka_14_t_section-department_name IS NOT INITIAL.
      go_main->display_ders( ).
      go_main->get_lecture_score( ).
    ENDIF.
  ENDIF.

  IF sy-ucomm EQ '&REC' AND
         ( gs_selected_student IS INITIAL  ).

    IF zka_14_s_student_info-student_id IS INITIAL.
      MESSAGE i008.
      RETURN.
    ELSE.
      DATA : lv_return TYPE c.

      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          titlebar              = 'Confirmation '
          text_question         = 'Do you want to record Student?'
          text_button_1         = 'Yes'(001)
          icon_button_1         = '@01@'
          text_button_2         = 'No'(002)
          icon_button_2         = '@02@'
          default_button        = '1'
          display_cancel_button = abap_false
        IMPORTING
          answer                = lv_return
        EXCEPTIONS
          text_not_found        = 1
          OTHERS                = 2.

      IF lv_return EQ 1.
        go_main->mail_valid( ).
        IF gv_mail_flag NE 1. " If E-Mail is Valid
          gv_freeze = 1.
          go_main->add_student_image( ).
          go_main->add_new_student( ).
          gv_studdoc = 1.
        ENDIF.
      ELSE.
        MESSAGE s010 DISPLAY LIKE 'E'.
      ENDIF.
    ENDIF.
  ENDIF.

  CASE sy-ucomm.
    WHEN '&ADD'.
      CALL SCREEN '300' STARTING AT 50 5 ENDING AT 100 20.
    WHEN '&CLR'.
      go_main->refresh_screen( ).
    WHEN '&MDF'.
      go_main->modify_student_data( ).
    WHEN '&UPL'.
      CALL FUNCTION 'F4_FILENAME'
        EXPORTING
          program_name  = syst-cprog
          dynpro_number = syst-dynnr
        IMPORTING
          file_name     = gv_imgupl.
    WHEN '&DOC'.
      IF zka_14_t_section-department_name IS NOT INITIAL.
        go_main->display_student_document( ).
      ELSE.
        MESSAGE i006.
      ENDIF.
  ENDCASE.

ENDMODULE.

MODULE ext INPUT.
  LEAVE TO SCREEN 0.
ENDMODULE.

MODULE tabcntrl_active_tab_get INPUT.
  ok_code = sy-ucomm.
  CASE ok_code.
    WHEN c_tabcntrl-tab1.
      g_tabcntrl-pressed_tab = c_tabcntrl-tab1.
    WHEN c_tabcntrl-tab2.
      g_tabcntrl-pressed_tab = c_tabcntrl-tab2.
    WHEN c_tabcntrl-tab3.
      g_tabcntrl-pressed_tab = c_tabcntrl-tab3.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.

MODULE user_command_0101 INPUT.

ENDMODULE.

MODULE user_command_0102 INPUT.

ENDMODULE.

MODULE user_command_0103 INPUT.

ENDMODULE.

MODULE user_command_0200 INPUT.

ENDMODULE.

MODULE create_dropdown INPUT.

ENDMODULE.

*&SPWIZARD: INPUT MODULE FOR TC 'TBCNTRL'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: PROCESS USER COMMAND
MODULE tbcntrl_user_command INPUT.
  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'TBCNTRL'
                              'GT_SCORE'
                              ' '
                     CHANGING ok_code.
  sy-ucomm = ok_code.
ENDMODULE.

MODULE get_dropdown_value INPUT.
  DATA: lt_dynpfields LIKE dynpread OCCURS 1 WITH HEADER LINE.

  IF zka_14_t_section-department_name IS NOT INITIAL.
    lt_dynpfields-fieldname = 'ZKA_14_T_SECTION-DEPARTMENT_NAME' .
    APPEND lt_dynpfields.


    CALL FUNCTION 'DYNP_VALUES_READ'
      EXPORTING
        dyname     = sy-cprog "Current program
        dynumb     = sy-dynnr "Current screen
      TABLES
        dynpfields = lt_dynpfields "Relevant screen fields
      EXCEPTIONS
        OTHERS     = 0.


  ENDIF.
ENDMODULE.

MODULE get_student_data INPUT.
  go_main->get_student( ).
ENDMODULE.

MODULE get_deptlec_data INPUT.
  go_main->display_ders( ).
  go_main->get_lecture_score( ).
ENDMODULE.

MODULE tbcntrl_modify_data INPUT.

  IF gs_score-score GE 85.
    gs_score-succes = 'A'.
  ELSEIF gs_score-score BETWEEN 70 AND 84.
    gs_score-succes = 'B'.
  ELSEIF gs_score-score BETWEEN 60 AND 69.
    gs_score-succes = 'C'.
  ELSEIF gs_score-score BETWEEN 50 AND 59.
    gs_score-succes = 'D'.
  ELSE.
    gs_score-succes = 'E'.
  ENDIF.

  MODIFY gt_score FROM gs_score INDEX tbcntrl-current_line.
ENDMODULE.

MODULE score_comparison INPUT.
  MODIFY zka_14_t_score FROM TABLE gt_score.
  COMMIT WORK AND WAIT.
ENDMODULE.

*MODULE image_upload INPUT.
*  CALL FUNCTION 'KD_GET_FILENAME_ON_F4'
*    EXPORTING
*      static    = 'X'
*    CHANGING
*      file_name = gv_imgupl.
*ENDMODULE.

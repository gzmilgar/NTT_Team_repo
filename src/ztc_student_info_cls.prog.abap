*&---------------------------------------------------------------------*
*& Include          ZTC_STUDENT_INFO_CLS
*&---------------------------------------------------------------------*
CLASS lcl_main DEFINITION.
  PUBLIC SECTION.
    METHODS: handle_button_click FOR EVENT toolbar OF cl_gui_alv_grid
      IMPORTING
        e_object,

      handle_user_command FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING
          e_ucomm,

      handle_data_changed
        FOR EVENT data_changed OF cl_gui_alv_grid
        IMPORTING
          er_data_changed,

      handle_onf4
        FOR EVENT onf4 OF cl_gui_alv_grid
        IMPORTING
          e_fieldname
          e_fieldvalue
          es_row_no
          er_event_data.


    METHODS:
      where_the_story_begins,
      status_0100,
      screen_process,
      text_editor,
      mail_valid,
      display_pic,
      read_text_editor,
      check_department_data,
      add_department_alv,
      get_student,
      dropdown_department,
      get_ders_data,
      display_ders,
      get_lecture_score,
      add_new_line,
      add_student_department,
      add_new_student,
      get_full_student_info,
      sent_record_mail,
      refresh_screen,
      get_dept_view,
      display_student_document,
      screen_freezer,
      studdoc_visibility,
      init,
      screen_statu,
      modify_student_data,
      add_student_image.


  PRIVATE SECTION.
    CONSTANTS: BEGIN OF c_screen,
                 s100 TYPE sy-dynnr VALUE '0100',
                 s300 TYPE sy-dynnr VALUE '0300',
               END OF c_screen.

    METHODS :
      dept_data_for_f4,
      excluding_toolbar,
      set_fcat IMPORTING is_struc       TYPE any
               RETURNING VALUE(rt_fcat) TYPE lvc_t_fcat,
      set_layo RETURNING VALUE(rs_layo) TYPE lvc_s_layo.



ENDCLASS.

CLASS lcl_main IMPLEMENTATION.

  METHOD handle_button_click.
    DATA : ls_toolbar TYPE stb_button.
    CLEAR ls_toolbar.
    ls_toolbar-function = '&NEW'.
    ls_toolbar-text = 'Insert Row'.
    ls_toolbar-icon = '@17@'.
    ls_toolbar-quickinfo = 'Insert Row'.
    IF gv_tcode EQ 1.
      ls_toolbar-disabled = abap_true.
    ENDIF.
    APPEND ls_toolbar TO e_object->mt_toolbar.

    CLEAR ls_toolbar.
    ls_toolbar-function = '&SAV3'.
    ls_toolbar-text = 'Save'.
    ls_toolbar-icon = '@2L@'.
    ls_toolbar-quickinfo = 'Save'.
    IF gv_tcode EQ 1.
      ls_toolbar-disabled = abap_true.
    ENDIF.
    APPEND ls_toolbar TO e_object->mt_toolbar.

    IF gv_tcode EQ 1.
      CLEAR ls_toolbar.
      ls_toolbar-function = '&DOC'.
      ls_toolbar-text = 'Document'.
      ls_toolbar-icon = '@AR@'.
      ls_toolbar-quickinfo = 'Display Student Document'.
      APPEND ls_toolbar TO e_object->mt_toolbar.
    ENDIF.
  ENDMETHOD.

  METHOD handle_user_command.
    CASE e_ucomm.
      WHEN '&NEW'.
        add_new_line( ).
      WHEN '&SAV3'.
        add_student_department( ).
      WHEN '&DOC'.
        display_student_document( ).
    ENDCASE.
  ENDMETHOD.

  METHOD handle_data_changed.
    LOOP AT er_data_changed->mt_good_cells ASSIGNING FIELD-SYMBOL(<fs_datachanged>).
      READ TABLE gt_department ASSIGNING FIELD-SYMBOL(<fs_dept>) INDEX <fs_datachanged>-row_id.
      IF sy-subrc EQ 0.
        CASE <fs_datachanged>-fieldname.
          WHEN 'FACULTY_ID'.
            <fs_dept>-faculty_id = <fs_datachanged>-value.
          WHEN 'DEPARTMENT_ID'.
            <fs_dept>-department_id = <fs_datachanged>-value.
          WHEN 'DEPARTMENT_NAME'.
            <fs_dept>-department_name = <fs_datachanged>-value.
        ENDCASE.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD handle_onf4.
    DATA : lt_return_tab  TYPE TABLE OF ddshretval,
           lt_selfac_dept TYPE TABLE OF zka_14_t_section.

    LOOP AT gt_department_list ASSIGNING FIELD-SYMBOL(<fs_dept_list>) WHERE faculty_id EQ gv_faculty_id.
      lt_selfac_dept = VALUE #( BASE lt_selfac_dept ( <fs_dept_list> ) ).
    ENDLOOP.

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        retfield        = 'DEPARTMENT_ID'
        window_title    = 'Department F4 Help'
        value_org       = 'S'
      TABLES
        value_tab       = lt_selfac_dept
        return_tab      = lt_return_tab
      EXCEPTIONS
        parameter_error = 1
        no_values_found = 2
        OTHERS          = 3.

    READ TABLE lt_return_tab INTO DATA(ls_return_tab) WITH KEY fieldname = 'F0003'.
    IF sy-subrc IS INITIAL.
      READ TABLE gt_department ASSIGNING FIELD-SYMBOL(<fs_alv>) INDEX es_row_no-row_id.
      IF <fs_alv> IS ASSIGNED.
        LOOP AT lt_selfac_dept INTO DATA(ls_selfac_dept) WHERE department_id = ls_return_tab-fieldval.
          DATA(lv_dept_name) = ls_selfac_dept-department_name.
        ENDLOOP.
        <fs_alv>-department_name = lv_dept_name.
        <fs_alv>-department_id = ls_return_tab-fieldval.
      ENDIF.
    ENDIF.
    er_event_data->m_event_handled = abap_true.
    go_add_grid->refresh_table_display( i_soft_refresh = abap_true ).

  ENDMETHOD.

  METHOD where_the_story_begins.
    CALL SCREEN c_screen-s100.
  ENDMETHOD.

  METHOD status_0100.
    SET: PF-STATUS 'STATUS_0100',
         TITLEBAR 'TITLE_0100'.
  ENDMETHOD.

  METHOD screen_process.
    IF gs_screenstat-display IS NOT INITIAL.
      gv_tcode = 1.

      LOOP AT SCREEN.
        CASE screen-name.
          WHEN 'NRECORD' OR 'MODIFY' OR 'STUD_DOC' OR 'STD_IMG' OR 'IMAGE_UPLOAD'.
            screen-invisible = 1.
            MODIFY SCREEN.
          WHEN 'GV_BUTTON'.
            gv_button = 'Dept. Info'.
            MODIFY SCREEN.
        ENDCASE.
        CASE screen-group1.
          WHEN 'PR1'.
            screen-input = 0.
            MODIFY SCREEN.
        ENDCASE.
      ENDLOOP.
    ELSEIF gs_screenstat-create IS NOT INITIAL.
      LOOP AT SCREEN.
        CASE screen-name.
          WHEN 'STUD_DOC' OR 'DISPLAY' OR 'MODIFY'.
            screen-active = 0.
            MODIFY SCREEN.
        ENDCASE.
      ENDLOOP.
    ELSEIF gs_screenstat-edit IS NOT INITIAL.
      LOOP AT SCREEN.
        CASE screen-name.
          WHEN 'STUD_DOC' OR 'NRECORD'.
            screen-active = 0.
            MODIFY SCREEN.
        ENDCASE.
      ENDLOOP.
    ENDIF.

    IF gv_freeze EQ 1.
      go_main->screen_freezer( ).
    ENDIF.

    IF gv_studdoc EQ 1.
      go_main->studdoc_visibility( ).
    ENDIF.


  ENDMETHOD.

  METHOD text_editor.
    IF go_editor_cont IS NOT BOUND.
      go_editor_cont = NEW #( container_name = 'CC_ADDR' ).
      go_editor = NEW #( parent                     = go_editor_cont
                         wordwrap_to_linebreak_mode = cl_gui_textedit=>true ).
      IF gv_tcode EQ 1.
        go_editor->set_readonly_mode(
          EXPORTING
            readonly_mode          = 1
          EXCEPTIONS
            error_cntl_call_method = 1
            invalid_parameter      = 2
            OTHERS                 = 3 ).
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD mail_valid.
    CLEAR gv_mail_flag.
    gv_pattern = '^([0-9a-zA-Z]([-.w]*[0-9a-zA-Z])*@([0-9a-zA-Z][-w]*[0-9a-zA-Z].)+[azA-Z]{2,9})'.
    TRY.
        gr_matcher = cl_abap_matcher=>create( pattern     = gv_pattern
                                              ignore_case = abap_false
                                              text        = zka_14_s_student_info-email ).
        IF gr_matcher->match( ) IS INITIAL.
          MESSAGE i013.
          gv_mail_flag = 1.
        ENDIF.
      CATCH cx_sy_regex.
      CATCH cx_sy_matcher.
    ENDTRY.
  ENDMETHOD.

  METHOD display_pic.
    CLEAR : gv_imgnam.

    DATA(lv_studentid) = CONV char8( zka_14_s_student_info-student_id ).
    gv_imgnam = lv_studentid.

    gs_stxbmaps-tdobject = 'GRAPHICS'.
    gs_stxbmaps-tdname = gv_imgnam.
    gs_stxbmaps-tdid = 'BMAP'.
    gs_stxbmaps-tdbtype = 'BCOL'.

    CALL FUNCTION 'SAPSCRIPT_GET_GRAPHIC_BDS'
      EXPORTING
        i_object       = gs_stxbmaps-tdobject
        i_name         = gv_imgnam "g_stxbmaps-tdname
        i_id           = gs_stxbmaps-tdid
        i_btype        = gs_stxbmaps-tdbtype
      IMPORTING
        e_bytecount    = gv_bytecnt
      TABLES
        content        = gt_content
      EXCEPTIONS
        not_found      = 1
        bds_get_failed = 2
        bds_no_content = 3
        OTHERS         = 4.

    CALL FUNCTION 'SAPSCRIPT_CONVERT_BITMAP'
      EXPORTING
        old_format               = 'BDS'
        new_format               = 'BMP'
        bitmap_file_bytecount_in = gv_bytecnt
      IMPORTING
        bitmap_file_bytecount    = gv_graphic_size
      TABLES
        bds_bitmap_file          = gt_content
        bitmap_file              = gt_graphic_table
      EXCEPTIONS
        OTHERS                   = 1.

    CALL FUNCTION 'DP_CREATE_URL'
      EXPORTING
        type     = 'image'
        subtype  = cndp_sap_tab_unknown
        size     = gv_graphic_size
        lifetime = cndp_lifetime_transaction
      TABLES
        data     = gt_graphic_table
      CHANGING
        url      = gv_graphic_url
      EXCEPTIONS
        OTHERS   = 4.

    IF go_pic_container IS NOT BOUND.
      CREATE OBJECT go_pic_container
        EXPORTING
          container_name = 'CC_PIC'.

      CREATE OBJECT go_picture EXPORTING parent = go_pic_container.

    ENDIF.

    CALL METHOD go_picture->load_picture_from_url
      EXPORTING
        url    = gv_graphic_url
      IMPORTING
        result = gv_result.

    CALL METHOD go_picture->set_display_mode
      EXPORTING
        display_mode = cl_gui_picture=>display_mode_fit.

  ENDMETHOD.

  METHOD read_text_editor.
    TRY.
        go_editor->get_text_as_r3table(
          IMPORTING
            table                  = gt_address_text
          EXCEPTIONS
            error_dp               = 1
            error_cntl_call_method = 2
            error_dp_create        = 3
            potential_data_loss    = 4
            OTHERS                 = 5 ).
        READ TABLE gt_address_text INTO gs_stud_address INDEX 1.
      CATCH cx_sy_ref_is_initial INTO DATA(lo_exp).
        MESSAGE i014.
    ENDTRY.
  ENDMETHOD.

  METHOD excluding_toolbar.
    IF gv_tcode EQ 1.
      gv_excluding = cl_gui_alv_grid=>mc_fc_loc_delete_row. "VALUE
      APPEND gv_excluding TO gt_excluding.
    ENDIF.
    gv_excluding = cl_gui_alv_grid=>mc_fc_print.
    APPEND gv_excluding TO gt_excluding.
    gv_excluding = cl_gui_alv_grid=>mc_fc_info.
    APPEND gv_excluding TO gt_excluding.
    gv_excluding = cl_gui_alv_grid=>mc_fc_find.
    APPEND gv_excluding TO gt_excluding.
    gv_excluding = cl_gui_alv_grid=>mc_fc_find_more.
    APPEND gv_excluding TO gt_excluding.
    gv_excluding = cl_gui_alv_grid=>mc_fc_filter.
    APPEND gv_excluding TO gt_excluding.
    gv_excluding = cl_gui_alv_grid=>mc_fc_average.
    APPEND gv_excluding TO gt_excluding.
    gv_excluding = cl_gui_alv_grid=>mc_fc_maximum.
    APPEND gv_excluding TO gt_excluding.
    gv_excluding = cl_gui_alv_grid=>mc_fc_minimum.
    APPEND gv_excluding TO gt_excluding.
    gv_excluding = cl_gui_alv_grid=>mc_fc_sum.
    APPEND gv_excluding TO gt_excluding.
    gv_excluding = cl_gui_alv_grid=>mc_fc_views.
    APPEND gv_excluding TO gt_excluding.
    gv_excluding = cl_gui_alv_grid=>mc_fc_loc_insert_row.
    APPEND gv_excluding TO gt_excluding.
    gv_excluding = cl_gui_alv_grid=>mc_fc_loc_undo.
    APPEND gv_excluding TO gt_excluding.
    gv_excluding = cl_gui_alv_grid=>mc_fc_loc_copy_row.
    APPEND gv_excluding TO gt_excluding.
    gv_excluding = cl_gui_alv_grid=>mc_fc_loc_copy.
    APPEND gv_excluding TO gt_excluding.
    gv_excluding = cl_gui_alv_grid=>mc_fc_check.
    APPEND gv_excluding TO gt_excluding.
    gv_excluding = cl_gui_alv_grid=>mc_fc_loc_cut.
    APPEND gv_excluding TO gt_excluding.
    gv_excluding = cl_gui_alv_grid=>mc_fc_loc_append_row.
    APPEND gv_excluding TO gt_excluding.
    gv_excluding = cl_gui_alv_grid=>mc_fc_refresh.
    APPEND gv_excluding TO gt_excluding.
    gv_excluding = cl_gui_alv_grid=>mc_fc_loc_paste_new_row.
    APPEND gv_excluding TO gt_excluding.
    gv_excluding = cl_gui_alv_grid=>mc_fc_loc_paste.
    APPEND gv_excluding TO gt_excluding.
    gv_excluding = cl_gui_alv_grid=>mc_fc_detail.
    APPEND gv_excluding TO gt_excluding.



  ENDMETHOD.
  METHOD check_department_data.
    DATA : ls_student_dept TYPE zka_14_t_stud_dp.
    LOOP AT gt_department INTO DATA(ls_department).
      ls_student_dept-student_id = zka_14_s_student_info-student_id.
      ls_student_dept-faculty_id = ls_department-faculty_id.
      ls_student_dept-department_id = ls_department-department_id.
      INSERT zka_14_t_stud_dp FROM ls_student_dept.
    ENDLOOP.

    MESSAGE s011.
  ENDMETHOD.

  METHOD get_student.

    CLEAR : gs_selected_student.

    SELECT SINGLE * FROM
             zka_14_t_student
             WHERE student_id EQ @zka_14_s_student_info-student_id
             INTO @gs_selected_student.

    IF gs_selected_student IS NOT INITIAL AND gs_screenstat-create IS NOT INITIAL.
      MESSAGE i007 WITH zka_14_s_student_info-student_id.
*      me->refresh_screen( ).
      RETURN.
    ENDIF.

    IF sy-subrc IS INITIAL.

      zka_14_s_student_info-name       = gs_selected_student-name.
      zka_14_s_student_info-surname    = gs_selected_student-surname.
      zka_14_s_student_info-gender     = gs_selected_student-gender.
      zka_14_s_student_info-dob        = gs_selected_student-dob.
      zka_14_s_student_info-faculty    = gs_selected_student-faculty.
      zka_14_s_student_info-study_type = gs_selected_student-study_type.
      zka_14_s_student_info-period     = gs_selected_student-period.
      zka_14_t_section-department_name = gs_value-text.
      zka_14_s_student_info-telf1      = gs_selected_student-telf1.
      zka_14_s_student_info-telf2      = gs_selected_student-telf2.
      zka_14_s_student_info-email      = gs_selected_student-email.
      IF go_editor IS NOT BOUND.
        text_editor( ).
      ENDIF.
      DATA lt_table TYPE TABLE OF char200.
      APPEND gs_selected_student-address TO lt_table.
      go_editor->set_text_as_r3table(
        EXPORTING
          table           = lt_table
        EXCEPTIONS
          error_dp        = 1
          error_dp_create = 2
          OTHERS          = 3 ).

    ENDIF.



  ENDMETHOD.

  METHOD dropdown_department.
    SELECT dp~student_id, dp~department_id, sc~department_name
       FROM zka_14_t_stud_dp AS dp
       INNER JOIN zka_14_t_section AS sc
       ON dp~department_id = sc~department_id AND
          dp~faculty_id    = sc~faculty_id
       WHERE student_id = @zka_14_s_student_info-student_id
       INTO TABLE @DATA(ls_dept).

    REFRESH gt_values.
    LOOP AT ls_dept ASSIGNING FIELD-SYMBOL(<fs_dept>).
      gs_value-key = <fs_dept>-department_id.
      gs_value-text = <fs_dept>-department_name.
      APPEND gs_value TO gt_values.
      CLEAR : gs_value.
    ENDLOOP.

    CALL FUNCTION 'VRM_SET_VALUES'
      EXPORTING
        id              = 'ZKA_14_T_SECTION-DEPARTMENT_NAME'
        values          = gt_values
      EXCEPTIONS
        id_illegal_name = 1
        OTHERS          = 2.

    TRY.
        zka_14_t_section-department_name = gt_values[ 1 ].
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

  ENDMETHOD.

  METHOD add_student_department.
    IF zka_14_s_student_info-student_id IS NOT INITIAL.
      SELECT * FROM
             zka_14_t_stud_dp
             INTO TABLE @DATA(lt_department_check)
             WHERE student_id = @zka_14_s_student_info-student_id.

      DATA(lv_lines) = lines( lt_department_check ).
      READ TABLE lt_department_check ASSIGNING FIELD-SYMBOL(<fs_check>) INDEX 1.
      IF lt_department_check IS INITIAL.
        check_department_data( ).
      ELSEIF lv_lines GE 2.
        MESSAGE i003 WITH zka_14_s_student_info-student_id.
      ELSE.
        READ TABLE gt_department ASSIGNING FIELD-SYMBOL(<fs_dept>) WITH KEY faculty_id = <fs_check>-faculty_id.
        IF <fs_dept> IS ASSIGNED.
          check_department_data( ).
        ELSE.
          MESSAGE i004 WITH zka_14_s_student_info-student_id.
        ENDIF.
      ENDIF.
    ELSE.
      MESSAGE i008.
      RETURN.
    ENDIF.
  ENDMETHOD.

  METHOD add_new_student.
    read_text_editor( ).
    IF gs_stud_address IS NOT INITIAL.
      DATA ls_student TYPE zka_14_t_student.
      ls_student-student_id = zka_14_s_student_info-student_id.
      ls_student-name       = zka_14_s_student_info-name.
      ls_student-surname    = zka_14_s_student_info-surname.
      ls_student-gender     = zka_14_s_student_info-gender.
      ls_student-dob        = zka_14_s_student_info-dob.
      ls_student-faculty    = zka_14_s_student_info-faculty.
      ls_student-study_type = zka_14_s_student_info-study_type.
      ls_student-period     = zka_14_s_student_info-period.
      ls_student-telf1      = zka_14_s_student_info-telf1.
      ls_student-telf2      = zka_14_s_student_info-telf2.
      ls_student-email      = zka_14_s_student_info-email.
      ls_student-address    = gs_stud_address.
      INSERT zka_14_t_student FROM ls_student.
      IF sy-subrc IS INITIAL.
        sent_record_mail( ).
        MESSAGE s009.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD get_full_student_info.
    SELECT st~student_id, name, surname, gender, dob, faculty,
           sc~department_name, study_type, period, telf1, email, address
           FROM zka_14_t_student AS st
           INNER JOIN zka_14_t_stud_dp AS dp
           ON st~student_id EQ dp~student_id
           INNER JOIN zka_14_t_section AS sc
           ON dp~faculty_id EQ sc~faculty_id AND
              dp~department_id EQ sc~department_id
           WHERE st~student_id EQ @zka_14_s_student_info-student_id
           INTO TABLE @gt_full_student_info.
  ENDMETHOD.

  METHOD sent_record_mail.
    go_gbt = NEW #( ).

    gv_content = ' <!DOCTYPE html>                                                                                                                                                                              '
              &&   ' <html lang="en" xmlns="http://www.w3.org/1999/xhtml" xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office">                                              '
              &&   ' <head>                                                                                                                                                                                       '
              &&   '     <meta charset="utf-8">                                                                                                                                                                   '
              &&   '     <meta name="viewport" content="width=device-width">                                                                                                                                      '
              &&   '     <meta http-equiv="X-UA-Compatible" content="IE=edge">                                                                                                                                    '
              &&   '     <meta name="x-apple-disable-message-reformatting">                                                                                                                                       '
              &&   '     <title></title>                                                                                                                                                                          '
              &&   '     <link href="https://fonts.googleapis.com/css?family=Poppins:200,300,400,500,600,700" rel="stylesheet">                                                                                   '
              &&   '     <style>                                                                                                                                                                                  '

              &&   '         html,                                                                                                                                                                                '
              &&   ' body {                                                                                                                                                                                       '
              &&   '     margin: 0 auto !important;                                                                                                                                                               '
              &&   '     padding: 0 !important;                                                                                                                                                                   '
              &&   '     height: 100% !important;                                                                                                                                                                 '
              &&   '     width: 100% !important;                                                                                                                                                                  '
              &&   '     background: #f1f1f1;                                                                                                                                                                     '
              &&   ' }                                                                                                                                                                                            '
              &&   '   {                                                                                                                                                                                          '
              &&   '     -ms-text-size-adjust: 100%;                                                                                                                                                              '
              &&   '     -webkit-text-size-adjust: 100%;                                                                                                                                                          '
              &&   ' }                                                                                                                                                                                            '
              &&   ' div[style*="margin: 16px 0"] {                                                                                                                                                               '
              &&   '     margin: 0 !important;                                                                                                                                                                    '
              &&   ' }                                                                                                                                                                                            '
              &&   ' table,                                                                                                                                                                                       '
              &&   ' td {                                                                                                                                                                                         '
              &&   '     mso-table-lspace: 0pt !important;                                                                                                                                                        '
              &&   '     mso-table-rspace: 0pt !important;                                                                                                                                                        '
              &&   ' }                                                                                                                                                                                            '
              &&   ' table {                                                                                                                                                                                      '
              &&   '     border-spacing: 0 !important;                                                                                                                                                            '
              &&   '     border-collapse: collapse !important;                                                                                                                                                    '
              &&   '     table-layout: fixed !important;                                                                                                                                                          '
              &&   '     margin: 0 auto !important;                                                                                                                                                               '
              &&   ' }                                                                                                                                                                                            '
              &&   ' img {                                                                                                                                                                                        '
              &&   '     -ms-interpolation-mode:bicubic;                                                                                                                                                          '
              &&   ' }                                                                                                                                                                                            '
              &&   ' a {                                                                                                                                                                                          '
              &&   '     text-decoration: none;                                                                                                                                                                   '
              &&   ' }                                                                                                                                                                                            '
              &&   '  [x-apple-data-detectors],  /* iOS */                                                                                                                                                        '
              &&   ' .unstyle-auto-detected-links *,                                                                                                                                                              '
              &&   ' .aBn {                                                                                                                                                                                       '
              &&   '     border-bottom: 0 !important;                                                                                                                                                             '
              &&   '     cursor: default !important;                                                                                                                                                              '
              &&   '     color: inherit !important;                                                                                                                                                               '
              &&   '     text-decoration: none !important;                                                                                                                                                        '
              &&   '     font-size: inherit !important;                                                                                                                                                           '
              &&   '     font-family: inherit !important;                                                                                                                                                         '
              &&   '     font-weight: inherit !important;                                                                                                                                                         '
              &&   '     line-height: inherit !important;                                                                                                                                                         '
              &&   ' }                                                                                                                                                                                            '
              &&   ' .a6S {                                                                                                                                                                                       '
              &&   '     display: none !important;                                                                                                                                                                '
              &&   '     opacity: 0.01 !important;                                                                                                                                                                '
              &&   ' }                                                                                                                                                                                            '
              &&   ' .im {                                                                                                                                                                                        '
              &&   '     color: inherit !important;                                                                                                                                                               '
              &&   ' }                                                                                                                                                                                            '
              &&   ' img.g-img + div {                                                                                                                                                                            '
              &&   '     display: none !important;                                                                                                                                                                '
              &&   ' }                                                                                                                                                                                            '
              &&   ' @media only screen and (min-device-width: 320px) and (max-device-width: 374px) {                                                                                                             '
              &&   '     u ~ div .email-container {                                                                                                                                                               '
              &&   '         min-width: 320px !important;                                                                                                                                                         '
              &&   '     }                                                                                                                                                                                        '
              &&   ' }                                                                                                                                                                                            '
              &&   ' @media only screen and (min-device-width: 375px) and (max-device-width: 413px) {                                                                                                             '
              &&   '     u ~ div .email-container {                                                                                                                                                               '
              &&   '         min-width: 375px !important;                                                                                                                                                         '
              &&   '     }                                                                                                                                                                                        '
              &&   ' }                                                                                                                                                                                            '
              &&   ' @media only screen and (min-device-width: 414px) {                                                                                                                                           '
              &&   '     u ~ div .email-container {                                                                                                                                                               '
              &&   '         min-width: 414px !important;                                                                                                                                                         '
              &&   '     }                                                                                                                                                                                        '
              &&   ' }                                                                                                                                                                                            '
              &&   '                                                                                                                                                                                              '
              &&   '     </style>                                                                                                                                                                                 '
              &&   '                                                                                                                                                                                              '
              &&   '     <style>                                                                                                                                                                                  '
              &&   '         .primary{                                                                                                                                                                            '
              &&   '     background: #17bebb;                                                                                                                                                                     '
              &&   ' }                                                                                                                                                                                            '
              &&   ' .bg_white{                                                                                                                                                                                   '
              &&   '     background: #ffffff;                                                                                                                                                                     '
              &&   ' }                                                                                                                                                                                            '
              &&   ' .bg_light{                                                                                                                                                                                   '
              &&   '     background: #f7fafa;                                                                                                                                                                     '
              &&   ' }                                                                                                                                                                                            '
              &&   ' .bg_black{                                                                                                                                                                                   '
              &&   '     background: #000000;                                                                                                                                                                     '
              &&   ' }                                                                                                                                                                                            '
              &&   ' .bg_dark{                                                                                                                                                                                    '
              &&   '     background: rgba(0,0,0,.8);                                                                                                                                                              '
              &&   ' }                                                                                                                                                                                            '
              &&   ' .email-section{                                                                                                                                                                              '
              &&   '     padding:2.5em;                                                                                                                                                                           '
              &&   ' }                                                                                                                                                                                            '
              &&   '                                                                                                                                                                                              '
              &&   ' .btn{                                                                                                                                                                                        '
              &&   '     padding: 10px 15px;                                                                                                                                                                      '
              &&   '     display: inline-block;                                                                                                                                                                   '
              &&   ' }                                                                                                                                                                                            '
              &&   ' .btn.btn-primary{                                                                                                                                                                            '
              &&   '     border-radius: 25px;                                                                                                                                                                     '
              &&   '     background: #e77d1a;                                                                                                                                                                     '
              &&   '     color: #ffffff;                                                                                                                                                                          '
              &&   ' }                                                                                                                                                                                            '
              &&   ' .btn.btn-white{                                                                                                                                                                              '
              &&   '     border-radius: 5px;                                                                                                                                                                      '
              &&   '     background: #ffffff;                                                                                                                                                                     '
              &&   '     color: #000000;                                                                                                                                                                          '
              &&   ' }                                                                                                                                                                                            '
              &&   ' .btn.btn-white-outline{                                                                                                                                                                      '
              &&   '     border-radius: 25px;                                                                                                                                                                     '
              &&   '     background: transparent;                                                                                                                                                                 '
              &&   '     border: 1px solid #e77d1a;                                                                                                                                                               '
              &&   '     color: #e77d1a;                                                                                                                                                                          '
              &&   ' }                                                                                                                                                                                            '
              &&   ' .btn.btn-black-outline{                                                                                                                                                                      '
              &&   '     border-radius: 0px;                                                                                                                                                                      '
              &&   '     background: transparent;                                                                                                                                                                 '
              &&   '     border: 2px solid #000;                                                                                                                                                                  '
              &&   '     color: #000;                                                                                                                                                                             '
              &&   '     font-weight: 700;                                                                                                                                                                        '
              &&   ' }                                                                                                                                                                                            '
              &&   ' .btn-custom{                                                                                                                                                                                 '
              &&   '     color: rgba(0,0,0,.3);                                                                                                                                                                   '
              &&   '     text-decoration: underline;                                                                                                                                                              '
              &&   ' }                                                                                                                                                                                            '
              &&   ' h1,h2,h3,h4,h5,h6{                                                                                                                                                                           '
              &&   '     font-family: ''Poppins'', sans-serif;                                                                                                                                                    '
              &&   '     color: #000000;                                                                                                                                                                          '
              &&   '     margin-top: 0;                                                                                                                                                                           '
              &&   '     font-weight: 400;                                                                                                                                                                        '
              &&   ' }                                                                                                                                                                                            '
              &&   ' body{                                                                                                                                                                                        '
              &&   '     font-family: ''Poppins'', sans-serif;                                                                                                                                                    '
              &&   '     font-weight: 400;                                                                                                                                                                        '
              &&   '     font-size: 15px;                                                                                                                                                                         '
              &&   '     line-height: 1.8;                                                                                                                                                                        '
              &&   '     color: rgba(0,0,0,.4);                                                                                                                                                                   '
              &&   ' }                                                                                                                                                                                            '
              &&   ' a{                                                                                                                                                                                           '
              &&   '     color: #17bebb;                                                                                                                                                                          '
              &&   ' }                                                                                                                                                                                            '
              &&   ' table{                                                                                                                                                                                       '
              &&   ' }                                                                                                                                                                                            '
              &&   ' .logo h1{                                                                                                                                                                                    '
              &&   '     margin: 0;                                                                                                                                                                               '
              &&   ' }                                                                                                                                                                                            '
              &&   ' .logo h1 a{                                                                                                                                                                                  '
              &&   '     color: #17bebb;                                                                                                                                                                          '
              &&   '     font-size: 24px;                                                                                                                                                                         '
              &&   '     font-weight: 700;                                                                                                                                                                        '
              &&   '     font-family: ''Poppins'', sans-serif;                                                                                                                                                    '
              &&   ' }                                                                                                                                                                                            '
              &&   ' .hero{                                                                                                                                                                                       '
              &&   '     position: relative;                                                                                                                                                                      '
              &&   '     z-index: 0;                                                                                                                                                                              '
              &&   ' }                                                                                                                                                                                            '
              &&   '                                                                                                                                                                                              '
              &&   ' .hero .text{                                                                                                                                                                                 '
              &&   '     color: rgba(0,0,0,.3);                                                                                                                                                                   '
              &&   ' }                                                                                                                                                                                            '
              &&   ' .hero .text h2{                                                                                                                                                                              '
              &&   '     color: #000;                                                                                                                                                                             '
              &&   '     font-size: 34px;                                                                                                                                                                         '
              &&   '     margin-bottom: 0;                                                                                                                                                                        '
              &&   '     font-weight: 200;                                                                                                                                                                        '
              &&   '     line-height: 1.4;                                                                                                                                                                        '
              &&   ' }                                                                                                                                                                                            '
              &&   ' .hero .text h3{                                                                                                                                                                              '
              &&   '     font-size: 24px;                                                                                                                                                                         '
              &&   '     font-weight: 300;                                                                                                                                                                        '
              &&   ' }                                                                                                                                                                                            '
              &&   ' .hero .text h2 span{                                                                                                                                                                         '
              &&   '     font-weight: 600;                                                                                                                                                                        '
              &&   '     color: #000;                                                                                                                                                                             '
              &&   ' }                                                                                                                                                                                            '
              &&   ' .text-author{                                                                                                                                                                                '
              &&   '     bordeR: 1px solid rgba(0,0,0,.05);                                                                                                                                                       '
              &&   '     max-width: 50%;                                                                                                                                                                          '
              &&   '     margin: 0 auto;                                                                                                                                                                          '
              &&   '     padding: 2em;                                                                                                                                                                            '
              &&   ' }                                                                                                                                                                                            '
              &&   ' .text-author img{                                                                                                                                                                            '
              &&   '     border-radius: 50%;                                                                                                                                                                      '
              &&   '     padding-bottom: 20px;                                                                                                                                                                    '
              &&   ' }                                                                                                                                                                                            '
              &&   ' .text-author h3{                                                                                                                                                                             '
              &&   '     margin-bottom: 0;                                                                                                                                                                        '
              &&   ' }                                                                                                                                                                                            '
              &&   ' ul.social{                                                                                                                                                                                   '
              &&   '     padding: 0;                                                                                                                                                                              '
              &&   ' }                                                                                                                                                                                            '
              &&   ' ul.social li{                                                                                                                                                                                '
              &&   '     display: inline-block;                                                                                                                                                                   '
              &&   '     margin-right: 10px;                                                                                                                                                                      '
              &&   ' }                                                                                                                                                                                            '
              &&   ' .footer{                                                                                                                                                                                     '
              &&   '     border-top: 1px solid rgba(0,0,0,.05);                                                                                                                                                   '
              &&   '     color: rgba(0,0,0,.5);                                                                                                                                                                   '
              &&   ' }                                                                                                                                                                                            '
              &&   ' .footer .heading{                                                                                                                                                                            '
              &&   '     color: #000;                                                                                                                                                                             '
              &&   '     font-size: 20px;                                                                                                                                                                         '
              &&   ' }                                                                                                                                                                                            '
              &&   ' .footer ul{                                                                                                                                                                                  '
              &&   '     margin: 0;                                                                                                                                                                               '
              &&   '     padding: 0;                                                                                                                                                                              '
              &&   ' }                                                                                                                                                                                            '
              &&   ' .footer ul li{                                                                                                                                                                               '
              &&   '     list-style: none;                                                                                                                                                                        '
              &&   '     margin-bottom: 10px;                                                                                                                                                                     '
              &&   ' }                                                                                                                                                                                            '
              &&   ' .footer ul li a{                                                                                                                                                                             '
              &&   '     color: rgba(0,0,0,1);                                                                                                                                                                    '
              &&   ' }                                                                                                                                                                                            '
              &&   ' @media screen and (max-width: 500px) {                                                                                                                                                       '
              &&   ' }                                                                                                                                                                                            '
              &&   '     </style>                                                                                                                                                                                 '
              &&   ' </head>                                                                                                                                                                                      '
              &&   '     <center style="width: 100%; background-color: #f1f1f1;">                                                                                                                                 '
              &&   '     <div style=" display: none; font-size: 1px;max-height: 0px; max-width: 0px; opacity: 0; overflow: hidden; mso-hide: all; font-family: sans-serif;"></div>                                '
              &&   '     <div style=" max-width: 900px; margin: 0 auto;" class="email-container">                                                                                                                 '
              &&   '       <table align="center" role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%" style="background-color: #dedede; margin: auto;">                                    '
              &&   '         <tr>                                                                                                                                                                                 '
              &&   '           <td valign="middle" class="hero bg_white" style="background-color: #dedede; padding: 2em 0 2em 0;">                                                                                '
              &&   '             <div class="text-author" style="border-radius: 20px;background-color: #ffffff;border-color: #ffffff; ">                                                                          '
              &&   '                 <table table role="presentation" border="0" cellpadding="0" cellspacing="0" width="100%">                                                                                    '
              &&   '                     <tr>                                                                                                                                                                     '
              &&   '                         <td style="text-align: center;">                                                                                                                                     '
              &&   '                             <img src="https://www.sva.de/sites/default/files/styles/partners_block/public/2023-04/ntt-logo-sva-2023.png?itok=6avsCDRo" style="height: 100px; width: auto;">  '
              &&   '                         </td>                                                                                                                                                                '
              &&   '                     </tr>                                                                                                                                                                    '
              &&   '                     <tr>                                                                                                                                                                     '
              &&   '                         <td style="text-align: left;">                                                                                                                                       '
              &&   '                             <h3 class="name" style="font-weight: 600; font-size: 25px; color: #171717;">Merhaba,</h3>                                                                        '
              &&                               | <span class="position"> { zka_14_s_student_info-student_id } numaralı ve { zka_14_s_student_info-name } { zka_14_s_student_info-surname } | && 'isimli'
              &&   '             öğrencinin kaydı gerçekleşmiştir ! Lütfen internet onayını gerçekleştirin !  ' && sy-datum &&  ' </span> '
              &&   '                         </td>                                                                                                                                                                '
              &&   '                     </tr>                                                                                                                                                                    '
              &&   '                     <tr>                                                                                                                                                                     '
              &&   '                         <td style="text-align: left;">                                                                                                                                       '
              &&   '                             <div style="height: 10px;"></div>                                                                                                                                '
              &&   '                             <span class="position" style="color: #dbdbdb;">Otomatik e-postadır.</span>                                                                                       '
              &&   '                             <div style="height: 10px;"></div>                                                                                                                                '
              &&   '                         </td>                                                                                                                                                                '
              &&   '                     </tr>                                                                                                                                                                    '
              &&   '                     <tr>                                                                                                                                                                     '
              &&   '                         <td style="text-align: left;">                                                                                                                                       '
              &&   '                             <div class="separator" style="background-color: #d7d7d7; height: 1px;"></div>                                                                                    '
              &&   '                         </td>                                                                                                                                                                '
              &&   '                     </tr>                                                                                                                                                                    '
              &&   '                     <tr>                                                                                                                                                                     '
              &&   '                         <td style="text-align: center;">                                                                                                                                     '
              &&   '                             <div style="height: 20px;"></div>                                                                                                                                '
              &&   '                             <span class="position" style="color: #dbdbdb;">Belirtilen işlemleri daha önceden yaptıysanz lütfen bu e-maili dikkate almayınız.</span>                          '
              &&   '                         </td>                                                                                                                                                                '
              &&   '                     </tr>                                                                                                                                                                    '
              &&   '                     <tr>                                                                                                                                                                     '
              &&   '                         <td style="text-align: left;">                                                                                                                                       '
              &&   '                             <h3 class="name" style="font-weight: 250; font-size: 16px; color: #171717;">Saygılarımla,</h3>                                                                   '
              &&   '                             <h3 class="name" style="font-weight: 600; font-size: 16px; color: #171717;">Kağan AKKAYA</h3>                                                                    '
              &&   '                         </td>                                                                                                                                                                '
              &&   '                     </tr>                                                                                                                                                                    '
              &&   '                 </table>                                                                                                                                                                     '
              &&   '             </div>                                                                                                                                                                           '
              &&   '           </td>                                                                                                                                                                              '
              &&   '           </tr>                                                                                                                                                                              '
              &&   '           <tr>                                                                                                                                                                               '
              &&   '             <td style="text-align: center;">                                                                                                                                                 '
              &&   '                 <div>                                                                                                                                                                        '
              &&   '                     <h3 style="color: #898989; font-size: 14px;">© NTT DATA Business Solutions</h3>                                                                                          '
              &&   '                 </div>                                                                                                                                                                       '
              &&   '             </td>                                                                                                                                                                            '
              &&   '           </tr>                                                                                                                                                                              '
              &&   '       </table>                                                                                                                                                                               '
              &&   '     </div>                                                                                                                                                                                   '
              &&   '   </center>                                                                                                                                                                                  '
              &&   ' </body>                                                                                                                                                                                      '
              &&   ' </html>'.


    gt_soli = cl_document_bcs=>string_to_soli( gv_content ).

    go_gbt->set_main_html( gt_soli ).

    go_doc_bcs = cl_document_bcs=>create_from_multirelated(
      i_subject          = |{ zka_14_s_student_info-student_id } Numaralı Öğrenci Kaydı Hakkında|
      i_multirel_service = go_gbt ).

    go_recipient = cl_cam_address_bcs=>create_internet_address(
      i_address_string = 'akkayahome@gmail.com' ).

    go_bcs = cl_bcs=>create_persistent( ).
    go_bcs->set_document( i_document = go_doc_bcs ).
    go_bcs->add_recipient( i_recipient  = go_recipient ).

    gv_status = 'N'.

    go_bcs->set_status_attributes( i_requested_status = gv_status ).

    TRY.
        go_bcs->send( ).
        COMMIT WORK.
      CATCH cx_bcs INTO DATA(lx_bcs).
        ROLLBACK WORK.
    ENDTRY.

  ENDMETHOD.

  METHOD set_fcat.
    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name       = is_struc
        i_bypassing_buffer     = abap_true
      CHANGING
        ct_fieldcat            = rt_fcat
      EXCEPTIONS
        inconsistent_interface = 1
        program_error          = 2
        OTHERS                 = 3.

    LOOP AT rt_fcat ASSIGNING FIELD-SYMBOL(<fs_fcat>).
      IF <fs_fcat> IS ASSIGNED.
        <fs_fcat>-just = 'C'.
        CASE <fs_fcat>-fieldname.
          WHEN 'DEPARTMENT_ID'.
            <fs_fcat>-f4availabl = <fs_fcat>-edit = abap_true.
            <fs_fcat>-outputlen = 8.
          WHEN 'DEPARTMENT_NAME'.
            <fs_fcat>-edit = abap_true.
            <fs_fcat>-outputlen = 29.
          WHEN 'FACULTY_ID'.
            <fs_fcat>-outputlen = 8.
        ENDCASE.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD set_layo.
    rs_layo-col_opt = rs_layo-zebra = abap_true.
    rs_layo-sel_mode = 'B'.
  ENDMETHOD.

  METHOD add_department_alv.

    IF go_add_cont IS NOT BOUND.
      DATA(lt_fcat) = set_fcat( is_struc = 'ZKA_14_T_SECTION' ).
      DATA(ls_layo) = set_layo( ).
      excluding_toolbar( ).

      IF gv_tcode EQ 1.
        get_dept_view( ).
        LOOP AT lt_fcat ASSIGNING FIELD-SYMBOL(<fs_fcat>).
          <fs_fcat>-edit = abap_false.
        ENDLOOP.
      ENDIF.

      go_add_cont = NEW #( container_name = 'CC_DEPARTMENT' ).
      go_add_grid = NEW #( i_parent = go_add_cont ).

      DATA : lt_f4 TYPE lvc_t_f4.
      lt_f4 = VALUE #( ( fieldname = 'DEPARTMENT_ID' getbefore = abap_true chngeafter = abap_true register = abap_true ) ).
      go_add_grid->register_f4_for_fields( it_f4 = lt_f4 ).

      SET HANDLER : handle_button_click FOR go_add_grid,
                    handle_user_command FOR go_add_grid,
                    handle_data_changed FOR go_add_grid,
                    handle_onf4         FOR go_add_grid.



      go_add_grid->register_edit_event( i_event_id = cl_gui_alv_grid=>mc_evt_modified ).

      go_add_grid->set_table_for_first_display(
        EXPORTING
          i_bypassing_buffer            = abap_true
          is_layout                     = ls_layo
          it_toolbar_excluding          = gt_excluding
        CHANGING
          it_outtab                     = gt_department
          it_fieldcatalog               = lt_fcat
        EXCEPTIONS
          invalid_parameter_combination = 1
          program_error                 = 2
          too_many_lines                = 3
          OTHERS                        = 4 ).

    ENDIF.
  ENDMETHOD.

  METHOD get_ders_data.
    SELECT lt~period, lecture, lecture_desc
           FROM zka_14_t_lecture AS lt INNER JOIN zka_14_t_stud_dp AS dp
           ON lt~faculty_id EQ dp~faculty_id AND
              lt~department_id EQ dp~department_id
          INNER JOIN zka_14_t_student AS sd
           ON dp~student_id EQ sd~student_id
           WHERE lt~period EQ  @zka_14_s_student_info-period AND
                 lt~department_id EQ @zka_14_t_section-department_name AND
                 dp~student_id EQ @zka_14_s_student_info-student_id
                 INTO TABLE @gt_ders.
  ENDMETHOD.

  METHOD display_ders.
    go_main->get_ders_data( ).
    IF go_ders_cont IS NOT BOUND.
      DATA(lt_fcat) = set_fcat( is_struc = 'ZKA_14_S_LECTURE' ).
      DATA(ls_layo) = set_layo( ).

      go_ders_cont = NEW #( container_name = 'CC_DERS' ).
      go_ders_grid = NEW #( i_parent = go_ders_cont ).

      go_ders_grid->set_table_for_first_display(
        EXPORTING
          i_bypassing_buffer            = abap_true
          is_layout                     = ls_layo
        CHANGING
          it_outtab                     = gt_ders
          it_fieldcatalog               = lt_fcat
        EXCEPTIONS
          invalid_parameter_combination = 1
          program_error                 = 2
          too_many_lines                = 3
          OTHERS                        = 4 ).
    ELSE.
      go_ders_grid->refresh_table_display( ).
    ENDIF.
  ENDMETHOD.

  METHOD get_lecture_score.
    SELECT * FROM zka_14_t_score
             WHERE student_id     = @zka_14_s_student_info-student_id AND
                   period         = @zka_14_s_student_info-period     AND
                   department_id  = @zka_14_t_section-department_name
             INTO TABLE @gt_score.
  ENDMETHOD.

  METHOD add_new_line.
    DATA ls_department TYPE zka_14_t_section.
    SELECT SINGLE faculty_id FROM zka_14_t_faculty
           INTO @gv_faculty_id
            WHERE faculty = @zka_14_s_student_info-faculty.
    ls_department-faculty_id = gv_faculty_id.
    APPEND ls_department TO gt_department.
    go_add_grid->refresh_table_display( ).
  ENDMETHOD.

  METHOD refresh_screen.
    CLEAR : zka_14_s_student_info-address, zka_14_s_student_info-dob, zka_14_s_student_info-email, zka_14_s_student_info-faculty, zka_14_s_student_info-gender, zka_14_s_student_info-name,
            zka_14_s_student_info-period, zka_14_s_student_info-student_id, zka_14_s_student_info-study_type, zka_14_s_student_info-surname, zka_14_s_student_info-telf1,
            zka_14_s_student_info-telf2,zka_14_t_section-department_name.

    CLEAR : gs_selected_student.

    REFRESH : gt_score, gt_values, gt_ders.

    IF go_ders_grid IS BOUND.
      go_ders_grid->refresh_table_display( ).
    ENDIF.

    IF go_picture IS BOUND.
      go_picture->free( ).

      go_picture->clear_picture(
        EXCEPTIONS
          error  = 1 " Errors
          OTHERS = 2 ).

      CLEAR go_picture.
    ENDIF.

    IF go_pic_container IS BOUND.
      go_pic_container->free( ).
      CLEAR go_pic_container.
    ENDIF.

    IF go_editor IS BOUND.
      go_editor->delete_text(
        EXCEPTIONS
          error_cntl_call_method = 1
          OTHERS                 = 2 ).
    ENDIF.

  ENDMETHOD.

  METHOD get_dept_view.
    CLEAR gt_department.
    SELECT  dp~faculty_id, dp~department_id, sc~department_name
           FROM zka_14_t_stud_dp AS dp
           INNER JOIN zka_14_t_section AS sc
           ON dp~faculty_id EQ sc~faculty_id AND
              dp~department_id EQ sc~department_id
           WHERE dp~student_id EQ @zka_14_s_student_info-student_id
           INTO TABLE @DATA(lt_temp_dept).

    gt_department = CORRESPONDING #( lt_temp_dept ).

  ENDMETHOD.

  METHOD display_student_document.
    get_full_student_info( ).
    LOOP AT gt_values INTO DATA(ls_values) WHERE key EQ zka_14_t_section-department_name.
      READ TABLE gt_full_student_info ASSIGNING FIELD-SYMBOL(<fs_dept_choice>) WITH KEY department = ls_values-text.
    ENDLOOP.
    IF <fs_dept_choice> IS ASSIGNED.

      gs_outputparams-nodialog = abap_on.
      gs_outputparams-preview = abap_on.
      gs_outputparams-dest = 'LP01'.

      CALL FUNCTION 'FP_JOB_OPEN'
        CHANGING
          ie_outputparams = gs_outputparams
        EXCEPTIONS
          cancel          = 1
          usage_error     = 2
          system_error    = 3
          internal_error  = 4
          OTHERS          = 5.

      gv_name = 'ZTC_AF_STUDENT_DOCUMENT'.

      CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
        EXPORTING
          i_name     = gv_name
        IMPORTING
          e_funcname = gv_funcname.

      CALL FUNCTION gv_funcname  " /1BCDWB/SM00000450
        EXPORTING
          /1bcdwb/docparams    = gs_sfpdocarams
          is_student_info_full = <fs_dept_choice>
          iv_student_id        = zka_14_s_student_info-student_id
        IMPORTING
          /1bcdwb/formoutput   = gs_formoutput
        EXCEPTIONS
          usage_error          = 1
          system_error         = 2
          internal_error       = 3
          OTHERS               = 4.


      CALL FUNCTION 'FP_JOB_CLOSE'
        EXCEPTIONS
          usage_error    = 1
          system_error   = 2
          internal_error = 3
          OTHERS         = 4.


    ENDIF.

  ENDMETHOD.

  METHOD screen_freezer.
    IF go_editor IS BOUND.
      go_editor->set_readonly_mode(
        EXPORTING
          readonly_mode          = 1
        EXCEPTIONS
          error_cntl_call_method = 1
          invalid_parameter      = 2
          OTHERS                 = 3 ).
    ENDIF.

    LOOP AT SCREEN.
      IF screen-group1 EQ 'PR1' OR screen-group1 EQ 'PR2'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
      IF screen-name EQ 'NRECORD' OR screen-name EQ 'TEMIZLE' OR screen-name EQ 'DISPLAY'.
        screen-active = 0.
        MODIFY SCREEN.
      ELSEIF screen-name EQ 'STUD_DOC'.
        screen-active = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD studdoc_visibility.
    LOOP AT SCREEN.
      IF screen-name EQ 'STUD_DOC'.
        screen-invisible = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD dept_data_for_f4.
    SELECT * FROM zka_14_t_section
      INTO TABLE @gt_department_list.
  ENDMETHOD.

  METHOD init.
    me->screen_statu( ).
    me->dept_data_for_f4( ).
  ENDMETHOD.

  METHOD screen_statu.
    CASE sy-tcode.
      WHEN c_tcode-view.
        gs_screenstat-display = abap_true.
      WHEN c_tcode-create.
        gs_screenstat-create  = abap_true.
      WHEN c_tcode-edit.
        gs_screenstat-edit    = abap_true.
    ENDCASE.
  ENDMETHOD.

  METHOD modify_student_data.
    read_text_editor( ).
    IF gs_stud_address IS NOT INITIAL.
      DATA ls_student TYPE zka_14_t_student.
      ls_student-student_id = zka_14_s_student_info-student_id.
      ls_student-name       = zka_14_s_student_info-name.
      ls_student-surname    = zka_14_s_student_info-surname.
      ls_student-gender     = zka_14_s_student_info-gender.
      ls_student-dob        = zka_14_s_student_info-dob.
      ls_student-faculty    = zka_14_s_student_info-faculty.
      ls_student-study_type = zka_14_s_student_info-study_type.
      ls_student-period     = zka_14_s_student_info-period.
      ls_student-telf1      = zka_14_s_student_info-telf1.
      ls_student-telf2      = zka_14_s_student_info-telf2.
      ls_student-email      = zka_14_s_student_info-email.
      ls_student-address    = gs_stud_address.
      MODIFY zka_14_t_student FROM ls_student.
      IF sy-subrc IS INITIAL.
        MESSAGE s012 WITH zka_14_s_student_info-student_id.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD add_student_image.
    gv_imgnam = zka_14_s_student_info-student_id. "StudentID Photo
    DATA(lv_image_desc) = | { gv_imgnam } && { zka_14_s_student_info-name } |.
    PERFORM import_bitmap USING gv_imgupl
                                gv_imgnam
                                'lv_image_desc'.

  ENDMETHOD.


ENDCLASS.

*&---------------------------------------------------------------------*
*& Include ZTC_STUDENT_INFO_TOP                     - Report ZTC_STUDENT_INFO
*&---------------------------------------------------------------------*
CLASS: lcl_main DEFINITION DEFERRED.
TABLES:zka_14_s_student_info, sscrfields, zka_14_t_section.

CONSTANTS: BEGIN OF c_tabcntrl,
             tab1 LIKE sy-ucomm VALUE 'TABCNTRL_FC1',
             tab2 LIKE sy-ucomm VALUE 'TABCNTRL_FC2',
             tab3 LIKE sy-ucomm VALUE 'TABCNTRL_FC3',
           END OF c_tabcntrl.

CONSTANTS : BEGIN OF c_tcode,
              view   LIKE sy-tcode VALUE 'ZSTUDVIEW',
              create LIKE sy-tcode VALUE 'ZSTUDCREATE',
              edit   LIKE sy-tcode VALUE 'ZSTUDEDIT',
              login  LIKE sy-tcode VALUE 'ZSTUDLOGIN',
            END OF c_tcode.


CONTROLS:  tabcntrl TYPE TABSTRIP.

DATA : BEGIN OF gs_screenstat,
         display TYPE abap_bool,
         create  TYPE abap_bool,
         edit    TYPE abap_bool,
       END OF gs_screenstat.

DATA: BEGIN OF g_tabcntrl,
        subscreen   LIKE sy-dynnr,
        prog        LIKE sy-repid VALUE 'ZTC_STUDENT_INFO',
        pressed_tab LIKE sy-ucomm VALUE c_tabcntrl-tab1,
      END OF g_tabcntrl.

DATA: go_main TYPE REF TO lcl_main.
DATA: ok_code LIKE sy-ucomm.

" Add Department ALV
DATA : go_add_grid TYPE REF TO cl_gui_alv_grid,
       go_add_cont TYPE REF TO cl_gui_custom_container.

" Ders ALV
DATA : gt_ders      TYPE TABLE OF zka_14_s_lecture,
       go_ders_grid TYPE REF TO cl_gui_alv_grid,
       go_ders_cont TYPE REF TO cl_gui_custom_container.

"Text Editor for Contact
DATA : go_editor      TYPE REF TO cl_gui_textedit,
       go_editor_cont TYPE REF TO cl_gui_custom_container.

" Read text-editor
DATA : gt_address_text TYPE STANDARD TABLE OF char200,
       gs_stud_address LIKE LINE OF gt_address_text.

" Regex Mail Validate
DATA: gr_regex     TYPE REF TO cl_abap_regex,
      gr_matcher   TYPE REF TO cl_abap_matcher,
      gv_pattern   TYPE string,
      gv_mail_flag TYPE i.

" Student Image Upload
DATA : gv_imgupl    TYPE localfile,
       gv_temp_path TYPE rlgrap-filename,
       gv_imgnam    TYPE stxbitmaps-tdname.

" PICTURE DISPLAY
CONSTANTS: cntl_true  TYPE i VALUE 1,
           cntl_false TYPE i VALUE 0.
DATA:go_picture       TYPE REF TO cl_gui_picture,
     go_pic_container TYPE REF TO cl_gui_custom_container.

DATA: gv_graphic_url(255),
      gv_graphic_refresh(1),
      gv_result LIKE cntl_true.

TYPES: BEGIN OF ty_graphic_table,
         line(255) TYPE x,
       END OF ty_graphic_table.

DATA: gt_graphic_table TYPE TABLE OF ty_graphic_table,
      gv_graphic_size  TYPE i.

DATA: gs_stxbmaps TYPE stxbitmaps,
      gv_bytecnt  TYPE i,
      gt_content  TYPE  STANDARD TABLE OF bapiconten INITIAL SIZE 0.

" Toolbar Excluding
DATA : gv_excluding TYPE ui_func,
       gt_excluding TYPE ui_functions.

" ALV Department Table
DATA : gt_department      TYPE TABLE OF zka_14_t_section,
       gt_department_list TYPE TABLE OF zka_14_t_section.

" Get Selected Student Data
DATA : gs_selected_student TYPE zka_14_t_student.

" Department Dropdown
DATA : gt_values     TYPE vrm_values,
       gs_value      LIKE LINE OF gt_values,
       gv_faculty_id TYPE zka_e_faculty_id.

" Sent Student Record Mail
DATA : go_gbt       TYPE REF TO cl_gbt_multirelated_service,
       go_bcs       TYPE REF TO cl_bcs,
       go_doc_bcs   TYPE REF TO cl_document_bcs,
       go_recipient TYPE REF TO if_recipient_bcs,
       gt_soli      TYPE TABLE OF soli,
       gs_soli      TYPE soli,
       gv_status    TYPE bcs_rqst,
       gv_content   TYPE string.

" Set and Display Lecture Score
DATA : gt_score TYPE TABLE OF zka_14_t_score,
       gs_score LIKE LINE OF gt_score.


DATA : gv_button(12) VALUE 'ADD'.
DATA : gv_tcode   TYPE i, " For Screen Process
       gv_freeze  TYPE i, " For Screen Input
       gv_studdoc TYPE i. " For Studen Document Visibility

" Full Student Info for Adobe Form
DATA : gt_full_student_info TYPE zka_14_tt_student_info_full.

" Adobe Forms
DATA : gs_outputparams TYPE  sfpoutputparams,
       gv_name         TYPE  fpname,
       gv_funcname     TYPE  funcname,
       gs_sfpdocarams  TYPE  sfpdocparams,
       gs_formoutput   TYPE  fpformoutput.

" Table Control Comparison
DATA gt_temp_score TYPE zka_14_t_score.


*&SPWIZARD: DECLARATION OF TABLECONTROL 'TBCNTRL' ITSELF
CONTROLS: tbcntrl TYPE TABLEVIEW USING SCREEN 0101.

*&SPWIZARD: LINES OF TABLECONTROL 'TBCNTRL'
DATA:     g_tbcntrl_lines  LIKE sy-loopc.


DATA : gv_tbc_cols LIKE LINE OF tbcntrl-cols. " Modify Student Score for Table Control 'tbcntrl'

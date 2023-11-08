*&---------------------------------------------------------------------*
*& Report ZTC_STUDENT_INFO
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ztc_student_info MESSAGE-ID zka_stud.
INCLUDE ztc_student_info_top.
INCLUDE ztc_student_info_cls.
INCLUDE ztc_student_info_pai.
INCLUDE ztc_student_info_pbo.
INCLUDE ztc_student_info_frm.

INITIALIZATION.
  go_main = NEW #( ).
  go_main->init( ).


START-OF-SELECTION.
  go_main->where_the_story_begins( ).

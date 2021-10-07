"Objetos
    DATA: lo_send_request TYPE REF TO cl_bcs,
          lo_document     TYPE REF TO cl_document_bcs,
          lo_recipient    TYPE REF TO cl_cam_address_bcs,
          lo_sender       TYPE REF TO if_sender_bcs.

    "Tabelas
    DATA: lt_linhas TYPE TABLE OF soli.

    "Variáveis
    DATA: lv_subject         TYPE so_obj_des,
          lv_email           TYPE adr6-smtp_addr,
          lv_sent_to_all     TYPE os_boolean.

    "Objeto que enviará o e-mail
    lo_send_request = cl_bcs=>create_persistent( ).

    "Assunto
    lv_subject = 'Assunto do email'.

    "Monta corpo do email
    APPEND 'Olá bom dia Sr.' TO lt_linhas.
    APPEND 'Atenciosamente.' TO lt_linhas.

    "Gera corpo do email
    lo_document = cl_document_bcs=>create_document( i_type    = 'RAW'
                                                    i_text    = lt_linhas
                                                    i_subject = lv_subject ).

    lo_send_request->set_document( lo_document ).

    "Email Destinarios
    lv_email = "exemple@gmail.com".

    "Destinatário
    lo_recipient = cl_cam_address_bcs=>create_internet_address( lv_email ).

    lo_send_request->add_recipient( i_recipient  = lo_recipient
                                    i_blind_copy = abap_true    ).

    "Remetente
    lo_sender = cl_cam_address_bcs=>create_internet_address(
                  i_address_string = 'exemplo@gmail.com'
                  i_address_name  =  'Nome Email na Transação SOST'
                ).

    "Seta o Remetente no objeto de e-mail
    lo_send_request->set_sender( lo_sender ).

    "Nunca solicitar confirmação de recebimento
    lo_send_request->set_status_attributes( 'N' ).

    "Envia o e-mail e armazena o retorno do envio
    lv_sent_to_all = lo_send_request->send( i_with_error_screen = 'X' ).

    COMMIT WORK AND WAIT.

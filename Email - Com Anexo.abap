    "Objetos
    DATA: lo_send_email   TYPE REF TO zcl_convert_doc_send_email,
          lo_send_request TYPE REF TO cl_bcs,
          lo_document     TYPE REF TO cl_document_bcs,
          lo_recipient    TYPE REF TO cl_cam_address_bcs,
          lo_sender       TYPE REF TO if_sender_bcs.

    "Tabelas
    DATA: lt_linhas     TYPE TABLE OF soli,
          lt_content    TYPE solix_tab.

    "Variáveis
    DATA: lv_subject         TYPE so_obj_des,
          lv_nome_anexo      TYPE sood-objdes,
          lv_type            TYPE soodk-objtp,
          lv_email           TYPE adr6-smtp_addr,
          lv_sent_to_all     TYPE os_boolean,
          lv_size_danfe      TYPE so_obj_len.

*** Incio do processo para envio de email ***
      "Objeto que enviará o e-mail
      lo_send_request = cl_bcs=>create_persistent( ).

      "Assunto do email
      lv_subject = 'Assunto do email'.

      "Corpo do Email
      APPEND 'Segue em anexo o XML' TO lt_linhas

      "Gera corpo do email
      lo_document = cl_document_bcs=>create_document(
                    i_type    = 'RAW'
                    i_text    = lt_linhas
                    i_subject = lv_subject ).

*** Adiciona XML ***
      CREATE OBJECT lo_send_email
        EXPORTING
          iv_xml = lv_cfe.

      "Processo de seleção e conversão do XML para Danfe em PDF XString
      lo_send_email->process_xml_to_pdf(
        IMPORTING
          ev_xstring = DATA(lv_xstring_pdf)
          ev_size    = DATA(lv_size_danfe_process) ).

      "Tamanho do arquivo
      lv_size_danfe = CONV #( lv_size_danfe_process ).

      "Conversão para hexadecimal
      lt_content = cl_bcs_convert=>xstring_to_solix( iv_xstring = lv_xstring_xml ).

      "Adiciona Anexo
      add_attachment(
        EXPORTING
          iv_type       = 'XML'
          iv_nome_anexo = 'DANFE XML'
          iv_size       = lv_size_xml
          it_content    = lt_content
        CHANGING
          co_document   = lo_document ).

      lo_send_request->set_document( lo_document ).

      "Email Destinarios
      lv_email = 'exemplo@gmail.com'.

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

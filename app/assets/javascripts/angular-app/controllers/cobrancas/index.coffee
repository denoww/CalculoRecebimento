angular.module 'app'
  .controller 'Cobranca::IndexCtrl', [
    '$scope', '$timeout', '$filter', 'CobrancaResource', 'RecebimentoResource', 'ReceberResource', 'scTopMessages', 'scAlert', 'ConfigCobrancaResource'
    (sc, $timeout, $filter, CobrancaResource, RecebimentoResource, ReceberResource, scTopMessages, scAlert, ConfigCobrancaResource)->

      idCobranca = 1

      sc.carregando = true
      sc.cobranca = CobrancaResource.get {id: idCobranca},
        (data)->
          sc.carregando = false
          sc.tipo_recebe = data.configCobranca.juros_simples
        (response)->
          scTopMessages.openDanger "Houve algum erro na busca da cobrança, contate ao Suporte se percistir!"

      sc.receber =
        data: '', valor: 0, juros: 0, multa: 0, valor_base: 0, juros_atual: 0
        multa_atual: 0, cobranca_id: idCobranca, juros_simples: true

      sc.mudarTipoReceb = (j_simples = true)->
        config_cobrancas =
          juros_simples: j_simples
        ConfigCobrancaResource.update
          id: 1,
          config_cobrancas,
          (data)->
            # Sucesso
          (response)->
            scAlert.open
              title: 'Atenção!'
              messages: response.data.errors
              buttons: [
                {
                  label: 'Ok'
                  color: 'yellow'
                }
              ]

      resetReceb = ()->
        sc.receber =
          data: '', valor: 0, juros: 0, multa: 0, valor_base: 0, juros_atual: 0
          multa_atual: 0, cobranca_id: idCobranca, juros_simples: true, nova_composicao: 0

      sc.addRec = ()->
        if sc.receber.valor != 0
          sc.receber.salvando = true
          RecebimentoResource.save sc.receber,
            (data)->
              sc.receber.salvando = false
              sc.receber.nova_composicao = data.nova_composicao
              sc.cobranca.recebimentos.push data.recebimento
              sc.cobranca.totais = data.totais
              sc.cobranca.pagamentoMaior = data.pagamentoMaior
              sc.cobranca.divida_cobranca = data.divida_cobranca
              resetReceb()
              scTopMessages.openSuccess "Recebimento realizado com sucesso!"
            (response)->
              sc.receber.salvando = false
              scAlert.open
                title: 'Atenção!'
                messages: response.data.errors
                buttons: [
                  {
                    label: 'Ok'
                    color: 'yellow'
                  }
                ]

      sc.calcularSemJurosMulta = ->
        $timeout ->
          sc.receber.juros = null
          sc.receber.multa = null
          calcular()
        , 900

      sc.calcularComJurosMulta = ()->
        $timeout ->
          calcular()
        , 900

      calcular = ()->
        sc.receber.calculando = true
        ReceberResource.calcular_divida sc.receber,
          (data)->
            sc.receber.calculando       = false
            sc.receber.juros            = data.juros
            sc.receber.multa            = data.multa
            sc.receber.nova_composicao  = data.nova_composicao
            sc.receber.multa_atual      = data.multa_atual
            sc.receber.juros_atual      = data.juros_atual
            sc.receber.valor_base       = data.valor_base
            sc.receber.divida_cobranca  = data.divida_cobranca
            sc.receber.min_data_error   = 0
            sc.receber.pagamentoMaior   = data.pagamentoMaior
          (response)->
            sc.receber.min_data = response.data.errors.min_date
            sc.receber.min_data_error = -1
            sc.receber.calculando = false

      sc.deleteReceb = (item, index)->
        scAlert.open
          title: 'Você tem certeza?'
          messages: 'Você não será capaz de recuperar esse registro!'
          buttons: [
            {
              label: 'Cancelar'
              color: 'gray'
            }
            {
              label: 'Excluír'
              color: 'red'
              action: ()->
                RecebimentoResource.delete
                  id: item.id,
                  (data)->
                    sc.cobranca.recebimentos.splice index, 1
                    sc.cobranca.totais = data.totais
                    sc.cobranca.divida_cobranca = data.divida_cobranca
                    sc.cobranca.pagamentoMaior = data.pagamentoMaior
                    scTopMessages.openDanger "Recebimento excluido com sucesso!"
                    $timeout ()->
                      scTopMessages.close()
                    , 5000
            }
          ]
          (response)->

]

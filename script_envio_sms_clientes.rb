#!/usr/bin/env ruby
##
# Script para envio de SMS em lote para varios clientes a partir do numero de contrato do cliente
#
#   * Ao rodar o script, utilizar uma string com a mensagem que sera enviada por SMS (no maximo 140 caracteres).
#   * Como terceiro parametro, utilizar uma string com os numeros dos contratos separados por virgula.
#   
#
# EXEMPLOS:
#   * contratos = ['20062214','20146357','20148104','20146038','20146449','20148316','20148458','20151326','20148119','20147474','20150785','20146883','20146680','20146654','20148161','20148030','20147037','20147640','20146747','20147471','20146431','20147941','20148352','20146713','20148035','20146574','20150632','20146259','20147888','20148720','20146757','20148717','20150760','20146861','20148256','20147835','20147595','20148459','20147999','20150012','20148265','20148328','20147998','20153701','20146500','20148449','20153441','20150073','20153466','20153224','20146614','20146798','20147832','20146848','20152988','20146282','201650648','20146761','20147574','20147146','20155260','20153237','20147775','20146433','20148164','20148498','20146688','20152445','20146664','20146344','20152685','20148330','20146792','20151210','20155055','20153282','20148507','20146246','20153959','201649470','20146877','20151808','20148418','20151812','20150197','20153420','20148198','20146794','201547638','20150339','201649524','20151851','201548377','20151642','20147623','20147108','20151845','201548297','20148126','20146439','20146206','20146881','20148460','20152590','20147806','201648715','20151843','20148722','20153635','201648711','20151170','20148760','20154690','201649099','20154683','20147088','20148095','20152629','20152761','20152727','20154067','20147512','20153317','20154437','20150681','20153520','20148309','20148084','201547975','20147955','20152362','20147487','20146196','20151595','201649137', '20152706']
#   * mensagem = 'Comunicamos que os planos vigentes serao extintos na localidade Frei Orlando e adjacencias devido a inviabilidade tecnica dos servicos.' #
#   
##

mensagem  = ARGV[1].present? ? ARGV[1] : nil
contratos = ARGV[2].present? ? ARGV[2].split(',').map(&:to_i) : nil

# Encerra a execuçao do script se o segundo e terceiro parametros nao foram 'passados' corretamente
exit if contratos.nil? || mensagem.nil?

# Clientes selecionados a partir de contratos
clientes = ::Base::Cliente.joins(:contratos).where('ativacao_contratos.numero': contratos).uniq

clientes.each do |cliente|
  numeros_telefones = cliente.telefones_sms

  # Sai do loop se nao existirem telefones para o envio neste cliente
  next if numeros_telefones.blank?

  begin

    # Parametros para criar a mensagem com informações do BD
    base_mensagem_params = {
      funcionario_id: 99999,
      comunicavel_id: cliente.id,
      comunicavel_type: 'Base::Cliente',
      conteudo: mensagem,
      numeros: numeros_telefones
    }

    # Cria mensagem que vai disparar o envio do SMS
    Base::Mensagem.create!(base_mensagem_params)
    log "SMS enviado para: #{cliente.id} - #{numeros_telefones}"

  rescue StandardError => e
    log "#{cliente.id} | #{e.inspect}"
    Raven.capture_exception(e)
    raise ActiveRecord::Rollback
  end
end
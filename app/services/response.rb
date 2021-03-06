class Response

  def self.not_found
    {file: 'public/404.html', status: :not_found, layout: false}
  end

  def self.object_erros(object)
    {json: {errors: object.errors}, status: :bad_request}
  end

  def self.nao_pode_receber
    {json: {errors: "Existem recebimentos com data posterior a escolhida. Não é permitido realizar pagamentos"}, status: :bad_request}
  end
end

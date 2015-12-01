# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Cobranca.create(valor: 95, juros: 0.03, multa: 2, atualizado: 0, vencimento: "2015-10-12")
ComposicaoCobranca.create(titulo: "Taxa de Condomínio", valor: 15, cobranca_id: 1)
ComposicaoCobranca.create(titulo: "Salão de festas", valor: 80, cobranca_id: 1)
ConfigCobranca.create!

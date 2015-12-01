angular.module 'app'
  .factory 'ConfigCobrancaResource', [
    '$resource'
    ($resource)->
      return $resource '/config_cobranca/:id.json',
        id: '@id',
          'update': method:'PUT'
  ]

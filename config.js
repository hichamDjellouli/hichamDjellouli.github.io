(function () {
    'use strict';
    angular
        .module('ClinicApp')
        .factory('IPConfig', IPConfig);
    IPConfig.$inject = ['$rootScope'];
    function IPConfig($rootScope) {
        var service = {};
        $rootScope.main_url = "http://127.0.0.1:8080/";
        $rootScope.api_url = "http://127.0.0.1:3000/api/";
        return service;
    }
})();


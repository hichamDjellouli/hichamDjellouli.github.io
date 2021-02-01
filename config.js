(function () {
    'use strict';
    angular
        .module('ClinicApp')
        .factory('IPConfig', IPConfig);
    IPConfig.$inject = ['$rootScope'];
    function IPConfig($rootScope) {
        var service = {};
        $rootScope.main_url = "http://dzental.me/";
        $rootScope.api_url = "http://dzental.me:3000/api/";
        return service;
    }
})();


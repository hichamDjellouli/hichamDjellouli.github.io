/*
A user service designed to interact with a resultTful web service to manage reports within the system.
*/
(function () {
    'use strict';

    angular
        .module('ClinicApp')
        .factory('ReportsService', ReportsService);

    ReportsService.$inject = ['$http', '$rootScope'];
    function ReportsService($http, $rootScope) {
        var service = {};
        // var api_url = "http://192.168.23.2:3000/api/";
        service.Get_Statistiques_patients_sexes_ages = Get_Statistiques_patients_sexes_ages;

        service.Get_Statistiques_rdvs = Get_Statistiques_rdvs;

        service.Get_Statistiques_Transactions = Get_Statistiques_Transactions;

        return service;


        function Get_Statistiques_patients_sexes_ages(date_du, date_au) {
            return $http.post($rootScope.api_url + 'reports/statistiques_patients_sexes_ages', { date_du: date_du, date_au: date_au }).then(OnehandleSuccess, handleError);
        }

        function Get_Statistiques_rdvs(date_du, date_au) {
            return $http.post($rootScope.api_url + 'reports/statistiques_rdvs', { date_du: date_du, date_au: date_au }).then(OnehandleSuccess, handleError);
        }

        function Get_Statistiques_Transactions(date_du, date_au) {
            return $http.post($rootScope.api_url + 'reports/statistiques_transactions', { date_du: date_du, date_au: date_au }).then(OnehandleSuccess, handleError);
        }

        function OnehandleSuccess(result) {
            return { success: true, data: result.data[0] };
        }

        function ManyhandleSuccess(result) {
            console.log('UserService -> : result.data' + result.data);
            return { success: true, data: result.data };
        }

        function handleError(result) {
            return { success: false, code: result.data.code, message: result.data.message };
        }
    }

})();

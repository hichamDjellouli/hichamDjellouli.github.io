/*
A user service designed to interact with a resultTful web service to manage transactions within the system.
*/
(function () {
    'use strict';

    angular
        .module('ClinicApp')
        .factory('TransactionsService', TransactionsService);

    TransactionsService.$inject = ['$http', '$rootScope'];
    function TransactionsService($http, $rootScope) {
        var service = {};

        service.Get_All_Transactions = Get_All_Transactions;
        service.Add_Transaction = Add_Transaction;
        service.Edit_Transaction = Edit_Transaction;
        service.Delete_Transaction = Delete_Transaction;
        service.get_total_actes_total_versements = get_total_actes_total_versements;

        return service;


        function Get_All_Transactions() {
            return $http.get($rootScope.api_url + 'transactions/get_all_transactions').then(ManyhandleSuccess, handleError);
        }

        function Add_Transaction(New_Transaction) {
            return $http.post($rootScope.api_url + 'transactions/add_transaction', New_Transaction).then(ManyhandleSuccess, handleError);
        }

        function Edit_Transaction(Selected_Transaction) {
            return $http.put($rootScope.api_url + 'transactions/edit_transaction', Selected_Transaction).then(ManyhandleSuccess, handleError);
        }
    
        function Delete_Transaction(transaction_versement_id) {
            return $http.delete($rootScope.api_url + 'transactions/delete_transaction/' + transaction_versement_id).then(ManyhandleSuccess, handleError);
        }

        function get_total_actes_total_versements() {
            return $http.post($rootScope.api_url + 'transactions/get_total_actes_total_versements',).then(ManyhandleSuccess, handleError);
        }

        /**************************************************************************************************************/
        function OnehandleSuccess(result) {
            return { success: true, data: result.data[0] };
        }

        function ManyhandleSuccess(result) {
            //console.log('TransactionsService -> : result.data' + JSON.stringify(result.data));
            return { success: true, data: result.data };
        }

        function handleError(result) {
            return { success: false, code: result.data.code, message: result.data.message };
        }
    }



})();


(function () {
    'use strict';
    angular
        .module('ClinicApp')
        .factory('alert', alert);

    alert.$inject = ['$http','$rootScope','$uibModal'];
    function alert($http,$rootScope,$uibModal) {
        var service = {};
        //console.log('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
        service.show = show;
        service.Get_All_Patients = Get_All_Patients;

        return service;


        function show(action, event) {
            return $uibModal.open({
                templateUrl: 'modal.html',
                controller: function () {
                    $rootScope.action = action;
                    $rootScope.event = event;
                    console.log("pooooooooo event "+JSON.stringify(event))

                },
               
            });
        }

        function Get_All_Patients() {
            return $http.get($rootScope.api_url + 'patients/get_all_patients').then(ManyhandleSuccess, handleError);
        }
    }

})();
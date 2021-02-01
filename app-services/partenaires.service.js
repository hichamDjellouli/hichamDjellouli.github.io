/*
A partenaire service designed to interact with a resultTful web service to manage partenaire within the system.
*/
(function () {
    'use strict';

    angular
        .module('ClinicApp')
        .factory('PartenaireService', OrgService);

    OrgService.$inject = ['$http', '$rootScope'];
    function OrgService($http, $rootScope) {
        var service = {};
        // var api_url = "http://192.168.23.2:3000/api/";



        service.Get_All_Partenaires = Get_All_Partenaires;
        service.Add_Partenaire = Add_Partenaire;
        service.Delete_Partenaire = Delete_Partenaire;

        service.Upload_Logo_File = Upload_Logo_File;

        return service;


        /*** Annuaire ***/
        function Get_All_Partenaires(partenaire_id) {
            return $http.post($rootScope.api_url + 'partenaires/get_all_partenaires', { partenaire_id }).then(ManyhandleSuccess, handleError);
        }

        function Add_Partenaire(New_Partenaire) {
            return $http.post($rootScope.api_url + 'partenaires/add_partenaire',  New_Partenaire ).then(ManyhandleSuccess, handleError);
        }

        function Delete_Partenaire(partenaire_id) {
            return $http.delete($rootScope.api_url + 'partenaires/delete_partenaire/' + partenaire_id).then(ManyhandleSuccess, handleError);
        }
        /***************************************************************/
        function Upload_Logo_File(logo_document, fileName) {
            var fd = new FormData();
            fd.append('file', logo_document);
            fd.append('fileName', fileName);
            return $http.post($rootScope.api_url + 'partenaire/logo_document', fd, {
                transformRequest: angular.identity,
                headers: { 'Content-Type': undefined }
            }).then(OnehandleSuccess, handleError);
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

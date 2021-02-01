/*
A org service designed to interact with a resultTful web service to manage org within the system.
*/
(function () {
    'use strict';

    angular
        .module('ClinicApp')
        .factory('OrgService', OrgService);

    OrgService.$inject = ['$http', '$rootScope'];
    function OrgService($http, $rootScope) {
        var service = {};
        // var api_url = "http://192.168.23.2:3000/api/";

        service.GetAll = GetAll;
        service.GetById = GetById;

        service.Create = Create;
        service.Update = Update;
        service.Delete = Delete;

        service.Get_AllOrgUsers = Get_AllOrgUsers;

        service.GetAllOrgProduits = GetAllOrgProduits;
        service.Add_OrgProduits = Add_OrgProduits;
        service.Delete_OrgProduits = Delete_OrgProduits;

        service.Upload_Logo_File = Upload_Logo_File;
        service.Upload_background_File = Upload_background_File;
        return service;

        function GetAll() {
            return $http.get($rootScope.api_url + 'org/all').then(ManyhandleSuccess, handleError);
        }

        function GetById(id) {
            return $http.get($rootScope.api_url + 'org/' + id).then(OnehandleSuccess, handleError);
        }

        function Create(org) {
            return $http.post($rootScope.api_url + 'org/insert', org).then(OnehandleSuccess, handleError);
        }

        function Update(org) {
            console.log('OrgService -> : org : ' + org);
            console.log('OrgService -> : JSON.stringify(org) : ' + JSON.stringify(org));
            return $http.put($rootScope.api_url + 'org/', org).then(OnehandleSuccess, handleError);
        }

        function Delete(id) {
            return $http.delete($rootScope.api_url + 'org/' + id).then(OnehandleSuccess, handleError);
        }

        function Get_AllOrgUsers(id) {
            return $http.get($rootScope.api_url + 'org/orgusers/' + id).then(ManyhandleSuccess, handleError);
        }

        function GetAllOrgProduits(id) {
            return $http.get($rootScope.api_url + 'org/orgproduits/' + id).then(org_org_produit_ManyhandleSuccess, handleError);
        }

        function Add_OrgProduits(org_id, produit_id) {
            return $http.post($rootScope.api_url + 'org/orgproduits/', { org_id, produit_id }).then(org_org_produit_ManyhandleSuccess, handleError);
        }

        function Delete_OrgProduits(org_id, produit_id) {
            return $http.put($rootScope.api_url + 'org/orgproduits/', { org_id, produit_id }).then(org_org_produit_ManyhandleSuccess, handleError);
        }


        /***************************************************************/
        function Upload_Logo_File(logo_document, fileName) {
            var fd = new FormData();
            fd.append('file', logo_document);
            fd.append('fileName', fileName);
            return $http.post($rootScope.api_url + 'org/logo_document', fd, {
                transformRequest: angular.identity,
                headers: { 'Content-Type': undefined }
            }).then(OnehandleSuccess, handleError);
        }


        function Upload_background_File(background_document, fileNameBackground) {
            var fd = new FormData();
            fd.append('file', background_document);
            fd.append('fileNameBackground', fileNameBackground);
            return $http.post($rootScope.api_url + 'org/background_document', fd, {
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

        function org_org_produit_ManyhandleSuccess(result) {
            console.log('UserService -> : result.data' + result.data);
            return {
                success: true,
                orgproduits: result.data[0].orgproduits,
                produits_without_orgproduits: result.data[0].produits_without_orgproduits
            };
        }

        function handleError(result) {
            return { success: false, code: result.data.code, message: result.data.message };
        }
    }

})();

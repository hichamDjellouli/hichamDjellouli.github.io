/*
A user service designed to interact with a resultTful web service to manage patients within the system.
*/
(function () {
    'use strict';

    angular
        .module('ClinicApp')
        .factory('RDVService', RDVService);

    RDVService.$inject = ['$http', '$rootScope'];
    function RDVService($http, $rootScope) {
        var service = {};

        service.Get_All_RDVs = Get_All_RDVs;
        service.Add_RDV = Add_RDV;
        service.Edit_RDV = Edit_RDV;
        service.Delete_RDV = Delete_RDV;

        return service;


        function Get_All_RDVs() {
            return $http.post($rootScope.api_url + 'rdv/get_all_rdvs').then(ManyhandleSuccess, handleError);
        }

        function Add_RDV(patient_id, Selected_Patient_RDV_title, Selected_Patient_RDV_Motif_id, Selected_Patient_RDV_Color, Selected_Patient_RDV_Etat, Selected_Patient_RDV_startsAt, Selected_Patient_RDV_endsAt) {
            return $http.post($rootScope.api_url + 'rdv/add_rdv', { patient_id, Selected_Patient_RDV_title, Selected_Patient_RDV_Motif_id, Selected_Patient_RDV_Color, Selected_Patient_RDV_Etat, Selected_Patient_RDV_startsAt, Selected_Patient_RDV_endsAt }).then(ManyhandleSuccess, handleError);
        }

        function Edit_RDV(Selected_Patient_id, Selected_Patient_RDV_id, Selected_Patient_RDV_startsAt, Selected_Patient_RDV_endsAt, Selected_Patient_RDV_etat_id) {
            return $http.put($rootScope.api_url + 'rdv/edit_rdv', { Selected_Patient_id, Selected_Patient_RDV_id, Selected_Patient_RDV_startsAt, Selected_Patient_RDV_endsAt, Selected_Patient_RDV_etat_id }).then(ManyhandleSuccess, handleError);
        }

        function Delete_RDV(patient_rdv_id) {
            return $http.delete($rootScope.api_url + 'rdv/delete_rdv/' + patient_rdv_id).then(ManyhandleSuccess, handleError);
        }

        /**************************************************************************************************************/
        function OnehandleSuccess(result) {
            return { success: true, data: result.data[0] };
        }

        function ManyhandleSuccess(result) {
            //console.log('RDVService -> : result.data' + JSON.stringify(result.data));
            return { success: true, data: result.data };
        }

        /**************************************************************************************************************/
        function GetAll(id) {
            return $http.get($rootScope.api_url + 'patients/patients-of-list/' + id, { cache: false }).then(ManyhandleSuccess, handleError);
        }
        function GetAllControlled(id) {
            return $http.get($rootScope.api_url + 'patients/patients-of-controlled-list/' + id).then(ControleSuccess, handleError);
        }

        function GetById(id) {
            return $http.get($rootScope.api_url + 'patients/' + id).then(OnehandleSuccess, handleError);
        }

        function GetByUsername(username) {
            return $http.get($rootScope.api_url + 'patients/' + username).then(OnehandleSuccess, handleError);
        }



        function CreateGrouped(p_demande_controle_id, user_id, patientss) {
            return $http.post($rootScope.api_url + 'patients/insert-grouped', { p_demande_controle_id, user_id, patientss }).then(OnehandleSuccess, handleError);
        }

        function Update(user) {
            //console.log('RDVService -> : user : ' + user);
            //console.log('RDVService -> : JSON.stringify(user) : ' + JSON.stringify(user));
            return $http.put($rootScope.api_url + 'patients/update', user).then(OnehandleSuccess, handleError);
        }

        function UpdateGrouped(patientss) {
            //console.log('RDVService -> : patientss : ' + patientss);
            return $http.put($rootScope.api_url + 'patients/update-grouped', patientss).then(OnehandleSuccess, handleError);
        }

        function Delete(id) {
            return $http.delete($rootScope.api_url + 'patients/' + id).then(OnehandleSuccess, handleError);
        }


        function IsNotTheSamePerson(resultat_controle_ligne) {
            //console.log(' resultat_controle_ligne.controle_resultat_id,resultat_controle_ligne.patients_id' + resultat_controle_ligne.controle_resultat_id + '-' + resultat_controle_ligne.patients_id)
            return $http.put($rootScope.api_url + 'patients/isnotthesameperson', { controle_resultat_id: resultat_controle_ligne.controle_resultat_id, patients_id: resultat_controle_ligne.patients_id }).then(OnehandleSuccess, handleError);
        }

        function IsTheSamePerson(resultat_controle_ligne, controle_resultat_type) {
            //console.log(' resultat_controle_ligne.controle_resultat_id,resultat_controle_ligne.patients_id' + resultat_controle_ligne.controle_resultat_id + '-' + resultat_controle_ligne.patients_id)
            return $http.put($rootScope.api_url + 'patients/isthesameperson', { controle_resultat_id: resultat_controle_ligne.controle_resultat_id, patients_id: resultat_controle_ligne.patients_id, controle_resultat_type: controle_resultat_type }).then(OnehandleSuccess, handleError);
        }

        function GetAllNegatifs(id) {
            return $http.get($rootScope.api_url + 'patients/negatif-patients-of-controlled-list/' + id).then(ControleSuccess, handleError);
        }

        function GetAllPositifs(id) {
            return $http.get($rootScope.api_url + 'patients/positif-patients-of-controlled-list/' + id).then(ControleSuccess, handleError);
        }


        function GetAllpatientssOfCurrentUser() {
            return $http.get($rootScope.api_url + 'patients/patients-of-current-user').then(patientsshandleSuccess, handleError);
        }

        // private functions



        function patientsshandleSuccess(result) {
            //console.log('BeneficiaireService -> : result.data' + result.data);
            return { success: true, data: result.data[0].patientss };
        }

        function ControleSuccess(result) {
            //console.log('resultat_controle : ' + JSON.stringify(result.data[0].resultat_controle));
            return {
                success: true,
                resultat_controle: result.data[0].resultat_controle,
            };
        }

        function handleError(result) {
            return { success: false, code: result.data.code, message: result.data.message };
        }
    }



})();

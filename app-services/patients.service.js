/*
A user service designed to interact with a resultTful web service to manage patients within the system.
*/
(function () {
    'use strict';

    angular
        .module('ClinicApp')
        .factory('PatientsService', PatientsService);

    PatientsService.$inject = ['$http', '$rootScope'];
    function PatientsService($http, $rootScope) {
        var service = {};

        service.Get_All_Patients = Get_All_Patients;
        service.Add_Patient = Add_Patient;
        service.Edit_Patient = Edit_Patient;

        service.Get_All_Patient_Vitals = Get_All_Patient_Vitals;
        service.Add_Patient_Vital = Add_Patient_Vital;
        service.Delete_Patient_Vital = Delete_Patient_Vital;

        service.Get_All_Patient_Pathologies = Get_All_Patient_Pathologies;
        service.Add_Patient_Pathologie = Add_Patient_Pathologie;
        service.Delete_Patient_Pathologie = Delete_Patient_Pathologie;

        service.Get_All_Patient_Radiographies = Get_All_Patient_Radiographies;
        service.Add_Patient_Radiographie = Add_Patient_Radiographie;
        service.Delete_Patient_Radiographie = Delete_Patient_Radiographie;
        service.Upload_Radio_File = Upload_Radio_File;

        service.Get_All_Patient_Traitements = Get_All_Patient_Traitements;
        service.Add_Patient_Traitement = Add_Patient_Traitement;
        service.Delete_Patient_Traitement = Delete_Patient_Traitement;


        service.Get_All_Patient_Versements = Get_All_Patient_Versements;
        service.Add_Patient_Versement = Add_Patient_Versement;
        service.Delete_Patient_Versement = Delete_Patient_Versement;

        service.get_total_actes_total_versements = get_total_actes_total_versements;

        service.Get_All_Patient_Ordonnances = Get_All_Patient_Ordonnances;
        service.Add_Patient_Ordonnance = Add_Patient_Ordonnance;
        service.Delete_Patient_Ordonnance = Delete_Patient_Ordonnance;

        service.Get_All_Patient_Certificats = Get_All_Patient_Certificats;
        service.Add_Patient_Certificat = Add_Patient_Certificat;
        service.Delete_Patient_Certificat = Delete_Patient_Certificat;

        service.Get_All_RDVs = Get_All_RDVs;
        service.Add_RDV = Add_RDV;
        service.Edit_RDV = Edit_RDV;
        service.Delete_RDV = Delete_RDV;
        /***************************************************/
        service.GetAllControlled = GetAllControlled;
        service.GetById = GetById;
        service.GetByUsername = GetByUsername;
        service.CreateGrouped = CreateGrouped;
        service.Update = Update;
        service.UpdateGrouped = UpdateGrouped;
        service.Delete = Delete;
        service.IsNotTheSamePerson = IsNotTheSamePerson;
        service.IsTheSamePerson = IsTheSamePerson;
        service.GetAllNegatifs = GetAllNegatifs;
        service.GetAllPositifs = GetAllPositifs;

        service.GetAllpatientssOfCurrentUser = GetAllpatientssOfCurrentUser;


        return service;


        function Get_All_Patients() {
            return $http.get($rootScope.api_url + 'patients/get_all_patients').then(ManyhandleSuccess, handleError);
        }

        function Add_Patient(New_Patient) {
            return $http.post($rootScope.api_url + 'patients/add_patient', New_Patient).then(ManyhandleSuccess, handleError);
        }

        function Edit_Patient(Selected_Patient) {
            return $http.put($rootScope.api_url + 'patients/edit_patient', Selected_Patient).then(ManyhandleSuccess, handleError);
        }

        /************************************* Patient_vitals *************************************/
        function Get_All_Patient_Vitals(patient_id) {
            return $http.post($rootScope.api_url + 'patients/get_all_patient_vitals', patient_id).then(ManyhandleSuccess, handleError);
        }

        function Add_Patient_Vital(patient_id, vital_id, selected_valeur) {
            return $http.post($rootScope.api_url + 'patients/add_patient_vital', { patient_id, vital_id, selected_valeur }).then(ManyhandleSuccess, handleError);
        }

        function Delete_Patient_Vital(patient_vital_id) {
            return $http.delete($rootScope.api_url + 'patients/delete_patient_vital/' + patient_vital_id).then(OnehandleSuccess, handleError);
        }
        /************************************* Patient_Pathologies *************************************/
        function Get_All_Patient_Pathologies(patient_id) {
            return $http.post($rootScope.api_url + 'patients/get_all_patient_pathologies', patient_id).then(ManyhandleSuccess, handleError);
        }

        function Add_Patient_Pathologie(patient_id, pathologie_id, severite_id, selected_explicatif) {
            return $http.post($rootScope.api_url + 'patients/add_patient_pathologie', { patient_id, pathologie_id, severite_id, selected_explicatif }).then(ManyhandleSuccess, handleError);
        }

        function Delete_Patient_Pathologie(patient_pathologie_id) {
            return $http.delete($rootScope.api_url + 'patients/delete_patient_pathologie/' + patient_pathologie_id).then(OnehandleSuccess, handleError);
        }

        /************************************* Patient_Radiographies *************************************/
        function Get_All_Patient_Radiographies(patient_id) {
            return $http.post($rootScope.api_url + 'patients/get_all_patient_radiographies', patient_id).then(ManyhandleSuccess, handleError);
        }

        function Add_Patient_Radiographie(patient_id, radiographie_id, selected_explicatif, file_name) {
            return $http.post($rootScope.api_url + 'patients/add_patient_radiographie', { patient_id, radiographie_id, selected_explicatif, file_name }).then(ManyhandleSuccess, handleError);
        }

        function Delete_Patient_Radiographie(patient_radiographie_id) {
            return $http.delete($rootScope.api_url + 'patients/delete_patient_radiographie/' + patient_radiographie_id).then(OnehandleSuccess, handleError);
        }


        function Upload_Radio_File(radio_document, fileName) {
            var fd = new FormData();
            fd.append('file', radio_document);
            fd.append('fileName', fileName);
            return $http.post($rootScope.api_url + 'patients/radio_document', fd, {
                transformRequest: angular.identity,
                headers: { 'Content-Type': undefined }
            }).then(OnehandleSuccess, handleError);
        }

        /************************************* Patient_Traitement *************************************/
        function Get_All_Patient_Traitements(patient_id) {
            return $http.post($rootScope.api_url + 'patients/get_all_patient_traitements', patient_id).then(ManyhandleSuccess, handleError);
        }

        function Add_Patient_Traitement(patient_id, Selected_Patient_Traitement_Date, Selected_Dent, Selected_Patient_Traitement_Procedure, Selected_Patient_Traitement_Acte, Selected_Patient_Traitement_Montant, Selected_Patient_Traitement_Observation) {
            return $http.post($rootScope.api_url + 'patients/add_patient_traitement', { patient_id, Selected_Patient_Traitement_Date, Selected_Dent, Selected_Patient_Traitement_Procedure, Selected_Patient_Traitement_Acte, Selected_Patient_Traitement_Montant, Selected_Patient_Traitement_Observation }).then(ManyhandleSuccess, handleError);
        }

        function Delete_Patient_Traitement(patient_traitement_id) {
            return $http.delete($rootScope.api_url + 'patients/delete_patient_traitement/' + patient_traitement_id).then(OnehandleSuccess, handleError);
        }

        /************************************* Patient_Versement *************************************/
        function Get_All_Patient_Versements(patient_id) {
            return $http.post($rootScope.api_url + 'patients/get_all_patient_versements', patient_id).then(ManyhandleSuccess, handleError);
        }

        function Add_Patient_Versement(patient_id, Selected_Patient_Versement_Date, Selected_Patient_Versement_Montant, Selected_Type, Selected_Patient_Versement_Observation) {
            return $http.post($rootScope.api_url + 'patients/add_patient_versement', { patient_id, Selected_Patient_Versement_Date, Selected_Patient_Versement_Montant, Selected_Type, Selected_Patient_Versement_Observation }).then(ManyhandleSuccess, handleError);
        }

        function Delete_Patient_Versement(patient_versement_id) {
            return $http.delete($rootScope.api_url + 'patients/delete_patient_versement/' + patient_versement_id).then(OnehandleSuccess, handleError);
        }

        function get_total_actes_total_versements(patient_id) {
            return $http.post($rootScope.api_url + 'patients/get_total_actes_total_versements', patient_id).then(ManyhandleSuccess, handleError);
        }

        /************************************* Patient_Ordonnance *************************************/
        function Get_All_Patient_Ordonnances(patient_id) {
            return $http.post($rootScope.api_url + 'patients/get_all_patient_ordonnances', patient_id).then(ManyhandleSuccess, handleError);
        }

        function Add_Patient_Ordonnance(patient_id, Selected_Patient_Ordonnance_Date, Selected_Patient_Ordonnance_Numero, Selected_Patient_Ordonnance_Details, Selected_Patient_Ordonnance_Observation) {
            return $http.post($rootScope.api_url + 'patients/add_patient_ordonnance', { patient_id, Selected_Patient_Ordonnance_Date, Selected_Patient_Ordonnance_Numero, Selected_Patient_Ordonnance_Details, Selected_Patient_Ordonnance_Observation }).then(ManyhandleSuccess, handleError);
        }

        function Delete_Patient_Ordonnance(patient_ordonnance_id) {
            return $http.delete($rootScope.api_url + 'patients/delete_patient_ordonnance/' + patient_ordonnance_id).then(OnehandleSuccess, handleError);
        }

        /************************************* Patient_Certificat *************************************/
        function Get_All_Patient_Certificats(patient_id) {
            return $http.post($rootScope.api_url + 'patients/get_all_patient_certificats', patient_id).then(ManyhandleSuccess, handleError);
        }

        function Add_Patient_Certificat(patient_id, Selected_Patient_Certificat_Date, Selected_Patient_Certificat_Numero,Selected_Patient_Certificat_certificat_motifs_id, Selected_Patient_Certificat_Observation) {
            return $http.post($rootScope.api_url + 'patients/add_patient_certificat', { patient_id, Selected_Patient_Certificat_Date, Selected_Patient_Certificat_Numero,Selected_Patient_Certificat_certificat_motifs_id, Selected_Patient_Certificat_Observation }).then(ManyhandleSuccess, handleError);
        }

        function Delete_Patient_Certificat(patient_certificat_id) {
            return $http.delete($rootScope.api_url + 'patients/delete_patient_certificat/' + patient_certificat_id).then(OnehandleSuccess, handleError);
        }

        /************************************* Patient_RDV *************************************/
        function Get_All_RDVs() {
            return $http.post($rootScope.api_url + 'patients/Get_All_RDVs').then(ManyhandleSuccess, handleError);
        }

        function Add_RDV(patient_id, Selected_Patient_RDV_title, Selected_Patient_RDV_Motif_id, Selected_Patient_RDV_Color, Selected_Patient_RDV_Etat, Selected_Patient_RDV_startsAt, Selected_Patient_RDV_endsAt) {
            return $http.post($rootScope.api_url + 'patients/Add_RDV', { patient_id, Selected_Patient_RDV_title, Selected_Patient_RDV_Motif_id, Selected_Patient_RDV_Color, Selected_Patient_RDV_Etat, Selected_Patient_RDV_startsAt, Selected_Patient_RDV_endsAt }).then(ManyhandleSuccess, handleError);
        }

        function Edit_RDV(Selected_Patient_id, Selected_Patient_RDV_id, Selected_Patient_RDV_startsAt, Selected_Patient_RDV_endsAt, Selected_Patient_RDV_etat_id) {
            return $http.put($rootScope.api_url + 'patients/Edit_RDV', { Selected_Patient_id, Selected_Patient_RDV_id, Selected_Patient_RDV_startsAt, Selected_Patient_RDV_endsAt, Selected_Patient_RDV_etat_id }).then(ManyhandleSuccess, handleError);
        }

        function Delete_RDV(patient_rdv_id) {
            return $http.delete($rootScope.api_url + 'patients/Delete_RDV/' + patient_rdv_id).then(ManyhandleSuccess, handleError);
        }

        /**************************************************************************************************************/
        function OnehandleSuccess(result) {
            return { success: true, data: result.data[0] };
        }

        function ManyhandleSuccess(result) {
            //console.log('PatientsService -> : result.data' + JSON.stringify(result.data));
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
            //console.log('PatientsService -> : user : ' + user);
            //console.log('PatientsService -> : JSON.stringify(user) : ' + JSON.stringify(user));
            return $http.put($rootScope.api_url + 'patients/update', user).then(OnehandleSuccess, handleError);
        }

        function UpdateGrouped(patientss) {
            //console.log('PatientsService -> : patientss : ' + patientss);
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

(function () {
    'use strict';
    angular
        .module('ClinicApp')
        .controller('SalleAttenteController', SalleAttenteController);

    SalleAttenteController.$inject = ['$rootScope', 'PatientsService', '$route', '$templateCache', 'filterFilter', '$timeout', '$compile', 'moment', 'calendarConfig'];
    function SalleAttenteController($rootScope, PatientsService, $route, $templateCache, filterFilter, $timeout, $compile, moment, calendarConfig) {
        var vm = this;

        vm.Add_Patient = Add_Patient;
        vm.Select_Patient_For_Edit = Select_Patient_For_Edit;
        vm.Edit_Patient = Edit_Patient;
        vm.SelectPatientForRDV = SelectPatientForRDV;
        vm.timespanClicked = timespanClicked;


        vm.closeModal = closeModal;
        /*****************************************************************/
        initController();

        function initController() {
            $rootScope.active_menu = 'salle_attente';
            vm.calendarView = 'day';


            $rootScope.Loading_App_Configs();
        }


        /***************************************************************************************************************/
        //Ajouter un nouveau patient
        function Add_Patient(New_Patient, Modal_ID, is_Submitted_Form_valid) {
            if (is_Submitted_Form_valid) {
                swal.fire({
                    title: "Confirmation",
                    text: "Êtes-vous sûr de vouloir ajouter ce patient!",
                    //type: "warning",
                    showCancelButton: true,
                    confirmButtonColor: "#DD6B55",
                    confirmButtonText: "Continuer",
                    cancelButtonText: "Annuler",

                }).then((resultConfirmation) => {
                    if (resultConfirmation.value) {
                        PatientsService.Add_Patient(New_Patient)
                            .then(function (result) {
                                if (result.success) {
                                    /*  New_Patient.id = result.data[result.data.length-1].id;
                                      New_Patient.lib = New_Patient.nom + ' ' + New_Patient.prenom + ' ' + New_Patient.date_naiss
                                      New_Patient.active = true;
                                      New_Patient.created = new Date();
                                      New_Patient.cree_par = $rootScope.user.lname + ' ' + $rootScope.user.fname;
                                      New_Patient.age = $rootScope.CalculateAge(New_Patient.date_naiss);
                                      New_Patient.is_adult = $rootScope.IsAdult(New_Patient.date_naiss);
  
                                      vm.Added_Patient = angular.copy(New_Patient);
                                      $rootScope.All_Patients.push(vm.Added_Patient)
                                      //MainService.Get_All_Patients();
                                      console.log('vm.Added_Patient : ' + JSON.stringify(vm.Added_Patient));
  
                                      vm.Selected_Patient_RDV = vm.Added_Patient;
                                    */
                                    $rootScope.All_Patients = result.data;
                                    angular.element(Modal_ID).modal('hide');
                                    $('#Add_RDV_Modal').trigger("reset");
                                    New_Patient = null;

                                    //loadallImportedPatients();
                                    toastr.success('Patient insérée avec succés');
                                }
                                else {
                                    toastr.error(result.message, 'Erreur : ' + result.code);
                                }

                            }, function (result) {
                                // this function handles error
                                //console.log('SalleAttenteController -> users error : ' + result);
                                toastr.error('Erreur apparue lors de l\'insertion');

                            })//.catch(angular.noop);
                            .catch(function (error) {
                                // handle errors
                                //console.log('SalleAttenteController -> Un probleme est survenu : ' + error);
                                toastr.error('Erreur apparue lors de l\'insertion');
                            });
                    } else {
                        swal.close();
                    }

                })
            } else {
                toastr.error('Veuillez vérifier la validité des données saisies');

            }
        }

        function Select_Patient_For_Edit() {
            vm.Edited_Patient = angular.copy(vm.Selected_Patient);
        }

        //Modifier une fiche patient
        function Edit_Patient(Edited_Patient, Modal_ID, is_Submitted_Form_valid) {
            if (is_Submitted_Form_valid) {
                swal.fire({
                    title: "Confirmation",
                    text: "Êtes-vous sûr de vouloir modifier la fiche de ce patient!",
                    //type: "warning",
                    showCancelButton: true,
                    confirmButtonColor: "#DD6B55",
                    confirmButtonText: "Continuer",
                    cancelButtonText: "Annuler",

                }).then((resultConfirmation) => {
                    if (resultConfirmation.value) {

                        PatientsService.Edit_Patient(Edited_Patient)
                            .then(function (result) {
                                if (result.success) {
                                    vm.Selected_Patient = Edited_Patient
                                    $rootScope.All_Patients[vm.Selected_index] = Edited_Patient
                                    angular.element(Modal_ID).modal('hide');

                                    //loadallImportedPatients();
                                    toastr.success('Fiche patient modifiée avec succés');
                                }
                                else {
                                    toastr.error(result.message, 'Erreur : ' + result.code);
                                }

                            }, function (result) {
                                // this function handles error
                                //console.log('SalleAttenteController -> users error : ' + result);
                                toastr.error('Erreur apparue lors de l\'insertion');

                            })//.catch(angular.noop);
                            .catch(function (error) {
                                // handle errors
                                //console.log('SalleAttenteController -> Un probleme est survenu : ' + error);
                                toastr.error('Erreur apparue lors de l\'insertion');
                            });
                    } else {
                        swal.close();
                    }

                })
            } else {
                toastr.error('Veuillez vérifier la validité des données saisies');

            }
        }

        function SelectPatientForRDV(patient) {
            console.log('patient' + patient);
            vm.Selected_Patient_RDV = JSON.parse(patient);
            console.log('Selected_Patient_RDV ' + vm.Selected_Patient_RDV);
        }
        /******************************************** PatientRDVTable *************************************************/
        vm.Selected_Patient_RDV_startsAt = new Date(new Date().getFullYear(), new Date().getMonth(), new Date().getDate(), '08', '00');
        vm.Selected_Patient_RDV_startOpen = false;
        vm.Selected_Patient_RDV_endOpen = false;
        $rootScope.startsAt_Changed = function () {
            vm.Selected_Patient_RDV_endsAt = new Date(vm.Selected_Patient_RDV_startsAt.getFullYear(),
                vm.Selected_Patient_RDV_startsAt.getMonth(), vm.Selected_Patient_RDV_startsAt.getDate(),
                vm.Selected_Patient_RDV_startsAt.getHours(), vm.Selected_Patient_RDV_startsAt.getMinutes() + 30);
        }

        function timespanClicked(modal_id, date, cell) {
            //console.log("$rootScope.calendarView " + $rootScope.calendarView + " date " + JSON.stringify(date))

            if ($rootScope.calendarView === 'day') {
                $rootScope.cellIsOpen = true;
                $rootScope.viewDate = date;
            }
            else if ($rootScope.calendarView === 'month') {
                if (($rootScope.cellIsOpen && moment(date).startOf('day').isSame(moment($rootScope.viewDate).startOf('day'))) || !cell || !cell.inMonth) {
                    $rootScope.cellIsOpen = false;
                } else {
                    $rootScope.cellIsOpen = true;
                    $rootScope.viewDate = date;
                }


            } else if ($rootScope.calendarView === 'year') {
                if (($rootScope.cellIsOpen && moment(date).startOf('month').isSame(moment($rootScope.viewDate).startOf('month'))) || !cell) {
                    $rootScope.cellIsOpen = false;
                } else {
                    $rootScope.cellIsOpen = true;
                    $rootScope.viewDate = date;
                }
            }

            //vm.Show_Add_Patient_RDV_Form = true;
            $(modal_id).modal('show');

            vm.Selected_Patient_RDV_Color = { "primary": $rootScope.getRandomColor(), "secondary": $rootScope.getRandomColor() };
            vm.Selected_Patient_RDV_Color.secondary = vm.Selected_Patient_RDV_Color.primary;

            var selected_Calendar_Date = new Date(date);
            //console.log("selected_Calendar_Date.getHours()" + selected_Calendar_Date.getHours())
            if (selected_Calendar_Date.getHours() === 0) {
                vm.Selected_Patient_RDV_startsAt = new Date(selected_Calendar_Date.getFullYear(),
                    selected_Calendar_Date.getMonth(), selected_Calendar_Date.getDate(),
                    '08', selected_Calendar_Date.getMinutes());
            } else {
                vm.Selected_Patient_RDV_startsAt = new Date(selected_Calendar_Date.getFullYear(),
                    selected_Calendar_Date.getMonth(), selected_Calendar_Date.getDate(),
                    selected_Calendar_Date.getHours(), selected_Calendar_Date.getMinutes());
            }
            vm.Selected_Patient_RDV_endsAt = new Date(vm.Selected_Patient_RDV_startsAt.getFullYear(),
                vm.Selected_Patient_RDV_startsAt.getMonth(), vm.Selected_Patient_RDV_startsAt.getDate(),
                vm.Selected_Patient_RDV_startsAt.getHours(), vm.Selected_Patient_RDV_startsAt.getMinutes() + 30);

        };

        $rootScope.Labels_PatientRDVsTable = ['Titre', 'Début le', 'Termine le', 'Supprimer',]


        //Ask for confirmation before closing modal
        function closeModal() {
            console.info("closeModal");
            if (vm.listePost_id !== null) {
                swal.fire({
                    title: "Confirmation",
                    text: "Êtes-vous sûr de vouloir continuer cette opération!",
                    //type: "warning",
                    showCancelButton: true,
                    confirmButtonColor: "#DD6B55",
                    confirmButtonText: "Continuer",
                    cancelButtonText: "Annuler",

                }).then((result) => {
                    if (result.value) {

                        vm.Selected_Patients = null;
                        vm.patients = [];

                        vm.modal_action = "Suivant";
                        vm.active_tab = 'list';
                        vm.listePost_id = null;
                        loadallImportedPatients();
                        angular.element('#add_Patients_modal').modal('hide');
                        toastr.info('N\'oubliez pas de charger les patients ultérieurement');
                    } else {
                        swal.close();
                    }
                })
            } else {
                angular.element('#add_Patients_modal').modal('hide');
            }
        }
    }

})();
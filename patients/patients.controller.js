(function () {
    'use strict';
    angular
        .module('ClinicApp')
        .controller('PatientsController', PatientsController);

    PatientsController.$inject = ['$rootScope', 'MainService', 'PatientsService', '$route', '$templateCache', 'filterFilter', '$timeout', '$compile', 'alert', 'moment', 'calendarConfig'];
    function PatientsController($rootScope, MainService, PatientsService, $route, $templateCache, filterFilter, $timeout, $compile, alert, moment, calendarConfig) {
        var vm = this;
        
        $rootScope.selected_row = 0;//Pour colorer la ligne selectionnée 'table-info': selected_row === Patients.id 
        vm.Selected_Patient = null;//Le patient selectionné dans la table patients

        vm.Select_A_Patient_Menu = Select_A_Patient_Menu;
        /***/
        //Get_All_Patients  est déplacé dans main.service
        vm.Refresh_Patients_Array = Refresh_Patients_Array;
        vm.Add_Patient = Add_Patient;
        vm.Select_Patient_For_Edit = Select_Patient_For_Edit;//utiliser avec angular.copy 
        vm.Edit_Patient = Edit_Patient;
        /***/
        vm.All_Patient_Vitals = [];
        vm.Get_All_Patient_Vitals = Get_All_Patient_Vitals;
        vm.Add_Patient_Vital = Add_Patient_Vital;
        vm.Delete_Patient_Vital = Delete_Patient_Vital;
        /***/
        vm.All_Patient_Pathologies = [];
        vm.Get_All_Patient_Pathologies = Get_All_Patient_Pathologies;
        vm.Add_Patient_Pathologie = Add_Patient_Pathologie;
        vm.Delete_Patient_Pathologie = Delete_Patient_Pathologie;
        /***/
        vm.All_Patient_Radiographies = [];
        vm.radio_file_url = null;
        $rootScope.Selected_Radiographie = 0;
        vm.Get_All_Patient_Radiographies = Get_All_Patient_Radiographies;
        vm.Add_Patient_Radiographie = Add_Patient_Radiographie;
        vm.Delete_Patient_Radiographie = Delete_Patient_Radiographie;
        vm.Show_Radiographie_Document = Show_Radiographie_Document;//initialiser vm.radio_file_url dans le modal de visualisation 
        /***/
        vm.All_Patient_Traitements = [];
        vm.Selected_Dent = null;
        vm.Show_Add_Patient_Traitement_Form = false;
        vm.Get_All_Patient_Traitements = Get_All_Patient_Traitements;
        vm.Add_Patient_Traitement = Add_Patient_Traitement;
        vm.Delete_Patient_Traitement = Delete_Patient_Traitement;
        vm.Search_Dent_In_Array = Search_Dent_In_Array;//Trouver le numéro de la dent dans vm.Already_Treated_Dents
        vm.Show_Adult_Child_Dents = Show_Adult_Child_Dents;//Si patient <18 => afficher les dens $rootScope.dents avec filtre 
        /***/
        vm.All_Patient_Versements = [];
        vm.Show_Add_Patient_Versement_Form = false;
        vm.Get_All_Patient_Versements = Get_All_Patient_Versements;
        vm.Add_Patient_Versement = Add_Patient_Versement;
        vm.Delete_Patient_Versement = Delete_Patient_Versement;

        vm.Patient_Total_Montants_actes = 0;
        vm.Patient_Total_Versement = 0;
        vm.Patient_Total_Reste = 0;
        vm.get_total_actes_total_versements = get_total_actes_total_versements;
        /***/
        vm.All_Patient_Ordonnances = [];
        vm.Selected_Patient_Ordonnance_Details = [];
        vm.Show_Add_Patient_Ordonnance_Form = false;
        vm.Get_All_Patient_Ordonnances = Get_All_Patient_Ordonnances;
        vm.Add_Patient_Ordonnance = Add_Patient_Ordonnance;
        vm.Delete_Patient_Ordonnance = Delete_Patient_Ordonnance;
        vm.Add_New_Object2Array = Add_New_Object2Array;//add new ligne(medicament,posologie) to vm.Selected_Patient_Ordonnance_Details
        vm.Afficher_Ordonnance = Afficher_Ordonnance;
        /***/
        vm.All_Patient_Certificats = [];
        vm.Selected_Patient_Certificat_Details = [];
        vm.Show_Add_Patient_Certificat_Form = false;
        vm.Get_All_Patient_Certificats = Get_All_Patient_Certificats;
        vm.Add_Patient_Certificat = Add_Patient_Certificat;
        vm.Delete_Patient_Certificat = Delete_Patient_Certificat;
        /***/
        vm.Selected_Patient_RDV_Details = [];
        vm.Show_Add_Patient_RDV_Form = false;
        vm.timespanClicked = timespanClicked;
        /***/

        initController();

        function initController() {
            $rootScope.active_menu = 'patients';
            vm.calendarView = 'month';
            $rootScope.Loading_App_Configs();
        }


        function Select_A_Patient_Menu(menu) {
            vm.Selected_Patient_Menu = menu;
        }
        /***************************************************************************************************************/
        function Refresh_Patients_Array() {
            $rootScope.All_Patients = [];
            PatientsService.Get_All_Patients()
                .then(function (result) {
                    if (result.success) {
                        $rootScope.All_Patients = result.data;
                        vm.filterTextMainTable = '';
                        vm.Selected_Patient = null;
                        $rootScope.selected_row = null;
                    }
                    else {
                        toastr.error(result.message, 'Erreur : ' + result.code);
                    }
                }, function (result) {
                    //console.log('SalleAttenteController -> users error : ' + result);
                })
                .catch(function (error) {
                    //console.log('SalleAttenteController -> Un probleme est survenu : ' + error);
                });

        }
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
                                    vm.Select_A_Patient_Menu('patients');
                                    /*
                                                                        New_Patient.id = result.data.id;
                                                                        New_Patient.active = true;
                                                                        New_Patient.created = new Date();
                                                                        New_Patient.cree_par = $rootScope.user.lname + ' ' + $rootScope.user.fname;
                                                                        New_Patient.age = $rootScope.CalculateAge(New_Patient.date_naiss);
                                                                        New_Patient.is_adult = $rootScope.IsAdult(New_Patient.date_naiss);
                                    
                                                                        vm.Added_Patient = angular.copy(New_Patient);
                                                                        $rootScope.All_Patients.push(vm.Added_Patient)
                                    */
                                    //MainService.Get_All_Patients();
                                    //Set added patient as selected in table
                                    vm.filterTextMainTable = '';//Vider le filtre pour afficher tous rows
                                    $rootScope.All_Patients = result.data;
                                    vm.Selected_Patient = result.data[result.data.length - 1];
                                    $rootScope.selected_row = result.data[result.data.length - 1].id



                                    //vm.Selected_Patient = $rootScope.All_Patients[$rootScope.All_Patients.length - 1];
                                    //Go To Last Page
                                    $rootScope.currentPageMainTable = Math.ceil($rootScope.All_Patients.length / $rootScope.itemsPerPageMainTable);



                                    //Scroll to the end of page
                                    $("html, body").animate({ scrollTop: $(document).height() - $(window).height() });

                                    angular.element(Modal_ID).modal('hide');
                                    $('#Add_Patients_Form').trigger("reset");
                                    New_Patient = null;

                                    //loadallImportedPatients();
                                    toastr.success('Patient insérée avec succés');
                                }
                                else {
                                    toastr.error(result.message, 'Erreur : ' + result.code);
                                }

                            }, function (result) {
                                // this function handles error
                                console.log('PatientsController -> users error : ' + result);
                                toastr.error('Erreur apparue lors de l\'insertion');

                            })//.catch(angular.noop);
                            .catch(function (error) {
                                // handle errors
                                console.log('PatientsController -> Un probleme est survenu : ' + error);
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

        function Select_Patient_For_Edit(patient, index) {
            console.log('index ' + index)
            vm.Edited_Patient = angular.copy(patient);
            $rootScope.CommunesOfWilaya(vm.Edited_Patient.wilaya_id); //To load list of communes
            vm.add2selectionMainTable(patient, index)
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
                                    $rootScope.All_Patients = result.data;
                                    for (var i = 0; i < $rootScope.All_Patients.length; i++) {
                                        if ($rootScope.All_Patients[i].id == Edited_Patient.id) {
                                            $rootScope.All_Patients[i] = Edited_Patient;
                                            vm.Selected_Patient = Edited_Patient
                                            $rootScope.selected_row = Edited_Patient.id
                                            //vm.Selected_index = index;
                                        }
                                    }

                                    angular.element(Modal_ID).modal('hide');

                                    //loadallImportedPatients();
                                    toastr.success('Fiche patient modifiée avec succés');
                                }
                                else {
                                    toastr.error(result.message, 'Erreur : ' + result.code);
                                }

                            }, function (result) {
                                // this function handles error
                                console.log('PatientsController -> users error : ' + result);
                                toastr.error('Erreur apparue lors de l\'insertion');

                            })//.catch(angular.noop);
                            .catch(function (error) {
                                // handle errors
                                console.log('PatientsController -> Un probleme est survenu : ' + error);
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

        /************************************** PatientVitalsTable ****************************************/
        $rootScope.Labels_PatientVitalsTable = ['N°', 'Signes vitaux', 'Valeurs et précisions', 'Supprimer',]

        function Get_All_Patient_Vitals() {
            vm.All_Patient_Vitals = [];
            PatientsService.Get_All_Patient_Vitals(vm.Selected_Patient.id)
                .then(function (result) {
                    if (result.success) {
                        vm.All_Patient_Vitals = result.data;
                        toastr.success("Vitals chargées avec succés");
                    }
                    else {
                        toastr.error(result.message, 'Erreur : ' + result.code);
                    }
                }, function (result) {
                    // this function handles error
                    console.log('UsersController -> users error : ' + result);
                })//.catch(angular.noop);
                .catch(function (error) {
                    // handle errors
                    console.log('UsersController -> Un probleme est survenu : ' + error);
                });
        }

        function Add_Patient_Vital(Selected_Vital, Selected_Valeur) {
            PatientsService.Add_Patient_Vital(vm.Selected_Patient.id, Selected_Vital, Selected_Valeur)
                .then(function (result) {
                    if (result.success) {
                        console.log("xxxxxxxx" + JSON.stringify(result.data))
                        vm.All_Patient_Vitals = result.data;
                        vm.Selected_Vital = null;
                        vm.Selected_Severite = null;
                        vm.Selected_Explicatif = null;
                        $('#Patient_Vitals_Form').trigger("reset");
                        //Scroll to the end of page
                        $("html, body").animate({ scrollTop: $(document).height() - $(window).height() });
                        toastr.success("Vitals ajoutée avec succés");
                    }
                    else {
                        toastr.error(result.message, 'Erreur : ' + result.code);
                    }
                }, function (result) {
                    // this function handles error
                    console.log('UsersController -> users error : ' + result);
                })//.catch(angular.noop);
                .catch(function (error) {
                    // handle errors
                    console.log('UsersController -> Un probleme est survenu : ' + error);
                });
        }

        function Delete_Patient_Vital(patient_vital_id, index) {
            PatientsService.Delete_Patient_Vital(patient_vital_id)
                .then(function (result) {
                    if (result.success) {
                        //vm.AllUsersProduits = result.data;
                        vm.All_Patient_Vitals.splice(index, 1)
                        toastr.success("Vitals retirée avec succés");
                    }
                    else {
                        toastr.error(result.message, 'Erreur : ' + result.code);
                    }
                }, function (result) {
                    // this function handles error
                    console.log('UsersController -> users error : ' + result);
                })//.catch(angular.noop);
                .catch(function (error) {
                    // handle errors
                    console.log('UsersController -> Un probleme est survenu : ' + error);
                });
        }
        /************************************** PatientPathologiesTable ****************************************/
        $rootScope.Labels_PatientPathologiesTable = ['N°', 'Pathologie', 'Severite', 'Explicatif', 'Supprimer',]

        function Get_All_Patient_Pathologies() {
            vm.All_Patient_Pathologies = [];
            PatientsService.Get_All_Patient_Pathologies(vm.Selected_Patient.id)
                .then(function (result) {
                    if (result.success) {
                        vm.All_Patient_Pathologies = result.data;
                        toastr.success("Pathologies chargées avec succés");
                    }
                    else {
                        toastr.error(result.message, 'Erreur : ' + result.code);
                    }
                }, function (result) {
                    // this function handles error
                    console.log('UsersController -> users error : ' + result);
                })//.catch(angular.noop);
                .catch(function (error) {
                    // handle errors
                    console.log('UsersController -> Un probleme est survenu : ' + error);
                });
        }

        function Add_Patient_Pathologie(Selected_Pathologie, Selected_Severite, Selected_Explicatif) {
            PatientsService.Add_Patient_Pathologie(vm.Selected_Patient.id, Selected_Pathologie, Selected_Severite, Selected_Explicatif)
                .then(function (result) {
                    if (result.success) {
                        console.log("xxxxxxxx" + JSON.stringify(result.data))
                        vm.All_Patient_Pathologies = result.data;
                        vm.Selected_Pathologie = null;
                        vm.Selected_Severite = null;
                        vm.Selected_Explicatif = null;
                        $('#Patient_Pathologies_Form').trigger("reset");
                        //Scroll to the end of page
                        $("html, body").animate({ scrollTop: $(document).height() - $(window).height() });
                        toastr.success("Pathologies ajoutée avec succés");
                    }
                    else {
                        toastr.error(result.message, 'Erreur : ' + result.code);
                    }
                }, function (result) {
                    // this function handles error
                    console.log('UsersController -> users error : ' + result);
                })//.catch(angular.noop);
                .catch(function (error) {
                    // handle errors
                    console.log('UsersController -> Un probleme est survenu : ' + error);
                });
        }

        function Delete_Patient_Pathologie(patient_pathologie_id, index) {
            PatientsService.Delete_Patient_Pathologie(patient_pathologie_id)
                .then(function (result) {
                    if (result.success) {
                        //vm.AllUsersProduits = result.data;
                        vm.All_Patient_Pathologies.splice(index, 1)
                        toastr.success("Pathologies retirée avec succés");
                    }
                    else {
                        toastr.error(result.message, 'Erreur : ' + result.code);
                    }
                }, function (result) {
                    // this function handles error
                    console.log('UsersController -> users error : ' + result);
                })//.catch(angular.noop);
                .catch(function (error) {
                    // handle errors
                    console.log('UsersController -> Un probleme est survenu : ' + error);
                });
        }

        /************************************** PatientRadiographiesTable ****************************************/
        $rootScope.Labels_PatientRadiographiesTable = ['N°', 'Radiographie', 'Explicatif', 'Afficher', 'Supprimer',]

        function Get_All_Patient_Radiographies() {
            vm.All_Patient_Radiographies = [];
            PatientsService.Get_All_Patient_Radiographies(vm.Selected_Patient.id)
                .then(function (result) {
                    if (result.success) {
                        vm.All_Patient_Radiographies = result.data;
                        toastr.success("Radiographies chargées avec succés");
                    }
                    else {
                        toastr.error(result.message, 'Erreur : ' + result.code);
                    }
                }, function (result) {
                    // this function handles error
                    console.log('UsersController -> users error : ' + result);
                })//.catch(angular.noop);
                .catch(function (error) {
                    // handle errors
                    console.log('UsersController -> Un probleme est survenu : ' + error);
                });
        }

        function Add_Patient_Radiographie(Selected_Radiographie_id, Selected_Explicatif, radio_document) {
            var file_name = $('#radio_document').val().replace(/C:\\fakepath\\/i, '');
            // grab the extension
            if (file_name) {
                var fileExtension = '.' + file_name.split('.').pop();
                console.log('file_name' + file_name + ' fileExtension ' + fileExtension)
                // rename the file with a sufficiently random value and add the file extension back
                //vm.SelectedRecours.file_name = Math.random().toString(36).substring(7) + new Date().getTime() + fileExtension;
                var file_name = 'radio_' + vm.Selected_Patient.id + '_' + Selected_Radiographie_id + '_' + $rootScope.TodayDate() + fileExtension;
            }
            PatientsService.Add_Patient_Radiographie(vm.Selected_Patient.id, Selected_Radiographie_id, Selected_Explicatif, file_name)
                .then(function (result) {
                    if (result.success) {
                        console.log("xxxxxxxx" + JSON.stringify(result.data))
                        vm.All_Patient_Radiographies = result.data;

                        toastr.success("Radiographies ajoutée avec succés");
                        if (file_name) {
                            //Inséré radio document
                            PatientsService.Upload_Radio_File(radio_document, file_name).
                                then(function (result_file) {
                                    if (result_file.success) {
                                        //Scroll to the end of page
                                        $("html, body").animate({ scrollTop: $(document).height() - $(window).height() });
                                        toastr.success('Radio insérée avec succès');
                                        // document.getElementById('radio_document').reset();
                                    }
                                    else {
                                        toastr.error('Problème lors de l\'insertion du document')
                                    }
                                })
                                .then(function (result_file) {
                                    console.log("error!! " + JSON.stringify(result_file));
                                });
                        }

                        $rootScope.Selected_Radiographie = null;
                        vm.Selected_Explicatif = null;
                        vm.radio_file_url = null;
                        $('#Patient_Radiographies_Form').trigger("reset");
                    }
                    else {
                        toastr.error(result.message, 'Erreur : ' + result.code);
                    }
                }, function (result) {
                    // this function handles error
                    console.log('UsersController -> users error : ' + result);
                })//.catch(angular.noop);
                .catch(function (error) {
                    // handle errors
                    console.log('UsersController -> Un probleme est survenu : ' + error);
                });
        }

        function Delete_Patient_Radiographie(patient_radiographie_id, index) {
            PatientsService.Delete_Patient_Radiographie(patient_radiographie_id)
                .then(function (result) {
                    if (result.success) {
                        //vm.AllUsersProduits = result.data;
                        vm.All_Patient_Radiographies.splice(index, 1)
                        toastr.success("Radiographies retirée avec succés");
                    }
                    else {
                        toastr.error(result.message, 'Erreur : ' + result.code);
                    }
                }, function (result) {
                    // this function handles error
                    console.log('UsersController -> users error : ' + result);
                })//.catch(angular.noop);
                .catch(function (error) {
                    // handle errors
                    console.log('UsersController -> Un probleme est survenu : ' + error);
                });
        }

        function Show_Radiographie_Document(radio_file_name) {
            console.log('radio_file_name ' + radio_file_name);
            if (radio_file_name) { vm.radio_file_url = 'patients/radiographies/' + radio_file_name; }
            $rootScope.magnify("radio_image", $rootScope.ZoomImageDegree);
        }

        /************************************** PatientTraitementsTable ****************************************/
        $rootScope.Labels_PatientTraitementsTable = ['Effectué le', 'Dent', 'Procedure', 'Acte', 'Coût(DA)', 'Observations', 'Supprimer',]

        function Get_All_Patient_Traitements() {
            vm.Show_Add_Patient_Traitement_Form = false;
            //Select Default dental Schema
            vm.Show_Adult_Child_Dents(vm.Selected_Patient.is_adult)

            vm.All_Patient_Traitements = [];
            PatientsService.Get_All_Patient_Traitements(vm.Selected_Patient.id)
                .then(function (result) {
                    if (result.success) {
                        vm.All_Patient_Traitements = result.data;
                        vm.All_Patient_Traitements_Total = $rootScope.Calculate_Sum_Array(vm.All_Patient_Traitements);

                        vm.Already_Treated_Dents = [];

                        if (vm.All_Patient_Traitements) {
                            vm.Already_Treated_Dents
                                = vm.All_Patient_Traitements.map(function (result) {
                                    return {
                                        dent: result.dent_num,
                                    }
                                });
                        }

                        toastr.success("Traitements chargées avec succés ");
                    }
                    else {
                        toastr.error(result.message, 'Erreur : ' + result.code);
                    }
                }, function (result) {
                    // this function handles error
                    console.log('UsersController -> users error : ' + result);
                })//.catch(angular.noop);
                .catch(function (error) {
                    // handle errors
                    console.log('UsersController -> Un probleme est survenu : ' + error);
                });
        }

        function Add_Patient_Traitement(Is_Valid_Form, Selected_Patient_Traitement_Date, Selected_Patient_Traitement_Procedure, Selected_Patient_Traitement_Acte, Selected_Patient_Traitement_Montant, Selected_Patient_Traitement_Observation) {
            if (Is_Valid_Form) {
                //Supprimer le formatage du montant
                if (Selected_Patient_Traitement_Montant) {
                    Selected_Patient_Traitement_Montant = Selected_Patient_Traitement_Montant.toString().replaceAll(' ', '');
                }
                else {
                    Selected_Patient_Traitement_Montant = 0;
                }
                PatientsService.Add_Patient_Traitement(vm.Selected_Patient.id, Selected_Patient_Traitement_Date, vm.Selected_Dent, Selected_Patient_Traitement_Procedure, Selected_Patient_Traitement_Acte, Selected_Patient_Traitement_Montant, Selected_Patient_Traitement_Observation)
                    .then(function (result) {
                        if (result.success) {
                            console.log("xxxxxxxx" + JSON.stringify(result.data))
                            vm.All_Patient_Traitements = result.data;
                            vm.All_Patient_Traitements_Total = $rootScope.Calculate_Sum_Array(vm.All_Patient_Traitements);

                            if (vm.All_Patient_Traitements) {
                                vm.Already_Treated_Dents
                                    = vm.All_Patient_Traitements.map(function (result) {
                                        return {
                                            dent: result.dent_num,
                                        }
                                    });
                            }

                            toastr.success("Traitement ajoutée avec succés");

                            vm.Selected_Dent = null;
                            vm.Selected_Patient_Traitement_Procedure = null;
                            vm.Selected_Patient_Traitement_Acte = null;
                            $rootScope.Selected_Patient_Traitement_Montant = null;
                            vm.Selected_Patient_Traitement_Observation = null;
                            $('#Patient_Nouveau_Traitements_Form').trigger("reset");
                            vm.Show_Add_Patient_Traitement_Form = false;


                        }
                        else {
                            toastr.error(result.message, 'Erreur : ' + result.code);
                        }
                    }, function (result) {
                        // this function handles error
                        console.log('UsersController -> users error : ' + result);
                    })//.catch(angular.noop);
                    .catch(function (error) {
                        // handle errors
                        console.log('UsersController -> Un probleme est survenu : ' + error);
                    });
            }
        }

        function Delete_Patient_Traitement(patient_traitement_id, index) {
            PatientsService.Delete_Patient_Traitement(patient_traitement_id)
                .then(function (result) {
                    if (result.success) {
                        //vm.AllUsersProduits = result.data;
                        vm.All_Patient_Traitements.splice(index, 1)
                        vm.All_Patient_Traitements_Total = $rootScope.Calculate_Sum_Array(vm.All_Patient_Traitements);

                        if (vm.All_Patient_Traitements) {
                            vm.Already_Treated_Dents
                                = vm.All_Patient_Traitements.map(function (result) {
                                    return {
                                        dent: result.dent_num,
                                    }
                                });
                        }
                        vm.Selected_Dent = null;
                        toastr.success("Traitements retirée avec succés");
                    }
                    else {
                        toastr.error(result.message, 'Erreur : ' + result.code);
                    }
                }, function (result) {
                    // this function handles error
                    console.log('UsersController -> users error : ' + result);
                })//.catch(angular.noop);
                .catch(function (error) {
                    // handle errors
                    console.log('UsersController -> Un probleme est survenu : ' + error);
                });
        }

        function Search_Dent_In_Array(dent_num) {
            if (vm.Already_Treated_Dents) {
                if ((filterFilter(vm.Already_Treated_Dents, { dent: dent_num }, true)).length > 0) return true
                else return false;
            }
            else return false;
        }

        function Show_Adult_Child_Dents(isAdult) {
            vm.Selected_Patient.is_adult = isAdult;
            vm.Filtred_Dents = filterFilter($rootScope.dents, { adult: isAdult }, true);
            console.log(JSON.stringify(vm.Filtred_Dents))
        }



        /************************************** PatientOrdonnancesTable ****************************************/
        $rootScope.Labels_PatientOrdonnancesTable = ['Numéro', 'Effectué le', 'Détails', 'Observations', 'Afficher', 'Supprimer',]

        function Get_All_Patient_Ordonnances() {
            vm.Show_Add_Patient_Ordonnance_Form = false;
            vm.Selected_Patient_Ordonnance_Details.push({ 'medicament': 0, 'posologie': '', 'observation': '' });

            vm.All_Patient_Ordonnances = [];
            PatientsService.Get_All_Patient_Ordonnances(vm.Selected_Patient.id)
                .then(function (result) {
                    if (result.success) {
                        vm.All_Patient_Ordonnances = result.data;
                        vm.Selected_Patient_Ordonnance_Numero = "Ordonnance N° " + (vm.All_Patient_Ordonnances.length + 1);

                        toastr.success("Ordonnances chargées avec succés ");
                    }
                    else {
                        toastr.error(result.message, 'Erreur : ' + result.code);
                    }
                }, function (result) {
                    // this function handles error
                    console.log('UsersController -> users error : ' + result);
                })//.catch(angular.noop);
                .catch(function (error) {
                    // handle errors
                    console.log('UsersController -> Un probleme est survenu : ' + error);
                });
        }

        function Add_Patient_Ordonnance(Is_Valid_Form, Selected_Patient_Ordonnance_Date, Selected_Patient_Ordonnance_Numero, Selected_Patient_Ordonnance_Details, Selected_Patient_Ordonnance_Observation) {
            if (Is_Valid_Form) {
                if (Selected_Patient_Ordonnance_Details.length === 0) { toastr.error("Veuillez ajouter le détail de l'ordonnance"); }
                else {
                    PatientsService.Add_Patient_Ordonnance(vm.Selected_Patient.id, Selected_Patient_Ordonnance_Date, Selected_Patient_Ordonnance_Numero, Selected_Patient_Ordonnance_Details, Selected_Patient_Ordonnance_Observation)
                        .then(function (result) {
                            if (result.success) {
                                console.log("xxxxxxxx" + JSON.stringify(result.data))
                                vm.All_Patient_Ordonnances = result.data;
                                vm.Selected_Patient_Ordonnance_Numero = "Ordonnance N° " + (vm.All_Patient_Ordonnances.length + 1);
                                //Scroll to the end of page
                                $("html, body").animate({ scrollTop: $(document).height() - $(window).height() });
                                vm.Show_Add_Patient_Ordonnance_Form = false;
                                toastr.success("Ordonnance ajoutée avec succés");
                                vm.Selected_Patient_Ordonnance_Date = null;
                                vm.Selected_Patient_Ordonnance_Details = [{ 'medicament': 0, 'posologie': '', 'observation': '' }];
                                vm.Selected_Patient_Ordonnance_Observation = null;
                                $('#Patient_Nouvelle_Ordonnance_Form').trigger("reset");
                                vm.Show_Add_Patient_Ordonnance_Form = false;


                            }
                            else {
                                toastr.error(result.message, 'Erreur : ' + result.code);
                            }
                        }, function (result) {
                            // this function handles error
                            console.log('UsersController -> users error : ' + result);
                        })//.catch(angular.noop);
                        .catch(function (error) {
                            // handle errors
                            console.log('UsersController -> Un probleme est survenu : ' + error);
                        });
                }
            }
        }

        function Delete_Patient_Ordonnance(patient_ordonnance_id, index) {
            PatientsService.Delete_Patient_Ordonnance(patient_ordonnance_id)
                .then(function (result) {
                    if (result.success) {
                        //vm.AllUsersProduits = result.data;
                        vm.All_Patient_Ordonnances.splice(index, 1)
                        vm.Selected_Patient_Ordonnance_Numero = "Ordonnance N° " + (vm.All_Patient_Ordonnances.length + 1);


                        toastr.success("Ordonnances retirée avec succés");
                    }
                    else {
                        toastr.error(result.message, 'Erreur : ' + result.code);
                    }
                }, function (result) {
                    // this function handles error
                    console.log('UsersController -> users error : ' + result);
                })//.catch(angular.noop);
                .catch(function (error) {
                    // handle errors
                    console.log('UsersController -> Un probleme est survenu : ' + error);
                });
        }

        function Add_New_Object2Array(medicament) {
            vm.Selected_Patient_Ordonnance_Details.push({ 'medicament': 0, 'posologie': '', 'observation': '' });
        }

        function Afficher_Ordonnance() {
            console.log('xxxxxxxxxxxxxxxxxxxxxx Afficher_Ordonnance')
            vm.Ordonnance_Document = 'Patient_Ordonnance';
            vm.to_print_ordonnance =
                '<table class="table table-bordered" style="text-align: center;"><tbody><tr><td><br></td><td><h3 class="page-header" style="font-family: &quot;Open Sans&quot;, sans-serif; color: rgb(33, 37, 41); text-align: center; background-color: rgb(255, 255, 255);"><span class="fa fa-tooth"><br></span>&nbsp;<span style="font-weight: bolder;">Cabinet Dentaire DR.Djellouli</span></h3></td><td><br></td></tr><tr><td><br></td><td><br><h3 class="page-header" style="font-family: &quot;Open Sans&quot;, sans-serif; color: rgb(33, 37, 41); text-align: center;"><p ng-if="user.org_adresse" class="" style="line-height: 0.1;"><span style="font-weight: bolder;">Adresse :</span>&nbsp;Cité 23 logts Debdaba, route de ouakda, (Exe SNTV) Béchar</p><p ng-if="user.org_email" class="" style="line-height: 0.1;"><span style="font-weight: bolder;">Email :</span>&nbsp;h_djellouli@esi.dz</p><p ng-if="user.org_tel" class="" style="line-height: 0.1;"><span style="font-weight: bolder;">Tel :</span>&nbsp;049 83 83 86</p><p ng-if="user.org_fax" class="" style="line-height: 0.1;"><span style="font-weight: bolder;">Fax :</span>&nbsp;0555 55 55 55</p><p ng-if="user.org_site_internet" class="" style="line-height: 0.1;"><span style="font-weight: bolder;">Site web :</span>&nbsp;www.site.com</p></h3></td><td><br></td></tr><tr><td><br><p style="line-height: 0.1;"><span style="font-weight: bolder;">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; Nom :&nbsp;</span>Guermis</p><p style="line-height: 0.1;"><span style="font-weight: bolder;">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; Prénom :&nbsp;</span>Aida</p><p style="line-height: 0.1;"><span style="font-weight: bolder;">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; Age :&nbsp;</span>15 Ans</p></td><td><h1><span style="font-family: &quot;Arial Black&quot;;"><font color="#000000" style="">Ordonnance</font></span></h1></td><td style="text-align: center; "><span style="font-size: 13px; font-weight: bolder;">BECHAR</span><span style="font-size: 13px;">&nbsp;le 22/01/2021</span><br></td></tr></tbody></table><div class="row"><div class="col-12" style="width: 498.788px; text-align: center; margin: auto;"><h3 class="page-header"><br></h3></div></div><div class="row invoice-info"><div style="text-align: center;"><br></div><div class="col-sm-4 invoice-col" style="width: 166.262px; flex-basis: 33.3333%; max-width: 33.3333%; text-align: right;"><p style="text-align: center;"><span style="font-size: 16px;">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp;</span></p></div></div><p><div style="text-align: center;"><span style="font-size: 16px;"><br></span></div><div style="text-align: center;"><span style="font-size: 16px;"><br></span></div></p><div class="row" style="margin: auto; text-align: center; color: rgba(13, 105, 180, 0.686);"><h2 style="margin: auto;"><br></h2></div><p><div style="text-align: center;"><span style="font-size: 16px;"><br></span></div></p>';
        }
        /************************************** PatientCertificatsTable ****************************************/
        $rootScope.Labels_PatientCertificatsTable = ['Numéro', 'Effectué le', 'Motifs', 'Observations', 'Afficher', 'Supprimer',]

        function Get_All_Patient_Certificats() {
            vm.Show_Add_Patient_Certificat_Form = false;
            vm.Selected_Patient_Certificat_Details.push({ 'medicament': 0, 'posologie': '', 'observation': '' });

            vm.All_Patient_Certificats = [];
            PatientsService.Get_All_Patient_Certificats(vm.Selected_Patient.id)
                .then(function (result) {
                    if (result.success) {
                        vm.All_Patient_Certificats = result.data;
                        vm.Selected_Patient_Certificat_Numero = "Certificat N° " + (vm.All_Patient_Certificats.length + 1);

                        toastr.success("Certificats chargées avec succés ");
                    }
                    else {
                        toastr.error(result.message, 'Erreur : ' + result.code);
                    }
                }, function (result) {
                    // this function handles error
                    console.log('UsersController -> users error : ' + result);
                })//.catch(angular.noop);
                .catch(function (error) {
                    // handle errors
                    console.log('UsersController -> Un probleme est survenu : ' + error);
                });
        }

        function Add_Patient_Certificat(Is_Valid_Form, Selected_Patient_Certificat_Date, Selected_Patient_Certificat_Numero, Selected_Patient_Certificat_certificat_motifs_id, Selected_Patient_Certificat_Observation) {
            if (Is_Valid_Form) {

                PatientsService.Add_Patient_Certificat(vm.Selected_Patient.id, Selected_Patient_Certificat_Date, Selected_Patient_Certificat_Numero, Selected_Patient_Certificat_certificat_motifs_id, Selected_Patient_Certificat_Observation)
                    .then(function (result) {
                        if (result.success) {
                            console.log("xxxxxxxx" + JSON.stringify(result.data))
                            vm.All_Patient_Certificats = result.data;
                            vm.Selected_Patient_Certificat_Numero = "Certificat N° " + (vm.All_Patient_Certificats.length + 1);
                            //Scroll to the end of page
                            $("html, body").animate({ scrollTop: $(document).height() - $(window).height() });

                            toastr.success("Certificat ajoutée avec succés");
                            vm.Selected_Patient_Certificat_Date = null;
                            vm.Selected_Patient_Certificat_Details = [{ 'medicament': 0, 'posologie': '', 'observation': '' }];
                            vm.Selected_Patient_Certificat_Observation = null;
                            $('#Patient_Nouvelle_Certificat_Form').trigger("reset");
                            vm.Show_Add_Patient_Certificat_Form = false;


                        }
                        else {
                            toastr.error(result.message, 'Erreur : ' + result.code);
                        }
                    }, function (result) {
                        // this function handles error
                        console.log('UsersController -> users error : ' + result);
                    })//.catch(angular.noop);
                    .catch(function (error) {
                        // handle errors
                        console.log('UsersController -> Un probleme est survenu : ' + error);
                    });

            }
        }

        function Delete_Patient_Certificat(patient_certificat_id, index) {
            PatientsService.Delete_Patient_Certificat(patient_certificat_id)
                .then(function (result) {
                    if (result.success) {
                        //vm.AllUsersProduits = result.data;
                        vm.All_Patient_Certificats.splice(index, 1)
                        vm.Selected_Patient_Certificat_Numero = "Certificat N° " + (vm.All_Patient_Certificats.length + 1);


                        toastr.success("Certificats retirée avec succés");
                    }
                    else {
                        toastr.error(result.message, 'Erreur : ' + result.code);
                    }
                }, function (result) {
                    // this function handles error
                    console.log('UsersController -> users error : ' + result);
                })//.catch(angular.noop);
                .catch(function (error) {
                    // handle errors
                    console.log('UsersController -> Un probleme est survenu : ' + error);
                });
        }

        /******************************************** PatientRDVTable *************************************************/
        vm.Selected_Patient_RDV_Color = { "primary": $rootScope.getRandomColor(), "secondary": $rootScope.getRandomColor() };
        vm.Selected_Patient_RDV_Color.secondary = vm.Selected_Patient_RDV_Color.primary;

        vm.Selected_Patient_RDV_startsAt = new Date(new Date().getFullYear(), new Date().getMonth(), new Date().getDate(), '08', '00');
        vm.Selected_Patient_RDV_startOpen = false;
        vm.Selected_Patient_RDV_endOpen = false;
        $rootScope.startsAt_Changed = function () {
            vm.Selected_Patient_RDV_endsAt = new Date(vm.Selected_Patient_RDV_startsAt.getFullYear(),
                vm.Selected_Patient_RDV_startsAt.getMonth(), vm.Selected_Patient_RDV_startsAt.getDate(),
                vm.Selected_Patient_RDV_startsAt.getHours(), vm.Selected_Patient_RDV_startsAt.getMinutes() + 30);
        }

        $rootScope.Labels_PatientRDVsTable = ['Titre', 'Début le', 'Termine le', 'Supprimer',]

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


        /************************************** PatientVersementsTable ****************************************/
        $rootScope.Labels_PatientVersementsTable = ['Effectué le', 'Montant versé(DA)', 'Par', 'Observations', 'Supprimer',]

        function Get_All_Patient_Versements() {
            vm.Show_Add_Patient_Versement_Form = false;

            vm.All_Patient_Versements = [];
            PatientsService.Get_All_Patient_Versements(vm.Selected_Patient.id)
                .then(function (result) {
                    if (result.success) {
                        vm.All_Patient_Versements = result.data;
                        vm.All_Patient_Versements_Total = $rootScope.Calculate_Sum_Array(vm.All_Patient_Versements);

                        get_total_actes_total_versements();
                        toastr.success("Versements chargées avec succés ");
                    }
                    else {
                        toastr.error(result.message, 'Erreur : ' + result.code);
                    }
                }, function (result) {
                    // this function handles error
                    console.log('UsersController -> users error : ' + result);
                })//.catch(angular.noop);
                .catch(function (error) {
                    // handle errors
                    console.log('UsersController -> Un probleme est survenu : ' + error);
                });
        }

        function Add_Patient_Versement(Is_Valid_Form, Selected_Patient_Versement_Date, Selected_Patient_Versement_Montant, Selected_Type, Selected_Patient_Versement_Observation) {
            if (Is_Valid_Form) {
                //Supprimer le formatage du montant
                Selected_Patient_Versement_Montant = Selected_Patient_Versement_Montant.toString().replaceAll(' ', '');

                PatientsService.Add_Patient_Versement(vm.Selected_Patient.id, Selected_Patient_Versement_Date, Selected_Patient_Versement_Montant, Selected_Type, Selected_Patient_Versement_Observation)
                    .then(function (result) {
                        if (result.success) {
                            vm.All_Patient_Versements = result.data;
                            vm.All_Patient_Versements_Total = $rootScope.Calculate_Sum_Array(vm.All_Patient_Versements);

                            get_total_actes_total_versements();
                            //Scroll to the end of page
                            $("html, body").animate({ scrollTop: $(document).height() - $(window).height() });

                            toastr.success("Versement ajoutée avec succés");

                            vm.Selected_Patient_Versement_Montant = null;
                            vm.Selected_Patient_Versement_Observation = null;
                            $('#Patient_Nouveau_Versements_Form').trigger("reset");
                            vm.Show_Add_Patient_Versement_Form = false;


                        }
                        else {
                            toastr.error(result.message, 'Erreur : ' + result.code);
                        }
                    }, function (result) {
                        // this function handles error
                        console.log('UsersController -> users error : ' + result);
                    })//.catch(angular.noop);
                    .catch(function (error) {
                        // handle errors
                        console.log('UsersController -> Un probleme est survenu : ' + error);
                    });
            }
        }

        function Delete_Patient_Versement(patient_versement_id, index) {
            PatientsService.Delete_Patient_Versement(patient_versement_id)
                .then(function (result) {
                    if (result.success) {
                        //vm.AllUsersProduits = result.data;
                        vm.All_Patient_Versements.splice(index, 1)
                        vm.All_Patient_Versements_Total = $rootScope.Calculate_Sum_Array(vm.All_Patient_Versements);

                        get_total_actes_total_versements();
                        toastr.success("Versements retirée avec succés");
                    }
                    else {
                        toastr.error(result.message, 'Erreur : ' + result.code);
                    }
                }, function (result) {
                    // this function handles error
                    console.log('UsersController -> users error : ' + result);
                })//.catch(angular.noop);
                .catch(function (error) {
                    // handle errors
                    console.log('UsersController -> Un probleme est survenu : ' + error);
                });
        }

        //Get total couts et total versments
        function get_total_actes_total_versements() {
            vm.Patient_Total_Montants_actes = 0;
            vm.Patient_Total_Versement = 0;
            vm.Patient_Total_Reste = 0;

            PatientsService.get_total_actes_total_versements(vm.Selected_Patient.id)
                .then(function (result) {
                    if (result.success) {
                        vm.Patient_Total_Montants_actes = result.data[0].total_montant_actes;
                        vm.Patient_Total_Versement = result.data[0].total_montant_verse;
                        vm.Patient_Total_Reste = vm.Patient_Total_Montants_actes - vm.Patient_Total_Versement;
                        //toastr.success("Versements chargées avec succés ");
                    }
                    else {
                        toastr.error(result.message, 'Erreur : ' + result.code);
                    }
                }, function (result) {
                    // this function handles error
                    console.log('UsersController -> users error : ' + result);
                })//.catch(angular.noop);
                .catch(function (error) {
                    // handle errors
                    console.log('UsersController -> Un probleme est survenu : ' + error);
                });
        }
        /****************************** mainTable ************************************/
        $rootScope.labelsMainTable = ['', 'N°', 'Nom', 'Prenom', 'Date de naissance', 'N° Telephone', 'Cree le', 'Cree par', 'Active', 'Modifier',];

        vm.filterTextMainTable = '';
        $rootScope.currentPageMainTable = 1;
        $rootScope.maxSizePageMainTable = 5; //Number of pager buttons to show
        $rootScope.itemsPerPageMainTable = 10;//Must be the same as the html one ms-per-page="5"

        // Selection
        $rootScope.selected_lignesMainTable = 0;
        $rootScope.selected_lignes_arrayMainTable = [];

        vm.add2selectionMainTable = function add2selectionMainTable(patient, index) {
            $rootScope.selected_row = patient.id
            vm.Selected_Patient = patient;
            vm.Selected_index = index;
            console.log("vm.Selected_index" + vm.Selected_index + 'patient.id ' + patient.id + ' selected_row: ' + $rootScope.selected_row);
        };
        vm.pageChangedMainTable = function pageChangedMainTable() {
            console.log('PatientsController -> $rootScope.currentPage : ' + $rootScope.currentPageMainTable);
        };
        vm.sortColumnMainTable = function sortColumnMainTable(label) {
            console.log('PatientsController ->$rootScope.label : ' + label);
            $rootScope.orderByFieldMainTable = label;
            $rootScope.sortByDescendingMainTable = !$rootScope.sortByDescendingMainTable;
            console.log('PatientsController ->$rootScope.sortByDescendingMainTable : ' + $rootScope.sortByDescendingMainTable);
        };
        vm.setItemsPerPageMainTable = function setItemsPerPageMainTable(num) {
            $rootScope.itemsPerPageMainTable = num;
            $rootScope.currentPageMainTable = 1; //reset to first page
            console.log('PatientsController -> itemsPerPage : ' + $rootScope.itemsPerPageMainTable);
            console.log('PatientsController -> itemsPerPageMainTable:itemsPerPageMainTable*(currentPageMainTable-1) : ' + $rootScope.itemsPerPageMainTable * ($rootScope.currentPageMainTable - 1))
        }
        vm.setPage = function setPage(pageNo) {
            $rootScope.currentPageMainTable = pageNo;
        };

    }
})();
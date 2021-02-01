(function () {
    'use strict';
    angular
        .module('ClinicApp')
        .controller('CaisseController', CaisseController);

    CaisseController.$inject = ['$rootScope','MainService', 'TransactionsService', '$route', '$templateCache', 'filterFilter', '$timeout', '$compile', 'alert', 'moment', 'calendarConfig'];
    function CaisseController($rootScope,MainService, TransactionsService, $route, $templateCache, filterFilter, $timeout, $compile, alert, moment, calendarConfig) {
        var vm = this;
        vm.selected_row = 0;
        vm.Selected_Transaction = null;
        vm.All_Transactions = [];

        vm.Get_All_Transactions = Get_All_Transactions;
        vm.SelectPatientForTransaction = SelectPatientForTransaction;
        vm.Add_Transaction = Add_Transaction;
        vm.Edit_Transaction = Edit_Transaction;
        vm.Delete_Transaction = Delete_Transaction;
        vm.Filter_Dates_Changes = Filter_Dates_Changes;

        vm.Download_Transactions_Array = Download_Transactions_Array;
        vm.closeModal = closeModal;

        initController();

        function initController() {
            $rootScope.active_menu = 'caisse';
            vm.Transaction_Filtre_Du = new Date(new Date(new Date(new Date(new Date().setUTCMonth('0')).setUTCDate('1')).setHours('00')).setMinutes('00'));

            vm.Transaction_Filtre_Au = new Date(new Date(new Date().setHours('23')).setMinutes('59'));

            MainService.LoadingPartenaires()
            .then(function (result) {
                $rootScope.partenaires = result.data;
            }
            );

            vm.Get_All_Transactions();
            $rootScope.Loading_App_Configs();
        }



        /***************************************************************************************************************/
        $rootScope.Labels_TransactionVersementsTable = ['Effectué le', 'Montant versé(DA)', 'Par', 'Observations', 'Supprimer',]

        function Get_All_Transactions() {
            vm.All_Transactions = [];
            vm.All_Transactions_Initial = [];
            TransactionsService.Get_All_Transactions()
                .then(function (result) {
                    if (result.success) {

                        vm.All_Transactions_Initial = result.data.map(function (item) {
                            return {
                                id: item.id,
                                operation: item.operation,
                                type_transaction: item.type_transaction,
                                type_transaction_id: item.type_transaction_id,
                                transaction_id: item.transaction_id,
                                transaction: item.transaction,
                                patient_id: item.patient_id,
                                patient: item.patient,
                                partenaire_id: item.partenaire_id,
                                partenaire: item.partenaire,
                                tiers: item.tiers,
                                org_id: item.org_id,
                                org: item.org,
                                montant: item.montant,
                                date_transaction: item.date_transaction,
                                type_paiement: item.type_paiement,
                                type_paiement_id: item.type_paiement_id,
                                createdby: item.createdby,
                                SupDatDu: $rootScope.DateA_Sup_DateB(item.date_transaction, vm.Transaction_Filtre_Du),
                                InfDatAu: $rootScope.DateA_Inf_DateB(item.date_transaction, vm.Transaction_Filtre_Au),
                            }
                        });

                        vm.All_Transactions = angular.copy(vm.All_Transactions_Initial);
                        Filter_Dates_Changes();
                        // console.log("vm.All_Transactions : " + JSON.stringify(vm.All_Transactions))

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

        function SelectPatientForTransaction(transaction) {
            console.log('transaction' + transaction);
            vm.Selected_Patient_Transaction = JSON.parse(transaction);
        }

        //Ajouter un nouveau transaction
        function Add_Transaction(is_Submitted_Form_valid, New_Transaction, Modal_ID) {
            //    if (is_Submitted_Form_valid) {
            swal.fire({
                title: "Confirmation",
                text: "Êtes-vous sûr de vouloir ajouter ce transaction!",
                //type: "warning",
                showCancelButton: true,
                confirmButtonColor: "#DD6B55",
                confirmButtonText: "Continuer",
                cancelButtonText: "Annuler",

            }).then((resultConfirmation) => {
                if (resultConfirmation.value) {

                    New_Transaction.type_transaction_id = vm.Selected_Type_Transaction.id

                    if (vm.Selected_Patient_Transaction) {
                        New_Transaction.patient_id = vm.Selected_Patient_Transaction.id;
                        New_Transaction.tiers = vm.Selected_Patient_Transaction.lib;
                    }
                    if (vm.Selected_Partenaire) {
                        New_Transaction.partenaire_id = vm.Selected_Partenaire.id;
                        New_Transaction.tiers = vm.Selected_Partenaire.designation;
                    }
                    New_Transaction.type_paiement_id = vm.Selected_Type_Paiement.id;
                    New_Transaction.montant = New_Transaction.montant.toString().replace(" ", "");

                    TransactionsService.Add_Transaction(New_Transaction)
                        .then(function (result) {
                            if (result.success) {

                                vm.All_Transactions_Initial = result.data.map(function (item) {
                                    return {
                                        id: item.id,
                                        operation: item.operation,
                                        type_transaction: item.type_transaction,
                                        type_transaction_id: item.type_transaction_id,
                                        transaction_id: item.transaction_id,
                                        transaction: item.transaction,
                                        patient_id: item.patient_id,
                                        patient: item.patient,
                                        partenaire_id: item.partenaire_id,
                                        partenaire: item.partenaire,
                                        tiers: item.tiers,
                                        org_id: item.org_id,
                                        org: item.org,
                                        montant: item.montant,
                                        date_transaction: item.date_transaction,
                                        type_paiement: item.type_paiement,
                                        type_paiement_id: item.type_paiement_id,
                                        createdby: item.createdby,
                                        SupDatDu: $rootScope.DateA_Sup_DateB(item.date_transaction, vm.Transaction_Filtre_Du),
                                        InfDatAu: $rootScope.DateA_Inf_DateB(item.date_transaction, vm.Transaction_Filtre_Au),
                                    }
                                });

                                vm.All_Transactions = angular.copy(vm.All_Transactions_Initial);
                                Filter_Dates_Changes();

                                //Go To Last Page
                                $rootScope.currentPageMainTable = Math.ceil(vm.All_Transactions.length / $rootScope.itemsPerPageMainTable);

                                //Set added transaction as selected in table
                                vm.filterTextMainTable = ''; 
                                vm.add2selectionMainTable(New_Transaction, (result.data.length - 1));

                                //Scroll to the end of page
                                $("html, body").animate({ scrollTop: $(document).height() - $(window).height() });

                                angular.element(Modal_ID).modal('hide');
                                $('#Transaction_Nouvelle_Transactions_Form').trigger("reset");
                                New_Transaction = null;

                                //loadallImportedTransactions();
                                toastr.success('Transaction insérée avec succés');
                            }
                            else {
                                toastr.error(result.message, 'Erreur : ' + result.code);
                            }

                        }, function (result) {
                            // this function handles error
                            console.log('CaisseController -> users error : ' + result);
                            toastr.error('Erreur apparue lors de l\'insertion');

                        })//.catch(angular.noop);
                        .catch(function (error) {
                            // handle errors
                            console.log('CaisseController -> Un probleme est survenu : ' + error);
                            toastr.error('Erreur apparue lors de l\'insertion');
                        });
                } else {
                    swal.close();
                }

            })
        /*    } else {
                toastr.error('Veuillez vérifier la validité des données saisies');

            }
        */}

        //Modifier une fiche transaction
        function Edit_Transaction(is_Submitted_Form_valid, Edited_Transaction, Modal_ID) {
            //    if (is_Submitted_Form_valid) {
            swal.fire({
                title: "Confirmation",
                text: "Êtes-vous sûr de vouloir modifier la fiche de ce transaction!",
                //type: "warning",
                showCancelButton: true,
                confirmButtonColor: "#DD6B55",
                confirmButtonText: "Continuer",
                cancelButtonText: "Annuler",

            }).then((resultConfirmation) => {
                if (resultConfirmation.value) {
                    Edited_Transaction.montant = Edited_Transaction.montant.toString().replace(" ", "");

                    TransactionsService.Edit_Transaction(Edited_Transaction)
                        .then(function (result) {
                            if (result.success) {
                                vm.All_Transactions_Initial = result.data.map(function (item) {
                                    return {
                                        id: item.id,
                                        operation: item.operation,
                                        type_transaction: item.type_transaction,
                                        type_transaction_id: item.type_transaction_id,
                                        transaction_id: item.transaction_id,
                                        transaction: item.transaction,
                                        patient_id: item.patient_id,
                                        patient: item.patient,
                                        partenaire_id: item.partenaire_id,
                                        partenaire: item.partenaire,
                                        tiers: item.tiers,
                                        org_id: item.org_id,
                                        org: item.org,
                                        montant: item.montant,
                                        date_transaction: item.date_transaction,
                                        type_paiement: item.type_paiement,
                                        type_paiement_id: item.type_paiement_id,
                                        createdby: item.createdby,
                                        SupDatDu: $rootScope.DateA_Sup_DateB(item.date_transaction, vm.Transaction_Filtre_Du),
                                        InfDatAu: $rootScope.DateA_Inf_DateB(item.date_transaction, vm.Transaction_Filtre_Au),
                                    }
                                });

                                vm.All_Transactions = angular.copy(vm.All_Transactions_Initial);
                                Filter_Dates_Changes();

                                angular.element(Modal_ID).modal('hide');

                                //loadallImportedTransactions();
                                toastr.success('Fiche transaction modifiée avec succés ' + vm.Selected_index);
                            }
                            else {
                                toastr.error(result.message, 'Erreur : ' + result.code);
                            }

                        }, function (result) {
                            // this function handles error
                            console.log('CaisseController -> users error : ' + result);
                            toastr.error('Erreur apparue lors de l\'insertion');

                        })//.catch(angular.noop);
                        .catch(function (error) {
                            // handle errors
                            console.log('CaisseController -> Un probleme est survenu : ' + error);
                            toastr.error('Erreur apparue lors de l\'insertion');
                        });
                } else {
                    swal.close();
                }

            })
          /*  } else {
                toastr.error('Veuillez vérifier la validité des données saisies');

            }
        */     }

        function Delete_Transaction(transaction_versement_id, index) {
            TransactionsService.Delete_Transaction(transaction_versement_id)
                .then(function (result) {
                    if (result.success) {
                        vm.All_Transactions_Initial = result.data.map(function (item) {
                            return {
                                id: item.id,
                                operation: item.operation,
                                type_transaction: item.type_transaction,
                                type_transaction_id: item.type_transaction_id,
                                transaction_id: item.transaction_id,
                                transaction: item.transaction,
                                patient_id: item.patient_id,
                                patient: item.patient,
                                partenaire_id: item.partenaire_id,
                                partenaire: item.partenaire,
                                tiers: item.tiers,
                                org_id: item.org_id,
                                org: item.org,
                                montant: item.montant,
                                date_transaction: item.date_transaction,
                                type_paiement: item.type_paiement,
                                type_paiement_id: item.type_paiement_id,
                                createdby: item.createdby,
                                SupDatDu: $rootScope.DateA_Sup_DateB(item.date_transaction, vm.Transaction_Filtre_Du),
                                InfDatAu: $rootScope.DateA_Inf_DateB(item.date_transaction, vm.Transaction_Filtre_Au),
                            }
                        });

                        vm.All_Transactions = angular.copy(vm.All_Transactions_Initial);
                        Filter_Dates_Changes();

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


        function Filter_Dates_Changes() {
            console.log('vm.Transaction_Filtre_Du ' + vm.Transaction_Filtre_Au)
            vm.All_Transactions = filterFilter(
                angular.copy(vm.All_Transactions_Initial).map(function (item) {
                    return {
                        id: item.id,
                        operation: item.operation,
                        type_transaction: item.type_transaction,
                        type_transaction_id: item.type_transaction_id,
                        transaction_id: item.transaction_id,
                        transaction: item.transaction,
                        patient_id: item.patient_id,
                        patient: item.patient,
                        partenaire_id: item.partenaire_id,
                        partenaire: item.partenaire,
                        tiers: item.tiers,
                        org_id: item.org_id,
                        org: item.org,
                        montant: item.montant,
                        date_transaction: item.date_transaction,
                        type_paiement: item.type_paiement,
                        type_paiement_id: item.type_paiement_id,
                        createdby: item.createdby,
                        SupDatDu: $rootScope.DateA_Sup_DateB(item.date_transaction, vm.Transaction_Filtre_Du),
                        InfDatAu: $rootScope.DateA_Inf_DateB(item.date_transaction, moment(vm.Transaction_Filtre_Au).hours(23).minutes(59)),
                    }
                })
                , { SupDatDu: true, InfDatAu: true }, true);
        }

        function Download_Transactions_Array() {
            var TransactionsToExport = [];
            if (vm.dataMainTable) {
                TransactionsToExport = vm.dataMainTable.map(function (item) {
                    return {
                        operation: item.operation.toUpperCase(),
                        type: item.type_transaction,
                        tiers: item.tiers,
                        date: moment(item.date_transaction).format('DD/MM/YYYY HH:mm'),//new Date().toJSON().slice(0, 10).split('-').reverse().join('_');
                        montant: $rootScope.StringToMoney(item.montant),
                        paiement: item.type_paiement,
                    }
                });
            }

            $rootScope.ExportDataToExcel('Transactions_' + moment(vm.Transaction_Filtre_Du).format('DD/MM/YYYY') + '_' + moment(vm.Transaction_Filtre_Au).format('DD/MM/YYYY') + '.xls', TransactionsToExport);

        }

        /****************************** mainTable ************************************/
        $rootScope.labelsMainTable = ['', 'N°', 'Opération', 'Type', 'Tiers', 'Par', 'Date', 'Montant', 'Cree par', 'Supprimer'];

        vm.filterTextMainTable = '';
        $rootScope.currentPageMainTable = 1;
        $rootScope.maxSizePageMainTable = 5; //Number of pager buttons to show
        $rootScope.itemsPerPageMainTable = 10;//Must be the same as the html one ms-per-page="5"

        // Selection
        $rootScope.selected_lignesMainTable = 0;
        $rootScope.selected_lignes_arrayMainTable = [];

        vm.add2selectionMainTable = function add2selectionMainTable(transaction, index) {
            vm.selected_row = transaction.id
            vm.Selected_Transaction = transaction;
            vm.Selected_Transaction.date_transaction = new Date(transaction.date_transaction)

            vm.Selected_index = index;
            console.log("vm.Selected_index" + vm.Selected_index + 'transaction.id ' + transaction.id + ' selected_row: ' + vm.selected_row);
        };
        vm.pageChangedMainTable = function pageChangedMainTable() {
            console.log('CaisseController -> $rootScope.currentPage : ' + $rootScope.currentPageMainTable);
        };
        vm.sortColumnMainTable = function sortColumnMainTable(label) {
            console.log('CaisseController ->$rootScope.label : ' + label);
            $rootScope.orderByFieldMainTable = label;
            $rootScope.sortByDescendingMainTable = !$rootScope.sortByDescendingMainTable;
            console.log('CaisseController ->$rootScope.sortByDescendingMainTable : ' + $rootScope.sortByDescendingMainTable);
        };
        vm.setItemsPerPageMainTable = function setItemsPerPageMainTable(num) {
            $rootScope.itemsPerPageMainTable = num;
            $rootScope.currentPageMainTable = 1; //reset to first page
            console.log('CaisseController -> itemsPerPage : ' + $rootScope.itemsPerPageMainTable);
            console.log('CaisseController -> itemsPerPageMainTable:itemsPerPageMainTable*(currentPageMainTable-1) : ' + $rootScope.itemsPerPageMainTable * ($rootScope.currentPageMainTable - 1))
        }
        vm.setPage = function setPage(pageNo) {
            $rootScope.currentPageMainTable = pageNo;
        };
        /************************************************************/

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

                        vm.Selected_Transactions = null;
                        vm.transactions = [];

                        vm.modal_action = "Suivant";
                        vm.active_tab = 'list';
                        vm.listePost_id = null;
                        loadallImportedTransactions();
                        angular.element('#add_Transactions_modal').modal('hide');
                        toastr.info('N\'oubliez pas de charger les transactions ultérieurement');
                    } else {
                        swal.close();
                    }
                })
            } else {
                angular.element('#add_Transactions_modal').modal('hide');
            }
        }
    }
})();
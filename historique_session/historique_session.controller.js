(function () {
    'use strict';

    angular
        .module('ClinicApp')
        .controller('HistoriqueSessionController', HistoriqueSessionController);

    HistoriqueSessionController.$inject = ['$rootScope', 'UsersService', '$route', '$templateCache', 'filterFilter'];
    function HistoriqueSessionController($rootScope, UsersService, $route, $templateCache, filterFilter) {
        var vm = this;

        vm.AllHistoriqueSession = [];

        vm.loadallHistoriqueSession = loadallHistoriqueSession;

        vm.toastrsetOptions = toastrsetOptions;

        initController();

        function initController() {
            $rootScope.active_menu = 'historique_session';
            vm.loadallHistoriqueSession();
            vm.toastrsetOptions();
        }


        function loadallHistoriqueSession() {
            vm.AllHistoriqueSession = [];

            //Get toutes les listes postulants
            UsersService.GetAllHistoriqueSession()
                .then(function (result) {
                    if (result.success) {
                        vm.AllHistoriqueSession = result.data;
                        // vm.sortColumnMainTable($rootScope.labelsMainTable[1]);
                        toastr.info('Chargement réussi de l\'historique des sessions');
                    }
                    else {
                        toastr.error(result.message, 'Erreur : ' + result.code);
                    }
                }, function (result) {
                    toastr.error(result.message, 'Erreur : ' + result.code);
                })
                .catch(function (error) {
                    console.log('HistoriqueSessionController -> Un probleme est survenu : ' + error);
                });
        }

        /*********************** mainTable ************************************/
        $rootScope.labelsMainTable = ['id', 'hostname', 'browser_name', 'browser_version', 'os_name', 'os_version', 'date_online', 'date_exit', 'online'];
        $rootScope.currentPageMainTable = 1;
        $rootScope.maxSizePageMainTable = 5; //Number of pager buttons to show
        $rootScope.itemsPerPageMainTable = 10;//Must be the same as the html one ms-per-page="5"

        $rootScope.selected_lignesMainTable = 0;
        $rootScope.selected_lignes_arrayMainTable = [];

        vm.add2selectionMainTable = function add2selectionMainTable(user) {
            if (!user.unselected) {
                user.unselected = true;
                $rootScope.selected_lignes_arrayMainTable.push(user);
                console.log('HistoriqueSessionController -> add2selection : ' + $rootScope.selected_lignesMainTable);
            } else {
                user.unselected = false;
                $rootScope.selected_lignes_arrayMainTable.splice($rootScope.selected_lignes_arrayMainTable.indexOf(user), 1);
            }
            $rootScope.selected_lignesMainTable = $rootScope.selected_lignes_arrayMainTable.length;
        };
        vm.pageChangedMainTable = function pageChangedMainTable() {
            console.log('HistoriqueSessionController -> $rootScope.currentPage : ' + $rootScope.currentPageMainTable);
        };
        vm.sortColumnMainTable = function sortColumnMainTable(label) {
            console.log('HistoriqueSessionController ->$rootScope.label : ' + label);
            $rootScope.orderByFieldMainTable = label;
            $rootScope.sortByDescendingMainTable = !$rootScope.sortByDescendingMainTable;
            console.log('HistoriqueSessionController ->$rootScope.sortByDescendingMainTable : ' + $rootScope.sortByDescendingMainTable);
        };
        vm.setItemsPerPageMainTable = function setItemsPerPageMainTable(num) {
            $rootScope.itemsPerPageMainTable = num;
            $rootScope.currentPageMainTable = 1; //reset to first page
            console.log('HistoriqueSessionController -> itemsPerPage : ' + $rootScope.itemsPerPageMainTable);
            console.log('HistoriqueSessionController -> itemsPerPageMainTable:itemsPerPageMainTable*(currentPageMainTable-1) : ' + $rootScope.itemsPerPageMainTable * ($rootScope.currentPageMainTable - 1))
        }
        vm.setPage = function setPage(pageNo) {
            $scope.currentPageMainTable = pageNo;
        };

        /************************************************************/
        function toastrsetOptions() {
            toastr.options.positionClass = "toast-bottom-right";
            toastr.options.closeButton = true;
            toastr.options.showMethod = 'slideDown';
            toastr.options.hideMethod = 'slideUp';
            //toastr.options.newestOnTop = false;
            toastr.options.progressBar = true;
        };
    }

})();
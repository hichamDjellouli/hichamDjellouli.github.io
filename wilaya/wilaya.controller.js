(function () {
    'use strict';

    angular
        .module('ClinicApp')
        .controller('WilayaController', WilayaController);

    WilayaController.$inject = ['$rootScope', 'UsersService','filterFilter', '$route', '$templateCache',];
    function WilayaController($rootScope, UsersService, filterFilter,$route, $templateCache, ) {
        var vm = this;

        vm.allUsers = [];
        vm.SelectedUser = null;

        if ($rootScope.user && ($rootScope.user.role_id == 0 || $rootScope.user.role_id == 1)) {
            $rootScope.labels = ['Select', 'ID', 'Designation', 'Active ?', 'Modifier', 'Supprimer'];
        } else {
            $rootScope.labels = ['Select', 'ID', 'Designation', 'Active ?'];
        }
        // Table & Pagination
        // PAGINATION
        $rootScope.currentPage = 1;
        $rootScope.itemsPerPage = 15;//Must be the same as the html one ms-per-page="5"


        // Selection
        $rootScope.selected = undefined;

        vm.pageChanged = pageChanged;
        vm.sortColumn = sortColumn;


        vm.SelectedeUser = SelectedeUser;
        vm.NoSelectedeUser = NoSelectedeUser;

        vm.addUser = addUser;
        vm.updateUser = updateUser;
        vm.deleteUser = deleteUser;
        vm.toastrsetOptions = toastrsetOptions;


        initController();

        function initController() {
            $rootScope.active_menu = 'wilaya';
           
            vm.toastrsetOptions();
        }

        //Bootstrap Table Functions
        function pageChanged() {
            console.log('WilayaController -> $rootScope.currentPage : ' + $rootScope.currentPage);
        };

        function sortColumn(label) {
            console.log('WilayaController ->$rootScope.label : ' + $rootScope.label);
            console.log('WilayaController ->$rootScope.orderByField : ' + $rootScope.orderByField);
            $rootScope.orderByField = label;
            $rootScope.sortByDescending = !$rootScope.sortByDescending;
        }

        function loadAllUsers() {

            //Get list of users
            UsersService.GetAll()
                .then(function (result) {
                    console.log('WilayaController -> vm.allUsers before : ' + vm.allUsers + ' Of : ' + vm.allUsers.length);
                    vm.allUsers = result;
                    sortColumn($rootScope.labels[1]);
                    console.log('WilayaController -> vm.allUsers After : ' + vm.allUsers + ' Of : ' + vm.allUsers.length);

                }, function (result) {
                    // this function handles error
                    console.log('WilayaController -> users error : ' + result);
                })//.catch(angular.noop);
                .catch(function (error) {
                    // handle errors
                    console.log('WilayaController -> Un probleme est survenu : ' + error);
                });
        }

        function SelectedeUser(id, user, index) {
            vm.SelectedUser = user;
            console.log('WilayaController -> id : ' + id);
        }

        //Pour vider vm.SelectedUser
        function NoSelectedeUser() {
            vm.SelectedUser = null;
        }

        function addUser(user, index) {
            swal.fire({
                title: "Confirmation",
                text: "Êtes-vous sûr de vouloir continuer cette opération!",
                type: "warning",
                showCancelButton: true,
                confirmButtonColor: "#DD6B55",
                confirmButtonText: "Continuer",
                cancelButtonText: "Annuler",

            }).then((result) => {
                if (result.value) {
                    user.gender = null;
                    user.address = null;
                    user.password = null;
                    user.createdby = $rootScope.user.id;
                    user.updatedby = $rootScope.user.id;

                    // user.updated = new Date();
                    console.log('WilayaController -> xxxuserxxx : ' + user);
                    UsersService.Create(user)
                        .then(function () {
                            //vm.allUsers.splice[index, 1];
                            // loadAllUsers();
                            angular.element('#add_user_modal').modal('hide');
                            toastr.success('Insertion terminée avec succés');
                        }, function (result) {
                            // this function handles error
                            console.log('WilayaController -> users error : ' + result);
                            toastr.error('Erreur apparue lors de l\'insertion');

                        })//.catch(angular.noop);
                        .catch(function (error) {
                            // handle errors
                            console.log('WilayaController -> Un probleme est survenu : ' + error);
                            toastr.error('Erreur apparue lors de l\'insertion');
                        });
                } else {
                    swal.close();
                }
            })
        }

        function updateUser(user, index) {

            swal.fire({
                title: "Confirmation",
                text: "Êtes-vous sûr de vouloir continuer cette opération!",
                type: "warning",
                showCancelButton: true,
                confirmButtonColor: "#DD6B55",
                confirmButtonText: "Continuer",
                cancelButtonText: "Annuler",

            }).then((result) => {
                if (result.value) {
                    user.updatedby = $rootScope.user.id;
                    // user.updated = new Date();
                    console.log('WilayaController -> xxxuserxxx : ' + user);
                    UsersService.Update(user)
                        .then(function () {
                            //vm.allUsers.splice[index, 1];
                            // loadAllUsers();
                            angular.element('#edit_user_modal').modal('hide');
                            toastr.success('Modification terminée avec succés');
                            //swal.fire("Bravo!", 'Votre enregistrement a été effectué avec succès', "success");
                        }, function (result) {
                            // this function handles error
                            console.log('WilayaController -> users error : ' + result);
                            toastr.error('Erreur apparue lors de la modification');
                        })//.catch(angular.noop);
                        .catch(function (error) {
                            // handle errors
                            console.log('WilayaController -> Un probleme est survenu : ' + error);
                            toastr.error('Erreur apparue lors de la modification');
                        });
                } else {
                    swal.close();
                }
            })

        }

        function deleteUser(id, user, index) {
            UsersService.Delete(id)
                .then(function () {
                    loadAllUsers();
                });
        }

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
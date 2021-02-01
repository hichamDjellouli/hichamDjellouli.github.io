(function () {
    'use strict';

    angular
        .module('ClinicApp')
        .controller('OrgController', OrgController);

    OrgController.$inject = ['$rootScope', 'UsersService','OrgService','filterFilter', '$route', '$templateCache',];
    function OrgController($rootScope, UsersService,OrgService,filterFilter, $route, $templateCache,) {
        var vm = this;

        vm.allUsers = [];
        vm.SelectedUser = null;
        if ($rootScope.user && ($rootScope.user.role_id == 0 || $rootScope.user.role_id == 1)) {
            $rootScope.labels = ['Select', 'ID', 'Designation', 'Active ?','Produits', 'Modifier', 'Supprimer'];
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

        vm.GetAllOrgProduits = GetAllOrgProduits;
        vm.Add_OrgProduits = Add_OrgProduits;
        vm.Delete_OrgProduits = Delete_OrgProduits;

        initController();

        function initController() {
            $rootScope.active_menu = 'org';
        
            vm.toastrsetOptions();
        }

        //Bootstrap Table Functions
        function pageChanged() {
            console.log('OrgController -> $rootScope.currentPage : ' + $rootScope.currentPage);
        };

        function sortColumn(label) {
            console.log('OrgController ->$rootScope.label : ' + $rootScope.label);
            console.log('OrgController ->$rootScope.orderByField : ' + $rootScope.orderByField);
            $rootScope.orderByField = label;
            $rootScope.sortByDescending = !$rootScope.sortByDescending;
        }

        function loadAllUsers() {

            //Get list of users
            UsersService.GetAll()
                .then(function (result) {
                    console.log('OrgController -> vm.allUsers before : ' + vm.allUsers + ' Of : ' + vm.allUsers.length);
                    vm.allUsers = result;
                    sortColumn($rootScope.labels[1]);
                    console.log('OrgController -> vm.allUsers After : ' + vm.allUsers + ' Of : ' + vm.allUsers.length);

                }, function (result) {
                    // this function handles error
                    console.log('OrgController -> users error : ' + result);
                })//.catch(angular.noop);
                .catch(function (error) {
                    // handle errors
                    console.log('OrgController -> Un probleme est survenu : ' + error);
                });
        }

        function SelectedeUser(id, user, index) {
            vm.SelectedUser = user;
            console.log('OrgController -> id : ' + id);
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
                    console.log('OrgController -> xxxuserxxx : ' + user);
                    UsersService.Create(user)
                        .then(function () {
                            //vm.allUsers.splice[index, 1];
                            // loadAllUsers();
                            angular.element('#add_user_modal').modal('hide');
                            toastr.success('Insertion terminée avec succés');
                        }, function (result) {
                            // this function handles error
                            console.log('OrgController -> users error : ' + result);
                            toastr.error('Erreur apparue lors de l\'insertion');

                        })//.catch(angular.noop);
                        .catch(function (error) {
                            // handle errors
                            console.log('OrgController -> Un probleme est survenu : ' + error);
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
                    console.log('OrgController -> xxxuserxxx : ' + user);
                    UsersService.Update(user)
                        .then(function () {
                            //vm.allUsers.splice[index, 1];
                            // loadAllUsers();
                            angular.element('#edit_user_modal').modal('hide');
                            toastr.success('Modification terminée avec succés');
                            //swal.fire("Bravo!", 'Votre enregistrement a été effectué avec succès', "success");
                        }, function (result) {
                            // this function handles error
                            console.log('OrgController -> users error : ' + result);
                            toastr.error('Erreur apparue lors de la modification');
                        })//.catch(angular.noop);
                        .catch(function (error) {
                            // handle errors
                            console.log('OrgController -> Un probleme est survenu : ' + error);
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


        //Table orgs_produits
        $rootScope.labels_orgs_produits = ['Id', 'Produit', 'Supprimer',]

        function GetAllOrgProduits(org_id, org) {
            vm.SelectedOrg = org;

            //Get list of orgs
            OrgService.GetAllOrgProduits(org_id)
                .then(function (result) {
                    if (result.success) {
                        vm.AllOrgsProduits = result.orgproduits;
                        //Authorised products for org 
                        vm.produits_without_orgproduits = result.produits_without_orgproduits;

                    }
                    else {
                        toastr.error(result.message, 'Erreur : ' + result.code);
                    }
                }, function (result) {
                    // this function handles error
                    console.log('OrgsController -> orgs error : ' + result);
                })//.catch(angular.noop);
                .catch(function (error) {
                    // handle errors
                    console.log('OrgsController -> Un probleme est survenu : ' + error);
                });
        }

        function Add_OrgProduits(org_id, selected_produit) {
            //Get list of orgs
            OrgService.Add_OrgProduits(org_id, selected_produit)
                .then(function (result) {
                    if (result.success) {
                        vm.AllOrgsProduits = result.orgproduits;
                        //Authorised products for org 
                        vm.produits_without_orgproduits = result.produits_without_orgproduits;
                    }
                    else {
                        toastr.error(result.message, 'Erreur : ' + result.code);
                    }
                }, function (result) {
                    // this function handles error
                    console.log('OrgsController -> orgs error : ' + result);
                })//.catch(angular.noop);
                .catch(function (error) {
                    // handle errors
                    console.log('OrgsController -> Un probleme est survenu : ' + error);
                });
        }


        function Delete_OrgProduits(org_id, selected_produit) {
            //Get list of orgs
            OrgService.Delete_OrgProduits(org_id, selected_produit)
                .then(function (result) {
                    if (result.success) {
                        vm.AllOrgsProduits = result.orgproduits;
                        //Authorised products for org 
                        vm.produits_without_orgproduits = result.produits_without_orgproduits;
                    }
                    else {
                        toastr.error(result.message, 'Erreur : ' + result.code);
                    }
                }, function (result) {
                    // this function handles error
                    console.log('OrgsController -> orgs error : ' + result);
                })//.catch(angular.noop);
                .catch(function (error) {
                    // handle errors
                    console.log('OrgsController -> Un probleme est survenu : ' + error);
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
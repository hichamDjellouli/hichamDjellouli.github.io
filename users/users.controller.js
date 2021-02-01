(function () {
    'use strict';

    angular
        .module('ClinicApp')
        .controller('UsersController', UsersController);

    UsersController.$inject = ['$rootScope', 'UsersService', 'filterFilter', '$route', '$templateCache',];
    function UsersController($rootScope, UsersService, filterFilter, $route, $templateCache,) {
        var vm = this;

        vm.allUsers = [];
        vm.SelectedUser = null;
        vm.SelectedProduit = '';




        // Table & Pagination
        // PAGINATION
        $rootScope.currentPage = 1;
        $rootScope.itemsPerPage = 10;//Must be the same as the html one ms-per-page="5"


        // Selection
        $rootScope.selected_lignes = 0;
        $rootScope.selected_lignes_array = [];
        $rootScope.selected = undefined;
        vm.add2selection = add2selection;

        vm.pageChanged = pageChanged;
        vm.sortColumn = sortColumn;
        vm.sortColumn = setItemsPerPage;

        vm.SelectedeUser = SelectedeUser;
        vm.NoSelectedeUser = NoSelectedeUser;

        vm.addUser = addUser;
        vm.updateUser = updateUser;
        vm.deleteUser = deleteUser;

        vm.validatePassword = validatePassword;


        vm.GetAllUsersProduits = GetAllUsersProduits;
        vm.Add_UsersProduits = Add_UsersProduits;
        vm.Delete_UsersProduits = Delete_UsersProduits;

        vm.toastrsetOptions = toastrsetOptions;


        initController();

        function initController() {
            $rootScope.active_menu = 'users';
            loadAllUsers();

            vm.toastrsetOptions();
        }

        //Ajouter les lignes selectionnées
        function add2selection(user) {
            if (!user.unselected) {
                user.unselected = true;
                $rootScope.selected_lignes_array.push(user);
                console.log('UsersController -> add2selection : ' + $rootScope.selected_lignes);
            } else {
                user.unselected = false;
                $rootScope.selected_lignes_array.splice($rootScope.selected_lignes_array.indexOf(user), 1);
            }
            $rootScope.selected_lignes = $rootScope.selected_lignes_array.length;
        };


        //Bootstrap Table Functions
        function pageChanged() {
            console.log('UsersController -> $rootScope.currentPage : ' + $rootScope.currentPage);
        };

        function sortColumn(label) {
            console.log('UsersController ->$rootScope.label : ' + $rootScope.label);
            console.log('UsersController ->$rootScope.orderByField : ' + $rootScope.orderByField);
            $rootScope.orderByField = label;
            $rootScope.sortByDescending = !$rootScope.sortByDescending;
        }
        function setItemsPerPage(num) {
            $rootScope.itemsPerPage = num;
            $rootScope.currentPage = 1; //reset to first page
            console.log('UsersController -> itemsPerPage : ' + $rootScope.itemsPerPage)
        }

        function loadAllUsers() {

            //Get list of users
            UsersService.GetAll()
                .then(function (result) {
                    if (result.success) {
                        console.log('UsersController -> vm.allUsers before : ' + vm.allUsers + ' Of : ' + vm.allUsers.length);
                        vm.allUsers = result.data;
                        if ($rootScope.user && $rootScope.user.role_id !== 0 && $rootScope.user.role_id !== 1) {
                            vm.allUsers = filterFilter(vm.allUsers, { org_id: $rootScope.user.org_id }, true);
                        }
                        sortColumn($rootScope.labels[1]);
                        console.log('UsersController -> vm.allUsers After : ' + vm.allUsers + ' Of : ' + vm.allUsers.length);
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

        function SelectedeUser(id, user, index) {
            vm.SelectedUser = user;
            console.log('UsersController -> id : ' + id);
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
                    user.createdby = $rootScope.user.id;
                    user.updatedby = $rootScope.user.id;

                    console.log('UsersController -> xxxuserxxx : ' + user);
                    UsersService.Create(user)
                        .then(function (result) {
                            if (result.success) {
                                //vm.allUsers.splice[index, 1];
                                // loadAllUsers();
                                angular.element('#add_user_modal').modal('hide');
                                toastr.success('Insertion terminée avec succés');
                            }
                            else {
                                toastr.error(result.message, 'Erreur : ' + result.code);
                            }

                        }, function (result) {
                            // this function handles error
                            console.log('UsersController -> users error : ' + result);
                            toastr.error('Erreur apparue lors de l\'insertion');

                        })//.catch(angular.noop);
                        .catch(function (error) {
                            // handle errors
                            console.log('UsersController -> Un probleme est survenu : ' + error);
                            toastr.error('Erreur apparue lors de l\'insertion');
                        });

                    //Refresh table user 
                    loadAllUsers();
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
                    console.log('UsersController -> xxxuserxxx : ' + user);
                    UsersService.Update(user)
                        .then(function (result) {
                            if (result.success) {
                                //vm.allUsers.splice[index, 1];
                                // loadAllUsers();
                                angular.element('#edit_user_modal').modal('hide');
                                toastr.success('Modification terminée avec succés');
                                //swal.fire("Bravo!", 'Votre enregistrement a été effectué avec succès', "success");
                            }
                            else {
                                toastr.error(result.message, 'Erreur : ' + result.code);
                            }

                        }, function (result) {
                            // this function handles error
                            console.log('UsersController -> users error : ' + result);
                            toastr.error('Erreur apparue lors de la modification');
                        })//.catch(angular.noop);
                        .catch(function (error) {
                            // handle errors
                            console.log('UsersController -> Un probleme est survenu : ' + error);
                            toastr.error('Erreur apparue lors de la modification');
                        });

                    //Refresh table user 
                    loadAllUsers();

                } else {
                    swal.close();
                }
            })

        }

        function deleteUser(id, user, index) {
            UsersService.Delete(id)
                .then(function (result) {
                    if (result.success) {
                        loadAllUsers();
                    }
                    else {
                        toastr.error(result.message, 'Erreur : ' + result.code);
                    }

                });
        }


        function validatePassword() {
            console.log('xxxx' + vm.Selectedutilisateur.password)

            if (vm.Selectedutilisateur.password != vm.Selectedutilisateur.repassword) {
                console.log('Noooooooooooooooooook')

                $("#repassword_profile")[0].setCustomValidity("Les deux mots de passes ne sont pas identiques");
            } else {
                console.log('oooooooooooooooooook')

                $("#repassword_profile")[0].setCustomValidity('');
            }
        }


        //Table users_produits
        $rootScope.labels_users_produits = ['Id', 'Produit', 'Supprimer',]

        function GetAllUsersProduits(user_id, user) {
            vm.SelectedUser = user;

            //Get list of users
            UsersService.GetAllUsersProduits(user_id)
                .then(function (result) {
                    if (result.success) {
                        vm.AllUsersProduits = result.usersproduits;
                        //Authorised products for user 
                        vm.orgproduits_without_usersproduits = result.orgproduits_without_usersproduits;

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

        function Add_UsersProduits(user_id, selected_produit) {
            //Get list of users
            UsersService.Add_UsersProduits(user_id, selected_produit)
                .then(function (result) {
                    if (result.success) {
                        vm.AllUsersProduits = result.usersproduits;
                        //Authorised products for user 
                        vm.orgproduits_without_usersproduits = result.orgproduits_without_usersproduits;
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


        function Delete_UsersProduits(user_id, selected_produit) {
            //Get list of users
            UsersService.Delete_UsersProduits(user_id, selected_produit)
                .then(function (result) {
                    if (result.success) {
                        vm.AllUsersProduits = result.usersproduits;
                        //Authorised products for user 
                        vm.orgproduits_without_usersproduits = result.orgproduits_without_usersproduits;
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
        /*****************************************************************************************/
        if ($rootScope.user && ($rootScope.user.role_id == 0 || $rootScope.user.role_id == 1)) {
            $rootScope.labels = ['Select', 'ID', 'Org', 'Rôle', 'Nom', 'Prenom', 'Email', 'Active ?', 'Produits', 'Modifier', 'Supprimer'];
        } else {
            $rootScope.labels = ['Select', 'ID', 'Org', 'Rôle', 'Nom', 'Prenom', 'Email', 'Active ?'];
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
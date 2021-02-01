/*
The profile Controller exposes a single profile method which is called from the profile view when the form is submitted. The profile method then calls the UsersService.Create method to save the new user.
*/
(function () {
    'use strict';

    angular
        .module('ClinicApp')
        .controller('ParametresController', ParametresController);

    ParametresController.$inject = ['$rootScope', 'MainService', 'UsersService', 'OrgService', '$location', 'FlashService', 'filterFilter'];
    function ParametresController($rootScope, MainService, UsersService, OrgService, $location, FlashService, filterFilter) {
        var vm = this;
        vm.allUsers = [];
        vm.SelectedUser = null;
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
        vm.updateSelectedUser = updateSelectedUser;

        $rootScope.Labels_Table_Access = ['ID', 'Rubrique', 'Lecture ?', 'Création ?', 'Modification ?', 'Suppression ?'];
        vm.UpdateSelectedUserAccess = UpdateSelectedUserAccess;

        vm.deleteUser = deleteUser;



        vm.validatePassword = validatePassword;
        vm.update_clinique = update_clinique;

        initController();

        function initController() {
            $rootScope.active_menu = 'parametres';
            MainService.LoadingOrgProfessions()
                .then(function (result) {
                    $rootScope.org_professions = result.data;
                }
                );

            Get_AllOrgUsers();
            $rootScope.Loading_App_Configs();
        }



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

        function validatePassword() {
            if ($rootScope.user.password != $rootScope.user.repassword) {
                $("#repassword_profile")[0].setCustomValidity("Les deux mots de passes ne sont pas identiques");
            } else {
                $("#repassword_profile")[0].setCustomValidity('');
            }
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

        function update_clinique(valid_form, logo_document, background_document) {
            if (valid_form) {
                var file_name = $('#logo_document').val().replace(/C:\\fakepath\\/i, '');
                // grab the extension
                if (file_name) {
                    var fileExtension = '.' + file_name.split('.').pop();
                    console.log('file_name' + file_name + ' fileExtension ' + fileExtension)
                    // rename the file with a sufficiently random value and add the file extension back
                    //vm.SelectedRecours.file_name = Math.random().toString(36).substring(7) + new Date().getTime() + fileExtension;
                    var file_name = 'logo_' + $rootScope.org.id + '_' + $rootScope.TodayDate() + fileExtension;
                    $rootScope.org.file_name = file_name;
                }

                var file_name_background = $('#background_document').val().replace(/C:\\fakepath\\/i, '');
                // grab the extension
                if (file_name_background) {
                    var fileExtension = '.' + file_name_background.split('.').pop();
                    console.log('file_name_background' + file_name_background + ' fileExtension ' + fileExtension)
                    // rename the file with a sufficiently random value and add the file extension back
                    //vm.SelectedRecours.file_name = Math.random().toString(36).substring(7) + new Date().getTime() + fileExtension;
                    var file_name_background = 'logo_' + $rootScope.org.id + '_' + $rootScope.TodayDate() + fileExtension;
                    $rootScope.org.file_name_background = file_name_background;
                }

                vm.dataLoading = true;
                OrgService.Update($rootScope.org)
                    .then(function (response) {
                        if (response.success) {

                            if (logo_document && file_name) {
                                //Inséré logo document
                                OrgService.Upload_Logo_File(logo_document, file_name).
                                    then(function (result_file) {
                                        if (result_file.success) {
                                            console.log("success!!");
                                            $rootScope.org_logo_url = 'org/logo/' + file_name;
                                            toastr.success('logo insérée avec succès');
                                            // document.getElementById('logo_document').reset();
                                        }
                                        else {
                                            toastr.error('Problème lors de l\'insertion du document')
                                        }
                                    })
                                    .then(function (result_file) {
                                        console.log("error!! " + JSON.stringify(result_file));
                                    });
                            }

                            if (background_document && file_name_background) {
                                toastr.success('background insérée avec succès');

                                //Inséré background document
                                OrgService.Upload_background_File(background_document, file_name_background).
                                    then(function (result_file) {
                                        if (result_file.success) {
                                            console.log("success!!");
                                            $rootScope.org_background_url = 'org/background/' + file_name_background;
                                            toastr.success('background insérée avec succès');
                                            // document.getElementById('background_document').reset();
                                        }
                                        else {
                                            toastr.error('Problème lors de l\'insertion du document')
                                        }
                                    })
                                    .then(function (result_file) {
                                        console.log("error!! " + JSON.stringify(result_file));
                                    });
                            }

                            toastr.success('Les informations de votre clinique ont été mises à jour avec succèss');
                            vm.dataLoading = false;

                        } else {
                            FlashService.Error(response.message);
                            vm.dataLoading = false;
                        }
                    });
            } else {
                toastr.error('Veuillez vérifier les valeurs introduites dans le formulaire', 'Erreur');
            }
        }

        function Get_AllOrgUsers() {
            //Get list of users
            UsersService.Get_All_Org_Users()
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

        function SelectedeUser(utilisateur, index) {
            vm.SelectedUser = utilisateur;
            vm.SelectedUser.index = index;
            $rootScope.SelectedUserAccess_Control = filterFilter($rootScope.users_roles_access_control_All, { user_id: utilisateur.id }, true);
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
                    UsersService.insert_user_clinique(user)
                        .then(function (result) {
                            if (result.success) {
                                //vm.allUsers.splice[index, 1];
                                Get_AllOrgUsers();
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
                    Get_AllOrgUsers();
                } else {
                    swal.close();
                }
            })
        }

        //Update Current user profile
        function updateUser(avatar_document) {
            console.log('updaaaaaaaaaaaaaaate')
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
                    var file_name = $('#avatar_document').val().replace(/C:\\fakepath\\/i, '');
                    // grab the extension
                    if (file_name) {
                        var fileExtension = '.' + file_name.split('.').pop();
                        console.log('file_name' + file_name + ' fileExtension ' + fileExtension)
                        // rename the file with a sufficiently random value and add the file extension back
                        //vm.SelectedRecours.file_name = Math.random().toString(36).substring(7) + new Date().getTime() + fileExtension;
                        var file_name = 'avatar_' + $rootScope.user.id + '_' + $rootScope.TodayDate() + fileExtension;
                        $rootScope.user.file_name = file_name;
                    }

                    // user.updated = new Date();
                    UsersService.Update($rootScope.user)
                        .then(function (result) {
                            if (result.success) {
                                if (avatar_document && file_name) {
                                    //Inséré avatar document
                                    UsersService.Upload_avatar_File(avatar_document, file_name).
                                        then(function (result_file) {
                                            if (result_file.success) {
                                                console.log("success!!");
                                                $rootScope.user_avatar_url = 'users/avatar/' + file_name;
                                                toastr.success('avatar insérée avec succès');
                                                // document.getElementById('avatar_document').reset();
                                            }
                                            else {
                                                toastr.error('Problème lors de l\'insertion du document')
                                            }
                                        })
                                        .then(function (result_file) {
                                            console.log("error!! " + JSON.stringify(result_file));
                                        });
                                }
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
                    Get_AllOrgUsers();

                } else {
                    swal.close();
                }
            })

        }

        //Update Selected user
        function updateSelectedUser(utilisateur) {
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

                    // user.updated = new Date();
                    UsersService.updateSelectedUser(utilisateur)
                        .then(function (result) {
                            if (result.success) {
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
                    Get_AllOrgUsers();

                } else {
                    swal.close();
                }
            })

        }

        //Update Selected user Acces
        function UpdateSelectedUserAccess(SelectedUserAccess_Control) {
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

                    // user.updated = new Date();
                    UsersService.UpdateSelectedUserAccess(SelectedUserAccess_Control)
                        .then(function (result) {
                            if (result.success) {
                                angular.element('#user_access_modal').modal('hide');
                                toastr.success('Modification terminée avec succés');
                                //swal.fire("Bravo!", 'Votre enregistrement a été effectué avec succès', "success");
                            } else {
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
                } else {
                    swal.close();
                }
            })

        }
        function deleteUser(id, user, index) {
            UsersService.Delete(id)
                .then(function (result) {
                    if (result.success) {
                        Get_AllOrgUsers();
                    }
                    else {
                        toastr.error(result.message, 'Erreur : ' + result.code);
                    }

                });
        }
        /************************************************************************* ********/
        // if ($rootScope.user && ($rootScope.user.role_id == 0 || $rootScope.user.role_id == 1)) {
        $rootScope.labels = ['Select', 'Profession', 'Utilisateur', 'Email', 'Active ?', 'Modifier', 'Privilèges', 'Supprimer'];
        // } else {
        //   $rootScope.labels = ['Select', 'ID', 'Org', 'Rôle', 'Nom', 'Prenom', 'Email', 'Active ?'];
        // }
    }


})();

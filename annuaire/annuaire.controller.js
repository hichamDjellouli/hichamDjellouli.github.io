(function () {
    'use strict';

    angular
        .module('ClinicApp')
        .controller('AnnuaireController', AnnuaireController);

    AnnuaireController.$inject = ['$rootScope', 'PartenaireService', 'filterFilter', '$route', '$templateCache',];
    function AnnuaireController($rootScope, PartenaireService, filterFilter, $route, $templateCache,) {
        var vm = this;

        vm.All_Partenaires = [];
        vm.Get_All_Partenaires = Get_All_Partenaires;
        vm.Add_Partenaire = Add_Partenaire;
        vm.Delete_Partenaire = Delete_Partenaire;

        initController();

        function initController() {
            $rootScope.active_menu = 'annuaire';

            $rootScope.Loading_App_Configs();

            vm.Get_All_Partenaires();
        }

        function Get_All_Partenaires() {
            PartenaireService.Get_All_Partenaires()
                .then(function (result) {
                    if (result.success) {
                        vm.All_Partenaires = result.data;
                        vm.FilterPartenaire = '';
                    }
                    else {
                        toastr.error(result.message, 'Erreur : ' + result.code);
                    }
                }, function (result) {
                    // this function handles error
                    console.log('PartenairesController -> orgs error : ' + result);
                })//.catch(angular.noop);
                .catch(function (error) {
                    // handle errors
                    console.log('PartenairesController -> Un probleme est survenu : ' + error);
                });
        }

        function Add_Partenaire(New_Partenaire) {
            New_Partenaire.color = $rootScope.getRandomColor();
            PartenaireService.Add_Partenaire(New_Partenaire)
                .then(function (result) {
                    if (result.success) {
                        vm.All_Partenaires = result.data;
                        vm.FilterPartenaire = '';
                        vm.New_Partenaire=null;
                        angular.element(Add_Partenaire_Modal).modal('hide');
                        $('#Add_Partenaire_Form').trigger("reset");
                        toastr.success("Partenaire ajouté avec succés");

                    }
                    else {
                        toastr.error(result.message, 'Erreur : ' + result.code);
                    }
                }, function (result) {
                    // this function handles error
                    console.log('PartenairesController -> orgs error : ' + result);
                })//.catch(angular.noop);
                .catch(function (error) {
                    // handle errors
                    console.log('PartenairesController -> Un probleme est survenu : ' + error);
                });
        }

        function Delete_Partenaire(partenaire_id) {
            //Get list of orgs
            PartenaireService.Delete_Partenaire(partenaire_id)
                .then(function (result) {
                    if (result.success) {
                        vm.All_Partenaires = result.data;
                        vm.FilterPartenaire = '';
                    }
                    else {
                        toastr.error(result.message, 'Erreur : ' + result.code);
                    }
                }, function (result) {
                    // this function handles error
                    console.log('PartenairesController -> orgs error : ' + result);
                })//.catch(angular.noop);
                .catch(function (error) {
                    // handle errors
                    console.log('PartenairesController -> Un probleme est survenu : ' + error);
                });
        }

    }
})();
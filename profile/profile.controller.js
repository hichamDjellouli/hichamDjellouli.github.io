/*
The profile Controller exposes a single profile method which is called from the profile view when the form is submitted. The profile method then calls the UsersService.Create method to save the new user.
*/
(function () {
    'use strict';

    angular
        .module('ClinicApp')
        .controller('ProfileController', ProfileController);

    ProfileController.$inject = ['$rootScope', 'UsersService', '$location', 'FlashService',];
    function ProfileController($rootScope, UsersService, $location, FlashService, ) {
        var vm = this;

        vm.validatePassword = validatePassword;
        vm.profile = profile;



        function validatePassword() {
            if ($rootScope.user.password != $rootScope.user.repassword) {
                $("#repassword_profile")[0].setCustomValidity("Les deux mots de passes ne sont pas identiques");
            } else {
                $("#repassword_profile")[0].setCustomValidity('');
            }
        }

        function profile(valid_form) {
            console.log('PROFIIIIIIIIILE : ' + JSON.stringify($rootScope.user));
            if (valid_form && $rootScope.user.password == $rootScope.user.repassword) {
                vm.dataLoading = true;
                UsersService.Update($rootScope.user)
                    .then(function (response) {
                        if (response.success) {
                            FlashService.Success('Votre profile a été mis à jour avec succèss', true);
                            //$location.path('/login');
                            toastr.success('Votre profile a été mis à jour avec succèss');
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
    }

})();

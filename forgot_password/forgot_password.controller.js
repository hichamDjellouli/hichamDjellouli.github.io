(function () {
    'use strict';

    angular
        .module('ClinicApp')
        .controller('ForgotPasswordController', ForgotPasswordController);

    ForgotPasswordController.$inject = ['$rootScope', '$location', 'filterFilter', 'AuthenticationService', 'FlashService', '$window'];
    function ForgotPasswordController($rootScope, $location, filterFilter, AuthenticationService, FlashService, $window) {
        var vm = this;

        vm.reset_password = reset_password;

         function reset_password() {
            vm.dataLoading = true;
            AuthenticationService.reset_password(vm.email).then(function (result) {
                 if (result.success) {
                    vm.email = null;
                    toastr.info('Opération terminée avec succès, veuillez consulter votre boite de messagerie');
                    vm.dataLoading = false;
                    $location.path('/');
                }
                else{
                    toastr.error('Votre adresse mail n\'existe pas dans notre système');
                    vm.dataLoading = false;
                }
            })
        }
    }

})();

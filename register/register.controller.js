/*
The Register Controller exposes a single register method which is called from the register view when the form is submitted. The register method then calls the UsersService.Create method to save the new user.
*/
(function () {
    'use strict';

    angular
        .module('ClinicApp')
        .controller('RegisterContxroller', RegisterController);

    RegisterController.$inject = ['UsersService', '$location', 'FlashService', 'vcRecaptchaService'];
    function RegisterController(UsersService, $location, FlashService, vcRecaptchaService) {
        var vm = this;

        vm.user = null;
        vm.validatePassword = validatePassword;
        vm.register = register;

     
            $rootScope.active_menu = 'register';
            $rootScope.sexes = [{ id: 'M', designation: 'Masculin' }, { id: 'F', designation: 'Féminin' }];

     

        /********************* RECAPTCHA ***********************/
        vm.response = null;
        vm.widgetId = null;
        vm.model = {
            key: '6Lex0g0UAAAAAC9n7pxjk70Vs4y874pcjitci9O3'
        };
        vm.setResponse = function (response) {
            console.info('Response available : '+response);

            vm.response = response;
        };

        vm.setWidgetId = function (widgetId) {
            console.info('Created widget ID: %s', widgetId);

            vm.widgetId = widgetId;
        };

        vm.cbExpiration = function() {
            console.info('Captcha expired. Resetting response object');

            vcRecaptchaService.reload(vm.widgetId);

            vm.response = null;
         };
        /********************* RECAPTCHA ************************/

        function validatePassword() {
            if (vm.user.password != vm.user.repassword) {
                $("#repassword_register")[0].setCustomValidity("Les deux mots de passes ne sont pas identiques");
            } else {
                $("#repassword_register")[0].setCustomValidity('');
            }
        }

        function register(valid_form) {
            if (vm.response != null) {
                if (valid_form && vm.user.password == vm.user.repassword) {
                    vm.dataLoading = true;
                    vm.user.createdby = 0;
                    vm.user.updatedby = 0;
                    vm.user.org_id = 1; //Affectation pour les hebergements locals
                    UsersService.Create(vm.user)
                        .then(function (response) {
                            if (response.success) {
                                FlashService.Success('Vous êtes enregistré avec succés, une notification vous sera envoyée sur votre messagerie une fois votre compte activé', true);
                                $location.path('/login');
                                toastr.success('Vous êtes enregistré avec succés, une notification vous sera envoyée sur votre messagerie une fois votre compte activé');
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
            else {
                toastr.error('La case de vérification CAPTCHA est obligatoire', 'Erreur');
            }

        }
    }

})();

/*
The Login Controller clears the user credentials on load which logs the user out if they were logged 
in.
The login function exposed by the controller calls the Authentication Service to authenticate the 
username and password entered into the view.
*/
(function () {
    'use strict';

    angular
        .module('ClinicApp')
        .controller('LoginController', LoginController);

    LoginController.$inject = ['$rootScope', '$location', 'filterFilter', 'AuthenticationService', 'FlashService', '$window'];
    function LoginController($rootScope, $location, filterFilter, AuthenticationService, FlashService, $window) {
        var vm = this;

        vm.login = login;

        (function initController() {
            $rootScope.active_menu = 'login';

            // reset login status pour supprimer les cookies
            AuthenticationService.ClearCredentials();
        })();

        function login() {
            vm.dataLoading = true;
            AuthenticationService.authenticate(vm.email, vm.password, function (response) {
                console.log('LoginController -> response.success : ' + response.success);
                if (response.success) {
                    console.log("Hello this is your token : " + response.token);
                    AuthenticationService.SetCredentials(vm.email, vm.password, response.token);
                    $location.path('/');
                    //$window.location.reload();
                    Swal.fire({
                        position: 'top-end',
                        icon: 'success',
                        title: 'Votre session a été ouverte avec succéss',
                        showConfirmButton: false,
                        timer: 1500
                    })
                    // console.log("$rootScope.user.first_visit : " + JSON.stringify($rootScope.user));
                    //console.log("Welcome, is this your first visit ? " + JSON.stringify(response));
 
                    if (response.first_visit) {
                        $(function () {
                            introJs()
                                .setOption("nextLabel", " Suivant ")
                                .setOption("prevLabel", " Précédent")
                                .setOption("skipLabel", " Terminer ")
                                .setOption("doneLabel", " Terminer ")
                                .setOption("showProgress", true)
                                .setOption("tooltipPosition", "auto")
                                .setOption("scrollToElement", "true")
                                .setOption("scrollTo", "true")
                                .setOption("showBullets", "true")

                                .onchange(function (targetElement) {
                                    document.body.scrollTop = 0; // For Safari
                                    document.documentElement.scrollTop = 0; // For Chrome, Firefox, IE and Opera
                                })

                                /* 
                               .onafterchange(function (targetElement) {
                                    // alert("after new step"+JSON.stringify(targetElement));
                                    //targetElement.scrollTo(0, 1000);
                                    document.body.scrollTop = 0; // For Safari
                                    document.documentElement.scrollTop = 0; // For Chrome, Firefox, IE and Opera
                                })
                                */
                                .onexit(function () {
                                    // toastr.info('Vous pouvez à n\'importe quel momement revenir à ce tuto en cliquant sur le bouton en haut');
                                })
                                .start();
                        })
                    }


                    //swal.fire("Bravo!", 'Votre session a été ouverte avec succéss', "success");
                } else {
                    FlashService.Error(response.message);
                    vm.dataLoading = false;
                }
            });
        };
    }

})();

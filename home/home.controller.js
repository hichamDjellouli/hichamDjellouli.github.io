(function () {
    'use strict';

    angular
        .module('ClinicApp')
        .controller('HomeController', HomeController);

    HomeController.$inject = ['$rootScope', 'filterFilter', 'MainService', 'UsersService', '$route', '$templateCache',];
    function HomeController($rootScope, filterFilter, MainService, PatientsService, $route, $templateCache,) {
        //clear browser cache programmtically in angularJS
        //$templateCache.removeAll();

        //Relaod the page
        //$route.reload();


        var vm = this;


        vm.increment = increment;
        initController();

        function initController() {
            $rootScope.active_menu = 'home';
            $rootScope.Loading_App_Configs();

            MainService.Get_All_Org_Contacts_Messages();

            MainService.User_Notifications()
                .then(function (result) {
                    $rootScope.notifications = result.data;
                    $rootScope.unreadedNotifications = filterFilter($rootScope.notifications, { read: false }, true);
                }
                );
            if ($rootScope.All_Patients.length == 0) {
                MainService.Get_All_Patients();
            }


            if ($rootScope.All_RDVs.length == 0) {
                MainService.Get_All_RDVs();//mail rappel envoyé après chargement
            }
        }

        function increment(element_id, number) {
            $(function () {

                var $el = $("#" + element_id),
                    end_value = number;


                $({ value: 0 }).stop(true).animate({ value: end_value }, {
                    duration: 5000,
                    easing: "easeOutExpo",
                    step: function () {
                        // value with 1 decimal;
                        var temp_value = Math.round(this.value * 10) / 10;

                        $el.text(temp_value);
                    }
                }).promise().done(function () {
                    // hard set the value after animation is done to be
                    // sure the value is correct
                    $el.text(end_value);
                });

            })
        }
    }

})();
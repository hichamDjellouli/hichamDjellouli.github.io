(function () {
    'use strict';

    angular
        .module('ClinicApp')
        .controller('ReportsController', ReportsController);

    ReportsController.$inject = ['$rootScope', 'filterFilter', 'ReportsService', 'MainService', 'UsersService', '$route', '$templateCache',];
    function ReportsController($rootScope, filterFilter, ReportsService, MainService, UsersService, $route, $templateCache,) {
        //clear browser cache programmtically in angularJS
        //$templateCache.removeAll();

        //Relaod the page
        //$route.reload();

        var vm = this;
        vm.Statistiques_patients_sexes_ages = [];
        vm.Get_Statistiques_patients_sexes_ages = Get_Statistiques_patients_sexes_ages;

        vm.Statistiques_rdvs = [];
        vm.Get_Statistiques_rdvs = Get_Statistiques_rdvs;

        vm.Statistiques_Transactions = [];
        vm.Get_Statistiques_Transactions = Get_Statistiques_Transactions;

        vm.increment = increment;
        vm.Filter_Dates_Changes = Filter_Dates_Changes;

        initController();

        function initController() {
            $rootScope.Loading_App_Configs();

            vm.Report_Filtre_Du = new Date(new Date(new Date(new Date(new Date().setUTCMonth('0')).setUTCDate('1')).setHours('00')).setMinutes('00'));
            vm.Report_Filtre_Au = new Date(new Date(new Date().setHours('23')).setMinutes('59'));//new Date(new Date().setHours('23')).setMinutes('59'); 

            Get_Statistiques_patients_sexes_ages();
            Get_Statistiques_rdvs();
            Get_Statistiques_Transactions();
        }

        function Get_Statistiques_patients_sexes_ages() {
            console.log("vm.Report_Filtre_Du " + vm.Report_Filtre_Du)
            ReportsService.Get_Statistiques_patients_sexes_ages(vm.Report_Filtre_Du, vm.Report_Filtre_Au)
                .then(function (result) {
                    if (result.success) {
                        vm.Statistiques_patients_sexes_ages = result.data;
                        vm.increment('nb_patients', vm.Statistiques_patients_sexes_ages.patients);
                        $(function () {
                            //----------------------------------------------------
                            //- LINE CHART : chart_evolution_nb_patient          -
                            //----------------------------------------------------
                            var Canvas_evolution_nb_patient = $('#chart_evolution_nb_patient').get(0).getContext('2d')
                            var Options_evolution_nb_patient = {
                                maintainAspectRatio: true,
                                responsive: true,
                                legend: {
                                    display: true
                                },
                                scales: {
                                    xAxes: [{
                                        gridLines: {
                                            display: true,
                                        }
                                    }],
                                    yAxes: [{
                                        gridLines: {
                                            display: true,
                                        }
                                    }]
                                }
                            }

                            var mois = [];
                            if (new Date(vm.Report_Filtre_Du).getMonth() <= new Date(vm.Report_Filtre_Au).getMonth()) {
                                for (let index = new Date(vm.Report_Filtre_Du).getMonth(); index <= new Date(vm.Report_Filtre_Au).getMonth(); index++) {
                                    console.log("parseInt(index) " + parseInt(index))
                                    if ((parseInt(index) + 1) < 10) { mois.push("0" + (parseInt(index) + 1)); }
                                    else mois.push((parseInt(index) + 1));
                                    console.log("mois " + mois)
                                }
                            }
                            else {
                                for (let index = new Date(vm.Report_Filtre_Au).getMonth(); index <= new Date(vm.Report_Filtre_Du).getMonth(); index++) {
                                    console.log("parseInt(index) " + parseInt(index))
                                    if ((parseInt(index) + 1) < 10) { mois.push("0" + (parseInt(index) + 1)); }
                                    else mois.push((parseInt(index) + 1));
                                    console.log("mois " + mois);
                                }
                            }

                            console.log("mois " + mois);

                            var current_datas = [];
                            var last_datas = [];

                            if (mois.toString().includes('01')) {
                                current_datas.push(vm.Statistiques_patients_sexes_ages.patient_consultation_current_01)
                                last_datas.push(vm.Statistiques_patients_sexes_ages.patient_consultation_last_01)
                            }
                            if (mois.toString().includes('02')) {
                                current_datas.push(vm.Statistiques_patients_sexes_ages.patient_consultation_current_02)
                                last_datas.push(vm.Statistiques_patients_sexes_ages.patient_consultation_last_02)
                            }
                            if (mois.toString().includes('03')) {
                                current_datas.push(vm.Statistiques_patients_sexes_ages.patient_consultation_current_03)
                                last_datas.push(vm.Statistiques_patients_sexes_ages.patient_consultation_last_03)
                            }
                            if (mois.toString().includes('04')) {
                                current_datas.push(vm.Statistiques_patients_sexes_ages.patient_consultation_current_04)
                                last_datas.push(vm.Statistiques_patients_sexes_ages.patient_consultation_last_04)
                            }
                            if (mois.toString().includes('05')) {
                                current_datas.push(vm.Statistiques_patients_sexes_ages.patient_consultation_current_05)
                                last_datas.push(vm.Statistiques_patients_sexes_ages.patient_consultation_last_05)
                            }
                            if (mois.toString().includes('06')) {
                                current_datas.push(vm.Statistiques_patients_sexes_ages.patient_consultation_current_06)
                                last_datas.push(vm.Statistiques_patients_sexes_ages.patient_consultation_last_06)
                            }
                            if (mois.toString().includes('07')) {
                                current_datas.push(vm.Statistiques_patients_sexes_ages.patient_consultation_current_07)
                                last_datas.push(vm.Statistiques_patients_sexes_ages.patient_consultation_last_07)
                            }
                            if (mois.toString().includes('08')) {
                                current_datas.push(vm.Statistiques_patients_sexes_ages.patient_consultation_current_08)
                                last_datas.push(vm.Statistiques_patients_sexes_ages.patient_consultation_last_08)
                            }
                            if (mois.toString().includes('09')) {
                                current_datas.push(vm.Statistiques_patients_sexes_ages.patient_consultation_current_09)
                                last_datas.push(vm.Statistiques_patients_sexes_ages.patient_consultation_last_09)
                            }
                            if (mois.toString().includes('10')) {
                                current_datas.push(vm.Statistiques_patients_sexes_ages.patient_consultation_current_10)
                                last_datas.push(vm.Statistiques_patients_sexes_ages.patient_consultation_last_10)
                            }
                            if (mois.toString().includes('11')) {
                                current_datas.push(vm.Statistiques_patients_sexes_ages.patient_consultation_current_11)
                                last_datas.push(vm.Statistiques_patients_sexes_ages.patient_consultation_last_11)
                            }
                            if (mois.toString().includes('12')) {
                                current_datas.push(vm.Statistiques_patients_sexes_ages.patient_consultation_current_12)
                                last_datas.push(vm.Statistiques_patients_sexes_ages.patient_consultation_last_12)
                            }

                            console.log("current_datas " + current_datas + " last_datas " + last_datas)


                            var Datas_evolution_nb_patient = {
                                labels: mois,// labels: ['1','2','3','4','5','6','7','8','9','10','11','12',],
                                datasets: [
                                    {
                                        label: "Patients consultés l'année " + new Date(vm.Report_Filtre_Au).getFullYear(),
                                        backgroundColor: 'rgba(60,141,188,0.9)',
                                        borderColor: 'rgba(60,141,188,0.8)',
                                        pointRadius: true,
                                        pointColor: '#3b8bba',
                                        pointStrokeColor: 'rgba(60,141,188,1)',
                                        pointHighlightFill: '#fff',
                                        pointHighlightStroke: 'rgba(60,141,188,1)',
                                        data: current_datas,
                                    },
                                    {
                                        label: "Patients consultés l'année " + ((parseInt((new Date(vm.Report_Filtre_Au).getFullYear()))) - 1),
                                        backgroundColor: '#007dad36',
                                        borderColor: '#007dad36',
                                        pointRadius: true,
                                        pointColor: 'rgba(210, 214, 222, 1)',
                                        pointStrokeColor: '#c1c7d1',
                                        pointHighlightFill: '#fff',
                                        pointHighlightStroke: 'rgba(220,220,220,1)',
                                        data: last_datas,
                                    },

                                ]
                            }

                            Options_evolution_nb_patient.datasetFill = false
                            Datas_evolution_nb_patient.datasets[0].fill = false;
                            Datas_evolution_nb_patient.datasets[1].fill = false;

                            var lineChart = new Chart(Canvas_evolution_nb_patient, {
                                type: 'line',
                                data: Datas_evolution_nb_patient,
                                options: Options_evolution_nb_patient
                            });

                            //-------------
                            //- PIE CHART -
                            //-------------                         
                            var pieChartCanvas_sexe = $('#chart_patient_par_sexe').get(0).getContext('2d')
                            var pieData_sexe = {
                                labels: [
                                    'Masculin',
                                    'Féminin',
                                ],
                                datasets: [{
                                    data: [vm.Statistiques_patients_sexes_ages.patients_masculin,
                                    vm.Statistiques_patients_sexes_ages.patients_feminin],
                                    backgroundColor: ['#0a7b83', '#2aa876'],
                                }]
                            }
                            var pieOptions_sexe = {
                                responsive: true,
                                title: {
                                    display: false,
                                    text: 'Legend Position: '
                                },
                                legend: {
                                    display: false,
                                    position: 'right',
                                }
                            }
                            //Create pie or douhnut chart
                            // You can switch between pie and douhnut using the method below.
                            var pieChart = new Chart(pieChartCanvas_sexe, {
                                type: 'doughnut',
                                data: pieData_sexe,
                                options: pieOptions_sexe
                            });

                            /*********************************************/
                            var pieChartCanvas_age = $('#chart_patient_par_age').get(0).getContext('2d')
                            var pieData_age = {
                                labels: [
                                    'Moins de 18',
                                    '18-30',
                                    '30-40',
                                    '40-50',
                                    '50-60',
                                    'Plus de 60 ans',
                                ],
                                datasets: [{
                                    data: [
                                        vm.Statistiques_patients_sexes_ages.patients_inf_18
                                        , vm.Statistiques_patients_sexes_ages.patients_18_30
                                        , vm.Statistiques_patients_sexes_ages.patients_30_40
                                        , vm.Statistiques_patients_sexes_ages.patients_40_50
                                        , vm.Statistiques_patients_sexes_ages.patients_50_60
                                        , vm.Statistiques_patients_sexes_ages.patients_sup_60],
                                    backgroundColor: ['#6f42c1', '#2aa876', '#0a7b83', '#ffd265', '#f19c65', 'red'],
                                }]
                            }
                            var pieOptions_age = {
                                responsive: true,
                                title: {
                                    display: false,
                                    text: 'Legend Position: '
                                },
                                legend: {
                                    display: false,
                                    position: 'bottom',
                                }
                            }
                            //Create pie or douhnut chart
                            // You can switch between pie and douhnut using the method below.
                            var pieChart = new Chart(pieChartCanvas_age, {
                                type: 'doughnut',
                                data: pieData_age,
                                options: pieOptions_age
                            });

                            //-----------------
                            //- END PIE CHART -
                            //-----------------


                            //----------------------------------------------------
                            //- LINE CHART : chart_evolution_duree_consultation          -
                            //----------------------------------------------------
                            var Canvas_evolution_duree_consultation = $('#chart_evolution_duree_consultation').get(0).getContext('2d')
                            var Options_evolution_duree_consultation = {
                                maintainAspectRatio: true,
                                responsive: true,
                                legend: {
                                    display: true
                                },
                                scales: {
                                    xAxes: [{
                                        gridLines: {
                                            display: true,
                                        }
                                    }],
                                    yAxes: [{
                                        gridLines: {
                                            display: true,
                                        }
                                    }]
                                }
                            }

                            var mois_duree_consultation = [];
                            if (new Date(vm.Report_Filtre_Du).getMonth() <= new Date(vm.Report_Filtre_Au).getMonth()) {
                                for (let index = new Date(vm.Report_Filtre_Du).getMonth(); index <= new Date(vm.Report_Filtre_Au).getMonth(); index++) {
                                    console.log("parseInt(index) " + parseInt(index))
                                    if ((parseInt(index) + 1) < 10) { mois_duree_consultation.push("0" + (parseInt(index) + 1)); }
                                    else mois_duree_consultation.push((parseInt(index) + 1));
                                    console.log("mois_duree_consultation " + mois_duree_consultation)
                                }
                            }
                            else {
                                for (let index = new Date(vm.Report_Filtre_Au).getMonth(); index <= new Date(vm.Report_Filtre_Du).getMonth(); index++) {
                                    console.log("parseInt(index) " + parseInt(index))
                                    if ((parseInt(index) + 1) < 10) { mois_duree_consultation.push("0" + (parseInt(index) + 1)); }
                                    else mois_duree_consultation.push((parseInt(index) + 1));
                                    console.log("mois_duree_consultation " + mois_duree_consultation);
                                }
                            }

                            console.log("mois_duree_consultation " + mois_duree_consultation);

                            var current_datas_duree_consultation = [];
                            var last_datas_duree_consultation = [];

                            if (mois_duree_consultation.toString().includes('01')) {
                                current_datas_duree_consultation.push(vm.Statistiques_patients_sexes_ages.patient_consultation_current_duree_01)
                                //last_datas_duree_consultation.push(vm.Statistiques_patients_sexes_ages.rdv_last_01)
                            }
                            if (mois_duree_consultation.toString().includes('02')) {
                                current_datas_duree_consultation.push(vm.Statistiques_patients_sexes_ages.patient_consultation_current_duree_02)
                                //last_datas_duree_consultation.push(vm.Statistiques_patients_sexes_ages.rdv_last_02)
                            }
                            if (mois_duree_consultation.toString().includes('03')) {
                                current_datas_duree_consultation.push(vm.Statistiques_patients_sexes_ages.patient_consultation_current_duree_03)
                                //last_datas_duree_consultation.push(vm.Statistiques_patients_sexes_ages.rdv_last_03)
                            }
                            if (mois_duree_consultation.toString().includes('04')) {
                                current_datas_duree_consultation.push(vm.Statistiques_patients_sexes_ages.patient_consultation_current_duree_04)
                                //last_datas_duree_consultation.push(vm.Statistiques_patients_sexes_ages.rdv_last_04)
                            }
                            if (mois_duree_consultation.toString().includes('05')) {
                                current_datas_duree_consultation.push(vm.Statistiques_patients_sexes_ages.patient_consultation_current_duree_05)
                                //last_datas_duree_consultation.push(vm.Statistiques_patients_sexes_ages.rdv_last_05)
                            }
                            if (mois_duree_consultation.toString().includes('06')) {
                                current_datas_duree_consultation.push(vm.Statistiques_patients_sexes_ages.patient_consultation_current_duree_06)
                                //last_datas_duree_consultation.push(vm.Statistiques_patients_sexes_ages.rdv_last_06)
                            }
                            if (mois_duree_consultation.toString().includes('07')) {
                                current_datas_duree_consultation.push(vm.Statistiques_patients_sexes_ages.patient_consultation_current_duree_07)
                                //last_datas_duree_consultation.push(vm.Statistiques_patients_sexes_ages.rdv_last_07)
                            }
                            if (mois_duree_consultation.toString().includes('08')) {
                                current_datas_duree_consultation.push(vm.Statistiques_patients_sexes_ages.patient_consultation_current_duree_08)
                                //last_datas_duree_consultation.push(vm.Statistiques_patients_sexes_ages.rdv_last_08)
                            }
                            if (mois_duree_consultation.toString().includes('09')) {
                                current_datas_duree_consultation.push(vm.Statistiques_patients_sexes_ages.patient_consultation_current_duree_09)
                                //last_datas_duree_consultation.push(vm.Statistiques_patients_sexes_ages.rdv_last_09)
                            }
                            if (mois_duree_consultation.toString().includes('10')) {
                                current_datas_duree_consultation.push(vm.Statistiques_patients_sexes_ages.patient_consultation_current_duree_10)
                                //last_datas_duree_consultation.push(vm.Statistiques_patients_sexes_ages.rdv_last_10)
                            }
                            if (mois_duree_consultation.toString().includes('11')) {
                                current_datas_duree_consultation.push(vm.Statistiques_patients_sexes_ages.patient_consultation_current_duree_11)
                                //last_datas_duree_consultation.push(vm.Statistiques_patients_sexes_ages.rdv_last_11)
                            }
                            if (mois_duree_consultation.toString().includes('12')) {
                                current_datas_duree_consultation.push(vm.Statistiques_patients_sexes_ages.patient_consultation_current_duree_12)
                                //last_datas_duree_consultation.push(vm.Statistiques_patients_sexes_ages.rdv_last_12)
                            }

                            console.log("mois_duree_consultation " + mois_duree_consultation)


                            var Datas_evolution_duree_consultation = {
                                labels: mois_duree_consultation,// labels: ['1','2','3','4','5','6','7','8','9','10','11','12',],
                                datasets: [
                                    {
                                        label: "rdvs consultés l'année " + new Date(vm.Report_Filtre_Au).getFullYear(),
                                        backgroundColor: '#6f42c1',
                                        borderColor: '#6f42c1',
                                        pointRadius: true,
                                        pointColor: '#3b8bba',
                                        pointStrokeColor: 'rgba(60,141,188,1)',
                                        pointHighlightFill: '#fff',
                                        pointHighlightStroke: 'rgba(60,141,188,1)',
                                        data: current_datas_duree_consultation,
                                    },
                                    /*
                                     {
                                         label: "rdvs consultés l'année " + ((parseInt((new Date(vm.Report_Filtre_Au).getFullYear()))) - 1),
                                         backgroundColor: '#dc353557',
                                         borderColor: '#dc353557',
                                         pointRadius: true,
                                         pointColor: 'rgba(210, 214, 222, 1)',
                                         pointStrokeColor: '#c1c7d1',
                                         pointHighlightFill: '#fff',
                                         pointHighlightStroke: 'rgba(220,220,220,1)',
                                         data: last_datas_duree_consultation,
                                     },
                                     */

                                ]
                            }

                            Options_evolution_duree_consultation.datasetFill = false
                            Datas_evolution_duree_consultation.datasets[0].fill = false;
                            //Datas_evolution_duree_consultation.datasets[1].fill = false;

                            var lineChart = new Chart(Canvas_evolution_duree_consultation, {
                                type: 'bar',
                                data: Datas_evolution_duree_consultation,
                                options: Options_evolution_duree_consultation
                            })
                        })


                    }
                    else {
                        toastr.error(result.message, 'Erreur : ' + result.code);
                    }

                }, function (result) {
                    // this function handles error
                    console.log('PatientsController -> users error : ' + result);
                    toastr.error('Erreur apparue lors de l\'insertion');

                })//.catch(angular.noop);
                .catch(function (error) {
                    // handle errors
                    console.log('PatientsController -> Un probleme est survenu : ' + error);
                    toastr.error('Erreur apparue lors de l\'insertion');
                });

        }

        function Get_Statistiques_rdvs() {
            console.log("vm.Report_Filtre_Du " + vm.Report_Filtre_Du)
            ReportsService.Get_Statistiques_rdvs(vm.Report_Filtre_Du, vm.Report_Filtre_Au)
                .then(function (result) {
                    if (result.success) {
                        vm.Statistiques_rdvs = result.data;
                        vm.increment('nb_rdvs', vm.Statistiques_rdvs.rdvs);
                        $(function () {
                            //----------------------------------------------------
                            //- LINE CHART : chart_evolution_nb_rdv          -
                            //----------------------------------------------------
                            var Canvas_evolution_nb_rdv = $('#chart_evolution_nb_rdv').get(0).getContext('2d')
                            var Options_evolution_nb_rdv = {
                                maintainAspectRatio: true,
                                responsive: true,
                                legend: {
                                    display: true
                                },
                                scales: {
                                    xAxes: [{
                                        gridLines: {
                                            display: true,
                                        }
                                    }],
                                    yAxes: [{
                                        gridLines: {
                                            display: true,
                                        }
                                    }]
                                }
                            }

                            var mois_rdv = [];
                            if (new Date(vm.Report_Filtre_Du).getMonth() <= new Date(vm.Report_Filtre_Au).getMonth()) {
                                for (let index = new Date(vm.Report_Filtre_Du).getMonth(); index <= new Date(vm.Report_Filtre_Au).getMonth(); index++) {
                                    console.log("parseInt(index) " + parseInt(index))
                                    if ((parseInt(index) + 1) < 10) { mois_rdv.push("0" + (parseInt(index) + 1)); }
                                    else mois_rdv.push((parseInt(index) + 1));
                                    console.log("mois_rdv " + mois_rdv)
                                }
                            }
                            else {
                                for (let index = new Date(vm.Report_Filtre_Au).getMonth(); index <= new Date(vm.Report_Filtre_Du).getMonth(); index++) {
                                    console.log("parseInt(index) " + parseInt(index))
                                    if ((parseInt(index) + 1) < 10) { mois_rdv.push("0" + (parseInt(index) + 1)); }
                                    else mois_rdv.push((parseInt(index) + 1));
                                    console.log("mois_rdv " + mois_rdv);
                                }
                            }

                            console.log("mois_rdv " + mois_rdv);

                            var current_datas_nb_rdv = [];
                            var last_datas_nb_rdv = [];

                            if (mois_rdv.toString().includes('01')) {
                                current_datas_nb_rdv.push(vm.Statistiques_rdvs.rdv_current_01)
                                last_datas_nb_rdv.push(vm.Statistiques_rdvs.rdv_last_01)
                            }
                            if (mois_rdv.toString().includes('02')) {
                                current_datas_nb_rdv.push(vm.Statistiques_rdvs.rdv_current_02)
                                last_datas_nb_rdv.push(vm.Statistiques_rdvs.rdv_last_02)
                            }
                            if (mois_rdv.toString().includes('03')) {
                                current_datas_nb_rdv.push(vm.Statistiques_rdvs.rdv_current_03)
                                last_datas_nb_rdv.push(vm.Statistiques_rdvs.rdv_last_03)
                            }
                            if (mois_rdv.toString().includes('04')) {
                                current_datas_nb_rdv.push(vm.Statistiques_rdvs.rdv_current_04)
                                last_datas_nb_rdv.push(vm.Statistiques_rdvs.rdv_last_04)
                            }
                            if (mois_rdv.toString().includes('05')) {
                                current_datas_nb_rdv.push(vm.Statistiques_rdvs.rdv_current_05)
                                last_datas_nb_rdv.push(vm.Statistiques_rdvs.rdv_last_05)
                            }
                            if (mois_rdv.toString().includes('06')) {
                                current_datas_nb_rdv.push(vm.Statistiques_rdvs.rdv_current_06)
                                last_datas_nb_rdv.push(vm.Statistiques_rdvs.rdv_last_06)
                            }
                            if (mois_rdv.toString().includes('07')) {
                                current_datas_nb_rdv.push(vm.Statistiques_rdvs.rdv_current_07)
                                last_datas_nb_rdv.push(vm.Statistiques_rdvs.rdv_last_07)
                            }
                            if (mois_rdv.toString().includes('08')) {
                                current_datas_nb_rdv.push(vm.Statistiques_rdvs.rdv_current_08)
                                last_datas_nb_rdv.push(vm.Statistiques_rdvs.rdv_last_08)
                            }
                            if (mois_rdv.toString().includes('09')) {
                                current_datas_nb_rdv.push(vm.Statistiques_rdvs.rdv_current_09)
                                last_datas_nb_rdv.push(vm.Statistiques_rdvs.rdv_last_09)
                            }
                            if (mois_rdv.toString().includes('10')) {
                                current_datas_nb_rdv.push(vm.Statistiques_rdvs.rdv_current_10)
                                last_datas_nb_rdv.push(vm.Statistiques_rdvs.rdv_last_10)
                            }
                            if (mois_rdv.toString().includes('11')) {
                                current_datas_nb_rdv.push(vm.Statistiques_rdvs.rdv_current_11)
                                last_datas_nb_rdv.push(vm.Statistiques_rdvs.rdv_last_11)
                            }
                            if (mois_rdv.toString().includes('12')) {
                                current_datas_nb_rdv.push(vm.Statistiques_rdvs.rdv_current_12)
                                last_datas_nb_rdv.push(vm.Statistiques_rdvs.rdv_last_12)
                            }

                            console.log("mois_rdv " + mois_rdv)


                            var Datas_evolution_nb_rdv = {
                                labels: mois_rdv,// labels: ['1','2','3','4','5','6','7','8','9','10','11','12',],
                                datasets: [
                                    {
                                        label: "rdvs consultés l'année " + new Date(vm.Report_Filtre_Au).getFullYear(),
                                        backgroundColor: 'red',
                                        borderColor: 'red',
                                        pointRadius: true,
                                        pointColor: '#3b8bba',
                                        pointStrokeColor: 'rgba(60,141,188,1)',
                                        pointHighlightFill: '#fff',
                                        pointHighlightStroke: 'rgba(60,141,188,1)',
                                        data: current_datas_nb_rdv,
                                    },
                                    {
                                        label: "rdvs consultés l'année " + ((parseInt((new Date(vm.Report_Filtre_Au).getFullYear()))) - 1),
                                        backgroundColor: '#dc353557',
                                        borderColor: '#dc353557',
                                        pointRadius: true,
                                        pointColor: 'rgba(210, 214, 222, 1)',
                                        pointStrokeColor: '#c1c7d1',
                                        pointHighlightFill: '#fff',
                                        pointHighlightStroke: 'rgba(220,220,220,1)',
                                        data: last_datas_nb_rdv,
                                    },

                                ]
                            }

                            Options_evolution_nb_rdv.datasetFill = false
                            Datas_evolution_nb_rdv.datasets[0].fill = false;
                            Datas_evolution_nb_rdv.datasets[1].fill = false;

                            var lineChart = new Chart(Canvas_evolution_nb_rdv, {
                                type: 'line',
                                data: Datas_evolution_nb_rdv,
                                options: Options_evolution_nb_rdv
                            })
                        })
                    }
                    else {
                        toastr.error(result.message, 'Erreur : ' + result.code);
                    }
                }, function (result) {
                    // this function handles error
                    console.log('rdvsController -> users error : ' + result);
                    toastr.error('Erreur apparue lors de l\'insertion');

                })//.catch(angular.noop);
                .catch(function (error) {
                    // handle errors
                    console.log('rdvsController -> Un probleme est survenu : ' + error);
                    toastr.error('Erreur apparue lors de l\'insertion');
                });

        }

        function Get_Statistiques_Transactions() {
            console.log("vm.Report_Filtre_Du " + vm.Report_Filtre_Du)
            ReportsService.Get_Statistiques_Transactions(vm.Report_Filtre_Du, vm.Report_Filtre_Au)
                .then(function (result) {
                    if (result.success) {
                        vm.Statistiques_Transactions = result.data;
                        vm.increment('total_recettes_money', vm.Statistiques_Transactions.montant_credits);
                        vm.increment('total_depenses_money', vm.Statistiques_Transactions.montant_debits);
                        $(function () {
                            /*********************************************/
                            var pieChartCanvas_recettes_depenses = $('#chart_recettes_depenses').get(0).getContext('2d')
                            var pieData_recettes_depenses = {
                                labels: [
                                    'Recettes',
                                    'Dépenses',
                                ],
                                datasets: [{
                                    data: [
                                        vm.Statistiques_Transactions.montant_credits
                                        , vm.Statistiques_Transactions.montant_debits],
                                    backgroundColor: ['#17a2b8', 'brown',],
                                }]
                            }
                            var pieOptions_recettes_depenses = {
                                responsive: true,
                                title: {
                                    display: false,
                                    text: 'Legend Position: '
                                },
                                legend: {
                                    display: true,
                                    position: 'bottom',
                                }
                            }
                            //Create pie or douhnut chart
                            // You can switch between pie and douhnut using the method below.
                            var pieChart = new Chart(pieChartCanvas_recettes_depenses, {
                                type: 'pie',
                                data: pieData_recettes_depenses,
                                options: pieOptions_recettes_depenses
                            });
                            //----------------------------------------------------
                            //- LINE CHART : chart_evolution_nb_Transaction          -
                            //----------------------------------------------------
                            var Canvas_evolution_nb_Transaction = $('#chart_evolution_nb_Transaction').get(0).getContext('2d')
                            var Options_evolution_nb_Transaction = {
                                maintainAspectRatio: true,
                                responsive: true,
                                legend: {
                                    display: true
                                },
                                scales: {
                                    xAxes: [{
                                        gridLines: {
                                            display: true,
                                        }
                                    }],
                                    yAxes: [{
                                        gridLines: {
                                            display: true,
                                        }
                                    }]
                                }
                            }

                            var mois_Transaction = [];
                            if (new Date(vm.Report_Filtre_Du).getMonth() <= new Date(vm.Report_Filtre_Au).getMonth()) {
                                for (let index = new Date(vm.Report_Filtre_Du).getMonth(); index <= new Date(vm.Report_Filtre_Au).getMonth(); index++) {
                                    console.log("parseInt(index) " + parseInt(index))
                                    if ((parseInt(index) + 1) < 10) { mois_Transaction.push("0" + (parseInt(index) + 1)); }
                                    else mois_Transaction.push((parseInt(index) + 1));
                                    console.log("mois_Transaction " + mois_Transaction)
                                }
                            }
                            else {
                                for (let index = new Date(vm.Report_Filtre_Au).getMonth(); index <= new Date(vm.Report_Filtre_Du).getMonth(); index++) {
                                    console.log("parseInt(index) " + parseInt(index))
                                    if ((parseInt(index) + 1) < 10) { mois_Transaction.push("0" + (parseInt(index) + 1)); }
                                    else mois_Transaction.push((parseInt(index) + 1));
                                    console.log("mois_Transaction " + mois_Transaction);
                                }
                            }

                            console.log("mois_Transaction " + mois_Transaction);

                            var current_datas_nb_Transaction = [];
                            var last_datas_nb_Transaction = [];

                            if (mois_Transaction.toString().includes('01')) {
                                current_datas_nb_Transaction.push(vm.Statistiques_Transactions.recettes_01)
                                last_datas_nb_Transaction.push(-vm.Statistiques_Transactions.depenses_01)
                            }
                            if (mois_Transaction.toString().includes('02')) {
                                current_datas_nb_Transaction.push(vm.Statistiques_Transactions.recettes_02)
                                last_datas_nb_Transaction.push(-vm.Statistiques_Transactions.depenses_02)
                            }
                            if (mois_Transaction.toString().includes('03')) {
                                current_datas_nb_Transaction.push(vm.Statistiques_Transactions.recettes_03)
                                last_datas_nb_Transaction.push(-vm.Statistiques_Transactions.depenses_03)
                            }
                            if (mois_Transaction.toString().includes('04')) {
                                current_datas_nb_Transaction.push(vm.Statistiques_Transactions.recettes_04)
                                last_datas_nb_Transaction.push(-vm.Statistiques_Transactions.depenses_04)
                            }
                            if (mois_Transaction.toString().includes('05')) {
                                current_datas_nb_Transaction.push(vm.Statistiques_Transactions.recettes_05)
                                last_datas_nb_Transaction.push(-vm.Statistiques_Transactions.depenses_05)
                            }
                            if (mois_Transaction.toString().includes('06')) {
                                current_datas_nb_Transaction.push(vm.Statistiques_Transactions.recettes_06)
                                last_datas_nb_Transaction.push(-vm.Statistiques_Transactions.depenses_06)
                            }
                            if (mois_Transaction.toString().includes('07')) {
                                current_datas_nb_Transaction.push(vm.Statistiques_Transactions.recettes_07)
                                last_datas_nb_Transaction.push(-vm.Statistiques_Transactions.depenses_07)
                            }
                            if (mois_Transaction.toString().includes('08')) {
                                current_datas_nb_Transaction.push(vm.Statistiques_Transactions.recettes_08)
                                last_datas_nb_Transaction.push(-vm.Statistiques_Transactions.depenses_08)
                            }
                            if (mois_Transaction.toString().includes('09')) {
                                current_datas_nb_Transaction.push(vm.Statistiques_Transactions.recettes_09)
                                last_datas_nb_Transaction.push(-vm.Statistiques_Transactions.depenses_09)
                            }
                            if (mois_Transaction.toString().includes('10')) {
                                current_datas_nb_Transaction.push(vm.Statistiques_Transactions.recettes_10)
                                last_datas_nb_Transaction.push(-vm.Statistiques_Transactions.depenses_10)
                            }
                            if (mois_Transaction.toString().includes('11')) {
                                current_datas_nb_Transaction.push(vm.Statistiques_Transactions.recettes_11)
                                last_datas_nb_Transaction.push(-vm.Statistiques_Transactions.depenses_11)
                            }
                            if (mois_Transaction.toString().includes('12')) {
                                current_datas_nb_Transaction.push(vm.Statistiques_Transactions.recettes_12)
                                last_datas_nb_Transaction.push(-vm.Statistiques_Transactions.depenses_12)
                            }

                            console.log("mois_Transaction " + mois_Transaction)


                            var Datas_evolution_nb_Transaction = {
                                labels: mois_Transaction,// labels: ['1','2','3','4','5','6','7','8','9','10','11','12',],
                                datasets: [
                                    {
                                        label: "Recettes de l'année " + new Date(vm.Report_Filtre_Au).getFullYear(),
                                        backgroundColor: '#17a2b8',
                                        borderColor: '#17a2b8',
                                        pointRadius: true,
                                        pointColor: '#3b8bba',
                                        pointStrokeColor: 'rgba(60,141,188,1)',
                                        pointHighlightFill: '#fff',
                                        pointHighlightStroke: 'rgba(60,141,188,1)',
                                        data: current_datas_nb_Transaction,
                                    },
                                    {
                                        label: "Dépenses de l'année " + parseInt(new Date(vm.Report_Filtre_Au).getFullYear()),
                                        backgroundColor: 'brown',
                                        borderColor: 'brown',
                                        pointRadius: true,
                                        pointColor: 'rgba(210, 214, 222, 1)',
                                        pointStrokeColor: '#c1c7d1',
                                        pointHighlightFill: '#fff',
                                        pointHighlightStroke: 'rgba(220,220,220,1)',
                                        data: last_datas_nb_Transaction,
                                    },

                                ]
                            }

                            Options_evolution_nb_Transaction.datasetFill = false
                            Datas_evolution_nb_Transaction.datasets[0].fill = false;
                            Datas_evolution_nb_Transaction.datasets[1].fill = false;

                            var lineChart = new Chart(Canvas_evolution_nb_Transaction, {
                                type: 'line',
                                data: Datas_evolution_nb_Transaction,
                                options: Options_evolution_nb_Transaction
                            })




                        })


                    }
                    else {
                        toastr.error(result.message, 'Erreur : ' + result.code);
                    }

                }, function (result) {
                    // this function handles error
                    console.log('TransactionsController -> users error : ' + result);
                    toastr.error('Erreur apparue lors de l\'insertion');

                })//.catch(angular.noop);
                .catch(function (error) {
                    // handle errors
                    console.log('TransactionsController -> Un probleme est survenu : ' + error);
                    toastr.error('Erreur apparue lors de l\'insertion');
                });

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

                    if (element_id.toString().includes("money")) $el.text($rootScope.StringToMoney(end_value));
                    else $el.text(end_value);
                });

            })
        }

        function Filter_Dates_Changes() {
            Get_Statistiques_patients_sexes_ages();
            Get_Statistiques_rdvs();
            Get_Statistiques_Transactions();
        }
    }

})();
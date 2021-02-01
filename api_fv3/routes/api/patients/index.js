'use strict'

module.exports = async function (fastify, opts) {
    /*
    if (!license.F1) {
        console.log("license Has Feature 1  ");
       return 'license error'
      }
    */

    //Get all patients  
    fastify.get('/get_all_patients', async (request, reply) => {
        const p_org_id = request.org_id;
        const p_user_id = request.user_id;
        if (!global.license.F1) {return false}

        const { rows } = await fastify.pg.query(
            " SELECT id, nin, nom, nom_jeune_fille, prenom, sexe, to_char(date_naiss,\'dd/MM/yyyy\') date_naiss,  EXTRACT ( YEARS FROM age(now(), date_naiss)) age,"
            + " CASE WHEN (EXTRACT ( YEARS FROM age(now(), date_naiss)))< 18 THEN false ELSE true END is_adult,type_date_naiss, lieu_naiss, adresse,"
            + " situation_familiale, ppere, nmere, pmere, lib, tel, email, created, createdby, updated, updatedby,COALESCE(active,false::boolean) active,"
            + " uuid, wilaya_id, wilaya, commune_id, commune, users_id, cree_par, org_id, org,"
            + " nb_vitals,nb_pathologies, nb_radiographies, nb_traitements, nb_ordonnances, nb_certificats, "
            + " nb_rdvs, nb_versements, total_montant_actes, total_montant_verse"
            + " FROM public.vue_patients  WHERE org_id=$1 ORDER BY id;", [p_org_id],
        )


        return rows
    })

    //Add patient
    fastify.post('/add_patient', (request, reply) => {
        // will return a promise, fastify will send the result automatically
        return fastify.pg.transact(async client => {
            const p_org_id = request.org_id;
            const p_user_id = request.user_id;
            const { nin, nom, nom_jeune_fille, prenom, sexe, date_naiss, type_date_naiss, lieu_naiss, adresse,
                commune_id, wilaya_id, situation_familiale, ppere, nmere, pmere, tel, email, active } = request.body;

            const added_patient_id = (await fastify.pg.query("INSERT INTO public.patients( "
                + " org_id,nin, nom, nom_jeune_fille, prenom, sexe, date_naiss, type_date_naiss, lieu_naiss, adresse, "
                + " commune_id, wilaya_id, situation_familiale, ppere, nmere, pmere,tel, email, "
                + " created, createdby, updated, updatedby, active) "
                + " VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,now(),$19,now(),$20,true) RETURNING id ",
                [p_org_id, nin, nom, nom_jeune_fille, prenom, sexe, date_naiss, type_date_naiss, lieu_naiss, adresse,
                    commune_id, wilaya_id, situation_familiale, ppere, nmere, pmere, tel, email, p_user_id, p_user_id])).rows[0].id;
            if (added_patient_id) {
                const { rows } = await fastify.pg.query(
                    " SELECT id, nin, nom, nom_jeune_fille, prenom, sexe, to_char(date_naiss,\'dd/MM/yyyy\') date_naiss,  EXTRACT ( YEARS FROM age(now(), date_naiss)) age,"
                    + " CASE WHEN (EXTRACT ( YEARS FROM age(now(), date_naiss)))< 18 THEN false ELSE true END is_adult,type_date_naiss, lieu_naiss, adresse,"
                    + " situation_familiale, ppere, nmere, pmere, lib, tel, email, created, createdby, updated, updatedby,COALESCE(active,false::boolean) active,"
                    + " uuid, wilaya_id, wilaya, commune_id, commune, users_id, cree_par, org_id, org,nb_pathologies, nb_radiographies, nb_traitements, nb_ordonnances, nb_certificats, "
                    + " nb_rdvs, nb_versements, total_montant_actes, total_montant_verse"
                    + " FROM public.vue_patients  WHERE org_id=$1 ORDER BY id;", [p_org_id],
                )
                return rows
            }
        }).catch((err) => {
            //err.message = 'Erreur de modification'
            throw err
        })
    })

    //Edit patients
    fastify.put('/edit_patient', (request, reply) => {
        // will return a promise, fastify will send the result automatically
        return fastify.pg.transact(async client => {
            const p_org_id = request.org_id;
            const p_user_id = request.user_id;
            const { id, nin, nom, nom_jeune_fille, prenom, sexe, date_naiss, type_date_naiss, lieu_naiss, adresse,
                commune_id, wilaya_id, situation_familiale, ppere, nmere, pmere, tel, email, active } = request.body;

            const Edited_patient_id = (await fastify.pg.query("UPDATE patients SET "
                + " nin = $2, nom = $3, nom_jeune_fille = $4, prenom = $5, sexe = $6, date_naiss = $7, type_date_naiss = $8, "
                + " lieu_naiss = $9, adresse = $10, "
                + " commune_id = $11, wilaya_id = $12, situation_familiale = $13, ppere = $14, nmere = $15, pmere = $16,tel = $17, email = $18, "
                + " active = $19, created = now(), createdby = $20, updated = now(), updatedby = $21  WHERE id=$1 RETURNING id;",
                [id, nin, nom, nom_jeune_fille, prenom, sexe, date_naiss, type_date_naiss, lieu_naiss, adresse,
                    commune_id, wilaya_id, situation_familiale, ppere, nmere, pmere, tel, email, active, p_user_id, p_user_id])).rows[0].id;

            if (Edited_patient_id) {
                const { rows } = await fastify.pg.query(
                    " SELECT id, nin, nom, nom_jeune_fille, prenom, sexe, to_char(date_naiss,\'dd/MM/yyyy\') date_naiss,  EXTRACT ( YEARS FROM age(now(), date_naiss)) age,"
                    + " CASE WHEN (EXTRACT ( YEARS FROM age(now(), date_naiss)))< 18 THEN false ELSE true END is_adult,type_date_naiss, lieu_naiss, adresse,"
                    + " situation_familiale, ppere, nmere, pmere, lib, tel, email, created, createdby, updated, updatedby,COALESCE(active,false::boolean) active,"
                    + " uuid, wilaya_id, wilaya, commune_id, commune, users_id, cree_par, org_id, org,nb_pathologies, nb_radiographies, nb_traitements, nb_ordonnances, nb_certificats, "
                    + " nb_rdvs, nb_versements, total_montant_actes, total_montant_verse"
                    + " FROM public.vue_patients  WHERE org_id=$1 ORDER BY id;", [p_org_id],
                )
                return rows
            }
        }).catch((err) => {
            //err.message = 'Erreur de modification'
            throw err
        })
    })
    /*******************************************************************************************************************/
    /*** Patient_Vitals ***/
    //Get all patient vitals
    fastify.post('/get_all_patient_vitals', async (request, reply) => {
        const p_org_id = request.org_id;
        const p_user_id = request.user_id;
        const patient_id = request.body;
      //  console.log("patient_id " + patient_id)

        const { rows } = await fastify.pg.query(
            " SELECT patient_vitals.id, patient_id, vital_id, vitals.designation vital,valeur "
            + " FROM public.patient_vitals INNER JOIN vitals ON vitals.id = vital_id WHERE patient_id = $1 order by patient_vitals.id;", [patient_id]);

        return rows

    })

    //Add patient vital
    fastify.post('/add_patient_vital', (request, reply) => {
        // will return a promise, fastify will send the result automatically
        return fastify.pg.transact(async client => {
            const p_user_id = request.user_id;
            const { patient_id, vital_id, selected_valeur } = request.body;

            const id = (await fastify.pg.query("INSERT INTO public.patient_vitals("
                + "patient_id, vital_id,  valeur, created, createdby, updated, updatedby, active)"
                + " VALUES ($1,$2,$3,now(),$4,now(),$5,true) RETURNING id ",
                [patient_id, vital_id, selected_valeur, p_user_id, p_user_id])).rows;
          //  console.log("id " + id)
            const patient_vital = (await fastify.pg.query(
                " SELECT patient_vitals.id, patient_id, vital_id, vitals.designation vital, valeur "
                + " FROM public.patient_vitals INNER JOIN vitals ON vitals.id = vital_id WHERE patient_id = $1 order by patient_vitals.id; ", [patient_id])).rows;
            return patient_vital
        }).catch((err) => {
            //err.message = 'Erreur de modification'
            throw err
        })
    })

    //Delete patient vital
    fastify.delete('/delete_patient_vital/:patient_vital_id', (request, reply) => {
        return fastify.pg.transact(async client => {
            const { rows } = await fastify.pg.query("DELETE FROM patient_vitals WHERE id = $1 RETURNING id ",
                [request.params.patient_vital_id]
            )
            return rows
        }).catch((err) => {
            //err.message = 'Erreur de modification'
            throw err
        })
    })
    /*******************************************************************************************************************/
    /*** Patient_Pathologies ***/
    //Get all patient  pathologies
    fastify.post('/get_all_patient_pathologies', async (request, reply) => {
        const p_org_id = request.org_id;
        const p_user_id = request.user_id;
        const patient_id = request.body;
       // console.log("patient_id " + patient_id)

        const { rows } = await fastify.pg.query(
            " SELECT patient_pathologies.id, patient_id, pathologie_id, pathologies.designation pathologie,severite_id,severites.designation severite, explicatif "
            + " FROM public.patient_pathologies INNER JOIN pathologies ON pathologies.id = pathologie_id LEFT JOIN severites ON severites.id = severite_id WHERE patient_id = $1 ORDER BY patient_pathologies.id;", [patient_id]);

        return rows

    })

    //Add patient pathologie
    fastify.post('/add_patient_pathologie', (request, reply) => {
        // will return a promise, fastify will send the result automatically
        return fastify.pg.transact(async client => {
            const p_user_id = request.user_id;
            const { patient_id, pathologie_id, severite_id, selected_explicatif } = request.body;

            const id = (await fastify.pg.query("INSERT INTO public.patient_pathologies("
                + "patient_id, pathologie_id, severite_id, explicatif, created, createdby, updated, updatedby, active)"
                + " VALUES ($1,$2,$3,$4,now(),$5,now(),$6,true) RETURNING id ",
                [patient_id, pathologie_id, severite_id, selected_explicatif, p_user_id, p_user_id])).rows;
       //     console.log("id " + id)
            const patient_pathologie = (await fastify.pg.query(
                " SELECT patient_pathologies.id, patient_id, pathologie_id, pathologies.designation pathologie,severite_id,severites.designation severite, explicatif "
                + " FROM public.patient_pathologies INNER JOIN pathologies ON pathologies.id = pathologie_id LEFT JOIN severites ON severites.id = severite_id WHERE patient_id = $1 ORDER BY patient_pathologies.id;", [patient_id])).rows;
            return patient_pathologie
        }).catch((err) => {
            //err.message = 'Erreur de modification'
            throw err
        })
    })

    //Delete patient pathologie
    fastify.delete('/delete_patient_pathologie/:patient_pathologie_id', (request, reply) => {
        return fastify.pg.transact(async client => {
            const { rows } = await fastify.pg.query("DELETE FROM patient_pathologies WHERE id = $1 RETURNING id ", [request.params.patient_pathologie_id]
            )
            return rows
        }).catch((err) => {
            //err.message = 'Erreur de modification'
            throw err
        })
    })
    /*******************************************************************************************************************/
    /*** Patient_Radiographies ***/
    //Get all patient  radiographies
    fastify.post('/get_all_patient_radiographies', async (request, reply) => {
        const p_org_id = request.org_id;
        const p_user_id = request.user_id;
        const patient_id = request.body;
        //console.log("patient_id " + patient_id)

        const { rows } = await fastify.pg.query(
            " SELECT patient_radiographies.id, patient_id, radiographie_id, radiographies.designation,gravite, explicatif,file_name "
            + " FROM public.patient_radiographies INNER JOIN radiographies ON radiographies.id = radiographie_id WHERE patient_id = $1 ORDER BY patient_radiographies.id;", [patient_id],
        )


        return rows
    })

    //Add patient radiographie
    fastify.post('/add_patient_radiographie', (request, reply) => {
        // will return a promise, fastify will send the result automatically
        return fastify.pg.transact(async client => {
            const p_user_id = request.user_id;
            const { patient_id, radiographie_id, selected_explicatif, file_name } = request.body;

            const id = (await fastify.pg.query("INSERT INTO public.patient_radiographies("
                + "patient_id, radiographie_id, explicatif,file_name, created, createdby, updated, updatedby, active)"
                + " VALUES ($1,$2,$3,$4,now(),$5,now(),$6,true) RETURNING id ",
                [patient_id, radiographie_id, selected_explicatif, file_name, p_user_id, p_user_id])).rows;
           // console.log("id " + id)
            const patient_radiographie = (await fastify.pg.query(
                " SELECT patient_radiographies.id, patient_id, radiographie_id, radiographies.designation,gravite, explicatif,file_name "
                + " FROM public.patient_radiographies INNER JOIN radiographies ON radiographies.id = radiographie_id WHERE patient_id = $1 ORDER BY patient_radiographies.id;", [patient_id])).rows;
            return patient_radiographie
        }).catch((err) => {
            //err.message = 'Erreur de modification'
            throw err
        })
    })

    //Delete patient radiographie
    fastify.delete('/delete_patient_radiographie/:patient_radiographie_id', (request, reply) => {
        return fastify.pg.transact(async client => {
            const { rows } = await fastify.pg.query("DELETE FROM patient_radiographies WHERE id = $1 RETURNING id ", [request.params.patient_radiographie_id]
            )
            return rows
        }).catch((err) => {
            //err.message = 'Erreur de modification'
            throw err
        })
    })

    /********** Upload Patient Radiographies Documents ************/
    const multer = require('fastify-multer')
    fastify.register(multer.contentParser)
    var crypto = require('crypto');
    var mime = require('mime-types');

    const storage = multer.diskStorage({
        destination: function (req, file, cb) {
            cb(null, '../patients/radiographies/')

        },
        filename: function (req, file, cb) {
            crypto.pseudoRandomBytes(16, function (err, raw) {
                var old_file_name = raw.toString('hex') + Date.now() + '.' + mime.extension(file.mimetype);
                req.old_file_name = old_file_name;
                cb(null, old_file_name);
            });

        }
    })

    const upload = multer({ storage: storage })
    const cpUpload = upload.fields([{ name: 'file', maxCount: 1 },])

    var fs = require('fs');

    fastify.post('/radio_document', { preHandler: cpUpload }, async (request, reply) => {
        //console.log('old_file_name ' + request.old_file_name)
       // console.log('new_file_name' + request.body.fileName)

        fs.rename('../patients/radiographies/' + request.old_file_name, '../patients/radiographies/' + request.body.fileName, function (err) {
            if (err) console.log('ERROR: ' + err);
        });

        return { success: true }
    })

    const path = require('path')
    fastify.register(require('fastify-static'), {
        root: path.join(__dirname, ''),
    })

    fastify.get('/download_radio_document/:fileName', function (request, reply) {

        if (request.params.fileName) {
         //  console.log('request.body.fileName ' + request.params.fileName)
            reply.sendFile(request.params.fileName) // serving a file from a different root location
        } else
            return {
                success: false
            }
    })

    /**********************************************************************************************************/
    /*** Patient_Traitements ***/
    //Get all patient  traitements
    fastify.post('/get_all_patient_traitements', async (request, reply) => {
        const p_org_id = request.org_id;
        const p_user_id = request.user_id;
        const patient_id = request.body;
       // console.log("patient_id " + patient_id)

        const { rows } = await fastify.pg.query(
            " SELECT patient_traitements.id,date_traitement, patient_id,dent_num,"
            + " patient_traitements.procedure_id,procedures.designation \"procedure\","
            + " acte_id, actes.designation \"acte\", patient_traitements.montant,observation,patient_traitements.created"
            + " FROM public.patient_traitements "
            + " INNER JOIN procedures ON procedures.id = procedure_id "
            + " INNER JOIN actes ON actes.id = acte_id WHERE patient_id = $1 ORDER BY patient_traitements.id;", [patient_id],
        )


        return rows
    })

    //Add patient traitement
    fastify.post('/add_patient_traitement', (request, reply) => {
        // will return a promise, fastify will send the result automatically
        return fastify.pg.transact(async client => {
            const p_user_id = request.user_id;
            const { patient_id, Selected_Patient_Traitement_Date, Selected_Dent, Selected_Patient_Traitement_Procedure, Selected_Patient_Traitement_Acte, Selected_Patient_Traitement_Montant, Selected_Patient_Traitement_Observation } = request.body;

            const id = (await fastify.pg.query("INSERT INTO public.patient_traitements("
                + "patient_id,date_traitement, dent_num, procedure_id, acte_id, montant, observation, created, createdby, updated, updatedby, active)"
                + " VALUES ($1,$2,$3,$4,$5,$6,$7,now(),$8,now(),$9,true) RETURNING id ",
                [patient_id, Selected_Patient_Traitement_Date, Selected_Dent, Selected_Patient_Traitement_Procedure, Selected_Patient_Traitement_Acte, Selected_Patient_Traitement_Montant, Selected_Patient_Traitement_Observation, p_user_id, p_user_id])).rows;
          //  console.log("id " + id)
            const patient_traitement = (await fastify.pg.query(
                " SELECT patient_traitements.id, patient_id,date_traitement,dent_num,"
                + " patient_traitements.procedure_id,procedures.designation \"procedure\","
                + " acte_id, actes.designation \"acte\", patient_traitements.montant,observation,patient_traitements.created"
                + " FROM public.patient_traitements "
                + " INNER JOIN procedures ON procedures.id = procedure_id "
                + " INNER JOIN actes ON actes.id = acte_id WHERE patient_id = $1 ORDER BY patient_traitements.id;", [patient_id])).rows;
            return patient_traitement
        }).catch((err) => {
            //err.message = 'Erreur de modification'
            throw err
        })
    })

    //Delete patient traitement
    fastify.delete('/delete_patient_traitement/:patient_traitement_id', (request, reply) => {
        return fastify.pg.transact(async client => {
            const { rows } = await fastify.pg.query("DELETE FROM patient_traitements WHERE id = $1 RETURNING id ", [request.params.patient_traitement_id]
            )
            return rows
        }).catch((err) => {
            //err.message = 'Erreur de modification'
            throw err
        })
    })

    /**********************************************************************************************************/
    /*** Patient_Ordonnances ***/
    //Get all patient  ordonnances
    fastify.post('/get_all_patient_ordonnances', async (request, reply) => {
        const p_org_id = request.org_id;
        const p_user_id = request.user_id;
        const patient_id = request.body;
      //  console.log("patient_id " + patient_id)

        const { rows } = await fastify.pg.query(
            " SELECT  id, patient_id,numero_ordonnance, date_ordonnance, observation, details "
            + " FROM public.vue_patients_ordonnances   WHERE patient_id = $1 order by id;", [patient_id],
        )


        return rows
    })

    //Add patient ordonnance
    fastify.post('/add_patient_ordonnance', (request, reply) => {
        // will return a promise, fastify will send the result automatically
        return fastify.pg.transact(async client => {
            const p_user_id = request.user_id;
            const { patient_id, Selected_Patient_Ordonnance_Date, Selected_Patient_Ordonnance_Numero, Selected_Patient_Ordonnance_Details, Selected_Patient_Ordonnance_Observation } = request.body;

            const ordonnance_id = (await fastify.pg.query("INSERT INTO public.patient_ordonnances("
                + "patient_id,date_ordonnance, numero_ordonnance, observation, created, createdby, updated, updatedby, active)"
                + " VALUES ($1,$2,$3,$4,now(),$5,now(),$6,true) RETURNING id ",
                [patient_id, Selected_Patient_Ordonnance_Date, Selected_Patient_Ordonnance_Numero, Selected_Patient_Ordonnance_Observation, p_user_id, p_user_id])).rows[0].id;
        //    console.log("ordonnance_id " + ordonnance_id)

            if (ordonnance_id) {
                [Selected_Patient_Ordonnance_Details][0].forEach(async (detail, index) => {
                    fastify.log.info(`detail ` + detail.medicament);
                    const { medicament, ordonnance_posologies_id, observation } = detail;
                    if (medicament && ordonnance_posologies_id) {
                        await fastify.pg.query("INSERT INTO public.patient_ordonnances_details( "
                            + " ordonnance_id, medicament_id, ordonnance_posologies_id, observation, updatedby,  createdby,created, updated, active)"
                            + " VALUES ($1,$2,$3,$4,$5,$6,now(),now(),true)",
                            [ordonnance_id, medicament, ordonnance_posologies_id, observation, p_user_id, p_user_id])
                    }
                })
            }

            //Selected_Patient_Ordonnance_Details
            const patient_ordonnance = (await fastify.pg.query(
                " SELECT  id, patient_id,numero_ordonnance, date_ordonnance, observation, details "
                + " FROM public.vue_patients_ordonnances   WHERE patient_id = $1 order by id;", [patient_id])).rows;
            return patient_ordonnance
        }).catch((err) => {
            //err.message = 'Erreur de modification'
            throw err
        })
    })

    //Delete patient ordonnance
    fastify.delete('/delete_patient_ordonnance/:patient_ordonnance_id', (request, reply) => {
        return fastify.pg.transact(async client => {
            const { rows } = await fastify.pg.query("DELETE FROM patient_ordonnances WHERE id = $1 RETURNING id ", [request.params.patient_ordonnance_id]
            )
            return rows
        }).catch((err) => {
            //err.message = 'Erreur de modification'
            throw err
        })
    })

    /**********************************************************************************************************/
    /*** Patient_Certificats ***/
    //Get all patient  certificats
    fastify.post('/get_all_patient_certificats', async (request, reply) => {
        const p_org_id = request.org_id;
        const p_user_id = request.user_id;
        const patient_id = request.body;
      //  console.log("patient_id " + patient_id)

        const { rows } = await fastify.pg.query(
            " SELECT  patient_certificats.id, patient_id,numero_certificat, date_certificat,certificat_motifs.designation motif, observation "
            + " FROM public.patient_certificats INNER JOIN certificat_motifs "
            + " ON patient_certificats.certificat_motifs_id = certificat_motifs.id   WHERE patient_id = $1 order by patient_certificats.id;", [patient_id],
        )


        return rows
    })

    //Add patient certificat
    fastify.post('/add_patient_certificat', (request, reply) => {
        // will return a promise, fastify will send the result automatically
        return fastify.pg.transact(async client => {
            const p_user_id = request.user_id;
            const { patient_id, Selected_Patient_Certificat_Date, Selected_Patient_Certificat_Numero, Selected_Patient_Certificat_certificat_motifs_id, Selected_Patient_Certificat_Observation } = request.body;

            const certificat_id = (await fastify.pg.query("INSERT INTO public.patient_certificats("
                + "patient_id,date_certificat, numero_certificat, certificat_motifs_id,observation, created, createdby, updated, updatedby, active)"
                + " VALUES ($1,$2,$3,$4,$5,now(),$6,now(),$7,true) RETURNING id ",
                [patient_id, Selected_Patient_Certificat_Date, Selected_Patient_Certificat_Numero, Selected_Patient_Certificat_certificat_motifs_id, Selected_Patient_Certificat_Observation, p_user_id, p_user_id])).rows[0].id;
          //  console.log("certificat_id " + certificat_id)

            //Selected_Patient_Certificat_Details
            const patient_certificat = (await fastify.pg.query(
                " SELECT  patient_certificats.id, patient_id,numero_certificat, date_certificat,certificat_motifs.designation motif, observation "
                + " FROM public.patient_certificats INNER JOIN certificat_motifs "
                + " ON patient_certificats.certificat_motifs_id = certificat_motifs.id   WHERE patient_id = $1 order by patient_certificats.id;", [patient_id])).rows;
            return patient_certificat
        }).catch((err) => {
            //err.message = 'Erreur de modification'
            throw err
        })
    })

    //Delete patient certificat
    fastify.delete('/delete_patient_certificat/:patient_certificat_id', (request, reply) => {
        return fastify.pg.transact(async client => {
            const { rows } = await fastify.pg.query("DELETE FROM patient_certificats WHERE id = $1 RETURNING id ", [request.params.patient_certificat_id]
            )
            return rows
        }).catch((err) => {
            //err.message = 'Erreur de modification'
            throw err
        })
    })

    /**********************************************************************************************************/
    /*** org_transactions ***/
    //Get all patient  versements
    fastify.post('/get_all_patient_versements', async (request, reply) => {
        const p_org_id = request.org_id;
        const p_user_id = request.user_id;
        const patient_id = request.body;
        //console.log("patient_id " + patient_id)

        const { rows } = await fastify.pg.query(
            " SELECT id, org_id, org, type_transaction_id, type_transaction, type_paiement_id, type_paiement, "
            + " patient_id, patient, date_transaction, montant, observation, created, createdby, updated, updatedby, active "
            + " FROM public.vue_orgs_transactions  WHERE patient_id = $1 order by id;", [patient_id],
        )
        return rows
    })

    //Add patient versement
    fastify.post('/add_patient_versement', (request, reply) => {
        // will return a promise, fastify will send the result automatically
        return fastify.pg.transact(async client => {
            const p_org_id = request.org_id;
            const p_user_id = request.user_id;
            const { patient_id, Selected_Patient_Versement_Date, Selected_Patient_Versement_Montant, Selected_Type, Selected_Patient_Versement_Observation } = request.body;

            const id = (await fastify.pg.query("INSERT INTO public.org_transactions("
                + "org_id,patient_id,type_transaction_id,date_transaction, montant,type_paiement_id, observation, created, createdby, updated, updatedby, active)"
                + " VALUES ($1,$2,$3,$4,$5,$6,$7,now(),$8,now(),$9,true) RETURNING id ",
                [p_org_id, patient_id, 1, Selected_Patient_Versement_Date, Selected_Patient_Versement_Montant, Selected_Type, Selected_Patient_Versement_Observation, p_user_id, p_user_id])).rows;
         //   console.log("id " + id)

            const patient_versement = (await fastify.pg.query(
                " SELECT id, org_id, org, type_transaction_id, type_transaction, type_paiement_id, type_paiement, "
                + " patient_id, patient, date_transaction, montant, observation, created, createdby, updated, updatedby, active "
                + " FROM public.vue_orgs_transactions  WHERE patient_id = $1 order by id;", [patient_id])).rows;
            return patient_versement
        }).catch((err) => {
            //err.message = 'Erreur de modification'
            throw err
        })
    })

    //Delete patient versement
    fastify.delete('/delete_patient_versement/:patient_versement_id', (request, reply) => {
        return fastify.pg.transact(async client => {
            const { rows } = await fastify.pg.query("DELETE FROM org_transactions WHERE id = $1 RETURNING id ", [request.params.patient_versement_id]
            )
            return rows
        }).catch((err) => {
            //err.message = 'Erreur de modification'
            throw err
        })
    })


    //Get total cout et total versement
    fastify.post('/get_total_actes_total_versements', async (request, reply) => {
        const p_org_id = request.org_id;
        const p_user_id = request.user_id;
        const patient_id = request.body;
      //  console.log("patient_id " + patient_id)

        const { rows } = await fastify.pg.query(
            " SELECT id,total_montant_actes,total_montant_verse"
            + " FROM public.vue_patients  WHERE id = $1;", [patient_id],
        )


        return rows
    })


    /**********************************************************************************************************/



}//End Module

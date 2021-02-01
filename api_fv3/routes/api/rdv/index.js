'use strict'

module.exports = async function (fastify, opts) {

    /*** Patient_RDVs ***/
    //Get all patient  rdvs
    fastify.post('/get_all_rdvs', async (request, reply) => {
        const p_org_id = request.org_id;
        const p_user_id = request.user_id;
        if (!global.license.F2) {return false}
        
        const { rows } = await fastify.pg.query(
            "SELECT patient_rdvs.id, patient_rdvs.patient_id,patients.nom ||' '||patients.prenom patient,patients.email,title,motif_id, etat_id,etats.designation etat, color, startsat, endsat,reminder_sent, draggable, "
            + " resizable, patient_rdvs.created, patient_rdvs.createdby, patient_rdvs.updated, patient_rdvs.updatedby, patient_rdvs.active "
            + " FROM public.patient_rdvs INNER JOIN patients ON patients.id = patient_rdvs.patient_id INNER JOIN users ON users.id = patient_rdvs.createdby INNER JOIN etats ON etats.id = patient_rdvs.etat_id WHERE users.org_id= $1 order by startsat;", [p_org_id],
        )
    
        
        return rows
    })

    //Add patient rdv
    fastify.post('/add_rdv', (request, reply) => {
        // will return a promise, fastify will send the result automatically
        return fastify.pg.transact(async client => {
            const p_org_id = request.org_id;
            const p_user_id = request.user_id;
            const { patient_id, Selected_Patient_RDV_title, Selected_Patient_RDV_Motif_id, Selected_Patient_RDV_Color, Selected_Patient_RDV_Etat, Selected_Patient_RDV_startsAt, Selected_Patient_RDV_endsAt } = request.body;

            const new_rdv_id = (await fastify.pg.query("INSERT INTO public.patient_rdvs("
                + "patient_id,title,motif_id, color,etat_id, startsat, endsat, created, createdby, updated, updatedby, active)"
                + " VALUES ($1,$2,$3,$4,$5,$6,$7,now(),$8,now(),$9,true) RETURNING id ",
                [patient_id, Selected_Patient_RDV_title, Selected_Patient_RDV_Motif_id, Selected_Patient_RDV_Color, Selected_Patient_RDV_Etat, Selected_Patient_RDV_startsAt, Selected_Patient_RDV_endsAt, p_user_id, p_user_id])).rows[0].id;
          //  console.log("new_rdv_id " + new_rdv_id)
            if (new_rdv_id) {
                const { rows } = await fastify.pg.query(
                    "SELECT patient_rdvs.id, patient_rdvs.patient_id,patients.nom ||' '||patients.prenom patient,patients.email,title,motif_id, etat_id,etats.designation etat, color, startsat, endsat,reminder_sent, draggable, "
                    + " resizable, patient_rdvs.created, patient_rdvs.createdby, patient_rdvs.updated, patient_rdvs.updatedby, patient_rdvs.active "
                    + " FROM public.patient_rdvs INNER JOIN patients ON patients.id = patient_rdvs.patient_id INNER JOIN users ON users.id = patient_rdvs.createdby INNER JOIN etats ON etats.id = patient_rdvs.etat_id WHERE users.org_id= $1 order by startsat;", [p_org_id],
                )
                return rows;
            }
        }).catch((err) => {
            //err.message = 'Erreur de modification'
            throw err
        })
    })

    // Update patient rdv
    fastify.put('/edit_rdv', (request, reply) => {
        // will return a promise, fastify will send the result automatically
        return fastify.pg.transact(async client => {
            const p_org_id = request.org_id;
            const p_user_id = request.user_id;
            const { Selected_Patient_id, Selected_Patient_RDV_id, Selected_Patient_RDV_startsAt, Selected_Patient_RDV_endsAt, Selected_Patient_RDV_etat_id } = request.body;

            const edited_rdv_id = (await fastify.pg.query("UPDATE public.patient_rdvs "
                + " SET startsat = $2,endsat = $3,etat_id = $4,updatedby=$5,updated = now() WHERE id = $1 RETURNING id ",
                [Selected_Patient_RDV_id, Selected_Patient_RDV_startsAt, Selected_Patient_RDV_endsAt, Selected_Patient_RDV_etat_id, p_user_id])).rows[0].id;
          //  console.log("rdv_id " + edited_rdv_id)
            if (edited_rdv_id) {
                const { rows } = await fastify.pg.query(
                    "SELECT patient_rdvs.id, patient_rdvs.patient_id,patients.nom ||' '||patients.prenom patient,patients.email,title,motif_id, etat_id,etats.designation etat, color, startsat, endsat,reminder_sent, draggable, "
                    + " resizable, patient_rdvs.created, patient_rdvs.createdby, patient_rdvs.updated, patient_rdvs.updatedby, patient_rdvs.active "
                    + " FROM public.patient_rdvs INNER JOIN patients ON patients.id = patient_rdvs.patient_id INNER JOIN users ON users.id = patient_rdvs.createdby INNER JOIN etats ON etats.id = patient_rdvs.etat_id WHERE users.org_id= $1 order by startsat;", [p_org_id],
                )
                return rows;
            }
        }).catch((err) => {
            //err.message = 'Erreur de modification'
            throw err
        })
    })


    //Delete patient rdv
    fastify.delete('/delete_rdv/:patient_rdv_id', (request, reply) => {
        return fastify.pg.transact(async client => {
            const p_org_id = request.org_id;
            const p_user_id = request.user_id;

            const deleted_rdv_id = (await fastify.pg.query("DELETE FROM patient_rdvs WHERE id = $1 RETURNING patient_id ",
                [request.params.patient_rdv_id])).rows[0].patient_id;
            //console.log("deleted_rdv_id " + deleted_rdv_id)

            if (deleted_rdv_id) {
                const { rows } = await fastify.pg.query(
                    "SELECT patient_rdvs.id, patient_rdvs.patient_id,patients.nom ||' '||patients.prenom patient,patients.email,title,motif_id, etat_id,etats.designation etat, color, startsat, endsat,reminder_sent, draggable, "
                    + " resizable, patient_rdvs.created, patient_rdvs.createdby, patient_rdvs.updated, patient_rdvs.updatedby, patient_rdvs.active "
                    + " FROM public.patient_rdvs INNER JOIN patients ON patients.id = patient_rdvs.patient_id INNER JOIN users ON users.id = patient_rdvs.createdby INNER JOIN etats ON etats.id = patient_rdvs.etat_id WHERE users.org_id= $1 order by startsat;", [p_org_id],
                )
                return rows;
            }
        }).catch((err) => {
            //err.message = 'Erreur de modification'
            throw err
        })
    })

}//End Module

'use strict'

module.exports = async function (fastify, opts) {

    //Get all transactions  
    fastify.get('/get_all_transactions', async (request, reply) => {
        const p_org_id = request.org_id;
        const p_user_id = request.user_id;
        if (!global.license.F3) {return false}

        const { rows } = await fastify.pg.query(
            " SELECT id, org_id, org, operation, type_transaction_id, type_transaction, type_paiement_id, type_paiement,"
            + " patient_id, patient, partenaire_id, partenaire, tiers, date_transaction, montant, observation, created, createdby, updated, updatedby, active"
            + " FROM public.vue_orgs_transactions  WHERE org_id = $1 ORDER BY id;", [p_org_id],
        )
        return rows
    })

    //Add transactions
    fastify.post('/add_transaction', (request, reply) => {
        // will return a promise, fastify will send the result automatically
        return fastify.pg.transact(async client => {
            const p_org_id = request.org_id;
            const p_user_id = request.user_id;
            const { org_id, type_transaction_id, patient_id, partenaire_id, date_transaction, montant, type_paiement_id, observation } = request.body;

            const added_org_transaction_id = (await fastify.pg.query("INSERT INTO public.org_transactions( "
                + " org_id, type_transaction_id, patient_id,partenaire_id, date_transaction, montant,type_paiement_id, observation, "
                + " created, createdby, updated, updatedby, active) "
                + " VALUES ($1,$2,$3,$4,$5,$6,$7,$8,now(),$9,now(),$10,true) RETURNING id ",
                [p_org_id, type_transaction_id, patient_id, partenaire_id, date_transaction, montant, type_paiement_id, observation, p_user_id, p_user_id])).rows[0].id;

            if (added_org_transaction_id) {
                const { rows } = await fastify.pg.query(
                    " SELECT id, org_id, org, operation, type_transaction_id, type_transaction, type_paiement_id, type_paiement,"
                    + " patient_id, patient, partenaire_id, partenaire, tiers, date_transaction, montant, observation, created, createdby, updated, updatedby, active"
                    + " FROM public.vue_orgs_transactions  WHERE org_id = $1;", [p_org_id],
                )
                return rows
            }
        }).catch((err) => {
            //err.message = 'Erreur de modification'
            throw err
        })
    })

    //Edit transactions
    fastify.put('/edit_transaction', (request, reply) => {
        // will return a promise, fastify will send the result automatically
        return fastify.pg.transact(async client => {
            const p_org_id = request.org_id;
            const p_user_id = request.user_id;
            const { id, type_transaction_id, patient_id, partenaire_id, date_transaction, montant, observation, type_paiement_id } = request.body;

            const edited_org_transaction_id = (await fastify.pg.query("UPDATE public.org_transactions"
                + " SET  type_transaction_id=$2, patient_id=$3,  partenaire_id=$4,date_transaction=$5, montant=$6, observation=$7, type_paiement_id=$8, "
                + " created = now(), createdby = $9, updated = now(), updatedby = $10, active = true  WHERE id=$1 RETURNING id;",
                [id, type_transaction_id, patient_id, partenaire_id, date_transaction, montant, observation, type_paiement_id, p_user_id, p_user_id])).rows[0].id;

            if (edited_org_transaction_id) {
                const { rows } = await fastify.pg.query(
                    " SELECT id, org_id, org, operation, type_transaction_id, type_transaction, type_paiement_id, type_paiement,"
                    + " patient_id, patient, partenaire_id, partenaire, tiers, date_transaction, montant, observation, created, createdby, updated, updatedby, active"
                    + " FROM public.vue_orgs_transactions  WHERE org_id = $1;", [p_org_id],
                )
                return rows
            }
            return rows
        }).catch((err) => {
            //err.message = 'Erreur de modification'
            throw err
        })
    })

    //Delete transactions  
    fastify.delete('/delete_transaction/:transactions_id', (request, reply) => {
        return fastify.pg.transact(async client => {
            const p_org_id = request.org_id;

            const deleted_org_transaction_id  = (await fastify.pg.query("DELETE FROM org_transactions WHERE id = $1 RETURNING id; ", [request.params.transactions_id])).rows[0].id;

            if (deleted_org_transaction_id) {
                const { rows } = await fastify.pg.query(
                    " SELECT id, org_id, org, operation, type_transaction_id, type_transaction, type_paiement_id, type_paiement,"
                    + " patient_id, patient, partenaire_id, partenaire, tiers, date_transaction, montant, observation, created, createdby, updated, updatedby, active"
                    + " FROM public.vue_orgs_transactions  WHERE org_id = $1;", [p_org_id],
                )
                return rows
            }
        }).catch((err) => {
            //err.message = 'Erreur de modification'
            throw err
        })
    })

    //Get total cout et total versement
    fastify.post('/get_total_actes_total_versements', async (request, reply) => {
        const p_org_id = request.org_id;
        const p_user_id = request.user_id;
        const transactions_id = request.body;
      //  console.log("transactions_id " + transactions_id)

        const { deleted_org_transaction_id } = (await fastify.pg.query(
            " SELECT id, nb_versements, montant_versements,nb_paiements,montant_paiements  FROM public.vue_orgs_transactions_totaux WHERE id = $1 RETURNING id;", [p_org_id])).rows[0].id;

        if (deleted_org_transaction_id) {
            const { rows } = await fastify.pg.query(
                " SELECT id, org_id, org, operation, type_transaction_id, type_transaction, type_paiement_id, type_paiement,"
                + " patient_id, patient, partenaire_id, partenaire, tiers, date_transaction, montant, observation, created, createdby, updated, updatedby, active"
                + " FROM public.vue_orgs_transactions  WHERE org_id = $1;", [p_org_id],
            )
            return rows
        }
    })

}//End Module

'use strict'

module.exports = async function (fastify, opts) {

  //Get statistiques patient par sexe et age
  fastify.post('/statistiques_patients_sexes_ages', async (request, reply) => {
    const p_org_id = request.org_id;
    const p_user_id = request.user_id;
    const { date_du, date_au } = request.body;
    if (!global.license.F4) {return false}

   // console.log('statistiques_patients_sexes_ages p_org_id ' + p_org_id)
    const { rows } = await fastify.pg.query(
      " SELECT * FROM public.statistiques_patients_ages_sexes_consultations_by_org($1,$2::date,$3::date)", [p_org_id, date_du, date_au])
    return rows
  })


  //Get statistiques rdvs
  fastify.post('/statistiques_rdvs', async (request, reply) => {
    const p_org_id = request.org_id;
    const p_user_id = request.user_id;
    const { date_du, date_au } = request.body;
    if (!global.license.F4) {return false}

    const { rows } = await fastify.pg.query(
      " SELECT * FROM public.statistiques_rdvs_by_org($1,$2::date,$3::date)", [p_org_id, date_du, date_au])
    return rows
  })


  //Get statistiques_transactions
  fastify.post('/statistiques_transactions', async (request, reply) => {
    const p_org_id = request.org_id;
    const p_user_id = request.user_id;
    const { date_du, date_au } = request.body;
    if (!global.license.F4) {return false}

    const { rows } = await fastify.pg.query(
      " SELECT * FROM public.statistiques_transactions_by_orgs($1,$2::date,$3::date)", [p_org_id, date_du, date_au])
    return rows
  })

}//End Module

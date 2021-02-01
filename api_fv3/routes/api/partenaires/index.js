'use strict'

module.exports = async function (fastify, opts) {
  //This get query is used only in transactions
  fastify.get('/all', async (request, reply) => {
    return fastify.pg.transact(async client => {
      var p_user_id = request.user_id;
      const p_org_id = request.org_id;
      if (!global.license.F5) {return false}

     // console.log('xxxxxxxxxxxxxxx' + p_org_id)
      const partenaires = (await fastify.pg.query(
        "SELECT id, org_id, designation, adresse, email, tel, fax,color, created, createdby, updated, updatedby, active"
        + " FROM public.partenaires WHERE org_id=$1", [p_org_id])).rows

      return partenaires
    }).catch((err) => {
      //err.message = 'Erreur de modification'
      throw err
    })
  })

  /**** Partenaires ****/
  fastify.post('/get_all_partenaires', async (request, reply) => {
    return fastify.pg.transact(async client => {
      var p_user_id = request.user_id;
      const p_org_id = request.org_id;

      const { partenaire_id } = request.body;

      const partenaires = (await fastify.pg.query(
        "SELECT id, org_id, designation, adresse, email, tel, fax,color, created, createdby, updated, updatedby, active"
        + " FROM public.partenaires WHERE org_id=$1", [p_org_id])).rows

      return partenaires
    }).catch((err) => {
      //err.message = 'Erreur de modification'
      throw err
    })
  })

  //Add org annuaire
  fastify.post('/add_partenaire', (request, reply) => {
    return fastify.pg.transact(async client => {
      const p_org_id = request.org_id;
      const p_user_id = request.user_id;
      const { designation, adresse, email, tel, fax, color } = request.body;

      const new_partenaires_id = (await fastify.pg.query("INSERT INTO public.partenaires("
        + "org_id, designation, adresse, email, tel, fax,color, created, createdby, updated, updatedby, active)"
        + " VALUES ($1,$2,$3,$4,$5,$6,$7,now(),$8,now(),$9,true) RETURNING id ",
        [p_org_id, designation, adresse, email, tel, fax, color, p_user_id, p_user_id])).rows[0].id;
     // console.log("new_partenaires_id " + new_partenaires_id)
      if (new_partenaires_id) {
        const partenaires = (await fastify.pg.query(
          "SELECT id, org_id, designation, adresse, email, tel, fax,color, created, createdby, updated, updatedby, active"
          + " FROM public.partenaires WHERE org_id=$1", [p_org_id]
        )).rows
        return partenaires
      }
    }).catch((err) => {
      //err.message = 'Erreur de modification'
      throw err
    })
  })

  //Delete  partenaires
  fastify.delete('/delete_partenaire/:partenaires_id', (request, reply) => {
    return fastify.pg.transact(async client => {
      const p_org_id = request.org_id;
      const p_user_id = request.user_id;

      const deleted_partenaires_id = (await fastify.pg.query("DELETE FROM partenaires WHERE id = $1 RETURNING id ",
        [request.params.partenaires_id])).rows[0].id;
     // console.log("deleted_partenaires_id " + deleted_partenaires_id)

      if (deleted_partenaires_id) {
        const partenaires = (await fastify.pg.query(
          "SELECT id, org_id, designation, adresse, email, tel, fax,color, created, createdby, updated, updatedby, active"
          + " FROM public.partenaires WHERE org_id=$1", [p_org_id]
        )).rows
        return partenaires
      }
    }).catch((err) => {
      //err.message = 'Erreur de modification'
      throw err
    })
  })
  /**********************/
}

'use strict'

module.exports = async function (fastify, opts) {
  //Get all Medicaments
  fastify.get('/all', async (req, reply) => {



    const { rows } = await fastify.pg.query(
      ' SELECT id, designation,model, created, createdby, updated, updatedby, COALESCE(active,false::boolean) active FROM certificat_motifs;'
    )


    return rows
  })
}

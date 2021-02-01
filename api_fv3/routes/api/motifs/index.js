'use strict'

module.exports = async function (fastify, opts) {
  //Get all motifs
  fastify.get('/all', async (req, reply) => {
    
    

    const { rows } = await fastify.pg.query(
      ' SELECT  id, designation, created, createdby, updated, updatedby, COALESCE(active,false::boolean) active FROM motifs;'
    )

    
    return rows
  })
}

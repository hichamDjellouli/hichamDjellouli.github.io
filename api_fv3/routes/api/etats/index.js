'use strict'

module.exports = async function (fastify, opts) {
  //Get all etats
  fastify.get('/all', async (req, reply) => {
    
    

    const { rows } = await fastify.pg.query(
      ' SELECT  id, designation, created, createdby, updated, updatedby, COALESCE(active,false::boolean) active FROM etats;'
    )

    
    return rows
  })
}

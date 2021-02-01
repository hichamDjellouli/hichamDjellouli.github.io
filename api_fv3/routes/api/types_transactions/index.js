'use strict'

module.exports = async function (fastify, opts) {
  //Get all type versements
  fastify.get('/all', async (req, reply) => {
    
    

    const { rows } = await fastify.pg.query(
      ' SELECT  id, designation,operation,cible, created, createdby, updated, updatedby, COALESCE(active,false::boolean) active FROM types_transactions;'
    )

    
    return rows
  })
}

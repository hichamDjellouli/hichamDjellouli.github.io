'use strict'

module.exports = async function (fastify, opts) {
  //Get all radiographies
  fastify.get('/all', async (req, reply) => {
    
    

    const { rows } = await fastify.pg.query(
      ' SELECT id, designation,definition, created, createdby, updated, updatedby, COALESCE(active,false::boolean) active FROM radiographies;'
    )

    
    return rows
  })
}

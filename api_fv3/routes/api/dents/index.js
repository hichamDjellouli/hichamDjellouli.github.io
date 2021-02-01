'use strict'

module.exports = async function (fastify, opts) {
  //Get all pathologies
  fastify.get('/all', async (req, reply) => {
    
    

    const { rows } = await fastify.pg.query(
      ' SELECT  num, COALESCE(adult,false::boolean) adult, designation, created, createdby, updated, updatedby, COALESCE(active,false::boolean) active FROM dents;'
    )

    
    return rows
  })
}

'use strict'

module.exports = async function (fastify, opts) {
  //Get all wilaya
  fastify.get('/all', async (req, reply) => {
    
    

    const { rows } = await fastify.pg.query(
      ' SELECT id, code, designation, created, createdby, updated, updatedby, COALESCE(active,false::boolean) active FROM wilaya WHERE active order by id;'
    )

    
    return rows
  })
}

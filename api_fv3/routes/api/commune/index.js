'use strict'

module.exports = async function (fastify, opts) {
  //Get all commune
  fastify.get('/all', async (req, reply) => {
    
    const { rows } = await fastify.pg.query(  
      ' SELECT id,wilaya_id, code, designation, created, createdby, updated, updatedby, COALESCE(active,false::boolean) active FROM commune order by id;'
    )

    
    return rows
  })
}

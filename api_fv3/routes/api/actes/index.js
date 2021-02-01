'use strict'

module.exports = async function (fastify, opts) {
  //Get all pathologies
  fastify.get('/all', async (req, reply) => {
    
    

    const { rows } = await fastify.pg.query( 
      ' SELECT id, designation,definition,montant,procedure_id, created, createdby, updated, updatedby, COALESCE(active,false::boolean) active FROM actes;'
    )
    //Close connection
    //client.release()
    return rows
  })
}

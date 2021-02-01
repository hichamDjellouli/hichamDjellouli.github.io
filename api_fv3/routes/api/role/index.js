'use strict'

module.exports = async function (fastify, opts) {
   //Get all roles
   fastify.get('/all', async (request, reply) => {//async function (request, reply) {
    
    

    const { rows } = await fastify.pg.query(
      ' SELECT id, designation, created, createdby, updated, updatedby, COALESCE(active,false::boolean) active FROM role;'
    )

    
    return rows
  })
}

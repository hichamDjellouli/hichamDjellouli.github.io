'use strict'

module.exports = async function (fastify, opts) {
  //Add row to a static table
  fastify.post('/add_row', (request, reply) => {
    // will return a promise, fastify will send the result automatically
    return fastify.pg.transact(async client => {
      const p_org_id = request.org_id;
      const p_user_id = request.user_id;
      const { Table_Name, Static_Table_Ligne } = request.body;
    //  console.log("Static_Table_Ligne : " + Static_Table_Ligne.designation)
      var New_Row_Id = 0;
      if (Table_Name === 'certificat_motifs') {
        New_Row_Id = (await fastify.pg.query("INSERT INTO public." + Table_Name
          + "(designation,model,created, createdby, updated, updatedby, active)"
          + " VALUES ($1,$2,now(),$3,now(),$4,true) RETURNING id ",
          [Static_Table_Ligne.designation, Static_Table_Ligne.model, p_user_id, p_user_id])).rows[0].id;
      }
      else if (Table_Name === 'actes') {
        New_Row_Id = (await fastify.pg.query("INSERT INTO public." + Table_Name
          + "(designation,procedure_id,montant, created, createdby, updated, updatedby, active)"
          + " VALUES ($1,$2,$3,now(),$4,now(),$5,true) RETURNING id ",
          [Static_Table_Ligne.designation, Static_Table_Ligne.procedure_id, Static_Table_Ligne.montant, p_user_id, p_user_id])).rows[0].id;
      }
      else if (Table_Name === 'types_transactions') {
        New_Row_Id = (await fastify.pg.query("INSERT INTO public." + Table_Name
          + "(designation,operation,cible, created, createdby, updated, updatedby, active)"
          + " VALUES ($1,$2,$3,now(),$4,now(),$5,true) RETURNING id ",
          [Static_Table_Ligne.designation, Static_Table_Ligne.operation, Static_Table_Ligne.cible, p_user_id, p_user_id])).rows[0].id;
      }
      else {
        New_Row_Id = (await fastify.pg.query("INSERT INTO public." + Table_Name
          + "(designation, created, createdby, updated, updatedby, active)"
          + " VALUES ($1,now(),$2,now(),$3,true) RETURNING id ",
          [Static_Table_Ligne.designation, p_user_id, p_user_id])).rows[0].id;
      }

    //  console.log("New_Row_Id " + New_Row_Id)
      return New_Row_Id
    }).catch((err) => {
      throw err
    })
  })


  //Edit row from a static table
  fastify.put('/edit_row', (request, reply) => {
    return fastify.pg.transact(async client => {
      const p_user_id = request.user_id;
      const { Table_Name, Static_Table_Ligne } = request.body;
      var Updated_Row_Id = 0;
      if (Table_Name === 'certificat_motifs') {
        Updated_Row_Id = (await fastify.pg.query("UPDATE " + Table_Name
          + " SET designation =$2,model =$3,updatedby=$4,updated=now() WHERE id=$1 RETURNING id",
          [Static_Table_Ligne.id, Static_Table_Ligne.designation, Static_Table_Ligne.model, p_user_id])).rows[0].id;
      }
      else if (Table_Name === 'actes') {
        Updated_Row_Id = (await fastify.pg.query("UPDATE " + Table_Name
          + " SET designation =$2,procedure_id =$3,montant=$4,updatedby=$5,updated=now() WHERE id=$1 RETURNING id",
          [Static_Table_Ligne.id, Static_Table_Ligne.designation, Static_Table_Ligne.procedure_id, Static_Table_Ligne.montant, p_user_id])).rows[0].id;
      }
      else if (Table_Name === 'types_transactions') {
        Updated_Row_Id = (await fastify.pg.query("UPDATE " + Table_Name
          + " SET designation =$2,operation =$3,cible=$4,updatedby=$5,updated=now() WHERE id=$1 RETURNING id",
          [Static_Table_Ligne.id, Static_Table_Ligne.designation, Static_Table_Ligne.operation, Static_Table_Ligne.cible, p_user_id])).rows[0].id;
      }
      else {
        Updated_Row_Id = (await fastify.pg.query("UPDATE " + Table_Name
          + " SET designation =$2,updatedby=$3,updated=now() WHERE id=$1 RETURNING id",
          [Static_Table_Ligne.id, Static_Table_Ligne.designation, p_user_id])).rows[0].id;
      }


      return Updated_Row_Id
    }).catch((err) => {
      //err.message = 'Erreur de modification'
      throw err
    })
  })

  //Delete row from a static table
  fastify.put('/delete_row', (request, reply) => {
    return fastify.pg.transact(async client => {
      const { Table_Name, Static_Table_Ligne } = request.body;
      const Deleted_Row_Id = (await fastify.pg.query("DELETE FROM " + Table_Name + " WHERE id = $1 RETURNING id ", [Static_Table_Ligne.id])).rows[0].id;

      return Deleted_Row_Id
    }).catch((err) => {
      //err.message = 'Erreur de modification'
      throw err
    })

  })
}
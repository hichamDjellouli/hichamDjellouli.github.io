'use strict'

module.exports = async function (fastify, opts) {


    //Add messages
    fastify.post('/add_message', (request, reply) => {
        // will return a promise, fastify will send the result automatically
        return fastify.pg.transact(async client => {
            const p_org_id = request.org_id;
            const p_user_id = request.user_id;
            const { Selected_Contact_id, message } = request.body;

            const added_message_id = (await fastify.pg.query("INSERT INTO public.users_messages("
                + "read, created, createdby, to_user_id, message,updatedby) "
                + " VALUES ($1,now(),$2,$3,$4,$5 ) RETURNING id ",
                [false, p_user_id, Selected_Contact_id, message, p_user_id])).rows[0].id;

            if (added_message_id) {
                const contacts = (await fastify.pg.query(
                    "SELECT id, org_id, org,org_profession_id,profession, org_directions_id, direction, "
                    + " org_tel, org_email, org_site_internet, org_adresse,org_logo, "
                    + " wilaya_id, wilaya, "
                    + " role_id, user_role, lname, fname, gender, email, token,avatar, "
                    + " first_visit, active,created,createdby,password,password repassword  FROM dzental_users WHERE org_id = $1 AND id <> $2 ORDER BY id;", [p_org_id, p_user_id])).rows

                const messages = (await fastify.pg.query(
                    " SELECT * FROM public.vue_users_messages WHERE (createdby = $1) OR (to_user_id = $1) ORDER BY id;", [p_user_id])).rows

                return {
                    contacts: contacts,
                    messages: messages
                }
            }
        }).catch((err) => {
            //err.message = 'Erreur de modification'
            throw err
        })
    })
    //Delete messages  
    fastify.post('/delete_message', (request, reply) => {
        return fastify.pg.transact(async client => {
            var p_org_id = request.org_id;
            const p_user_id = request.user_id;
            const { Selected_Contact_id, message_id } = request.body;
            const deleted_org_message_id = (await fastify.pg.query("DELETE FROM users_messages WHERE id = $1 RETURNING id; ", [message_id])).rows[0].id;

            if (deleted_org_message_id) {
                const contacts = (await fastify.pg.query(
                    "SELECT id, org_id, org,org_profession_id,profession, org_directions_id, direction, "
                    + " org_tel, org_email, org_site_internet, org_adresse,org_logo, "
                    + " wilaya_id, wilaya, "
                    + " role_id, user_role, lname, fname, gender, email, token,avatar, "
                    + " first_visit, active,created,createdby,password,password repassword  FROM dzental_users WHERE org_id = $1 AND id <> $2 ORDER BY id;", [p_org_id, p_user_id])).rows

                const messages = (await fastify.pg.query(
                    " SELECT * FROM public.vue_users_messages WHERE (createdby = $1) OR (to_user_id = $1) ORDER BY id;", [p_user_id])).rows

                return {
                    contacts: contacts,
                    messages: messages
                }
            }
        }).catch((err) => {
            //err.message = 'Erreur de modification'
            throw err
        })
    })

    //set_messages_as_readed
    fastify.post('/set_messages_as_readed', (request, reply) => {
        return fastify.pg.transact(async client => {
            var p_org_id = request.org_id;
            const p_user_id = request.user_id;
            const { Current_User_id,Selected_Contact_id } = request.body;
           
            await fastify.pg.query("UPDATE users_messages  SET read = true WHERE createdby = $1 AND to_user_id = $2 RETURNING id; ", [Selected_Contact_id,Current_User_id])    
        }).catch((err) => {
            //err.message = 'Erreur de modification'
            throw err
        })
    })

}//End Module

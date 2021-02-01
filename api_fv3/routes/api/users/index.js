'use strict'

module.exports = async function (fastify, opts) {
  //test token
  fastify.post('/token', (request, reply) => {
    const token = fastify.jwt.sign({ foo: 'bar' })
    reply.send({ token })
  })

  //Vérifiy if user exists by email and password 
  fastify.post('/authenticate', (request, reply) => {
    const sysinfo = request.sysinfo;
    const clientIp = request.clientIp;
    const geo = request.geo;


    // will return a promise, fastify will send the result automatically
    return fastify.pg.transact(async client => {

      const { key, email, password } = request.body;
      // console.log(`request.body : ` + [key, email, password]);
      const { rows } = await fastify.pg.query("SELECT * FROM dzental_users "
        + " WHERE email=$1 AND password=$2 AND active='t' LIMIT 1 ", [email, password])

      //if user exists, attribute a token
      if (rows.length != 0) {
        var datetime = new Date();
        //  console.log(datetime);

        //token generated with date,fnl,id,mail
        const token = await fastify.jwt.sign({ date_token: datetime, key: [key], id: rows[0].id, email: rows[0].email });
        //  console.log("xxxxxxxrowsxxxxx" + rows[0].id);
        const { user } = await fastify.pg.query("UPDATE users SET token=$1 WHERE id = $2;", [token, rows[0].id]);
        const { session } = await fastify.pg.query(
          "INSERT INTO users_session ( user_id, email, hostname, remote_adresse, remote_port, localisation,"
          + " browser_name, browser_version, os_name, os_version, devise_name, "
          + " devise_version, token, date_online, online, created, "
          + " createdby, updated, updatedby, active)"
          + " VALUES($1,$2, $3, $4,$5,$6,$7,$8,$9,$10, $11,$12,$13,now(),true,now(),$1,now(),$1,true);", [rows[0].id, rows[0].email, request.hostname, request.remoteAddress
          , request.remotePort, JSON.stringify(geo), sysinfo.browser.name, sysinfo.browser.versionString, sysinfo.os.name,
          sysinfo.os.versionString, sysinfo.device.name, sysinfo.device.versionString, token]);

        //Loading user preference
        if (rows[0].role_id === 0) //|| rows[0].role_id === 1) //If system or central user
        {
          const user_wilayas = (await fastify.pg.query("SELECT id, code, designation, created, createdby, updated, updatedby, COALESCE(active,false::boolean) active FROM wilaya order by id;")).rows;
          const user_orgs = (await fastify.pg.query("SELECT id, designation, tel,fax, email, site_internet,file_name,reminder_delay, adresse, created, createdby, updated, updatedby, COALESCE(active,false::boolean) active FROM org order by designation; ")).rows;
          const user_produits = (await fastify.pg.query("SELECT id, code, designation, created, createdby, updated, updatedby, COALESCE(active,false::boolean) active FROM produit order by designation; ")).rows;

          const user_orgproduits = (await fastify.pg.query("SELECT org, designation, id, org_id, created, createdby, updated, updatedby, active FROM vue_org_produits WHERE org_id = $1; ", [rows[0].org_id])).rows;
          const user_usersproduits = (await fastify.pg.query(" SELECT id, users_id, designation, created, createdby, updated, updatedby,COALESCE(active,false::boolean) active FROM vue_users_produits WHERE users_id = $1; ", [rows[0].id])).rows;
          const users_roles_access_control = (await fastify.pg.query(" SELECT * FROM users_roles_access_control WHERE user_id = $1; ", [rows[0].id])).rows;
          const users_roles_access_control_All = (await fastify.pg.query(" SELECT * FROM users_roles_access_control WHERE org_id = $1; ", [rows[0].org_id])).rows;

          //if user the response
          reply.send([{
            success: true,
            data: rows,
            token: token,

            user_wilayas: user_wilayas,
            user_orgs: user_orgs,
            user_produits: user_produits,
            users_roles_access_control: users_roles_access_control,
            users_roles_access_control_All: users_roles_access_control_All,

            user_orgproduits: user_orgproduits,
            user_usersproduits: user_usersproduits,
          }]);
        }
        else {//Not system Or central user   
          const user_wilayas = [{ id: rows[0].wilaya_id, designation: rows[0].wilaya }];
          const user_orgs = [{
            id: rows[0].org_id, designation: rows[0].org, tel: rows[0].org_tel, fax: rows[0].org_fax, email: rows[0].org_email
            , site_internet: rows[0].org_site_internet, reminder_delay: rows[0].reminder_delay, is_rappel_rdv_automatique: rows[0].is_rappel_rdv_automatique, adresse: rows[0].org_adresse, wilaya_id: rows[0].org_wilaya_id, wilaya: rows[0].org_wilaya, org_logo: rows[0].org_logo
            , org_background: rows[0].org_background
          }];

          const user_orgproduits = (await fastify.pg.query("SELECT org, designation, id, org_id, created, createdby, updated, updatedby, active FROM vue_org_produits WHERE org_id = $1; ", [rows[0].org_id])).rows;
          const user_usersproduits = (await fastify.pg.query(" SELECT id, users_id, designation, created, createdby, updated, updatedby,COALESCE(active,false::boolean) active FROM vue_users_produits WHERE users_id = $1; ", [rows[0].id])).rows;
          const user_produits = user_usersproduits;
          const users_roles_access_control = (await fastify.pg.query(" SELECT * FROM users_roles_access_control WHERE user_id = $1; ", [rows[0].id])).rows;
          const users_roles_access_control_All = (await fastify.pg.query(" SELECT * FROM users_roles_access_control WHERE org_id = $1; ", [rows[0].org_id])).rows;

          //if user the response
          reply.send([{
            success: true,
            data: rows,
            token: token,
            user_wilayas: user_wilayas,
            user_orgs: user_orgs,
            user_produits: user_produits,
            users_roles_access_control: users_roles_access_control,
            users_roles_access_control_All: users_roles_access_control_All,

            user_orgproduits: user_orgproduits,
            user_usersproduits: user_usersproduits,
          }]);
          // console.log('Cloooooooooooooooooooose connection')
          ////;
          //client.end();
        }
      } else {
        reply.send([{
          success: false,
          data: "Incorrect email/password"
        }]);
      }
      //return rows
    }).catch((err) => {
      //err.message = 'Erreur de modification'
      throw err
    }).finally(() => {
      // console.log('Cloooooooooooooooooooose connection')
      ////;
      //client.end();
    })
  })



  //Reset a password 
  fastify.post('/reset_password', async (request, reply) => {
    return fastify.pg.transact(async client => {
      const { email } = request.body;
      var new_password = generate_random_password(6);
      const id = (await fastify.pg.query("UPDATE users SET password=$2 WHERE email = $1 RETURNING id",
        [email, new_password])).rows[0].id;
      // console.log('id ' + id)
      if (id) {

        fastify.nodemailer.sendMail({
          from: 'h_djellouli@esi.dz',
          to: email,//[email],
          subject: 'Mot de passe réinitialisé',
          html: 'Bonjour,'
            + '<p>Félicitations, votre nouveau mot de passe sur la plateforme DZENTAL est : <b>' + new_password + '</b></p>'
        }, (err, info) => {
          if (err) { console.log('err : ' + err) }
          //  console.log('info : ' + info)
          //reply.send({messageId: info.messageId})

        })
        return true;
      }
      else {
        return false;
      }

    }).catch((err) => {
      //err.message = 'Erreur de modification'
      throw err
    })
  })

  fastify.post('/logout', (request, reply) => {
    const { token } = request.body;
    return fastify.pg.transact(async client => {

      const { user } = await fastify.pg.query("UPDATE users SET token = null,first_visit=false WHERE token = $1;", [token]);
      const { user_session } = await fastify.pg.query("UPDATE users_session SET updated=now(),date_exit = now(),online=false WHERE token = $1;", [token]);

      reply.send({
        success: true,
      });

    }).catch((err) => {
      //err.message = 'Erreur de modification'
      throw err
    }).finally(() => {
      // console.log('Cloooooooooooooooooooose connection')
      //;
      //client.end();
    })
  })

  //Get all Users
  fastify.get('/all', async (request, reply) => {
    if (!global.license.F8) { return false }

    fastify.pg.query(
      "SELECT id, org_id, org,org_profession_id,profession, org_directions_id, direction, "
      + " org_tel,org_fax, org_email, org_site_internet, org_adresse,org_logo, org_background,reminder_delay,"
      + " wilaya_id, wilaya, "
      + " role_id, user_role, lname, fname, gender, email, token, avatar,"
      + " first_visit, active,created,createdby,password,password repassword  FROM dzental_users ORDER BY id;",
      function onResult(err, result) {
        //err.message = 'Erreur de selection'
        reply.send(err || result.rows)
      })

  })

  fastify.get('/allorgusers', async (request, reply) => {
    var p_org_id = request.org_id;
    if (!global.license.F8) { return false }

    const { rows } = await fastify.pg.query(
      "SELECT id, org_id, org,org_profession_id,profession, org_directions_id, direction, "
      + " org_tel,org_fax, org_email, org_site_internet, org_adresse,org_logo,org_background,reminder_delay, "
      + " wilaya_id, wilaya, "
      + " role_id, user_role, lname, fname, gender, email, token,avatar, "
      + " first_visit, active,created,createdby,password,password repassword  FROM dzental_users WHERE org_id = $1 ORDER BY id;", [p_org_id])

    return rows;

  })


  fastify.get('/historique_session', async (request, reply) => {
    fastify.pg.query(
      'SELECT id, user_id, email, hostname, remote_adresse, remote_port, localisation, '
      + ' browser_name, browser_version, os_name, os_version, devise_name, '
      + ' devise_version, token, date_online, date_exit, COALESCE(online,false::boolean) online, created, '
      + ' createdby, updated, updatedby, COALESCE(active,false::boolean) active'
      + ' FROM users_session ORDER BY id;',
      function onResult(err, result) {
        //err.message = 'Erreur de selection'
        reply.send(err || result.rows)
      })

  })

  //Get user by token
  fastify.post('/getbytoken/', async (request, reply) => {
    var p_org_id = request.org_id;
    var p_user_id = request.user_id;
    const { token } = request.body;
    const { rows } = await fastify.pg.query(
      'SELECT * FROM dzental_users WHERE token=$1', [token],
    )
    if (rows.length != 0) {

      //Loading user preference
      if (rows[0].role_id === 0)//|| rows[0].role_id === 1) //If system or central user
      {
        const user_wilayas = (await fastify.pg.query("SELECT id, code, designation, created, createdby, updated, updatedby, COALESCE(active,false::boolean) active FROM wilaya order by id;")).rows;
        const user_orgs = (await fastify.pg.query("SELECT id, designation, tel,fax, email, site_internet,reminder_delay, file_name,adresse, created, createdby, updated, updatedby, COALESCE(active,false::boolean) active FROM org order by designation; ")).rows;
        const user_produits = (await fastify.pg.query("SELECT id, code, designation, created, createdby, updated, updatedby, COALESCE(active,false::boolean) active FROM produit order by designation; ")).rows;
        const users_roles_access_control = (await fastify.pg.query(" SELECT * FROM users_roles_access_control WHERE user_id = $1; ", [rows[0].id])).rows;
        const users_roles_access_control_All = (await fastify.pg.query(" SELECT * FROM users_roles_access_control WHERE org_id = $1; ", [p_org_id])).rows;

        const user_orgproduits = (await fastify.pg.query("SELECT org, designation, id, org_id, created, createdby, updated, updatedby, active FROM vue_org_produits WHERE org_id = $1; ", [rows[0].org_id])).rows;
        const user_usersproduits = (await fastify.pg.query(" SELECT id, users_id, designation, created, createdby, updated, updatedby,COALESCE(active,false::boolean) active FROM vue_users_produits WHERE users_id = $1; ", [rows[0].id])).rows;
        //if user the response
        reply.send([{
          success: true,
          data: rows,
          token: token,

          user_wilayas: user_wilayas,
          user_orgs: user_orgs,
          user_produits: user_produits,
          users_roles_access_control: users_roles_access_control,
          users_roles_access_control_All: users_roles_access_control_All,

          user_orgproduits: user_orgproduits,
          user_usersproduits: user_usersproduits,
        }]);
      }
      else {//Not system Or central user
        const user_wilayas = [{ id: rows[0].wilaya_id, designation: rows[0].wilaya }];
        const user_orgs = [{
          id: rows[0].org_id, designation: rows[0].org, tel: rows[0].org_tel, fax: rows[0].org_fax, email: rows[0].org_email
          , site_internet: rows[0].org_site_internet, reminder_delay: rows[0].reminder_delay, is_rappel_rdv_automatique: rows[0].is_rappel_rdv_automatique, adresse: rows[0].org_adresse, wilaya_id: rows[0].org_wilaya_id, wilaya: rows[0].org_wilaya,
          org_logo: rows[0].org_logo, org_background: rows[0].org_background
        }];
        const user_orgproduits = (await fastify.pg.query("SELECT org, designation, id, org_id, created, createdby, updated, updatedby, active FROM vue_org_produits WHERE org_id = $1; ", [rows[0].org_id])).rows;
        const user_usersproduits = (await fastify.pg.query(" SELECT id, users_id, designation, created, createdby, updated, updatedby,COALESCE(active,false::boolean) active FROM vue_users_produits WHERE users_id = $1; ", [rows[0].id])).rows;
        const users_roles_access_control = (await fastify.pg.query(" SELECT * FROM users_roles_access_control WHERE user_id = $1; ", [rows[0].id])).rows;
        const users_roles_access_control_All = (await fastify.pg.query(" SELECT * FROM users_roles_access_control WHERE org_id = $1; ", [p_org_id])).rows;

        const user_produits = user_usersproduits;

        //if user the response
        reply.send([{
          success: true,
          data: rows,
          token: token,
          user_wilayas: user_wilayas,
          user_orgs: user_orgs,
          user_produits: user_produits,
          users_roles_access_control: users_roles_access_control,
          users_roles_access_control_All: users_roles_access_control_All,

          user_orgproduits: user_orgproduits,
          user_usersproduits: user_usersproduits,
        }]);
      }
    } else {
      reply.send([{
        success: false,
        data: "Token expired"
      }]);
    }
  })

  //Get user by email
  fastify.get('/:email', async (request, reply) => {
    //

    const { rows } = await fastify.pg.query(
      'SELECT id, fname, lname, gender, address, email, password,COALESCE(first_visit,false::boolean) first_visit,file_name   FROM users WHERE email=$1', [request.params.email],
    )
    //
    return rows

  })

  //Add new user
  fastify.post('/insert', (request, reply) => {
    // will return a promise, fastify will send the result automatically
    return fastify.pg.transact(async client => {
      var p_user_id = request.user_id;
      const { org_id, org_directions_id, wilaya_id, fname, lname, gender, address, email, password, createdby, updatedby, active, role_id } = request.body;
      if (p_user_id == null) {
        p_user_id = createdby;
      }
      if (p_user_id == null) {
        p_user_id = 0;//By system
      }
      var default_file_name = "man.png"
      if (gender === 'F') {
        default_file_name = "women.png"
      }

      const { rows } = await fastify.pg.query("INSERT INTO users(org_id,org_directions_id,wilaya_id,fname, lname, gender, address, email, password, created,createdby, updated, updatedby, active,file_name)"
        + " VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,now(),$10,now(),$11,false,$12) RETURNING id",
        [org_id, org_directions_id, wilaya_id, fname, lname, gender, address, email, password, p_user_id, p_user_id, default_file_name])
      //console.log('rows.id ' + JSON.stringify(rows[0].id));

      if (rows[0].id) {
        const { role } = await fastify.pg.query("INSERT INTO users_roles(user_id, role_id, created, createdby, updated, updatedby,active) VALUES ($1,$2,now(),$3,now(),$4,true)",
          [rows[0].id, role_id, p_user_id, p_user_id])
      }
      return rows
    }).catch((err) => {
      //err.message = 'Erreur de modification'
      throw err
    }).finally(() => {
      console.log('Cloooooooooooooooooooose connection')
      //;
      //client.end();
    })
  })

  //Add new user
  fastify.post('/insert_user_clinique', (request, reply) => {
    // will return a promise, fastify will send the result automatically
    return fastify.pg.transact(async client => {
      var p_org_id = request.org_id;
      var p_user_id = request.user_id;
      const { org_id, org_profession_id, wilaya_id, fname, lname, gender, address, email, password, createdby, updatedby, active, role_id } = request.body;
      if (p_user_id == null) {
        p_user_id = createdby;
      }
      if (p_user_id == null) {
        p_user_id = 0;//By system
      }
      var default_file_name = "man.png"
      if (gender === 'F') {
        default_file_name = "women.png"
      }
      const { rows } = await fastify.pg.query("INSERT INTO users(org_id,org_profession_id,wilaya_id,fname, lname, gender, address, email, password, created,createdby, updated, updatedby, active,file_name)"
        + " VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,now(),$10,now(),$11,false,$12) RETURNING id",
        [p_org_id, org_profession_id, wilaya_id, fname, lname, gender, address, email, password, p_user_id, p_user_id, default_file_name])
      //console.log('rows.id ' + JSON.stringify(rows[0].id));

      if (rows[0].id) {
        const { role } = await fastify.pg.query("INSERT INTO users_roles(user_id, role_id, created, createdby, updated, updatedby,active) VALUES ($1,$2,now(),$3,now(),$4,true)",
          [rows[0].id, role_id, p_user_id, p_user_id])
      }
      return rows
    }).catch((err) => {
      //err.message = 'Erreur de modification'
      throw err
    }).finally(() => {
      // console.log('Cloooooooooooooooooooose connection')
      //;
      //client.end();
    })
  })

  fastify.put('/updateSelectedUser', async (request, reply) => {
    if (!global.license.F6) { return false }

    return fastify.pg.transact(async client => {
      //const id = parseInt([request.params.id]);
      const p_user_id = request.user_id;
      const { id, fname, lname, gender, address, email, password, created, createdby, updatedby, active,
        wilaya_id, org_id, org_directions_id, org_profession_id, role_id, file_name } = request.body;

      const { rows } = await fastify.pg.query("UPDATE users SET fname=$2, lname=$3, gender=$4, address=$5, "
        + " email=$6, password=$7, created=$8, createdby=$9, updated=now(), updatedby=$10, active=$11, "
        + " wilaya_id=$12, org_id=$13, org_directions_id=$14, org_profession_id=$15 WHERE id = $1",
        [id, fname, lname, gender, address, email, password, created, createdby, updatedby, active,
          wilaya_id, org_id, org_directions_id, org_profession_id]);

      const { row_role_id } = await fastify.pg.query("UPDATE users_roles SET role_id=$2, updated=now(), updatedby=$3 WHERE user_id = $1",
        [id, role_id, p_user_id])

      // console.log('maiiiiiiil1' + [email])
      if ([active]) {
        fastify.nodemailer.sendMail({
          from: 'h_djellouli@esi.dz',
          to: email,//[email],
          subject: 'Compte DZental',
          html: 'Bonjour Mr/Mme,' + [fname] + ' ' + [lname] + ','
            + '<p>Votre compte a été modifié</p>'
        }, (err, info) => {
          if (err) { console.log('err : ' + err) }
          //   console.log('info : ' + info)
          reply.send({
            messageId: info.messageId
          })
        })
      }
      //   console.log('maiiiiiiil2')

      return id
    }).catch((err) => {
      //err.message = 'Erreur de modification'
      throw err
    })
  })

  fastify.put('/UpdateSelectedUserAccess', async (request, reply) => {
    if (!global.license.F8) { return false }

    return fastify.pg.transact(async client => {
      //const id = parseInt([request.params.id]);
      const p_org_id = request.org_id;
      const p_user_id = request.user_id;
      const SelectedUserAccess_Control = request.body;

      SelectedUserAccess_Control.forEach(async (Access_Control, index) => {
        const { id, user_id, role_id, table_name, can_create, can_read, can_update, can_delete, } = Access_Control;
        await client.query("UPDATE public.users_roles_access_control"
          + " SET can_create=$2, can_read=$3, "
          + " can_update=$4, can_delete=$5,updatedby=$6,updated=now() "
          + " WHERE id = $1;",
          [id, can_create, can_read, can_update, can_delete, p_user_id])
      })


      return 'ok'
    }).catch((err) => {
      //err.message = 'Erreur de modification'
      throw err
    })
  })


  fastify.post('/AllUsersAccess', async (request, reply) => {
    return fastify.pg.transact(async client => {
      //const id = parseInt([request.params.id]);
      const p_org_id = request.org_id;
      const p_user_id = request.user_id;
      const users_roles_access_control_All = (await fastify.pg.query(" SELECT * FROM users_roles_access_control WHERE org_id = $1 order by id; ", [p_org_id])).rows;
      return users_roles_access_control_All
    }).catch((err) => {
      //err.message = 'Erreur de modification'
      throw err
    })
  })


  //update a user 
  fastify.put('/', async (request, reply) => {
    if (!global.license.F6) { return false }

    return fastify.pg.transact(async client => {
      //const id = parseInt([request.params.id]);
      const p_user_id = request.user_id;
      const { id, fname, lname, gender, address, email, password, created, createdby, updatedby, active,
        wilaya_id, org_id, org_directions_id, org_profession_id, role_id, file_name } = request.body;

      const { rows } = await fastify.pg.query("UPDATE users SET fname=$2, lname=$3, gender=$4, address=$5, "
        + " email=$6, password=$7, created=$8, createdby=$9, updated=now(), updatedby=$10, active=$11, "
        + " wilaya_id=$12, org_id=$13, org_directions_id=$14, org_profession_id=$15,file_name=$16 WHERE id = $1",
        [id, fname, lname, gender, address, email, password, created, createdby, updatedby, active,
          wilaya_id, org_id, org_directions_id, org_profession_id, file_name]);

      const { row_role_id } = await fastify.pg.query("UPDATE users_roles SET role_id=$2, updated=now(), updatedby=$3 WHERE user_id = $1",
        [id, role_id, p_user_id])

      //   console.log('maiiiiiiil1' + [email])
      if ([active]) {
        fastify.nodemailer.sendMail({
          from: 'h_djellouli@esi.dz',
          to: email,//[email],
          subject: 'Compte DZental',
          html: 'Bonjour Mr/Mme,' + [fname] + ' ' + [lname] + ','
            + '<p>Votre compte a été modifié</p>'
        }, (err, info) => {
          if (err) { console.log('err : ' + err) }
          //  console.log('info : ' + info)
          reply.send({
            messageId: info.messageId
          })
        })
      }
      //   console.log('maiiiiiiil2')

      return id
    }).catch((err) => {
      //err.message = 'Erreur de modification'
      throw err
    })
  })

  /********** Upload Patient avatar  Documents ************/
  const multer = require('fastify-multer')
  fastify.register(multer.contentParser)
  var crypto = require('crypto');
  var mime = require('mime-types');

  const storage = multer.diskStorage({
    destination: function (req, file, cb) {
      cb(null, '../users/avatar/')

    },
    filename: function (req, file, cb) {
      crypto.pseudoRandomBytes(16, function (err, raw) {
        var old_file_name = raw.toString('hex') + Date.now() + '.' + mime.extension(file.mimetype);
        req.old_file_name = old_file_name;
        cb(null, old_file_name);
      });

    }
  })

  const upload = multer({ storage: storage })
  const cpUpload = upload.fields([{ name: 'file', maxCount: 1 },])

  var fs = require('fs');

  fastify.post('/avatar_document', { preHandler: cpUpload }, async (request, reply) => {
    // console.log('old_file_name ' + request.old_file_name)
    // console.log('new_file_name' + request.body.fileName)

    fs.rename('../users/avatar/' + request.old_file_name, '../users/avatar/' + request.body.fileName, function (err) {
      if (err) console.log('ERROR: ' + err);
    });

    return { success: true }
  })
  /***************************************************/
  //delete a user by id
  fastify.delete('/:id', async (request, reply) => {
    //
    if (request.params.id == 1) {
    //  console.log('identifiant = 1')
      //
      return 'xxxxxx'
    } else {
      const { rows } = await fastify.pg.query(
        'DELETE FROM Users WHERE id=$1', [request.params.id],
      )
      //
      return rows
    }
  })

  //Get users product
  fastify.get('/usersproduits/:id', async (request, reply) => {
    //
    const usersproduits = (await fastify.pg.query(
      ' SELECT id, users_id, designation, created, createdby, updated, updatedby,COALESCE(active,false::boolean) active FROM vue_users_produits WHERE users_id=$1', [request.params.id]
    )).rows

    const orgproduits_without_usersproduits = (await fastify.pg.query(
      ' SELECT users_id, id, org_id, designation, created, createdby, updated, updatedby, COALESCE(active,false::boolean) active '
      + ' FROM vue_orgproduits_without_usersproduits '
      + ' WHERE users_id=$1', [request.params.id]
    )).rows


    //
    reply.send([{
      success: true,
      usersproduits: usersproduits,
      orgproduits_without_usersproduits: orgproduits_without_usersproduits,
    }]);
  })

  //Add produits for users
  fastify.post('/usersproduits/', async (request, reply) => {
    return fastify.pg.transact(async client => {
      var p_user_id = request.user_id;
      const { user_id, produit_id } = request.body;
      if (user_id != null && produit_id) {
        const { id } = (await fastify.pg.query("INSERT INTO users_produits( user_id, produit_id, created,createdby, updated, updatedby, active)  VALUES ($1,$2,now(),$3,now(),$4,true) RETURNING id",
          [user_id, produit_id, p_user_id, p_user_id])).rows[0]
       // console.log("************ inserted_id *******" + JSON.stringify(id))

        if (id) {
          const usersproduits = (await fastify.pg.query(
            'SELECT id, users_id, designation, created, createdby, updated, updatedby,COALESCE(active,false::boolean) active FROM vue_users_produits WHERE users_id=$1', [user_id]
          )).rows

          const orgproduits_without_usersproduits = (await fastify.pg.query(
            ' SELECT users_id, id, org_id, designation, created, createdby, updated, updatedby, COALESCE(active,false::boolean) active '
            + ' FROM vue_orgproduits_without_usersproduits '
            + ' WHERE users_id=$1', [user_id]
          )).rows

          reply.send([{
            success: true,
            usersproduits: usersproduits,
            orgproduits_without_usersproduits: orgproduits_without_usersproduits,
          }]);
        }
      }
    }).catch((err) => {
      //err.message = 'Erreur de modification'
      throw err
    }).finally(() => {
     // console.log('Cloooooooooooooooooooose connection')
      //;
      //client.end();
    })

  })

  //delete produits for users
  //We use put because The $http service source code, a DELETE request using $http does not allow for data to be sent in the body of the request.
  fastify.put('/usersproduits/', async (request, reply) => {
    return fastify.pg.transact(async client => {

      const { user_id, produit_id } = request.body;
     // console.log("************ produit_id *******" + produit_id)
      if (user_id != null && produit_id) {

        const { id } = (await fastify.pg.query("DELETE FROM users_produits WHERE  user_id = $1 AND produit_id = $2 RETURNING id",
          [user_id, produit_id])).rows[0]
   //     console.log("************ inserted_id *******" + JSON.stringify(id))

        if (id) {
          const usersproduits = (await fastify.pg.query(
            'SELECT id, users_id, designation, created, createdby, updated, updatedby,COALESCE(active,false::boolean) active FROM vue_users_produits WHERE users_id=$1', [user_id]
          )).rows

          const orgproduits_without_usersproduits = (await fastify.pg.query(
            ' SELECT users_id, id, org_id, designation, created, createdby, updated, updatedby, COALESCE(active,false::boolean) active '
            + ' FROM vue_orgproduits_without_usersproduits '
            + ' WHERE users_id=$1', [user_id]
          )).rows

          reply.send([{
            success: true,
            usersproduits: usersproduits,
            orgproduits_without_usersproduits: orgproduits_without_usersproduits,
          }]);
        }
      }
    }).catch((err) => {
      //err.message = 'Erreur de modification'
      throw err
    }).finally(() => {
   //   console.log('Cloooooooooooooooooooose connection')
      //;
      //client.end();
    })

  })

  fastify.put('/readed_notification/:id', async (request, reply) => {
    return fastify.pg.transact(async client => {
      const p_user_id = request.user_id;
      const notification_id = parseInt([request.params.id]);
      const { id } = await fastify.pg.query("UPDATE users_notifications SET read=true,updatedby=$2,updated=now()  WHERE id = $1 RETURNING id;",
        [notification_id, p_user_id])
      reply.send(id)
    }).catch((err) => {
      //err.message = 'Erreur de modification'
      throw err
    }).finally(() => {
      //console.log('Cloooooooooooooooooooose connection')
      //;
      //client.end();
    })
  })



  //Get statistiques
  fastify.get('/statistiques', async (request, reply) => {
    const p_org_id = request.org_id;
    const p_user_id = request.user_id;
    const { rows } = await fastify.pg.query(
      'SELECT * FROM statistique_utilisateur WHERE id = $1', [p_user_id]
    )

    return rows
  })


  //Get notifications  
  fastify.get('/notifications', async (request, reply) => {
    const p_user_id = request.user_id;
    var p_org_id = request.org_id;

    const { rows } = await fastify.pg.query(
      'SELECT id, user_id, broadcast, expiration_date,header,message,age(now(),created) age,read,active'
      + ' FROM users_notifications '
      + ' WHERE (user_id= $1  OR broadcast) AND (now() <=expiration_date ) AND active AND org_id = $2'
      + ' ORDER BY created ;', [p_user_id, p_org_id]
    )

    //
    return rows
  })


  //ADD user notifications  
  fastify.post('/add_notification', (request, reply) => {
    // will return a promise, fastify will send the result automatically
    return fastify.pg.transact(async client => {
      const p_org_id = request.org_id;
      const p_user_id = request.user_id;
      const { broadcast, expiration_date, header, message, read } = request.body;

      const new_notification_id = (await fastify.pg.query("INSERT INTO public.users_notifications("
        + "org_id, user_id, broadcast, expiration_date,header, message,  read, created, createdby, updated, updatedby, active)"
        + " VALUES ($1,$2,$3,$4,$5,$6,$7,now(),$8,now(),$9,true) RETURNING id ",
        [p_org_id, p_user_id, broadcast, expiration_date, header, message, read, p_user_id, p_user_id])).rows[0].id;

      if (new_notification_id) {
        const { rows } = await fastify.pg.query(
          "SELECT * FROM users_notifications WHERE (user_id= $1  OR broadcast) AND (now() <=expiration_date ) AND active AND org_id = $2", [p_user_id, p_org_id],
        )
        return rows;
      }
    }).catch((err) => {
      //err.message = 'Erreur de modification'
      throw err
    })
  })

  fastify.get('/get_all_org_contacts_messages', async (request, reply) => {
    var p_org_id = request.org_id;
    const p_user_id = request.user_id;

    const contacts = (await fastify.pg.query(
      "SELECT id, org_id, org,org_profession_id,profession, org_directions_id, direction, "
      + " org_tel,org_fax, org_email, org_site_internet, org_adresse,org_logo,org_background, "
      + " wilaya_id, wilaya, "
      + " role_id, user_role, lname, fname, gender, email, token,avatar, "
      + " first_visit, active,created,createdby,password,password repassword  FROM dzental_users WHERE org_id = $1 AND id <> $2 ORDER BY id;", [p_org_id, p_user_id])).rows

    const messages = (await fastify.pg.query(
      " SELECT * FROM public.vue_users_messages WHERE (createdby = $1) OR (to_user_id = $1) ORDER BY id;", [p_user_id])).rows

    return {
      contacts: contacts,
      messages: messages
    }

  })




  function generate_random_password(length) {
    var result = '';
    var characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    var charactersLength = characters.length;
    for (var i = 0; i < length; i++) {
      result += characters.charAt(Math.floor(Math.random() * charactersLength));
    }
    return result;
  }


}//End Module

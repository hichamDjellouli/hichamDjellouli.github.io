'use strict'

module.exports = async function (fastify, opts) {
  //Get all Org
  fastify.get('/all', async (request, reply) => {
    
    fastify.pg.query(
      'SELECT * FROM org ORDER BY id;',
      function onResult(err, result) {
        //err.message = 'Erreur de selection'
        reply.send(err || result.rows)
      })

  })

  //Add new org
  fastify.post('/insert', (request, reply) => {
    // will return a promise, fastify will send the result automatically
    return fastify.pg.transact(async client => {
      var p_org_id = request.org_id;
      const { org_id, org_directions_id, wilaya_id, fname, lname, gender, address, email, password, createdby, updatedby, active, role_id } = request.body;
      if (p_org_id == null) {
        p_org_id = createdby;
      }
      if (p_org_id == null) {
        p_org_id = 0;//By system
      }
      const { rows } = await fastify.pg.query("INSERT INTO org(org_id,org_directions_id,wilaya_id,fname, lname, gender, address, email, password, created,createdby, updated, updatedby, active)  VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,now(),$10,now(),$11,false) RETURNING id",
        [org_id, org_directions_id, wilaya_id, fname, lname, gender, address, email, password, p_org_id, p_org_id])
      //console.log('rows.id ' + JSON.stringify(rows[0].id));

      const { role } = await fastify.pg.query("INSERT INTO org_roles(org_id, role_id, created, createdby, updated, updatedby,active) VALUES ($1,$2,now(),$3,now(),$4,true)",
        [rows[0].id, role_id, p_org_id, p_org_id])

      return rows
    }).catch((err) => {
      //err.message = 'Erreur de modification'
      throw err
    })
  })

  //update a org 
  fastify.put('/', async (request, reply) => {
    if (!global.license.F7) {return false}

    return fastify.pg.transact(async client => {
      //const id = parseInt([request.params.id]);
      const p_org_id = request.org_id;
      const p_user_id = request.user_id;

      const { id, designation, tel, email, site_internet, adresse, file_name, file_name_background, fax, wilaya_id, reminder_delay, is_rappel_rdv_automatique } = request.body;
      const { rows } = await fastify.pg.query("UPDATE public.org"
        + " SET designation=$2, tel=$3, email=$4, site_internet=$5, adresse=$6, file_name =$7,file_name_background =$8,fax =$9,wilaya_id = $10,reminder_delay = $11,is_rappel_rdv_automatique=$12,updated=now(), updatedby=$13, active=true"
        + " WHERE id = $1",
        [p_org_id, designation, tel, email, site_internet, adresse, file_name, file_name_background, fax, wilaya_id, reminder_delay, is_rappel_rdv_automatique, p_user_id]);

      return id
    }).catch((err) => {
      //err.message = 'Erreur de modification'
      throw err
    })
  })
  /********** Upload Patient Logo  Documents ************/
  const multer = require('fastify-multer')
  fastify.register(multer.contentParser)
  var crypto = require('crypto');
  var mime = require('mime-types');

  const storage = multer.diskStorage({
    destination: function (req, file, cb) {
      cb(null, '../org/logo/')

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

  fastify.post('/logo_document', { preHandler: cpUpload }, async (request, reply) => {
    //console.log('old_file_name ' + request.old_file_name)
    //console.log('new_file_name' + request.body.fileName)

    fs.rename('../org/logo/' + request.old_file_name, '../org/logo/' + request.body.fileName, function (err) {
      if (err) console.log('ERROR: ' + err);
    });

    return { success: true }
  })
  /****************************************************************************** */
  /********** Upload Patient Background  Documents ************/

  const storage2 = multer.diskStorage({
    destination: function (req, file, cb) {
      cb(null, '../org/background/')

    },
    filename: function (req, file, cb) {
      crypto.pseudoRandomBytes(16, function (err, raw) {
        var old_file_name_background = raw.toString('hex') + Date.now() + '.' + mime.extension(file.mimetype);
        req.old_file_name_background = old_file_name_background;
        cb(null, old_file_name_background);
      });

    }
  })

  const upload2 = multer({ storage: storage2 })
  const cpUpload2 = upload2.fields([{ name: 'file', maxCount: 1 },])


  fastify.post('/background_document', { preHandler: cpUpload2 }, async (request, reply) => {


    fs.rename('../org/background/' + request.old_file_name_background, '../org/background/' + request.body.fileNameBackground, function (err) {
      if (err) console.log('ERROR: ' + err);
    });

    return { success: true }
  })
  /*************************************************************************************** */
  const path = require('path')
  fastify.register(require('fastify-static'), {
    root: path.join(__dirname, ''),
  })

  fastify.get('/download_logo_document/:fileName', function (request, reply) {

    if (request.params.fileName) {
      //console.log('request.body.fileName ' + request.params.fileName)
      reply.sendFile(request.params.fileName) // serving a file from a different root location
    } else
      return {
        success: false
      }
  })
  /****************************************************************************/
  //delete a org by id
  fastify.delete('/:id', async (request, reply) => {

    if (request.params.id == 1) {
      //console.log('identifiant = 1')

      return 'xxxxxx'
    } else {
      const { rows } = await fastify.pg.query(
        'DELETE FROM Org WHERE id=$1', [request.params.id],
      )

      return rows
    }
  })

  fastify.get('/orgusers/:id', async (request, reply) => {

    const orgusers = (await fastify.pg.query(
      ' SELECT id, org_id, designation, created, createdby, updated, updatedby,COALESCE(active,false::boolean) active FROM vue_org_produits WHERE org_id=$1', [request.params.id]
    )).rows

    const produits_without_orgproduits = (await fastify.pg.query(
      ' SELECT  id, designation, created, createdby, updated, updatedby, COALESCE(active,false::boolean) active '
      + ' FROM produit '
      + ' WHERE NOT EXISTS(SELECT * FROM org_produits WHERE org_produits.produit_id = produit.id AND org_produits.org_id=$1) ', [request.params.id]
    )).rows

    //Close connection

    reply.send([{
      success: true,
      orgproduits: orgproduits,
      produits_without_orgproduits: produits_without_orgproduits,
    }]);
  })

  //Get org product
  fastify.get('/orgproduits/:id', async (request, reply) => {

    const orgproduits = (await fastify.pg.query(
      ' SELECT id, org_id, designation, created, createdby, updated, updatedby,COALESCE(active,false::boolean) active FROM vue_org_produits WHERE org_id=$1', [request.params.id]
    )).rows

    const produits_without_orgproduits = (await fastify.pg.query(
      ' SELECT  id, designation, created, createdby, updated, updatedby, COALESCE(active,false::boolean) active '
      + ' FROM produit '
      + ' WHERE NOT EXISTS(SELECT * FROM org_produits WHERE org_produits.produit_id = produit.id AND org_produits.org_id=$1) ', [request.params.id]
    )).rows

    //Close connection

    reply.send([{
      success: true,
      orgproduits: orgproduits,
      produits_without_orgproduits: produits_without_orgproduits,
    }]);
  })

  //Add produits for org
  fastify.post('/orgproduits/', async (request, reply) => {
    return fastify.pg.transact(async client => {
      var p_user_id = request.user_id;
      var p_org_id = request.org_id;
      const { org_id, produit_id } = request.body;
      //console.log("************ org_id *******" + org_id)
      //console.log("************ Query  *******" +
       // "INSERT INTO org_produits( org_id, produit_id, created,createdby, updated, updatedby, active)  VALUES (" + org_id + "," + produit_id + ",now()," + p_user_id + ",now()," + p_user_id + ",true) RETURNING id")

      if (org_id != null && produit_id != null) {
        const { id } = (await fastify.pg.query("INSERT INTO org_produits( org_id, produit_id, created,createdby, updated, updatedby, active)  VALUES ($1,$2,now(),$3,now(),$4,true) RETURNING id",
          [org_id, produit_id, p_user_id, p_user_id])).rows[0]
        //console.log("************ inserted_id *******" + JSON.stringify(id))

        if (id) {
          const orgproduits = (await fastify.pg.query(
            'SELECT id, org_id, designation, created, createdby, updated, updatedby,COALESCE(active,false::boolean) active FROM vue_org_produits WHERE org_id=$1', [org_id]
          )).rows

          const produits_without_orgproduits = (await fastify.pg.query(
            ' SELECT  id, designation, created, createdby, updated, updatedby, COALESCE(active,false::boolean) active '
            + ' FROM produit '
            + ' WHERE NOT EXISTS(SELECT * FROM org_produits WHERE org_produits.produit_id = produit.id AND org_produits.org_id=$1) ', [org_id]
          )).rows

          reply.send([{
            success: true,
            orgproduits: orgproduits,
            produits_without_orgproduits: produits_without_orgproduits,
          }]);
        }
      }
    }).catch((err) => {
      //err.message = 'Erreur de modification'
      throw err
    })

  })

  //delete produits for org
  //We use put because The $http service source code, a DELETE request using $http does not allow for data to be sent in the body of the request.
  fastify.put('/orgproduits/', async (request, reply) => {
    return fastify.pg.transact(async client => {

      const { org_id, produit_id } = request.body;
     // console.log("************ produit_id *******" + produit_id)
      if (org_id != null && produit_id != null) {

        const { id } = (await fastify.pg.query("DELETE FROM org_produits WHERE  org_id = $1 AND produit_id = $2 RETURNING id",
          [org_id, produit_id])).rows[0]
      //  console.log("************ inserted_id *******" + JSON.stringify(id))

        if (id) {
          const orgproduits = (await fastify.pg.query(
            'SELECT id, org_id, designation, created, createdby, updated, updatedby,COALESCE(active,false::boolean) active FROM vue_org_produits WHERE org_id=$1', [org_id]
          )).rows

          const produits_without_orgproduits = (await fastify.pg.query(
            ' SELECT  id, designation, created, createdby, updated, updatedby, COALESCE(active,false::boolean) active '
            + ' FROM produit '
            + ' WHERE NOT EXISTS(SELECT * FROM org_produits WHERE org_produits.produit_id = produit.id AND org_produits.org_id=$1) ', [org_id]
          )).rows

          reply.send([{
            success: true,
            orgproduits: orgproduits,
            produits_without_orgproduits: produits_without_orgproduits,
          }]);
        }
      }
    }).catch((err) => {
      //err.message = 'Erreur de modification'
      throw err
    })

  })



  fastify.put('/readed_notification/:id', async (request, reply) => {
    return fastify.pg.transact(async client => {
      const p_org_id = request.org_id;
      const notification_id = parseInt([request.params.id]);
      const { id } = await fastify.pg.query("UPDATE org_notifications SET read=true,updatedby=$2,updated=now()  WHERE id = $1 RETURNING id;",
        [notification_id, p_org_id])
      reply.send(id)
    }).catch((err) => {
      //err.message = 'Erreur de modification'
      throw err
    })
  })

}

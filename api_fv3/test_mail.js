const fastify = require('fastify')()

fastify.register(require('fastify-nodemailer'), {
    pool: true,
    host: 'smtp.gmail.com',
    port: 465,
    secure: true, // use TLS
    auth: {
        user: 'info.cnl.dz@gmail.com',
        pass: '7^7A4_vd;A-6Y5Y.svcX'
    }
})

fastify.get('/sendmail/:email', (req, reply, next) => {
   
    let { nodemailer } = fastify
    let recipient = req.params.email
    console.log('Begin Sending mail : '+recipient)
    fastify.nodemailer.sendMail({
        from: 'h_djellouli@esi.dz',
        to: recipient,
        subject: 'foo',
        text: 'bar'
    }, (err, info) => {
        if (err) next(err)
        reply.send({
            messageId: info.messageId
        })
    })
    console.log('End Sending mail')

})

fastify.listen(4000, err => {
    if (err) throw err
    console.log(`server listening on ${fastify.server.address().port}`)
})
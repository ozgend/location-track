var express = require('express'),
    app = express()
  , http = require('http')
  , server = http.createServer(app)
  , io = require('socket.io').listen(server);

server.listen(1188);

app.configure(function(){
	app.use(express.bodyParser());
});


app.set('title', 'ntap');

app.get('/', 
	function (req, res) {
  		res.sendfile(__dirname + '/index.html');
	}
);


app.post('/alive', function(req, res) {
    console.log("alive: %s ", JSON.stringify(req.body));
    io.sockets.emit('alive', req.body);
	res.send('ok');
});


io.sockets.on('connection', 
	function (socket) {
  		socket.emit('news', { hello: 'world' });
  		socket.on('my other event', function (data) {
    			console.log(data);
  		});
});
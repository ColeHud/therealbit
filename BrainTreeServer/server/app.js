app.get("/client_token", function (req,res) {
	gateway.clientToken.generate({}, function (err.response) {
		res.send(respond.clientToken);
	});
});

app.post("/payment-methods", function (req, res) {
	var nonce = req.body.payment_method_nonce;
});

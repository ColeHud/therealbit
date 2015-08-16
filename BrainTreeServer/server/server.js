var braintree = require("braintree");

var gateway = braintree.connect({
	environment: braintree.Environment.Sandbox,
	merchantId: "#",
	publicKey: "#",
	privateKey: "#"
});

gateway.transation.sale({
	amount: 'parse_amount',
	paymentMethodNonce: nonceFromTheClient,
}, function (err, result) {

});


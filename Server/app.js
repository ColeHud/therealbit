//libraries
var schedule = require('node-schedule');
var blockchain = require('blockchain.info');
var Parse = require('parse').Parse;

//set up parse
Parse.initialize("T7IdleWlnGMMAnwREm9clA8UogD46ZOIKnDq4t8Y", "7j1Dckyuv2QIiKbwgIsnSijfVnhnh5KspMBTkdnl");

//get the address of the person with the most points
var getWinnerAddress = function(cb)
{
	var HighScore = Parse.Object.extend("HighScore");
	var query = new Parse.Query(HighScore);
	query.equalTo("objectId", "XVKrk2qZjw");
	query.find({
  		success: function(results) {
   		 	console.log("Successfully retrieved " + results.length + " scores");
    		// Do something with the returned Parse.Object values
      			var object = results[0];
      			cb(null, object.get('address'));
  			},
  			error: function(error) {
  	  		alert("Error: " + error.code + " " + error.message);
  	  		cb(error);
  		}
	});
}

//pay the winner in bitcoin
var payTheWinner = function(address)
{
	var myWallet = new blockchain.MyWallet("f0c25bc8-3a69-4730-8c8e-4a4e4b132339", "$Hudson12compsci");
	myWallet.getBalance(function(err, data){
		var options = {
			'to': address,
			'amount': data,
			'from': '1NuL6cSsndGRCEk9dijAa9v7ysqo4qQax5',
			'fee': 1000
		}
		if(err)
		{
			console.log(err);
		}
		myWallet.send(options, function(err, data){
			console.log("Winner Paid");
		});
	});
}

//schedule the daily paying of the winner
var rule = new schedule.RecurrenceRule();

rule.dayOfWeek = [0, new schedule.Range(1, 6)];
rule.hour = 23;
rule.minute = 59;

var j = schedule.scheduleJob(rule, function(){
	getWinnerAddress(function(err, address) {
		if (err) {
			return console.error(err.stack);
		}
    	payTheWinner(address);
	})
});

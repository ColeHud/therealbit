//libraries
var schedule = require('node-schedule');
var blockchain = require('blockchain.info');
var Parse = require('parse').Parse;

//set up parse
Parse.initialize("T7IdleWlnGMMAnwREm9clA8UogD46ZOIKnDq4t8Y", "7j1Dckyuv2QIiKbwgIsnSijfVnhnh5KspMBTkdnl");
var app = new Parse(options);

//get the address of the person with the most points
var getWinnerAddress = function()
{
	var HighScore = Parse.Object.extend("HighScore");
	var query = new Parse.Query(HighScore);
	query.equalTo("objectId", "XVKrk2qZjw");
	query.find({
  		success: function(results) {
   		 	alert("Successfully retrieved " + results.length + " scores");
    		// Do something with the returned Parse.Object values
      			var object = results[0];
      			return object.get('address'));
  			},
  			error: function(error) {
  	  		alert("Error: " + error.code + " " + error.message);
  		}
	});
}

//pay the winner in bitcoin
var payTheWinner = function(address)
{
	var myWallet = new blockchain.MyWallet("f0c25bc8-3a69-4730-8c8e-4a4e4b132339", "$Hudson12compsci");
	myWallet.getBalance([false], function(err, data){
		var options = {
			'to': address,
			'amount': wallet.balance,
			'from': '1NuL6cSsndGRCEk9dijAa9v7ysqo4qQax5',
			'fee': 100
		}
	});
}

//schedule the daily paying of the winner
var rule = new schedule.RecurrenceRule();

rule.dayOfWeek = [0, new schedule.Range(0, 6)];
rule.hour = 23;
rule.minute = 59;

var j = schedule.scheduleJob(rule, function(){
    payTheWinner(getWinnerAddress());
});

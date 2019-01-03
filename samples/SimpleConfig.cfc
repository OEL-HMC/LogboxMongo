component{
	
	function configure(){
		logBox = {
			"appenders" = {
				"mongo" = {
	                "class" = "MongoAppender",
	                "properties" = {
	                	"target":{
	                		"database": "mongologbox",
	                		"collection": "mongologbox_collection",
	                		"host": "127.0.0.1",
	                    	"port": 27017,
	                    	"async": false
	                	},
	                	async: false
	                }
	            }
			},
			root = {levelMin = 'fatal', levelMax = 'debug', appenders = 'mongo'},
			categories = {
				'GENERAL' = {levelMin = 'fatal', levelMax = "debug", appenders = 'mongo'}
			}
		};
		
	}

}
component{
	
	function configure(){
		logBox = {
			"appenders" = {
				"mongo" = {
	                "class" = "MongoAppender",
	                "properties" = {
	                	"connection":{
	                		"host": "127.0.0.1",
	                    	"port": 20017	
	                	},
	                	"target":{
	                		"database": "mongologbox-db",
	                		"collection": "mongologbox-db"
	                	}
	                }
	            }
			},
			categories = {
				'QE.LOG' = {levelMin = 'FATAL', levelMax = "WARN", appenders = 'mongo'}
			}
		};
	}

}
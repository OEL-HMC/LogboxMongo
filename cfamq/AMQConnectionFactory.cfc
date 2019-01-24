component 
{
	
	property name="factory";
	
	public AMQConnectionFactory function init(){
		return this;
	}
	
	public AMQConnectionFactory function setFactory( required any factory ){
		variables.factory = arguments.factory;
		return this;
	}
	
	private struct function getShortenedConf( required struct conf ){
		
		var shortened = {
			"type": (structKeyExists( arguments.conf, 'type' ) ? arguments.conf.type : "default")
		};
		
		
		var check = 0;
		//must have 0 or both userName and password
		for( var key in ['userName', 'password'] ){
			if( structKeyExists( arguments.conf, local.key ) ){
				++ local.check;
			}
		}

		if( local.check == 1 ){
			throw( message="You must provide userName AND password to create the connection." );
		}

		if( local.check == 2 ){
			local.shortened['userName'] = arguments.conf.userName;
			local.shortened['password'] = arguments.conf.password;
		}
		
		return local.shortened;
		
	}
	
	
	public AMQConnection function buildAMQConnection( required struct conf = {} ){

		var shortenedConf = getShortenedConf( arguments.conf );
		var keysLen = listLen( structKeyList( local.shortenedConf ) );
		var connection = 0;
				
		switch( local.shortenedConf.type ){
			/*
			case 'default':
				if( keysLen == 3 ){
					local.connection = variables.factory.createConnection( local.shortenedConf.userName, local.shortenedConf.password  );
				}else{
					local.connection = variables.factory.createConnection();	
				}
				
			break;
			*/
			case 'default':
			case 'topic':
				if( keysLen == 3 ){
					local.connection = variables.factory.createTopicConnection( local.shortenedConf.userName, local.shortenedConf.password  );
				}else{
					local.connection = variables.factory.createTopicConnection(); 
				}
			break;
			case 'queue':
				if( keysLen == 3 ){
					local.connection = variables.factory.createQueueConnection( local.shortenedConf.userName, local.shortenedConf.password  );
				}else{
					local.connection = variables.factory.createQueueConnection(); 
				}
			break;
		}
		
		if( isSimpleValue( local.connection ) ){
			throw( message= "Cannot create connection." );
		}
		
		return new AMQConnection().setConnection( local.connection );
		
	}
	
}
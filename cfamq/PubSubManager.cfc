component {
	
	property name="connections" hint="stores AMQConnections";
	property name="sessions" hint="stores the sessions by client name";
	property name="publishers" type="struct";
	property name="consumers" type="struct" ;
	property name="configurationValidator";
	
	import "activemq.amq.*";
	
	public PubSubManager function init(){
		
		variables.configurationValidator = new AMQConfigurationValidator();
		variables.connectionFactoryBuilder = new ConnectionFactoryBuilder();
		
		variables.sys 				= createObject("java", "java.lang.System");
		
		for( var k in ['publishers', 'consumers', 'connections', 'sessions'] ){
			variables[ local.k ] = {};
		}
		 
		return this;	
	}
	
	/*
	* Sessions
	*/

	public boolean function hasAMQSession( required string name ){
		return structKeyExists( this.getAMQSessions(), arguments.name );
	}

	public void function addAMQSession( required string name, required AMQSession amqSession ){
		structInsert( this.getAMQSessions(), arguments.name, arguments.amqSession );
	}

	public void function removeAMQSession( required string name ){
		getAMQSession( arguments.name ).close();
		structDelete( this.getAMQSessions(), arguments.name );
	}

	public AMQSession function getAMQSession( required string name ){
		return variables.sessions[ arguments.name ];
	}

	public struct function getAMQSessions(){
		return variables.sessions;
	}

	/* 
	* Connections 
	*/
	public any function getAMQConnection( required string clientID ){ 
		return variables.connections[ arguments.clientID ]; 
	}
	
	public PubSubManager function addAMQConnection( required string name, required AMQConnection connection ){
		writeOutput("<br>#arguments.name# added");
		arguments.connection.getConnection().start();
		structInsert( variables.connections, arguments.name, arguments.connection, false );
		return this;
	}
	
	public any function hasAMQConnection( required string clientID ){ 
		return structKeyExists( variables.connections, arguments.clientID ); 
	}
	
	public void function openAMQConnection( required string clientID ){
		if( ! this.hasAMQConnection( arguments.clientID ) ){
			throw( message="The connection you are trying to open does not exist." );
		}
		getAMQConnection( arguments.clientID ).open();
	}
	
	public void function closeAMQConnection( required string clientID )
	hint="Closes the connection if it exists but does not remove it."
	{
		if( this.hasAMQConnection( arguments.clientID ) ){ 
			getAMQConnection( arguments.clientID ).getConnection().close(); 
		}
	}
	
	public void function removeAMQConnection( required string clientID )
	hint="Closes AMQ Connection and removes it from variables scope"
	{
		//no need to check existence as it is checked on close
		this.closeAMQConnection( arguments.clientID );
		structDelete( variables.connections,arguments.clientID, false );
	}
	
	public void function log( required string message )
	{
		variables.sys.out.println( arguments.message );
	}
	
	public struct function getConsumers(){
		return variables.consumers;
	}
	
	private void function addConsumer( 
		required string name, 
		required Consumer consumer 
	){
		variables.consumers[ arguments.name ] = arguments.consumer;	
	}
	
	private boolean function addPublisher( required string name, required Publisher publisher ){
		variables.publishers[ arguments.name ] = arguments.publisher;
	}
	
	public array function getPublisherNames(){
		return structKeyArray( variables.publishers );
	}
	
	public array function getConsumerNames(){
		return structKeyArray( variables.consumers );
	}
	
	public struct function getPublishers() hint="Gets the publishers structure" {
		return variables.publishers;
	}
	
	public Consumer function getConsumer( required string clientId ){
		return variables.consumers[ arguments.clientId ];
	}
	
	public Publisher function getPublisher( required string clientId ) hint="Gets a publisher using a connection name with args[clientId]" {
		return  variables.publishers[ arguments.clientId ];
	}
	
	public boolean function hasPublisher( required string clientId )
	hint="Tells if a publisher has been created with a connection having arg clientId as id."
	{
		return structKeyExists( variables.publishers, arguments.clientId );
	}
	
	public boolean function removeAll(){

		writeOutput( "<br>#arrayLen(structKeyArray(getPublishers()))# publishers to remove" );
		
		for( var pubName in getPublishers() ){
			removePublisher(pubName);
		}
		
		writeOutput( "<br>#arrayLen(structKeyArray(getConsumers()))# consumers to remove" );
		
		for( var pubName in getConsumers() ){
			removeConsumer(pubName);
		}

		writeOutput( "<br>#arrayLen(structKeyArray(getAMQSessions()))# sessions to remove" );
		
		for( var sessionName in getAMQSessions() ){
			removeAMQSession( local.sessionName );
		}

		writeOutput( "<br>#arrayLen( structKeyArray( variables.connections ) )# connections to remove" );
		
		for( var connName in variables.connections ){
			this.removeAMQConnection( local.connName );
		}

		return true;
	}
	
	public boolean function removePublisher( required string clientId ){
		if( ! hasPublisher(arguments.clientId) ){
			return false;
		}
		try{
			getPublisher( arguments.clientId ).getPublisher().close();
		}catch( any e ){}
		structDelete(variables.publishers, arguments.clientId, false  );
		return true;
	}
	
	public boolean function hasConsumer( required string name ){
		return structKeyExists( variables.consumers, arguments.name );
	}
	
	public boolean function removeConsumer( required string clientId ){
		if( ! hasConsumer(arguments.clientId) ){
			return false;
		}
		try{
			variables.consumers[ arguments.clientId ].getConsumer().close();
		}catch( any e ){
			//just sym
			writeDump(e);
		}
		structDelete(variables.consumers, arguments.clientId, false  );
		return true;
	}
	
	public array function getClientConfigurationRequiredKeys(){
		return ['name', 'type', 'connectionName', 'destinationType', 'destinationName'];
	}
	
	public struct function validateClientConfiguration( required struct conf ){
		
		var resp = { "valid": true, "message": "Everything went fine.", "wrongField": "" };
		
		/*
		if( structIsEmpty( arguments.conf ) ){
			return { "valid": false, "message": "client configuration should not be empty", "wrongField": "" };
		}*/
		
		for( var requiredKey in getClientConfigurationRequiredKeys() ){
			if( 
				! ( 
					structKeyExists( arguments.conf, local.requiredKey ) 
					&& ! isNull( arguments.conf[ local.requiredKey ] )
					&& isSimpleValue( arguments.conf[ local.requiredKey ] )
					&& ( trim( arguments.conf[ local.requiredKey ] ) != '' )
				) 
			){
				return { "valid": false, "message": "#local.requiredKey# is missing in AMQ configuration", "wrongField": local.requiredKey };
			}
		}
		return resp;
	}

	
	
	

	public PubSubManager function initiate( required struct conf ){
		
		
		
		
		var validation = configurationValidator.validateConfiguration(arguments.conf);
		
		if( ! validation.valid ){
			throw( type="CFAMQ.INVALID_CONFIGURATION", message="#validation.message#" );
		}
		

		for( var conn in arguments.conf.connections ){
			//try to create the connections if they don't exist.
			if( ! this.hasAMQConnection( local.conn.name ) ){
				var connectionObj = variables.connectionFactoryBuilder.buildConnectionFactory( local.conn ).buildAMQConnection( local.conn ) ;
				this.addAMQConnection( local.conn.name, local.connectionObj );
				//local.connectionObj.getConnection().start();
				
			}
			
		}

		//try to build the clients
		
			
			for( var clientConf in arguments.conf.clients ){
		
				var validation = validateClientConfiguration( local.clientConf );
				if( ! validation.valid ){
					throw( type="CFAMQ.INVALID_CLIENT_CONFIG", message=validation.message );
				}

				//check required fields		
				for( var requiredKey in ['name', 'type', 'connectionName', 'destinationType', 'destinationName'] ){
					if( 
						! ( 
							structKeyExists( local.clientConf, local.requiredKey ) 
							&& ! isNull( local.clientConf[ local.requiredKey ] )
							&& ( trim( local.clientConf[ local.requiredKey ] ) != '' )
						) 
					){
						throw( "Misconfiguration on activemq client" );
					}
				}

				

				//if the connection does not exist, it must be a misconfiguration
				if( ! hasAMQConnection( local.clientConf.connectionName ) ){
					throw( 'Check your configuration : #local.clientConf.connectionName# does not exist.' );
				}
				
				//get the connection
				var conn = getAMQConnection( local.clientConf.connectionName );
				
				//get the session configuration
				var sessionConf = ( structKeyExists( local.clientConf, 'session' ) ) ? local.clientConf.session : {};
				
				//build the session object
				var sess = conn.buildSession( local.sessionConf );
				var objAmqClient = sess.createAMQClient( local.clientConf );

				addAMQSession( objAMQClient.getName(), local.sess );
				
				switch( local.clientConf.type ){
					case 'consumer':
						addConsumer(local.clientConf.name, local.objAmqClient);	
					break;
					case 'publisher':
						addPublisher(local.clientConf.name, local.objAmqClient);
					break;
					default:
						throw("what's that type again ?");
					break;
				}
				
				
			}
			
		
		
		return this;
		
	}
	

	public struct function send(
		required string publisherName, 
		required string msg, 
		boolean deliveryMode, 
		numeric priority, 
		numeric timeToLive 
	){
		
		var result = { status: "ok" };
		//var publisherName = arguments.publisherName;
		
		//var args = duplicate(  );
		

		if( hasPublisher( arguments.publisherName ) ){
			//var args = structDelete( arguments , 'publisherName', false  );
			getPublisher( arguments.publisherName ).send( argumentCollection = arguments );
		}else{
			local.result = { status: "failed" };	
		}
	
		writeDump( local.result );
	
		return local.result;
	
	}

	/*
	public void function showConnections(){
		
		this.log( "Existing consumers and producers in EQS" );
		for( var key in ['publishers', 'consumers'] ){
			for( var pubName in variables[ key ] ){
				this.log( "In #local.key# we have : " & pubName );	
			}
		}
		
	}*/
	
}
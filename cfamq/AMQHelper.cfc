component accessors="false"
{

	property name="config";
	property name="psmName";
	property name="pubSubManagerName";
	property name="scopeName" type="string";
	property name="validator" type="AQMConfigurationValidator";
	
	
	import "activemq.amq.*";

	public AMQHelper function init( 
		string pubSubManagerName = 'AMQPubsubManager',
		string scopeName = 'application'
	){
		
		
		variables.validator = new AMQConfigurationValidator();


		if( ! listFind( getAllowedScopeNames(), arguments.scopeName ) ){
			throw( type="CFAMQ.INVALID_SCOPE_NAME", message="Allowed scope names are application or server" );
		}

		if( trim( arguments.pubSubManagerName ) == '' ){
			throw( type="CFAMQ.INVALID_PSM_NAME", message="PubSubManager name cannot be empty string." );
		}

		variables.pubSubManagerName = arguments.pubSubManagerName;
		variables.scopeName = arguments.scopeName;
		variables.config = {};
		return this;
	}

	public string function getScopeName(){
		return variables.scopeName;
	}

	public struct function getScope()
	hint="Returns the scope structure"
	{
		switch( getScopeName() ){
			case "application":
				return application;
			break; 
			case "server":
				return server;
			break; 
			case "request":
				return request;
			break; 
		}
	}

	public PubSubManager function getPubSubManager()
	hint="Returns the PubSubManager instance from scope"
	{
		return this.getScope()[ this.getPubSubManagerName() ];
	}

	public boolean function hasPubSubManager()
	hint="Tells if a pubSubManager has been registered"
	{
		return structKeyExists( this.getScope(), this.getPubSubManagerName() );
	}

	public struct function getConfig()
	hint="Returns the config"
	{
		return variables.config;
	}

	public string function getPubSubManagerName()
	hint="Returns the key holding the pubSubManager"
	{
		return variables.pubSubManagerName;
	}

	private string function getAllowedScopeNames(){
		return 'server,application,request';
	}
	


	public AMQHelper function setConfig( required struct conf ){
		/*
		{
			'connections':[
				{ 
					name:'', //required TRUE
					clientID: '', //required false, uses activeMQ generated ID if not sets
					'brokerURL':'127.0.0.1', // required FALSE default 127.0.0.1 
					userName: '', //required false | no default
					password:'', //required false  | no default
					 
				}
			],
			'clients': [
				{ 
					'type': 'consumer',
					'destinationType': 'topic|queue',
					'destinationName': 'topicName|queueName',  
					'durable': true | false
					'connectionName': 'connectionName',
					'listener': 'cfcPath',
					'session': {
						'transacted': true | false,
						'acknowledgeMode': 'auto|client|dups_ok'
					}
				}
			]
			
			'publisher': { topic: name, connectionName: '' },
			'consumer': { topic: name, listener: listener, connectionName }
		}
		*/
		var confValidation = validateConfiguration( arguments.conf ) ;
		if( ! confValidation.valid ){
			throw( type="AMQ.INVALID_CONFIF", message: confValidation.message );
		}
		variables.config = arguments.conf;
		return this;
	}
	
	public AMQHelper function registerPSM( required PubSubManager pubSubManager  ){

		structInsert( getScope(), getPubSubManagerName(), arguments.PubSubManager );
		sendNotification( "PSM registered in #getScopeName()#.#getPubSubManagerName()#" );

		return this;
	}
	
	public AMQHelper function unregisterPSM(){
		
		if( hasPubSubManager() ){
			this.killConnections();
		}
		
		structDelete( getScope(), getPubSubManagerName(), false );
		return this;
	}
	
	public AMQHelper function killConnections() hint="Tries to close all publishers and consumers connections"
	{
		
		getPubSubManager().removeAll();
		
		return this;
	}
	
	public struct function validateConfiguration( required struct config ){		
		return variables.validator.validateConfiguration( arguments.config );
	}

	public void function sendNotification( required string notification ){
		writeOutput( "<br>#arguments.notification#" );
	}

	public PubSubManager function createPSM()
	hint="create publish subscribe manager"
	{
		/* already tested
		if( structIsEmpty( this.getConfig() ) ){
			throw( type="CFAMQ.EMPTY_CONFIG", message="Impossible to create a PSM with an empty configuration. use setConfig(struct)" );
		}
		*/
		
		if( this.hasPubSubManager() ){
			this.killConnections().unregisterPSM();
			sendNotification( "Connections killed." );
		}
		
		
		var psm = new PubSubManager()
		registerPSM( local.psm );

		psm.initiate( getConfig() );
		

		
		
		return getPubSubManager(); 
	}
	
	public any function send( 
		required string publisherName, 
		required string msg, 
		boolean deliveryMode, 
		numeric priority, 
		numeric timeToLive 
	){
		getPubSubManager().send( argumentCollection = arguments  );
	}
	
	
	
}
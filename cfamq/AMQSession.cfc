component accessors="true"  
{
	
	property name="amqSession" type="any" hint="The JMS session";
	property name="amqSessionID";
	
	public AMQSession function init(){
		return this;
	}

	public void function close(){
		variables.amqSession.close();
	}
	
	public void function run(){
		variables.amqSession.run();
	}
	
	public any function createTopic( required string name ){
		return variables.amqSession.createTopic( arguments.name );
	}
	
	public any function createQueue( required string name )
	hint="Returns a javax.jms.Queue"
	{
		return variables.amqSession.createQueue( arguments.name );
	}
	
	
    private Publisher function createAMQConsumerPublisher( required struct clientConf ){
    	
    	writeDump(arguments.clientConf.destinationType);
    	
		switch( arguments.clientConf.destinationType ){
			case 'topic':
				var jPublisher = variables.amqSession.createPublisher(
					createTopic( arguments.clientConf.destinationName )
				);

				return new TopicPublisher()
					.setConnectionId( variables.amqSession.getConnection().getClientID() )
					.setPublisher( local.jPublisher )
					.setName( arguments.clientConf.name );

			break;
			case 'queue':
				var jPublisher = variables.amqSession.createSender(
					createQueue( arguments.clientConf.destinationName )
				);

				return new QueuePublisher()
					.setConnectionId( variables.amqSession.getConnection().getClientID() )
					.setPublisher( local.jPublisher )
					.setName( arguments.clientConf.name );
			break;
			
			default:
				throw( type="CFAMQ.WRONG_DESTINATIONTYPE_FOR_CLIENT", message="Destinationtype must be topic or queue." );
			break;
		}
    }


	public any function createTextMessage( string message ){	
		var msg = variables.amqSession.createTextMessage();
		if( structKeyExists( arguments, 'message' ) ){
			local.msg.setText( arguments.message );
		}
	}

	public struct function validateListenerConfiguration( required any configuration  ){
		
		
		if( ! isStruct( arguments.configuration ) || structIsEmpty(arguments.configuration) ){
			return { 'valid': false, message: "Listener configuration must be a non empty struct." };
		}
		
		if( ! structKeyExists( arguments.configuration, 'fullName' ) || ! isSimpleValue( arguments.configuration.fullName ) ){
			return { 'valid': false, message: "Listener configuration struct must have a fullname key as simple value." };
		}
		
		if( structKeyExists( arguments.configuration, 'initArgs' ) && ! isStruct( arguments.configuration.initArgs ) ){
			return { 'valid': false, message: "Listener configuration initArgs must be a non empty struct." };
		}
		
		return { valid: true, message: "Everything's fine." };
	}

	private function createListenerProxy( required any listenerConf ){

		var validation = validateListenerConfiguration(arguments.listenerconf);
		
		if( ! local.validation.valid ){
			throw( type="CFAMQ.INVALID_LISTENER_CONF", message="#local.validation.message#" );
		}

		var cfListener = 0;

		//If the CFC has already created;
		if( isObject( arguments.listenerConf ) ){
			local.cfListener = arguments.listenerConf;
		}
		
		
		if( isSimpleValue( local.cfListener ) ){ //still equals 0
			
			if( isStruct( arguments.listenerConf ) && structKeyExists( arguments.listenerConf, 'fullName' ) ){
				try{
					local.cfListener = createObject("component",  arguments.listenerConf.fullName);
				}catch( any e ){
					throw( type="CFAMQ.INVALID_FULLNAME_LISTENER", message="Cannot create component for listener #arguments.listenerConf.fullName#" );
				}
				if( structKeyExists( arguments.listenerConf, 'initArgs' ) ){
					try{
						local.cfListener.init( argumentCollection = arguments.listenerConf.initArgs );
					}catch( any e ){
						throw( type="CFAMQ.INVALID_INITARGS_LISTENER",  message="Cannot init component for listener with provided initArgs" );
					}
				}
			}
		}

		if( isSimpleValue( local.cfListener ) ){
			throw( message="Could not create the listener. Check your configuration." );
		}

		return createDynamicProxy( local.cfListener, ['javax.jms.MessageListener'] )

	}
	
	private Consumer function createAMQConsumerClient(  required struct clientConf  ){
		
		switch( arguments.clientConf.destinationType ){
			case 'topic':
				var selector = structKeyExists( arguments.clientConf, 'messageSelector' ) ? arguments.clientConf.messageSelector : '';
				var noLocal = structKeyExists( arguments.clientConf, 'noLocal' ) ? arguments.clientConf.noLocal : true;
				
				var subscriber =  createTopicSubscriber(
					arguments.clientConf.destinationName,
					local.selector,
					local.noLocal
				);

				subscriber.setMessageListener( createListenerProxy( arguments.clientConf.listener ) );
					
						
				return new TopicConsumer()
					.setConsumer( local.subscriber )
					.setConnectionId( variables.amqSession.getConnection().getClientID())
					.setName( arguments.clientConf.name );
				
			break;
			case 'queue':

				var selector = structKeyExists( arguments.clientConf, 'messageSelector' ) ? arguments.clientConf.messageSelector : '';
				var subscriber =  createQueueSubscriber( arguments.clientConf.destinationName, local.selector );
				subscriber.setMessageListener( createListenerProxy( arguments.clientConf.listener ) );

				return new QueueConsumer()
					.setConnectionId( variables.amqSession.getConnection().getClientID() )
					.setName( arguments.clientConf.name )
					.setConsumer( local.subscriber );

			break;
		}
	}
	
	public any function createAMQClient( required struct clientConf ){
		
		writeOutput( "<br>" & arguments.clientConf.type );
		
		switch( arguments.clientConf.type ){
			case 'consumer':
				
				return createAMQConsumerClient( arguments.clientConf );
			break;
			case 'publisher':
			     return createAMQConsumerPublisher( arguments.clientConf );
			break;
			default:
				throw(type="CFAMQ.WRONG_TYPE_FOR_CLIENT", message="Client type must be publisher or consumer");
			break;
		}
	}
	
	
	public any function createProducer( 
		required any destination, 
		string type hint="if used must be either topic or queue" 
	){
		if( ! structKeyExists( arguments, 'type' ) ){
			//must be a topic object or queue object
			return variables.amqSession.createProducer( arguments.destination );
		}
		
		if( ! isSimpleValue( arguments.destination ) ){
			throw( "Destination must be a string if type argument is used" );
		}
		
		switch( arguments.type ){
			case 'topic':
				return variables.amqSession.createProducer( createTopic( arguments.destination ) );	
			break;
			case 'queue':
				return variables.amqSession.createProducer( createQueue( arguments.destination ) );	
			break;
			default:
				throw( "Type argument must be either topic or queue" );
			break;
		}
		
	}
	
	
	public any function createDurableSubscriber(){
		
	}
	
	public any function createPublisher( required any topic ){
		if( isSimpleValue( arguments.topic ) ){
			//we build the topic before creating the publisher
			return variables.amqSession.createPublisher( this.createTopic( arguments.topic ) );
		}
		//must be a javax.jms.Topic instance
		return variables.amqSession.createPublisher( arguments.topic );
	}
	
	public any function createConsumer(
		required any destination hint="Can be a Topic or a queue object, or the name if destinationtype is provided" ,
		string destinationType = '',
		required any messageListener hint="can be a string (cfc fullname) or an instance",
		string messageSelector,
		boolean noLocal
	){
		
		var objDestination = arguments.destination;
		if( isSimpleValue( local.objDestination ) ){
			switch( arguments.destinationType  ){
				case 'topic':
					local.objDestination = createTopic( arguments.destination );
				break;
				case 'queue':
					local.objDestination = createQueue( arguments.destination );
				break;
				default:
					throw( "DestinationType must be topic or queue if destination argument is a string." );
				break;
			}
		}
		
		var objMessageListener = arguments.messageListener;
		if( isSimpleValue( local.objMessageListener ) ){
			try{
				local.objMessageListener = createObject("component", local.objMessageListener );
			}catch( any e){
				throw( "Could not create object messageListener" );
			}
			try{
				local.objMessageListener.init();
			}catch( any e){}
		}
		var check = 0;
		for( var k in ['messageSelector', 'noLocal'] ){
			if( structKeyExists( arguments, local.k ) ){
				++ check;
			}
		}
		switch( local.check ){
			case 0:
				return variables.amqSession.createConsumer( local.objDestination, local.objMessageListener );
			break;
			case 1:
				var scdArg = ( structKeyExists( arguments, 'messageSelector' ) ) ?  
					arguments.messageSelector : 
					javacast( 'boolean', arguments.noLocal )
				;
				 
				return variables.amqSession.createConsumer( 
					local.objDestination,
					local.scdArg,
					local.objMessageListener 
				);
			break;
			case 2:
				return variables.amqSession.createConsumer( 
					local.objDestination,
					arguments.messageSelector,
					javacast( 'boolean', arguments.noLocal ),
					local.objMessageListener 
				);
			break;
		}
		
	}
	

	public any function createQueueSubscriber( required any queue, string messageSelector ){
		var objqueue = ( isSimpleValue( arguments.queue ) ) ? createQueue( arguments.queue ) : arguments.queue;
		if( structKeyExists( arguments, "messageSelector" ) ){
			return variables.amqSession.createReceiver( local.objQueue, arguments.messageSelector );
		}
		return variables.amqSession.createReceiver( local.objQueue );
	}
	
	public any function createTopicSubscriber( 
		required any topic,
		string messageSelector,
		boolean noLocal
	){
		
		var objTopic = ( isSimpleValue( arguments.topic ) ) ? this.createTopic( arguments.topic ) : arguments.topic;
		
		if( structKeyExists( arguments, 'messageSelector' ) && structKeyExists( arguments, 'noLocal' ) ){
			return variables.amqSession.createSubscriber( local.objTopic, arguments.messageSelector, javacast('boolean', arguments.noLocal) );
		}
		
		return variables.amqSession.createSubscriber( local.objTopic );
		
	}
	

	public any function createTextMessage( string message ){
		var msg = ( structKeyExists( arguments, 'message' ) ) ? arguments.message : '';
		return variables.amqSession.createTextMessage( local.msg );
	}
	
}
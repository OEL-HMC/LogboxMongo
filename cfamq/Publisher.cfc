component accessors="true" extends="AMQClient"
{
	property name="publisher" hint="contains the ActiveMQTopicPublisher";
	
	
	public Publisher function init(){
		super.init();
		
		
		
		
		return this;
	}

	public Publisher function setPublisher( required any publisher ){
		variables.publisher = arguments.publisher;
		return this;
	}

	public string function getClientType(){
		return "publisher";
	}


	
	public any function createTextMessage( required string msg, boolean deliveryMode, numeric priority, numeric timeToLive ){
		return createObject( "java", "org.apache.activemq.command.ActiveMQMessage" ).init();
		
		var message = this.createTextMessage();
		message.setText( arguments.msg );
		
		if( structKeyExists( arguments, 'deliveryMode'  ) ){
			this.setMessagePersistent(message,arguments.deliveryMode);
		}
		
		if( structKeyExists( arguments, 'priority'  ) ){
			this.setMessagePriority(message,arguments.priority);
		}
		
		if( structKeyExists( arguments, 'timeToLive'  ) ){
			this.setMessageExpiration(message,arguments.timeToLive);
		}
		
		return local.message;
		
	}


	public void function setMessagePriority( required any message, required numeric priority ){
		var fixedPriority = arguments.priority;
		if( arguments.priority < 0 ){
			local.fixedPriority = 0;
		}
		if( arguments.priority > 9 ){
			local.fixedPriority = 9;
		}
		arguments.message.setPriority( javacast( 'int', local.priority)  );
	}
	
	public void function setMessagePersistent( required any message, required boolean persistent ){
		arguments.message.setPersistent( javacast("boolean", arguments.persistent) );
	}
	
	public void function setMessageExpiration( required any message, required numeric ttl ){
		arguments.message.setExpiration( javacast("long", arguments.ttl) );
	}
	
	
	
	

	public any function send( 
		required string message, 
		boolean persistent, 
		numeric priority, 
		numeric ttlMillis,
		any destination
	){


		var msg = createObject( "java", "org.apache.activemq.command.Message" ).init();

		local.msg.setText( arguments.message );


		

		if( structKeyExists( arguments, 'persistent' ) ){
			//https://docs.oracle.com/javaee/7/api/constant-values.html#javax.jms
			var persistentValue = ( arguments.persistent ) ? 2 : 1;
			local.msg.setPersistent(javacast("boolean", arguments.persistent));
		}

		if( structKeyExists( arguments, 'priority' ) ){
			var fixedPriority = arguments.priority;
			if( arguments.priority < 0 ){
				local.fixedPriority = 0;
			}
			if( arguments.priority > 9 ){
				local.fixedPriority = 9;
			}

			local.msg.setPriority( javacast("byte", local.fixedPriority) );
			
		}

		if( structKeyExists( arguments, 'ttlMillis' ) ){
			local.msg.setExpiration( javacast("long", arguments.ttlMillis) );
		}

		if( structKeyExists( arguments, "destination" ) ){
			
			
			var destination = arguments.destination;
		}else{
			var destination = variables.publisher.getDestination();
		}
		
		local.msg.setDestination( local.destination );

		

		variables.publisher.send(
			
			local.message,
			local.deliveryMode,
			local.fixedPriority,
			local.timeToLive
			
			
		);


	}


		
}
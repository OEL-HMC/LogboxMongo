component 
{
	
	property name="connection";
	
	public AMQConnection function init(){
		return this;
	}
	
	public any function getConnection(){
		return variables.connection;
	} 
	
	package AMQConnection function setConnection( required any connection ){
		variables.connection = arguments.connection;
		return this;
	}
	
	public struct function getDefaultSessionConfiguration(){
		return {
			"type": "default",
			"transacted": true,
			"acknowledgeMode": 'auto'
		};
	}
	
	
	public numeric function getJAcknowledgeMode( required string mode ){
		var jSession = "javax.jms.Session";
		switch( arguments.mode ){
			case 'auto':
				return createObject('java', local.jSession).AUTO_ACKNOWLEDGE;
			break;
			case 'client':
				return createObject('java', local.jSession).CLIENT_ACKNOWLEDGE;
			break;
			case 'dups_ok':
				return createObject('java', local.jSession).DUPS_OK_ACKNOWLEDGE;
			break;
			default:
				throw( "wrong value for acknowledge mode." );
			break;
		}
	}
	
	public any function buildSession( required struct conf ){
		
		var realConf = getDefaultSessionConfiguration();
		
		if( structKeyExists( arguments.conf , 'type' ) ){
			if( ! listFind( 'DEFAULT,TOPIC,QUEUE', ucase( arguments.conf.type ) ) ){
				throw( 'type must be default, topic, or queue' );
			}
			local.realConf.type = arguments.conf.type;
		}
		
		if( structKeyExists( arguments.conf, 'transacted' ) ){
			local.realConf.transacted = javacast('boolean', arguments.conf.transacted);		
		}
		
		if( structKeyExists( arguments.conf, 'acknowledgeMode' ) ){
			local.realConf.acknowledgeMode = javacast( 'int', getJAcknowledgeMode( arguments.conf.acknowledgeMode ) ) ;
		}else{
			local.realConf.acknowledgeMode = javacast( 'int', getJAcknowledgeMode( local.realConf.acknowledgeMode ) ) ;
		}
		
		
		
		
		var sess = 0;
		
		switch( local.realConf.type ){
			case 'default':
				local.sess = variables.connection.createSession( local.realConf.transacted, local.realConf.acknowledgeMode );
			break;
			case 'topic':
				local.sess = variables.connection.createTopicSession( local.realConf.transacted, local.realConf.acknowledgeMode );
			break;
			case 'queue':
				local.sess = variables.connection.createQueueSession( local.realConf.transacted, local.realConf.acknowledgeMode );
			break;
		}
		
		if( isSimpleValue( local.sess ) ){
			throw("impossible to create a JMS session");
		}
		
		return new AMQSession().setAmqSession( local.sess );
		
	}
	
}
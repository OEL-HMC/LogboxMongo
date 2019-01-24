component {
	
	public MessageListener function init(){
		variables.properties = {};
		return this;
	}
	
	public MessageListener function setProperty( required string key, required any value ){
		variables[ arguments.key] = arguments.value ;
		return this;
	}
	public MessageListener function removeProperty( required string key ){
		structDelete( variables, arguments.key, false );
		return this;
	}
	public boolean function hasProperty( required string key ){
		structKeyExists( variables, arguments.key );
	}
	
	public void function onMessage(any message) {
		systemOutput("Received a message", true);
		
		switch( arguments.message.getClass().getName() ){
			case 'org.apache.activemq.command.ActiveMQTextMessage':
				handleTextMessage( message );
			break;
		}
	}
	
	private void function handleTextMessage( required any message ){
		
		var System = createObject('java', 'java.lang.System');
		try{
			System.out.println( arguments.message.getText() );
			System.out.println( arguments.message.getPriority() );
		}catch( any e ){
			System.out.println( 'received and failed : ' & e.message );
		}
		
	}
	
}
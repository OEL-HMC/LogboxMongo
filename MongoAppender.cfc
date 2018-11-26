component extends="logbox.system.logging.AbstractAppender"    
{
	
	public MongoAppender function init(
		required string name,
		struct properties,
		string layout,
		numeric levelMin,
		numeric levelMax
	){
		super.init( argumentCollection = arguments );
		
		if( structKeyExists( arguments, "properties" ) ){
			parseConfig(arguments.properties);	
		}
		
		
		return this;
	}	

	public void function logMessage(
		required logbox.system.logging.LogEvent logEvent
	){
		/*
		timestamp
		category
		message
		severity
		extraInfo
		*/
	}
	
	private void function parseConfig( required struct config  ){
		if( ! propertyExists( "connection" ) ){
			throw( type="mongolobox.config.missing_connnection_info" );
		}
		
		if( ! propertyExists( "target" ) ){
			throw( type="mongolobox.config.missing_connnection_info" );
		}
		
	}
	
	
	public void function onRegistration(){
	}
	
	public void function onUnRegistration(){
		
	}
	

}
component output="false" extends="logbox.system.logging.AbstractAppender"    
{
	
	property name="mongoClient" getter="true" setter="false"  ;
	property name="mongoCollection" getter="true" setter="false";
	
	public MongoAppender function init(
		required string name,
		struct properties,
		string layout,
		numeric levelMin,
		numeric levelMax
	){
		if( structKeyExists( arguments, 'properties' ) ){
			if( structKeyExists( arguments.properties, 'target' ) ){
				var defConfiguration = getDefaultConfiguration().target;
				for( var k in defConfiguration ){
					if( ! structKeyExists(arguments.properties.target, local.k) ){
						structInsert(arguments.properties.target, local.k , local.defConfiguration[ local.k ] );
					}
				}
				structAppend( arguments.properties , getDefaultConfiguration(), false );
			}else{
				arguments.properties.target = getDefaultConfiguration();
			}
		}else{
			arguments.properties = getDefaultConfiguration();
		}
		
		super.init( argumentCollection = arguments );	
		
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
		var doc = createObject("java", "org.bson.Document").init();
		
		doc.put('timestamp', arguments.logEvent.getTimeStamp() );
		doc.put('category', arguments.logEvent.getCategory() );
		doc.put('message', arguments.logEvent.getMessage() );
		doc.put('severity', javacast("int",arguments.logEvent.getSeverity()) );
		doc.put('extraInfo', arguments.logEvent.getExtraInfo() );
		
		
		try{
			getMongoConnection()
			.getDatabase( getProperty('target').database)
			.getCollection( getProperty('target').collection )
			.insertOne( local.doc );
		}catch(any e){}
		
	}
	
	private struct function getDefaultConfiguration(){
		return {
			"target": {
				"host": "127.0.0.1", 
				"port": javacast('int',27017), 
				"async": false,
				"database": 'logboxmongo', 
				"collection": 'logs',
				"scope": 'application',
				"scopeKey": 'logboxmongo_connection'
			}
		};
	}
		
	public function getTargetConfiguration(){
		return getProperty( "target" );
	}
	
	private string function getScopeName()
	hint="Gets the name of scope to use, probably application or server"
	{
		return getProperty( "target" ).scope;
	}
	
	private struct function getScopeObject()
	hint="Gets the scope object"
	{
		return evaluate( getScopeName() );
	}
	
	private string function getScopeKey()
	hint="Gets the key in which mongodb connection is stored"
	{
		return getProperty( "target" ).scopeKey;
	}
	
	private any function getMongoConnection()
	hint="Gets the java mongodb connection object"
	{
		return getScopeObject()[ getScopeKey() ];
	}
	
	private boolean function hasMongoConnection()
	hint="Tells if the mongodb connection has already been created"
	{
		return structKeyExists( getScopeObject(), getScopeKey() );
	}
	
	private boolean function createMongoConnection()
	hint="Internal method to create and store mongodb connection"
	{
		if( hasMongoConnection() ){
			return true;
		}
		
		try{
			getScopeObject()[ getScopeKey() ] = createObject( "java", "com.mongodb.MongoClient" ).init(
				getProperty('target').host,
				getProperty('target').port
			);
			
		}catch( any e ){
			return false;
		}
		return true;
	}
	
	private boolean function closeMongoConnection()
	hint="internal method called from logbox onUnregistration"
	{
		var success = true;
		try{
			getMongoConnection().close()
		}catch( any e ){
			local.success=false;
		}
		return local.success;
	}
	
	public void function onRegistration()
	hint="Called from logbox"
	{
		createMongoConnection();
	}
	
	public void function onUnRegistration()
	hint="Called from logbox"
	{
		closeMongoConnection();
	}
	
}
component
{
	public ConnectionFactoryBuilder function init(){
		return this;
	}
	
	public struct function getProperConfig( required struct originalConf ){
		var properConf = duplicate(arguments.originalConf);
		structDelete(local.properConf,'name', false);
		return local.properConf;
	} 
	
	 

	

	
	public AMQConnectionFactory function buildConnectionFactory( required struct conf ){
		
		
		var factory = 0;
		var jPath = "org.apache.activemq.ActiveMQConnectionFactory";
		
		//Get rid of the 'name' entry
		//need to duplicate as this conf is reused by other components
		var realConf = getProperConfig(arguments.conf);
		
	
		if( structIsEmpty(local.realConf) ){
			return new AMQConnectionFactory().setFactory( createObject( "java", local.jPath ).init() );
		}
	
		switch( listLen( structKeyList( local.realConf ) ) ){
			case 1:
				if( structKeyExists( local.realConf, 'brokerURL' ) ){
					if( isNull( local.realConf.brokerURL ) || trim( local.realConf.brokerURL ) == ''  ){
						local.factory = createObject( "java", local.jPath ).init();
					}else{
						local.factory = createObject( "java", local.jPath ).init( arguments.conf[ 'brokerURL' ] );	
					}
				}
			break;
			case 3:
				if( 
					structKeyExists( local.realConf, 'brokerURL' )
					&& structKeyExists( local.realConf, 'userName' )
					&& structKeyExists( local.realConf, 'password' ) 
				){
					local.factory = createObject( "java", local.jPath ).init(
						local.realConf[ 'userName' ],
						local.realConf[ 'password' ],
						local.realConf[ 'brokerURL' ]
					);  
				}
			break;	
		}
		
		if( isSimpleValue( local.factory ) ){
			throw( message = "impossible to create the connection factory" );
		}
		
		return new AMQConnectionFactory().setFactory( local.factory );
		
	}
	
}
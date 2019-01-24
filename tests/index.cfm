<cfscript>
	//writeDump( application );
	
	if( structKeyExists( application, 'AMQPubsubManager' ) ){
		psm = application.AMQPubsubManager;
		psm.send( 'ok1', 'hello World' );
	}
	
	
</cfscript>
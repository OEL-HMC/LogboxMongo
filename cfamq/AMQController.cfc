component 
{
	
	public AMQController function init(){
		return this;
	}
	
	public struct function toStruct( required any psmName ){
		
		if( ! structKeyExists( application, arguments.psmName ) ){
			return { 'error': true, 'message': '#arguments.psmName# does not exist' };
		}
		
		var psm = application[ arguments.psmName ];
		var infos = { "publishers": [], "consumers": [] };
		
		for( var pName in psm.getPublishers() ){
			var info = psm.getPublisher( local.pName ).toStruct();
			//info.name = local.pName;
			arrayAppend( local.infos.publishers, local.info );
		}
		
		for( var pName in psm.getConsumers() ){
			var info = psm.getConsumer( local.pName ).toStruct();
			//info.name = local.pName;
			arrayAppend( local.infos.consumers, local.info );
		}
		
		
		
		return local.infos;
	}
	
}
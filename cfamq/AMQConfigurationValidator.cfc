component 
{
	
	public struct function validateConfiguration( required struct config ){

		var result = { "valid": true, "message":"Everything 's fine!" };

		for( var keyName in ['connections', 'clients'] ){

			//if 'connections' does not exist
			if( ! structKeyExists( arguments.config, local.keyName ) ){
				return { "valid": false, "message":"Missing #keyName#." };
			}
			//if connections is not an array or this array is empty
			if( ! isArray( arguments.config[local.keyName] ) || arrayIsEmpty( arguments.config[local.keyName] ) ){
				return { "valid": false, "message":"#local.keyName# must be a non empty array" };
			}


			for( var subObject in arguments.config[ local.keyName ] ){
				if( ! isStruct( local.subObject ) ){
					return { "valid": false, "message":"Each item in #local.keyName# must be a structure" };
				}

				var requiredKeys = 
					( local.keyName == 'connections' ) ? 
						['name'] : 
						['name', 'connectionName', 'destinationType']
				;

				for( var $1 in local.requiredKeys ){
					if( 
						! (
							structKeyExists( local.subObject, $1 )
							&& isSimpleValue( local.subObject[ local.$1 ] )
							&& trim(local.subObject[local.$1] ) != ''
						)
					){
						return { 
							"valid": false, 
							"message":"Each item in #local.keyName# must have a '#local.$1#' key holding a non empty string" 
						};
					}
				}

				if( local.keyName == 'clients' && listFindNoCase( 'queue,topic', local.subObject.destinationType == 0 ) ){
					return { 
							"valid": false, 
							"message":"wrong destinationType" 
						};
				}
				
			}

			var names = "";
			for( var subObject in arguments.config[ local.keyName ]  ){
				var curName = lcase( local.subObject['name'] );
				if( listFind( local.names, curName ) ){
					return { 
						"valid": false, 
						"message":"#local.keyName# names must be unique." 
					};
				}
				local.names = listAppend( local.names, local.curName );
			}

		}

		var realConnectionNames = '';
		for( var conn in arguments.config.connections ){
			local.realConnectionNames = listAppend(local.realConnectionNames, lcase( local.conn.name ) );
		}
		
		for( var cli in arguments.config.clients ){
			if(listFind( local.realConnectionNames, lcase(local.cli.connectionName) ) == 0){
				return { 
					"valid": false, 
					"message":"connectionName #local.cli.connectionName# does not exist in configured connections." 
				};
			}
		}

		return local.result;

	}
}
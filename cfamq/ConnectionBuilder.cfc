component 
{
	
	public ConnectionBuilder function init(){
		return this;
	}


	public any function buildConnection( required struct configuration ){
		
	}

	public struct function getDefaultConfiguration(){
		return {
			'transacted': true,
			'acknowledgeMode': 'auto'
		};
	}
	
	
	
}
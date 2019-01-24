component extends="Publisher"
{
	
	public QueuePublisher function init(){
		super.init();
		return this;
	}
	
	public string function getDestinationType(){
		return "queue";
	}
	
	public void function send( required string msg, boolean deliveryMode, numeric priority, numeric timeToLive ){
		
		var message = this.createTextMessage( argumentCollection = arguments );
		
		variables.publisher.send( variables.publisher.getQueue(), local.message );
		
	}

}
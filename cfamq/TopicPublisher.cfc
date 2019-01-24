component extends="Publisher"
{
	public TopicPublisher function init(){
		super.init();
		return this;
	}
	
	public string function getDestinationType(){
		return "topic";
	}

	public void function send( required string msg, boolean deliveryMode, numeric priority, numeric timeToLive ){
		
		var message = this.createTextMessage( argumentCollection = arguments );
		
		variables.publisher.publish( local.message );
		
	}

}
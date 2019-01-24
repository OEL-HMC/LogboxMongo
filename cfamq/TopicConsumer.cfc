component extends="Consumer" 
{
	
	public TopicConsumer function init(){
		super.init();
		return this;
	}

	public string function getDestinationType(){
		return "topic";
	}
	
}
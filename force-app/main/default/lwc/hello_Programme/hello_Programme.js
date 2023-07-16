import { LightningElement } from 'lwc';
export default class Hello_Programme extends LightningElement {
		input1;
		handletrue=false; 
		nameofperson;
		nameofvalue;
		handlechange(event)
		{
				if(event.target.name=="inputname"){
						this.input1=event.target.value;
						console.log('this.nameofvalue '+this.input1);
				}
		}
		handleclick(){
				this.nameofperson=this.input1;
										console.log('this.nameofperson '+this.nameofperson);

				this.handletrue=true; 
														console.log('this.handletrue '+this.handletrue);


		}
}
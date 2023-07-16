import { LightningElement } from 'lwc';
export default class Hello_Programme extends LightningElement {
		input1;
		input2;
		handletrue=false; 
		sum;
		sumofvalue;
		handlechange(event)
		{
				if(event.target.name=="inputname1"){
						this.input1=event.target.value;
						console.log('this.sumofvalue '+this.input1);
				}
				if(event.target.name=="inputname2"){
						this.input2=event.target.value;
						console.log('this.sumofvalue '+this.input2);
				}
		}
		handleclick(){
				sum=input1 + input2;
										console.log('this.sum '+this.sum);

				this.handletrue=true; 
														console.log('this.handletrue '+this.handletrue);


		}
}
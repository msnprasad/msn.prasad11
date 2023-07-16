import { LightningElement, track } from 'lwc';

export default class CalculatorCmp extends LightningElement {

@track number1;
@track number2;
sum;
handleInputChange1 (event) {
		this.number1 =event.target.value;
		console.log('n1 '+this.number1 );
}
handleInputChange2 (event) {
   this.number2 = event.target.value;
}
doSum(){
    this.sum = parseInt(this.number1) + parseInt(this.number2);
    console.log(this.number1);
    console.log(this.number2);
    alert(this.sum);
}
doSubsc(){
    const subsc = parseInt(this.number1) - parseInt(this.number2);
    console.log("sub" + this.number1);
    console.log("sub" + this.number2);
    alert(subsc);
}

doDiv(){
    const divOut = parseInt(this.number1) / parseInt(this.number2);
    alert(divOut);
}

doMulti(){
    const multiPli = parseInt(this.number1) * parseInt(this.number2);
    alert(multiPli);
}
}
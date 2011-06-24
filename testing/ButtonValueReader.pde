int val,valb,valc;

void setup() {
  pinMode(A5, INPUT);
  pinMode(A4, INPUT);
  pinMode(A3, INPUT);
  Serial.begin(9600);
}

void loop() {
  val = analogRead(A5);    // read the input pin
  Serial.println(val);            // debug value
  delay(500);
  valc = analogRead(A4);    // read the input pin
  Serial.println(valb);            // debug value
  delay(500);
  valb = analogRead(A3);    // read the input pin
  Serial.println(valc);            // debug value
  delay(500); 
}
const int wheelY = A0;
const int wheelX = A1;
const int resetButton = 2;

int wheelValY, wheelValX;
unsigned long lastTime;
boolean buttonState, lastState;

const int debounceTime = 500;
void setup()
{
  Serial.begin(9600);
  pinMode(wheelY, INPUT);
  pinMode(wheelX, INPUT);
  pinMode(resetButton, INPUT);
  pinMode(13, OUTPUT);
}

void loop()
{
  buttonState = digitalRead(resetButton);
  wheelValY = analogRead(wheelY);
  wheelValX = analogRead(wheelX);
  wheelValX = map(wheelValX, 0, 1023, 0, 127);
  wheelValY = map(wheelValY, 0, 1023, 0, 127);
  
  if (buttonState != lastState) {
    if (buttonState == HIGH && (millis() - lastTime) > debounceTime) {
      Serial.write(255);
    }
    lastState = buttonState;
    lastTime = millis();
  }
  
  Serial.write(wheelValX);
  Serial.write(wheelValY);
}
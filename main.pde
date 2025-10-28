VendingMachine vendingMachine;

void setup() {
  size(800, 525, P3D);
  
  // posisikan window di tengah layar
  surface.setLocation((displayWidth - width) / 2, (displayHeight - height) / 2);
  
  // inisialisasi komponen utama
  vendingMachine = new VendingMachine();
  
  // setup font dan rendering
  textAlign(CENTER, CENTER);
  smooth(8);
}

void draw() {
  // render vending machine 2d di depan (menghadap user)
  vendingMachine.display();
  vendingMachine.update();
}

// handle mouse click untuk numpad interaction dan pickup door
void mousePressed() {
  vendingMachine.handleNumpadClick();
  vendingMachine.handlePickupDoorClick();
}

// optional: keyboard input untuk testing cepat
void keyPressed() {
  if (key >= '0' && key <= '9') {
    if (vendingMachine.inputCode.length() < 2) {
      vendingMachine.inputCode += key;
    }
  } else if (key == '\n' || key == '\r') {
    vendingMachine.processPurchase();
  } else if (key == 'c' || key == 'C') {
    vendingMachine.inputCode = "";
  }
}

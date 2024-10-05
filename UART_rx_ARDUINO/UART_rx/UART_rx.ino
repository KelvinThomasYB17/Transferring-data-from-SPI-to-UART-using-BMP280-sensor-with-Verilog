// Definición de los pines UART (depende de la placa)
#define RX_PIN 0  // Pin de recepción UART

void setup() {
  Serial.begin(9600);  // Configura la velocidad de UART
  pinMode(RX_PIN, INPUT);  // Configura el pin RX como entrada

  Serial.println("Iniciando recepción de datos...");
}

void loop() {
  // Verificar si hay datos disponibles
  if (Serial.available() >= 1) {
    // Simular lectura del bit de start
    bool startBit = readStartBit();
    
    if (startBit == false) {  // Verifica si el bit de start es 0
      // Lee los 8 bits de datos
     // byte data = Serial.read();
    byte data_part1 = Serial.read();  // 8 bits más bajos
    // Lee los siguientes 8 bits
    byte data_part2 = Serial.read();  // 8 bits intermedios
    // Lee los últimos 4 bits
    byte data_part3 = Serial.read() & 0x0F;  // Solo los 4 bits más bajos

    // Combina las tres partes en un solo valor de 20 bits
    uint32_t data = (data_part3 << 16) | (data_part2 << 8) | data_part1;  
    
      // Calcula el bit de paridad
      bool parityBit = calculateEvenParity(data);
      
      // Lee el bit de stop
      bool stopBit = readStopBit();

      // Verifica que los bits de paridad y stop sean correctos
      if (checkParity(data, parityBit) && stopBit) {
        // Muestra los datos en el Monitor Serial
        Serial.print("Datos recibidos: ");
        Serial.println(data, BIN);  // Imprime los datos en binario

        // Muestra los datos en el Plotter Serial
        Serial.print("Data: ");
        Serial.println(data);  // Imprime los datos en decimal para el plotter
      } else {
        Serial.println("Error en la transmisión (Paridad o Stop bit incorrecto)");
      }

    } else {
      Serial.println("Error: Bit de start incorrecto (esperado 0)");
    }

    // Añade un pequeño delay para no saturar el monitor serial
    delay(100);
  }
}

// Función para leer el bit de start (simulado)
bool readStartBit() {
  // Simular lectura de bit de start (0)
  return false;  // Suponemos que el bit de start siempre es 0, como en UART estándar
}

// Función para calcular la paridad par de 8 bits
bool calculateEvenParity(byte data) {
  int count = 0;
  for (int i = 0; i < 20; i++) {
    if (bitRead(data, i)) {
      count++;
    }
  }
  // Retorna true si el número de bits en 1 es par, false si es impar
  return (count % 2 == 0);
}

// Función para verificar el bit de paridad recibido
bool checkParity(byte data, bool receivedParityBit) {
  bool expectedParity = calculateEvenParity(data);
  return (expectedParity == receivedParityBit);
}

// Función para leer el bit de stop
bool readStopBit() {
  // Suponiendo que el bit de stop es siempre 1
  return true;
}
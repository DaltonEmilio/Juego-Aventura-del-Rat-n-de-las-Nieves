 
 /* Autor: Dalton Emilio Enríquez Romero
 Juego - Programación Creativa

 
 
 ¡AVENTURA DEL RATÓN DE LAS NIEVES!
 Descripción: Aventura del Ratón de las Nieves es un juego de plataformas donde el jugador controla a un ratón
 que debe evitar cubos de hielo y recoger píldoras en un paisaje natural invernal con pinos y montañas nevadas 
 mientras avanza a través de niveles progresivamentemás difíciles. El juego incorpora conceptos de física 
 como gravedad y colisiones. Los elementos visuales y de diseño de niveles se han inspirado en clásicos 
 de los videojuegos de plataformas, como Super Mario Bros, adaptando sus principios para crear una experiencia única.
 
 Referencias:
 - Introducción a los Videojuegos del curso de Programación Creativa.
 - Nature of Code de Daniel Shiffman para los fundamentos de física.
 - Video "Super Mario Bros: Level 1-1 - How Super Mario Mastered Level Design" para el diseño de niveles.
 - Cuaderno de Programación Creativa de Joan Soler-Adillon, Anna Carreras Sales, Alfredo Calosci.
 - Learning Processing de Daniel Shiffman para la programación en Processing. */

// Importar la librería Minim
import ddf.minim.*;

Minim minim;
AudioPlayer jumpSound;
AudioPlayer winSound;
AudioPlayer loseSound;


// Defino las dimensiones de la pantalla del juego
int anchoPantalla = 1200;
int altoPantalla = 800;

// Declaro las variables para los objetos principales del juego
Jugador jugador;  // Objeto que representa al jugador
ArrayList<Plataforma> plataformas;  // Lista para manejar las plataformas
ArrayList<Enemigo> enemigos;  // Lista para manejar los enemigos
ArrayList<Enemigo> enemigosDisponibles;  // Lista para manejar enemigos disponibles
Pildora pildora;  // Objeto para las píldoras que el jugador puede recoger
ArrayList<Confeti> confetis;  // Lista para manejar los efectos visuales de confeti

// Variable para llevar la puntuación del jugador
int puntuacion = 0;

// Variables de estado del juego
boolean juegoTerminado = false;  // Indica si el juego ha terminado
boolean mostrarConfeti = false;  // Indica si se debe mostrar confeti
int tiempoInicioConfeti = 0;  // Tiempo en el que comienza a mostrarse el confeti
float velocidadEnemigos = 1;  // Controla la velocidad de los enemigos
int nivel = 1;  // Número del nivel actual
boolean nivelCompletado = false;  // Indica si se ha completado el nivel actual
boolean pildoraTocada = false;  // Indica si se ha recogido una píldora en el nivel 6

// Variables para manejar el botón "SALIR"
float botonX, botonY, botonAncho, botonAlto;

// Declaro la clase Fondo para manejar el fondo del juego
Fondo fondo;

// Fuente utilizada para los textos en el juego
PFont fuenteNegrita;

// Variables para manejar el texto "-1" cuando se pierde una vida o se sufre una penalización
boolean mostrarMenosUno = false;
int tiempoInicioMenosUno = 0;
float opacidadMenosUno = 255;
float xMenosUno, yMenosUno;

void settings() {
  // Defino el tamaño de la ventana del juego
  size(anchoPantalla, altoPantalla);
}

void setup() {
    minim = new Minim(this);
    jumpSound = minim.loadFile("up.mp3");
    winSound = minim.loadFile("win.mp3");
    loseSound = minim.loadFile("lose.mp3");
  // Creo una fuente en negrita de tamaño 12 para los textos
  fuenteNegrita = createFont("SansSerif-Bold", 12);
  
  // Instancio la clase Fondo para manejar el fondo del juego
  fondo = new Fondo();
  
  // Inicializo el juego configurando las variables y objetos necesarios
  inicializarJuego();
}

void draw() {
  // Muestro el fondo antes de dibujar otros elementos del juego
  fondo.mostrar();
  
  if (!juegoTerminado) {
    // Actualizo y muestro al jugador
    jugador.actualizar();
    jugador.mostrar();
    
    // Itero sobre las plataformas para mostrarlas y verificar colisiones con el jugador
    for (Plataforma p : plataformas) {
      p.mostrar();
      jugador.verificarColision(p);
    }
    
    // Itero sobre los enemigos para actualizarlos, mostrarlos y verificar colisiones con el jugador
    for (Enemigo e : enemigos) {
      e.actualizar();
      e.mostrar();
      if (jugador.verificarColision(e)) {
        // Si hay colisión, decremento la puntuación y reseteo la posición del jugador
        if (puntuacion > 0) {
          puntuacion--;
          jugador.resetPosition();
          mostrarMenosUno = true;
          tiempoInicioMenosUno = millis();
          opacidadMenosUno = 255;
          xMenosUno = jugador.x;
          yMenosUno = jugador.y - 10;
        } else {
          // Si la puntuación es 0, el juego termina
          juegoTerminado = true;
        }
      }
    }
    
    // Si hay una píldora en el juego, la muestro y verifico colisiones con el jugador
    if (pildora != null) {
      pildora.mostrar();
      if (jugador.verificarColision(pildora)) {
        // Si el jugador recoge la píldora, aumento la puntuación y genero confeti
        puntuacion++;
        mostrarConfeti = true;
        tiempoInicioConfeti = millis();
        generarConfeti(pildora.x, pildora.y);
        pildora = null;
        nivelCompletado = true;
        if (nivel == 6) {
          pildoraTocada = true;  // Actualizo la variable cuando se toca la píldora en el nivel 6
        }
        winSound.rewind();  // Reiniciar el sonido para que siempre se escuche
        winSound.play();     // Reproducir sonido al tocar la píldora
      }
    }
    
    // Muestro el confeti si se ha recogido una píldora y lo elimino después de 4 segundos
    if (mostrarConfeti) {
      confeti();
      if (millis() - tiempoInicioConfeti > 4000) {
        mostrarConfeti = false;
        confetis.clear();
      }
    }
    
    // Muestro la puntuación en la pantalla
    fill(255);
    textSize(24);
    text("Puntuación: " + puntuacion, 10, 30);
    
    // Dibujo las instrucciones del juego
    instruccionesJuego(90, 30);
    
    // Muestro el botón "SALIR"
    mostrarBotonSalir();
    
    // Manejo de niveles completados
    if (nivelCompletado) {
      if (nivel < 6) {
        mostrarBotonNivel();
        if (jugador.verificarColisionBoton(botonX, botonY, botonAncho, botonAlto)) {
          avanzarNivel();
        }
      } else {
        // Si se ha completado el último nivel, muestro el mensaje de "Juego Completado"
        fill(255, 255, 255, 170);
        rect(anchoPantalla / 2 - 170, altoPantalla / 2 - 50, 340, 130, 20);
        fill(255, 0, 0);
        textSize(36);
        textAlign(CENTER, CENTER);
        text("Juego Completado", anchoPantalla / 2, altoPantalla / 2 - 15);
        fill(0);
        textSize(24);
        text("PLAY", anchoPantalla / 2, altoPantalla / 2 + 35);
        textAlign(LEFT, BASELINE);
      }
    }
    
    // Muestro el texto "-1" si el jugador pierde una vida
    if (mostrarMenosUno) {
      mostrarTextoMenosUno();
    }
  } else {
    // Si el juego ha terminado, muestro el mensaje "Juego Terminado"
    fill(255, 0, 0);
    textSize(36);
    text("Juego Terminado", anchoPantalla / 2 - 100, altoPantalla / 2);
    fill(255);
    textSize(24);
    text("TRY AGAIN", anchoPantalla / 2 - 50, altoPantalla / 2 + 50);
  }
}

void keyPressed() {
  // Manejo de eventos de teclado para controlar al jugador
  if (!pildoraTocada && (key == ' ' || key == 'w' || key == 'W' || keyCode == UP)) {
    jugador.saltar();  // El jugador salta
    jumpSound.rewind();  // Reiniciar el sonido para que siempre se escuche
    jumpSound.play();     // Reproducir sonido del salto
  }
  if (!pildoraTocada && (key == 'a' || key == 'A' || keyCode == LEFT)) {
    jugador.mover(-1);  // El jugador se mueve a la izquierda
  }
  if (!pildoraTocada && (key == 'd' || key == 'D' || keyCode == RIGHT)) {
    jugador.mover(1);  // El jugador se mueve a la derecha
  }
}

void keyReleased() {
  // Detengo el movimiento del jugador cuando se suelta la tecla
  if (key == 'a' || key == 'A' || keyCode == LEFT || key == 'd' || key == 'D' || keyCode == RIGHT) {
    jugador.mover(0);  // El jugador deja de moverse
  }
}

void mousePressed() {
  // Reinicio el juego si el jugador hace clic en "TRY AGAIN" cuando el juego ha terminado
  if (juegoTerminado) {
    float textoX = anchoPantalla / 2 - 50;
    float textoY = altoPantalla / 2 + 50;
    float textoAncho = textWidth("TRY AGAIN");
    float textoAlto = 24;
    if (mouseX > textoX && mouseX < textoX + textoAncho && mouseY > textoY - textoAlto && mouseY < textoY) {
      reiniciarJuego();
    }
  } else if (nivelCompletado) {
    // Avanzo al siguiente nivel si el jugador hace clic en el botón correspondiente
    if (nivel < 6) {
      if (mouseX > botonX && mouseX < botonX + botonAncho && mouseY > botonY && mouseY < botonY + botonAlto) {
        avanzarNivel();
      }
    } else {
      // Reinicio el juego si el jugador hace clic en "PLAY" después de completar todos los niveles
      float textoX = anchoPantalla / 2 - 50;
      float textoY = altoPantalla / 2 + 50;
      float textoAncho = textWidth("PLAY");
      float textoAlto = 24;
      if (mouseX > textoX && mouseX < textoX + textoAncho && mouseY > textoY - textoAlto && mouseY < textoY) {
        reiniciarJuego();
      }
    }
  }
  // Salgo del juego si el jugador hace clic en "SALIR"
  if (mouseX > anchoPantalla - 1000 && mouseX < anchoPantalla - 30 && mouseY > 10 && mouseY < 40) {
    exit();
  }
}

// Función para mostrar el botón de "SALIR" en la interfaz del juego
void mostrarBotonSalir() {
  // Defino las coordenadas y dimensiones del botón "SALIR"
  float botonSalirX = anchoPantalla - 1000;
  float botonSalirY = 10;
  float botonSalirAncho = 70;
  float botonSalirAlto = 30;

  // Dibujo el fondo del botón con color rojo
  fill(255, 0, 0);
  rect(botonSalirX, botonSalirY, botonSalirAncho, botonSalirAlto, 10);

  // Dibujo el texto "SALIR" en el botón
  fill(255);
  textSize(18);
  textAlign(CENTER, CENTER);
  text("SALIR", botonSalirX + botonSalirAncho / 2, botonSalirY + botonSalirAlto / 2);

  // Restaura la alineación de texto por defecto
  textAlign(LEFT, BASELINE);
}

// Función para mostrar las instrucciones del juego en pantalla
void instruccionesJuego(float x, float y) {
  // Configuro el color de relleno para los botones de instrucciones
  fill(255);
  noStroke();

  // Dibujo el botón para la tecla 'a' (mover a la izquierda)
  ellipse(x - 50, y + 100, 50, 50);
  fill(135, 206, 235);
  triangle(x - 70, y + 100, x - 45, y + 80, x - 45, y + 120); // Triángulo apuntando hacia la izquierda
  fill(255);
  textSize(18);
  text("a", x - 58, y + 105);

  // Dibujo el botón para la tecla 'w' (saltar)
  fill(255);
  ellipse(x, y + 50, 50, 50);
  fill(135, 206, 235);
  triangle(x - 18, y + 60, x, y + 30, x + 18, y + 60); // Triángulo apuntando hacia arriba
  fill(255);
  text("w", x - 7, y + 56);

  // Dibujo el botón para la tecla 'd' (mover a la derecha)
  fill(255);
  ellipse(x + 50, y + 100, 50, 50);
  fill(135, 206, 235);
  triangle(x + 45, y + 80, x + 70, y + 100, x + 45, y + 120); // Triángulo apuntando hacia la derecha
  fill(255);
  text("d", x + 48, y + 105);
}

// Función para inicializar el juego configurando las variables y objetos necesarios
void inicializarJuego() {
  jugador = new Jugador();  // Inicializo el objeto jugador
  plataformas = new ArrayList<Plataforma>();  // Inicializo la lista de plataformas
  enemigos = new ArrayList<Enemigo>();  // Inicializo la lista de enemigos
  enemigosDisponibles = new ArrayList<Enemigo>();  // Inicializo la lista de enemigos disponibles
  confetis = new ArrayList<Confeti>();  // Inicializo la lista de confetis
  juegoTerminado = false;  // Reinicio el estado del juego
  mostrarConfeti = false;  // Inicializo la visualización de confeti
  tiempoInicioConfeti = 0;  // Reinicio el contador de tiempo para el confeti
  nivelCompletado = false;  // Reinicio el estado de nivel completado

  // Creo las plataformas del juego
  plataformas.add(new Plataforma(150, 700, 200, 20));
  plataformas.add(new Plataforma(500, 600, 200, 20));
  plataformas.add(new Plataforma(850, 500, 200, 20));
  plataformas.add(new Plataforma(500, 400, 200, 20));
  plataformas.add(new Plataforma(150, 300, 200, 20));
  plataformas.add(new Plataforma(500, 200, 200, 20));
  plataformas.add(new Plataforma(850, 100, 200, 20));
  
  // Creo todos los enemigos disponibles
  enemigosDisponibles.add(new Enemigo(150, 660));
  enemigosDisponibles.add(new Enemigo(400, 560));
  enemigosDisponibles.add(new Enemigo(650, 460));
  enemigosDisponibles.add(new Enemigo(900, 360));
  enemigosDisponibles.add(new Enemigo(1150, 260));
  enemigosDisponibles.add(new Enemigo(550, 160));
  
  // Añade los enemigos que deben estar presentes para el nivel actual
  for (int i = 0; i < min(nivel, enemigosDisponibles.size()); i++) {
    enemigos.add(enemigosDisponibles.get(i));
  }
  
  // Creo la píldora en el juego
  pildora = new Pildora(860, 50, 15, 30);
}

// Clase para definir el objeto jugador
class Jugador {
  float x, y, ancho, alto;  // Coordenadas y dimensiones del jugador
  float velocidadY = 0;  // Velocidad vertical del jugador
  float velocidadX = 0;  // Velocidad horizontal del jugador
  boolean enSuelo = false;  // Estado del jugador (si está en el suelo)

  // Constructor de la clase Jugador
  Jugador() {
    x = anchoPantalla / 2;  // Posición inicial en el centro de la pantalla
    y = altoPantalla - 40;  // Posición inicial cerca del fondo de la pantalla
    ancho = 30;  // Ancho del jugador
    alto = 40;  // Alto del jugador
  }

  // Función para actualizar la posición del jugador
  void actualizar() {
    velocidadY += 0.6;  // Aplico la gravedad al jugador
    y += velocidadY;  // Actualizo la posición vertical del jugador
    x += velocidadX;  // Actualizo la posición horizontal del jugador
    x = constrain(x, 0, anchoPantalla - ancho);  // Constriñir el movimiento del jugador dentro de la pantalla
    
    // Verifico si el jugador toca el suelo
    if (y + alto > altoPantalla) {
      y = altoPantalla - alto;
      velocidadY = 0;
      enSuelo = true;
    }
    if (y + alto < altoPantalla) {
      enSuelo = false;
    }
  }

  // Función para mostrar el jugador en pantalla
  void mostrar() {
    // Dibujar el cuerpo principal del ratón
    fill(139, 69, 19);  // Color marrón
    noStroke();
    arc(x + ancho / 2, y + 40, 40, 50, PI, TWO_PI);  // Cuerpo principal (semi-círculo-ratón)

    // Dibujar las orejas
    fill(139, 69, 19);  // Color marrón
    ellipse(x + ancho / 2 - 15, y + 15, 15, 15);  // Oreja izquierda
    ellipse(x + ancho / 2 + 15, y + 15, 15, 15);  // Oreja derecha

    // Detalles internos de las orejas
    fill(255, 218, 185);  // Color más claro para el interior de las orejas
    ellipse(x + ancho / 2 - 15, y + 15, 8, 8);  // Interior oreja izquierda
    ellipse(x + ancho / 2 + 15, y + 15, 8, 8);  // Interior oreja derecha

    // Dibujar los ojos
    fill(255);  // Color blanco para los ojos
    ellipse(x + ancho / 2 - 10, y + 30, 8, 8);  // Ojo izquierdo
    ellipse(x + ancho / 2 + 10, y + 30, 8, 8);  // Ojo derecho

    // Dibujar las pupilas
    fill(0);  // Color negro para las pupilas
    ellipse(x + ancho / 2 - 10, y + 30, 4, 4);  // Pupila izquierda
    ellipse(x + ancho / 2 + 10, y + 30, 4, 4);  // Pupila derecha

    // Dibujar la boca
    fill(0);  // Color negro
    ellipse(x + ancho / 2, y + 35, 6, 6);  // Boca

    // Dibujar la cola
    stroke(139, 69, 19);  // Color marrón
    strokeWeight(2);
    noFill();
    beginShape();
    vertex(x + ancho / 2 + 20, y + 40);  // Punto inicial de la cola
    vertex(x + ancho / 2 + 30, y + 30);  // Punto medio de la cola
    vertex(x + ancho / 2 + 25, y + 20);  // Punto final de la cola
    endShape();
  }

  // Función para hacer que el jugador salte
  void saltar() {
    if (enSuelo) {
      velocidadY = -15;
      enSuelo = false;
    }
  }

  // Función para mover al jugador a la izquierda o derecha
  void mover(int dir) {
    velocidadX = dir * 5;
  }

  // Función para verificar la colisión con plataformas
  void verificarColision(Plataforma p) {
    // Verificar colisión horizontal
    if (x + ancho > p.x && x < p.x + p.ancho) {
      // Verificar colisión vertical
      if (y + alto > p.y && y < p.y + p.alto) {
        // Ajustar posición del jugador
        if (y + alto - velocidadY <= p.y) {
          y = p.y - alto;
          velocidadY = 0;
          enSuelo = true;
        } else if (y - velocidadY >= p.y + p.alto) {
          y = p.y + p.alto;
          velocidadY = 0;
        } else if (x + ancho - velocidadX <= p.x) {
          x = p.x - ancho;
        } else if (x - velocidadX >= p.x + p.ancho) {
          x = p.x + p.ancho;
        }
      }
    }
  }

  // Función para verificar la colisión con enemigos
  boolean verificarColision(Enemigo e) {
    if (x + ancho > e.x && x < e.x + e.ancho && y + alto > e.y && y < e.y + e.alto) {
              loseSound.rewind();  // Reiniciar el sonido para que siempre se escuche
        loseSound.play();     // Reproducir sonido de derrota
      return true;
    }
    return false;
  }

  // Función para verificar la colisión con píldoras
  boolean verificarColision(Pildora p) {
    if (x + ancho > p.x && x < p.x + p.ancho && y + alto > p.y && y < p.y + p.alto) {
      return true;
    }
    return false;
  }

  // Función para verificar la colisión con botones
  boolean verificarColisionBoton(float bx, float by, float bw, float bh) {
    if (x + ancho > bx && x < bx + bw && y + alto > by && y < by + bh) {
      return true;
    }
    return false;
  }

  // Función para resetear la posición del jugador
  void resetPosition() {
    x = anchoPantalla / 2;
    y = altoPantalla - 40;
    velocidadY = 0;
    velocidadX = 0;
  }
}

// Clase para definir el objeto Plataforma
class Plataforma {
  float x, y, ancho, alto;  // Coordenadas y dimensiones de la plataforma
  
  // Constructor para inicializar la plataforma con sus coordenadas y dimensiones
  Plataforma(float x, float y, float ancho, float alto) {
    this.x = x;
    this.y = y;
    this.ancho = ancho;
    this.alto = alto;
  }
  
  // Método para mostrar la plataforma en pantalla
  void mostrar() {
    // Dibujo la parte superior de la plataforma como un rectángulo azul intenso con bordes redondeados
    fill(135, 206, 250);  // Color azul más intenso
    stroke(70, 130, 180);  // Color azul más oscuro para el borde
    strokeWeight(2);  // Grosor del borde
    rect(x, y, ancho, alto * 0.3, 20);  // Bordes redondeados con radio 20

    // Dibujo la parte inferior de la plataforma en forma de iceberg
    fill(135, 206, 250, 220);  // Color azul más intenso y menos translúcido para el iceberg
    noStroke();
    beginShape();
    vertex(x, y + alto * 0.3);
    vertex(x + ancho * 0.1, y + alto * 0.6);
    vertex(x + ancho * 0.3, y + alto);
    vertex(x + ancho * 0.5, y + alto * 0.8);
    vertex(x + ancho * 0.7, y + alto);
    vertex(x + ancho * 0.9, y + alto * 0.6);
    vertex(x + ancho, y + alto * 0.3);
    endShape(CLOSE);

    // Dibujo detalles de fragmentos de hielo
    fill(175, 238, 238, 220);  // Color más claro pero más intenso para los fragmentos
    beginShape();
    vertex(x + ancho * 0.1, y + alto * 0.3);
    vertex(x + ancho * 0.2, y + alto * 0.5);
    vertex(x + ancho * 0.3, y + alto * 0.3);
    endShape(CLOSE);

    beginShape();
    vertex(x + ancho * 0.5, y + alto * 0.3);
    vertex(x + ancho * 0.6, y + alto * 0.5);
    vertex(x + ancho * 0.7, y + alto * 0.3);
    endShape(CLOSE);

    beginShape();
    vertex(x + ancho * 0.3, y + alto * 0.6);
    vertex(x + ancho * 0.4, y + alto * 0.8);
    vertex(x + ancho * 0.5, y + alto * 0.6);
    endShape(CLOSE);
  }
}

// Clase para definir el objeto Enemigo
class Enemigo {
  float x, y, ancho, alto;  // Coordenadas y dimensiones del enemigo
  float velocidadX;  // Velocidad horizontal del enemigo
  float escala;  // Variable para la escala de inflado/desinflado
  boolean inflando;  // Indicador de si está inflando o desinflando

  // Constructor para inicializar las coordenadas del enemigo
  Enemigo(float x, float y) {
    this.x = x;
    this.y = y;
    this.ancho = 30;
    this.alto = 40;  // Ajusto para que sea un cubo
    this.velocidadX = velocidadEnemigos;  // Uso la variable global para la velocidad
    this.escala = 1.0;
    this.inflando = true;
  }

  // Método para actualizar la posición del enemigo
  void actualizar() {
    x += velocidadX;  // Muevo al enemigo horizontalmente
    // Cambio la dirección si el enemigo alcanza los bordes de la pantalla
    if (x < 0 || x + ancho > anchoPantalla) {
      velocidadX *= -1;
    }
    
    // Actualizo la escala para el efecto de inflado/desinflado
    if (inflando) {
      escala += 0.002;  // Hago el inflado más lento
      if (escala >= 1.2) {
        inflando = false;
      }
    } else {
      escala -= 0.005;  // Hago el desinflado más lento
      if (escala <= 1.0) {
        inflando = true;
      }
    }
  }

  // Método para mostrar el enemigo en la pantalla
  void mostrar() {
    float centroX = x + ancho / 2;
    float centroY = y + alto / 2;
    pushMatrix();
    translate(centroX, centroY);
    scale(escala);
    translate(-centroX, -centroY);
    
    fill(173, 216, 230);  // Color azul claro
    rect(x, y, ancho, alto, 7);  // Rectángulo con esquinas redondeadas
    
    // Añade detalles para que parezca un cubo de hielo
    fill(255, 255, 255, 100);  // Color blanco semitransparente para los detalles
    rect(x + 5, y + 5, ancho - 10, alto - 10, 5);  // Añade un borde interno redondeado
    
    // Añade un reflejo en la esquina superior izquierda
    fill(255, 255, 255, 150);  // Color blanco más transparente
    noStroke();  // Sin borde para el reflejo
    beginShape();
    vertex(x + 5, y + 5);
    vertex(x + 15, y + 5);
    vertex(x + 5, y + 15);
    endShape(CLOSE);
    
    // Añade una burbuja de aire en el hielo
    fill(255, 255, 255, 100);  // Color blanco semitransparente para los detalles
    rect(x + 15, y + 20, ancho - 20, alto - 30, 5);  // Burbuja de aire
    
    popMatrix();
  }
}

// Clase para definir el objeto Pildora
class Pildora {
  float x, y, ancho, alto;  // Coordenadas y dimensiones de la píldora
  color c;  // Color de la píldora
  
  // Constructor para inicializar la píldora con sus coordenadas y dimensiones
  Pildora(float x, float y, float ancho, float alto) {
    this.x = x;
    this.y = y;
    this.ancho = ancho;
    this.alto = alto;
    cambiarColor();  // Inicializa con un color aleatorio
  }

  // Método para cambiar el color de la píldora a un color aleatorio
  void cambiarColor() {
    c = color(random(255), random(255), random(255));  // Cambia el color a un color aleatorio
  }
  
  // Método para mostrar la píldora en pantalla
  void mostrar() {
    noStroke();  // Eliminar borde negro
    fill(c);  // Usar el color actual de la píldora
    rect(x, y, ancho, alto);
    fill(255, 0, 0);  // Rojo
    rect(x, y + alto / 2, ancho, alto / 2);
    // Extremos redondeados
    fill(c);  // Usar el color actual de la píldora
    ellipse(x + ancho / 2, y, ancho, alto / 2);
    fill(255, 0, 0);  // Rojo
    ellipse(x + ancho / 2, y + alto, ancho, alto / 2);
  }
}

// Clase para definir el objeto Confeti
class Confeti {
  float x, y, velocidadX, velocidadY;  // Coordenadas y velocidades del confeti
  int forma;  // 0 para círculo, 1 para rectángulo, 2 para triángulo
  color c;  // Color del confeti
  
  // Constructor para inicializar las coordenadas del confeti
  Confeti(float x, float y) {
    this.x = x;
    this.y = y;
    this.velocidadX = random(-2, 2);
    this.velocidadY = random(-2, 2);
    this.forma = int(random(3));  // Forma aleatoria
    this.c = color(random(255), random(255), random(255));  // Color aleatorio
  }
  
  // Método para actualizar la posición del confeti
  void actualizar() {
    x += velocidadX;
    y += velocidadY;
  }
  
  // Método para mostrar el confeti en pantalla
  void mostrar() {
    fill(c);
    noStroke();
    if (forma == 0) {
      ellipse(x, y, 10, 10);  // Dibuja un círculo
    } else if (forma == 1) {
      rect(x, y, 10, 10);  // Dibuja un rectángulo
    } else if (forma == 2) {
      triangle(x, y, x + 10, y, x + 5, y - 10);  // Dibuja un triángulo
    }
  }
}

// Función para generar confeti en una posición específica
void generarConfeti(float x, float y) {
  // Agrego 100 partículas de confeti en la posición dada
  for (int i = 0; i < 100; i++) {
    confetis.add(new Confeti(x, y));
  }
}

// Función para mostrar y actualizar las partículas de confeti en la pantalla
void confeti() {
  // Itero sobre cada partícula de confeti para actualizar su posición y dibujarla
  for (Confeti c : confetis) {
    c.actualizar();
    c.mostrar();
  }
}

// Función para mostrar el botón de nivel en la pantalla
void mostrarBotonNivel() {
  // Defino las coordenadas y dimensiones del botón
  botonX = anchoPantalla - 150;
  botonY = 30;
  botonAncho = 110;
  botonAlto = 50;
  
  // Dibujo el fondo del botón con color blanco
  fill(255);
  rect(botonX, botonY, botonAncho, botonAlto, 5);
  
  // Dibujo un triángulo en el botón de color del cielo
  fill(135, 206, 235);
  triangle(botonX + 10, botonY + 10, botonX + 10, botonY + 40, botonX + 40, botonY + 25);
  
  // Dibujo el texto de nivel en el botón
  fill(135, 206, 235);
  textSize(24);
  text((nivel + 1) + "/6", botonX + 50, botonY + 35);
}

// Función para mostrar el texto "-1" en la pantalla cuando el jugador pierde una vida
void mostrarTextoMenosUno() {
  fill(255, 0, 0, opacidadMenosUno);  // Color rojo con opacidad variable
  textSize(200);
  text("-1", xMenosUno, yMenosUno);  // Dibujo el texto en la posición especificada
  opacidadMenosUno -= 255.0 / 60;  // Disminuye la opacidad para crear un efecto de desvanecimiento
  if (millis() - tiempoInicioMenosUno > 1000 || opacidadMenosUno <= 0) {
    mostrarMenosUno = false;  // Dejo de mostrar el texto después de 1 segundo o cuando la opacidad es 0
  }
}

// Función para avanzar al siguiente nivel del juego
void avanzarNivel() {
  if (nivel < 6) {
    nivel++;  // Incremento el nivel
    velocidadEnemigos += 0.5;  // Aumento la velocidad de los enemigos
    inicializarJuego();  // Reinicio el juego para el nuevo nivel
    pildora.cambiarColor();  // Cambio el color de la píldora al avanzar de nivel
  } else {
    // Si se han completado todos los niveles, muestro el mensaje de "Juego Completado"
    fill(255, 0, 0);
    textSize(36);
    text("Juego Completado", anchoPantalla / 2 - 150, altoPantalla / 2);
    noLoop();  // Detengo el bucle del juego
  }
}

// Función para reiniciar el juego desde el inicio
void reiniciarJuego() {
  puntuacion = 0;  // Reinicio la puntuación
  nivel = 1;  // Reinicio el nivel al primero
  juegoTerminado = false;  // Reinicio el estado del juego
  nivelCompletado = false;  // Reinicio el estado de nivel completado
  pildoraTocada = false;  // Reinicio la variable cuando el juego se reinicia
  velocidadEnemigos = 1;  // Reinicio la velocidad de los enemigos
  inicializarJuego();  // Reinicio el juego
}

// Clase para definir el fondo del juego
class Fondo {
  ArrayList<Particula> particulas;  // Lista de partículas en el fondo

  // Constructor para inicializar el fondo
  Fondo() {
    particulas = new ArrayList<Particula>();
    // Creo partículas iniciales para el fondo
    for (int i = 0; i < 50; i++) {
      particulas.add(new Particula());
    }
  }

  // Método para mostrar el fondo en la pantalla
  void mostrar() {
    // Dibujar el cielo con un degradado azul
    noStroke();
    for (int y = 0; y < altoPantalla; y++) {
      float inter = map(y, 0, altoPantalla, 0, 1);
      fill(lerpColor(color(135, 206, 235), color(173, 216, 230), inter));  // Degradado de azul
      rect(0, y, anchoPantalla, 1);
    }

    // Dibujar colinas distantes
    fill(144, 238, 144);  // Verde claro
    beginShape();
    vertex(0, altoPantalla);
    vertex(0, altoPantalla - 250);
    bezierVertex(300, altoPantalla - 300, 900, altoPantalla - 200, anchoPantalla, altoPantalla - 250);
    vertex(anchoPantalla, altoPantalla);
    endShape(CLOSE);

    fill(152, 251, 152);  // Verde más claro
    beginShape();
    vertex(0, altoPantalla);
    vertex(0, altoPantalla - 200);
    bezierVertex(400, altoPantalla - 250, 800, altoPantalla - 150, anchoPantalla, altoPantalla - 200);
    vertex(anchoPantalla, altoPantalla);
    endShape(CLOSE);

    // Dibujar colinas cercanas
    fill(50, 205, 50);  // Verde medio
    beginShape();
    vertex(0, altoPantalla);
    vertex(0, altoPantalla - 100);
    bezierVertex(400, altoPantalla - 150, 800, altoPantalla - 50, anchoPantalla, altoPantalla - 100);
    vertex(anchoPantalla, altoPantalla);
    endShape(CLOSE);

    // Dibujar colinas más cercanas
    fill(34, 139, 34);  // Verde más oscuro
    beginShape();
    vertex(0, altoPantalla);
    vertex(0, altoPantalla - 50);
    bezierVertex(400, altoPantalla - 100, 800, altoPantalla, anchoPantalla, altoPantalla - 50);
    vertex(anchoPantalla, altoPantalla);
    endShape(CLOSE);

    // Dibujar vegetación en primer plano
    fill(0, 128, 0);  // Verde oscuro
    beginShape();
    vertex(0, altoPantalla);
    vertex(0, altoPantalla - 20);
    bezierVertex(200, altoPantalla - 50, 400, altoPantalla - 10, 600, altoPantalla - 30);
    bezierVertex(800, altoPantalla - 60, 1000, altoPantalla - 20, anchoPantalla, altoPantalla - 40);
    vertex(anchoPantalla, altoPantalla);
    endShape(CLOSE);
    
    // Dibujar pinos en el fondo
    dibujarPino(300, 550, 1.0);  
    dibujarPino(250, 570, 0.5);  
    dibujarPino(370, 530, 1.5);  
    dibujarPino(420, 570, 0.5);  
    dibujarPino(1100, 593, 3);  
    dibujarPino(970, 556, 1.5); 
    
    // Mostrar los créditos en la esquina inferior derecha
    textFont(fuenteNegrita);  // Uso la fuente en negrita
    textAlign(RIGHT, BOTTOM);
    textSize(16);
    fill(255);  // Color blanco
    text("Dalton Enríquez Romero / 06-2024\n Programación Creativa", width - 10, height - 10);
    textAlign(LEFT, BASELINE);  // Restaura alineación de texto por defecto
    
    // Dibujar las partículas en el fondo
    for (Particula particula : particulas) {
      particula.actualizar();
      particula.mostrar();
    }
  }
}

// Función para dibujar pinos en la pantalla
void dibujarPino(float x, float y, float escala) {
  // Dibujo el tronco del pino
  fill(139, 69, 19);  // Color marrón
  rect(x - 10 * escala, y, 20 * escala, 40 * escala);

  // Dibujo las ramas del pino en tres niveles
  fill(34, 139, 34);  // Color verde
  triangle(x - 30 * escala, y, x, y - 60 * escala, x + 30 * escala, y);  // Nivel inferior de las ramas
  triangle(x - 25 * escala, y - 30 * escala, x, y - 80 * escala, x + 25 * escala, y - 30 * escala);  // Nivel medio de las ramas
  triangle(x - 20 * escala, y - 50 * escala, x, y - 100 * escala, x + 20 * escala, y - 50 * escala);  // Nivel superior de las ramas
}

// Clase para definir el objeto Partícula
class Particula {
  float x, y;  // Coordenadas de la partícula
  float velocidadY;  // Velocidad vertical de la partícula
  color c;  // Color de la partícula
  boolean derretida = false;  // Estado de derretimiento de la partícula
  float tiempoDerretimiento = 0;  // Tiempo transcurrido desde que la partícula empezó a derretirse
  float duracionDerretimiento = 7000;  // Duración total del derretimiento en milisegundos (7 segundos)

  // Constructor para inicializar las coordenadas y propiedades de la partícula
  Particula() {
    x = random(anchoPantalla);
    y = random(altoPantalla);
    velocidadY = random(0.2, 1);  // Velocidad de caída de la partícula
    c = color(255, random(100, 255));  // Color blanco con diferentes opacidades
  }

  // Método para actualizar la posición y estado de la partícula
  void actualizar() {
    if (!derretida) {
      // Si la partícula no está derretida, la hago caer
      y += velocidadY;
    } else {
      // Si la partícula está derretida, actualizo su opacidad
      tiempoDerretimiento += millis() / 5000.0;
      float opacidad = map(tiempoDerretimiento, 0, duracionDerretimiento, alpha(c), 0);
      c = color(red(c), green(c), blue(c), opacidad);
    }

    // Si la partícula alcanza el suelo, empieza a derretirse
    if (y > altoPantalla - 50) {
      y = altoPantalla - 50;
      derretida = true;
    }
    
    // Si la partícula ha terminado de derretirse, reinicio su estado
    if (tiempoDerretimiento >= duracionDerretimiento) {
      derretida = false;
      y = random(altoPantalla);
      tiempoDerretimiento = 0;
      c = color(255, random(100, 255));
    }
  }

  // Método para mostrar la partícula (nieve) en pantalla
  void mostrar() {
    noStroke();  // Sin borde
    fill(c);  // Usar el color actual de la partícula
    ellipse(x, y, 4, 5);  // Dibujar la partícula como un pequeño círculo
  }
}

///////////////////////////////////   FIN    ////////////////////////////////////////////////////////
